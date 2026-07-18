/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if os(Linux) || os(FreeBSD)
#if canImport(Glibc)
import Glibc
#endif

extension java.awt {

  /// Full 2D rendering context for X11 — mirrors `java.awt.Graphics2D`.
  ///
  /// Subclasses `_X11Graphics`, inheriting symbol resolution and all
  /// primitive drawing (`drawLine`, `fillRect`, `drawImage`, `clipRect`, ...)
  /// and adding the `Graphics2D`-level API: `Paint`/`Stroke`/`Composite`/
  /// `AffineTransform`/`RenderingHints` state, plus `draw(Shape)`/`fill(Shape)`
  /// built by flattening the shape into a polygon — X11's core drawing API
  /// (Xlib) has no native bezier or gradient primitives — and routing
  /// through the inherited `XFillPolygon` / `XDrawLines` calls.
  ///
  /// ### Paint support
  /// - `Color` → solid fill, exact (`setColor`/`setPaint` keep each other in
  ///   sync, matching Java's specified behaviour that `setColor` also
  ///   updates the current `Paint`).
  /// - `GradientPaint` → approximated: core Xlib has no native gradient
  ///   primitive, so the shape is band-filled with 128 thin solid-colour
  ///   quad strips perpendicular to the gradient axis (cyclic/reflecting
  ///   gradients are folded into the same fixed strip count rather than
  ///   generating one native stop per reflection cycle).
  /// - `TexturePaint` → native: `XSetFillStyle(FillTiled)` + `XSetTile`
  ///   with a `Pixmap` built via `XCreatePixmap`/`XPutImage` — core Xlib,
  ///   no extension library required. The tile always repeats at the
  ///   image's own pixel size (only the anchor's origin, not its
  ///   width/height, is honoured).
  ///
  /// ### Shape clipping
  /// Rectangular clips (`Rectangle`/`Rectangle2D`) go through the inherited
  /// rectangle-based `clipRect`. Arbitrary shapes are clipped precisely via
  /// an X11 `Region` built from the flattened polygon (`XPolygonRegion` /
  /// `XSetRegion` — core Xlib, no extension library required).
  ///
  /// ### Known limitations (first implementation)
  /// - `Stroke` dash patterns are not applied (only width/cap/join via
  ///   `XSetLineAttributes`); dashing would need per-segment gap logic.
  /// - `Composite`/alpha blending is stored but not applied — classic X11 GCs
  ///   have no alpha channel. (`XRender` would be needed for that.)
  /// - `RenderingHints` are stored but do not affect rendering (X11 core
  ///   drawing has no antialiasing toggle).
  /// - `clip(_:)` intersection with an existing non-rectangular clip falls
  ///   back to bounding-box intersection rather than true polygon
  ///   intersection.
  ///
  /// - Since: Java 1.2
  open class Graphics2D: java.awt.toolkit.x11._X11Graphics {

    // =========================================================================
    // MARK: - State
    // =========================================================================

    private var _stroke:    any java.awt.Stroke
    private var _paint:     any java.awt.Paint
    private var _composite: any java.awt.Composite
    private var _transform: java.awt.geom.AffineTransform
    private var _hints:     java.awt.RenderingHints
    private var _clip:      (any java.awt.Shape)?

    /// Active X11 `Region` handle for a non-rectangular clip, or `nil`
    /// when the clip is unset or rectangular (handled by the inherited
    /// rectangle clip instead). Must be destroyed via `XDestroyRegion`
    /// whenever replaced or the clip is cleared.
    private var currentRegion: UnsafeMutableRawPointer?

    /// Graphics2D-level save/restore stack, layered on top of the base
    /// class's own stack (origin/color/rect-clip). Both stacks are pushed
    /// and popped together from `save()`/`restore()`.
    private var g2dSaveStack: [(any java.awt.Stroke, any java.awt.Paint,
                                any java.awt.Composite, java.awt.geom.AffineTransform,
                                (any java.awt.Shape)?)] = []

    // =========================================================================
    // MARK: - Init
    // =========================================================================

    public override init(display: UnsafeMutableRawPointer,
                          drawable: UInt,
                          gc: UnsafeMutableRawPointer,
                          scaleFactor: Double = 1.0) {
      _stroke    = java.awt.BasicStroke(1.0)
      _paint     = java.awt.Color.black
      _composite = java.awt.AlphaComposite.SrcOver
      _transform = java.awt.geom.AffineTransform()
      _hints     = java.awt.RenderingHints()
      super.init(display: display, drawable: drawable, gc: gc, scaleFactor: scaleFactor)
    }

    deinit {
      if let r = currentRegion, let fn = fnDestroyRegion {
        _ = fn(r)
      }
    }

    // =========================================================================
    // MARK: - Stroke
    // =========================================================================

    public func getStroke() -> any java.awt.Stroke { _stroke }

    /// Sets the current stroke. When `stroke` is a `BasicStroke`, its width,
    /// cap, and join are applied immediately via `XSetLineAttributes`.
    /// Dash patterns are stored but not applied (see type-level docs).
    public func setStroke(_ stroke: any java.awt.Stroke) {
      _stroke = stroke
      guard let bs = stroke as? java.awt.BasicStroke, let fn = fnSetLineAttributes else { return }
      let lineWidth = UInt32(max(1, (Double(bs.lineWidth) * scaleFactor).rounded()))
      // X11 cap constants differ numerically from Java's BasicStroke.Cap:
      //   Java CAP_BUTT=0/CAP_ROUND=1/CAP_SQUARE=2  →  X11 CapButt=1/CapRound=2/CapProjecting=3
      let capStyle: Int32
      switch bs.endCap {
      case .butt:   capStyle = 1
      case .round:  capStyle = 2
      case .square: capStyle = 3
      }
      // X11 join constants happen to match Java's ordering: JoinMiter=0/JoinRound=1/JoinBevel=2.
      let joinStyle = Int32(bs.lineJoin.rawValue)
      _ = fn(display, gc, lineWidth, 0 /* LineSolid */, capStyle, joinStyle)
    }

    // =========================================================================
    // MARK: - Paint / Color
    // =========================================================================

    public func getPaint() -> any java.awt.Paint { _paint }

    public func setPaint(_ paint: any java.awt.Paint) {
      _paint = paint
      if let c = paint as? java.awt.Color { super.setColor(c) }
    }

    /// Mirrors Java's specified behaviour: `Graphics.setColor` also updates
    /// the current `Paint` on a `Graphics2D`.
    public override func setColor(_ color: java.awt.Color) {
      super.setColor(color)
      _paint = color
    }

    public override func getColor() -> java.awt.Color {
      (_paint as? java.awt.Color) ?? currentColor
    }

    // =========================================================================
    // MARK: - Composite
    // =========================================================================

    /// Classic X11 GCs have no alpha channel — the composite rule is stored
    /// for API completeness but does not affect rendering. `XRender` would
    /// be required for real alpha blending.
    public func getComposite() -> any java.awt.Composite { _composite }
    public func setComposite(_ comp: any java.awt.Composite) { _composite = comp }

    // =========================================================================
    // MARK: - Background
    // =========================================================================

    public func getBackground() -> java.awt.Color { backgroundColor }
    public func setBackground(_ color: java.awt.Color) { backgroundColor = color }

    // =========================================================================
    // MARK: - RenderingHints
    // =========================================================================

    /// Stored only — X11 core drawing has no antialiasing/interpolation
    /// toggle to apply these to.
    public func getRenderingHints() -> java.awt.RenderingHints { _hints }
    public func setRenderingHints(_ hints: java.awt.RenderingHints) { _hints = hints }
    public func addRenderingHints(_ hints: java.awt.RenderingHints) { _hints.putAll(hints) }
    public func getRenderingHint(_ key: java.awt.RenderingHints.Key) -> java.awt.RenderingHints.Value? {
      _hints.get(key)
    }
    public func setRenderingHint(_ key: java.awt.RenderingHints.Key,
                                 _ value: java.awt.RenderingHints.Value) {
      _hints.put(key, value)
    }

    // =========================================================================
    // MARK: - Transform
    // =========================================================================

    public func getTransform() -> java.awt.geom.AffineTransform {
      java.awt.geom.AffineTransform(_transform)
    }
    public func setTransform(_ tx: java.awt.geom.AffineTransform) {
      _transform.setToIdentity()
      _transform.concatenate(tx)
    }
    public func transform(_ tx: java.awt.geom.AffineTransform) {
      _transform.concatenate(tx)
    }
    /// - Note: Only affects shape-based `draw(_:)`/`fill(_:)`. The inherited
    ///   primitive calls (`drawLine`, `fillRect`, `drawString`, `drawImage`, …)
    ///   are only translation-aware (via `originX`/`originY`, an integer
    ///   offset) — they have no way to represent rotation/scale/shear. This
    ///   is an inherent limitation of the underlying `_X11Graphics` primitive
    ///   layer, not something this class can paper over.
    public func rotate(_ theta: Double) { _transform.rotate(theta) }
    public func rotate(_ theta: Double, _ anchorX: Double, _ anchorY: Double) {
      _transform.rotate(theta, anchorX, anchorY)
    }
    public func scale(_ sx: Double, _ sy: Double) { _transform.scale(sx, sy) }
    public func shear(_ shx: Double, _ shy: Double) { _transform.shear(shx, shy) }

    /// `Double`-precision translate — matches `Graphics2D.translate(double,double)`.
    ///
    /// Updates both `_transform` (used by shape-based `draw`/`fill`) and the
    /// inherited `originX`/`originY` (used by primitive calls like
    /// `drawLine`/`fillRect`), so all drawing on this context — not just
    /// `Shape`-based — reflects the translation. Sub-pixel remainders are
    /// lost when folded into the integer `originX`/`originY`.
    public func translate(_ tx: Double, _ ty: Double) {
      _transform.translate(tx, ty)
      originX += Int(tx.rounded())
      originY += Int(ty.rounded())
    }

    /// Keeps the shape-based `_transform` in sync when translation happens
    /// via the inherited `Int`-typed `Graphics.translate`.
    public override func translate(_ dx: Int, _ dy: Int) {
      super.translate(dx, dy)
      _transform.translate(Double(dx), Double(dy))
    }

    // =========================================================================
    // MARK: - Clip
    // =========================================================================

    public func getClip() -> (any java.awt.Shape)? { _clip }

    public func setClip(_ shape: (any java.awt.Shape)?) {
      _clip = shape
      applyShapeClip()
    }

    /// Intersects `shape` with the current clip.
    ///
    /// Precise polygon-vs-polygon intersection is out of scope for this
    /// first implementation; when an existing non-rectangular clip is
    /// present, the two shapes' bounding boxes are intersected instead
    /// (same approximation level as the rest of this file's shape support).
    public func clip(_ shape: any java.awt.Shape) {
      if let existing = _clip {
        let eb = existing.getBounds(), nb = shape.getBounds()
        let ix  = max(eb.x, nb.x)
        let iy  = max(eb.y, nb.y)
        let ix2 = min(eb.x + eb.width,  nb.x + nb.width)
        let iy2 = min(eb.y + eb.height, nb.y + nb.height)
        _clip = java.awt.Rectangle(ix, iy, max(0, ix2 - ix), max(0, iy2 - iy))
      } else {
        _clip = shape
      }
      applyShapeClip()
    }

    /// Rectangle-based clip — kept in sync with `_clip` so `getClip()`
    /// reflects calls made through the inherited `Graphics.clipRect`.
    public override func clipRect(_ x: Int, _ y: Int, _ w: Int, _ h: Int) {
      destroyRegionIfNeeded()
      super.clipRect(x, y, w, h)
      _clip = clipLogical.map { java.awt.Rectangle($0.x, $0.y, $0.width, $0.height) }
    }

    private func destroyRegionIfNeeded() {
      if let r = currentRegion, let fn = fnDestroyRegion {
        _ = fn(r)
        currentRegion = nil
      }
    }

    /// Applies `_clip` to the GC: rectangles go through the fast, exact
    /// rectangle path; arbitrary shapes get a precise `Region` built from
    /// the flattened polygon.
    private func applyShapeClip() {
      destroyRegionIfNeeded()

      guard let shape = _clip else {
        _ = fnSetClipMask?(display, gc, 0)
        return
      }
      if let r = shape as? java.awt.Rectangle {
        super.clipRect(r.x, r.y, r.width, r.height)
        return
      }
      if let r2 = shape as? java.awt.geom.Rectangle2D {
        super.clipRect(Int(r2.getX().rounded()), Int(r2.getY().rounded()),
                        Int(r2.getWidth().rounded()), Int(r2.getHeight().rounded()))
        return
      }
      guard let pts = flatten(shape), pts.count >= 3,
            let fnRegion = fnPolygonRegion, let fnSet = fnSetRegion else {
        // Fallback: bounding-box clip when Region symbols are unavailable
        // or the shape type isn't one `flatten(_:)` recognises.
        let b = shape.getBounds()
        super.clipRect(b.x, b.y, b.width, b.height)
        return
      }
      let xpoints: [(Int16, Int16)] = pts.map { p in
        let tp = transformedPoint(p)
        return (Int16(truncatingIfNeeded: scaled(Int(tp.0.rounded()) + originX)),
                Int16(truncatingIfNeeded: scaled(Int(tp.1.rounded()) + originY)))
      }
      guard let region = xpoints.withUnsafeBytes({ buf in
        fnRegion(buf.baseAddress!, Int32(xpoints.count), 0 /* EvenOddRule */)
      }) else { return }
      currentRegion = region
      _ = fnSet(display, gc, region)
    }

    // =========================================================================
    // MARK: - Save / restore (layered on top of the base class's stack)
    // =========================================================================

    public override func save() {
      super.save()
      g2dSaveStack.append((_stroke, _paint, _composite, _transform.clone(), _clip))
    }

    public override func restore() {
      super.restore()
      guard let (s, p, c, t, cl) = g2dSaveStack.popLast() else { return }
      _stroke = s; _paint = p; _composite = c; _transform = t; _clip = cl
    }

    // =========================================================================
    // MARK: - Shape → polygon flattening
    // =========================================================================
    //
    // X11's core drawing API has no bezier or ellipse-arc-as-shape primitive
    // usable for arbitrary Paint-based fills, so every Shape is flattened
    // into a polygon (straight-line approximation) before being handed to
    // the inherited `XFillPolygon`/`XDrawLines` calls. Curve subdivision
    // uses a fixed step count — matches the pragmatic, no-antialiasing
    // quality level already used elsewhere in this toolkit (nearest-neighbour
    // image scaling, non-antialiased polygon fills).

    private static let curveSteps  = 16
    private static let ovalSamples = 64

    private func flatten(_ shape: any java.awt.Shape) -> [(Double, Double)]? {
      if let r = shape as? java.awt.Rectangle {
        let x = Double(r.x), y = Double(r.y), w = Double(r.width), h = Double(r.height)
        return [(x, y), (x + w, y), (x + w, y + h), (x, y + h)]
      }
      if let r2 = shape as? java.awt.geom.Rectangle2D {
        let x = r2.getX(), y = r2.getY(), w = r2.getWidth(), h = r2.getHeight()
        return [(x, y), (x + w, y), (x + w, y + h), (x, y + h)]
      }
      if let e = shape as? java.awt.geom.Ellipse2D {
        let x = e.getX(), y = e.getY(), w = e.getWidth(), h = e.getHeight()
        let cx = x + w / 2, cy = y + h / 2, rx = w / 2, ry = h / 2
        return (0..<Graphics2D.ovalSamples).map { i in
          let theta = 2 * Double.pi * Double(i) / Double(Graphics2D.ovalSamples)
          return (cx + rx * cos(theta), cy + ry * sin(theta))
        }
      }
      if let l = shape as? java.awt.geom.Line2D {
        return [(l.getX1(), l.getY1()), (l.getX2(), l.getY2())]
      }
      if let path = shape as? java.awt.geom.Path2D {
        return flattenPath(path)
      }
      return nil
    }

    private func flattenPath(_ path: java.awt.geom.Path2D) -> [(Double, Double)] {
      var points: [(Double, Double)] = []
      var current: (Double, Double) = (0, 0)
      var subpathStart: (Double, Double) = (0, 0)

      for seg in path.segments {
        switch seg.kind {
        case .moveTo(let x, let y):
          current = (x, y)
          subpathStart = current
          points.append(current)

        case .lineTo(let x, let y):
          current = (x, y)
          points.append(current)

        case .quadTo(let cx, let cy, let x, let y):
          let steps = Graphics2D.curveSteps
          for i in 1...steps {
            let t  = Double(i) / Double(steps)
            let mt = 1 - t
            let px = mt * mt * current.0 + 2 * mt * t * cx + t * t * x
            let py = mt * mt * current.1 + 2 * mt * t * cy + t * t * y
            points.append((px, py))
          }
          current = (x, y)

        case .curveTo(let cx1, let cy1, let cx2, let cy2, let x, let y):
          let steps = Graphics2D.curveSteps
          for i in 1...steps {
            let t  = Double(i) / Double(steps)
            let mt = 1 - t
            let px = mt*mt*mt*current.0 + 3*mt*mt*t*cx1 + 3*mt*t*t*cx2 + t*t*t*x
            let py = mt*mt*mt*current.1 + 3*mt*mt*t*cy1 + 3*mt*t*t*cy2 + t*t*t*y
            points.append((px, py))
          }
          current = (x, y)

        case .close:
          points.append(subpathStart)
          current = subpathStart
        }
      }
      return points
    }

    /// Applies `_transform` to a single logical point.
    private func transformedPoint(_ p: (Double, Double)) -> (Double, Double) {
      let src = java.awt.geom.Point2D.Double(p.0, p.1)
      let dst = _transform.transform(src)
      return (dst.getX(), dst.getY())
    }

    /// Converts a flattened point list into physical-pixel `Int` coordinate
    /// arrays (applies `_transform`, then origin + HiDPI scale via the
    /// inherited `scaled(_:)`, matching what `drawPolygon`/`fillPolygon`
    /// expect as *logical* input — they apply origin/scale themselves, so
    /// here we only apply `_transform` and hand back logical Ints).
    private func transformedIntPoints(_ pts: [(Double, Double)]) -> (xs: [Int], ys: [Int]) {
      var xs: [Int] = []; xs.reserveCapacity(pts.count)
      var ys: [Int] = []; ys.reserveCapacity(pts.count)
      for p in pts {
        let tp = transformedPoint(p)
        xs.append(Int(tp.0.rounded()))
        ys.append(Int(tp.1.rounded()))
      }
      return (xs, ys)
    }

    // =========================================================================
    // MARK: - draw / fill (Shape)
    // =========================================================================

    /// Strokes the outline of `shape` using the current `Paint`.
    ///
    /// `Stroke` width/cap/join are applied via `setStroke`'s
    /// `XSetLineAttributes` call, already in effect on the GC; dash
    /// patterns are not rendered (see type-level docs).
    public func draw(_ shape: any java.awt.Shape) {
      if let l = shape as? java.awt.geom.Line2D {
        let p1 = transformedPoint((l.getX1(), l.getY1()))
        let p2 = transformedPoint((l.getX2(), l.getY2()))
        drawLine(Int(p1.0.rounded()), Int(p1.1.rounded()),
                Int(p2.0.rounded()), Int(p2.1.rounded()))
        return
      }
      guard let pts = flatten(shape), pts.count >= 2 else { return }
      let (xs, ys) = transformedIntPoints(pts)
      drawPolygon(xs, ys, xs.count)
    }

    /// Fills the interior of `shape` using the current `Paint`.
    public func fill(_ shape: any java.awt.Shape) {
      if let gradient = _paint as? java.awt.GradientPaint {
        fillWithGradient(shape, gradient)
        return
      }
      if let texture = _paint as? java.awt.TexturePaint {
        fillWithTexture(shape, texture)
        return
      }
      guard _paint is java.awt.Color else { return }
      guard let pts = flatten(shape), pts.count >= 3 else { return }
      let (xs, ys) = transformedIntPoints(pts)
      fillPolygon(xs, ys, xs.count)
    }

    // =========================================================================
    // MARK: - GradientPaint / TexturePaint
    // =========================================================================

    /// Approximates a `GradientPaint` fill on core Xlib (which has no native
    /// gradient primitive at all) by band-filling the shape with a fixed
    /// number of thin, solid-colour quad strips perpendicular to the
    /// gradient axis. 128 strips is a pragmatic middle ground — smooth
    /// enough for typical UI-sized shapes, and independent of how many
    /// reflection cycles a `cyclic` gradient spans (unlike the CoreGraphics/
    /// GDI backends, which build one native stop/vertex per cycle, core
    /// Xlib strips are capped at a constant count to avoid a combinatorial
    /// blow-up of `XFillPolygon` calls for highly cyclic gradients).
    private func fillWithGradient(_ shape: any java.awt.Shape, _ gradient: java.awt.GradientPaint) {
      let p1x = gradient.getPoint1().getX(), p1y = gradient.getPoint1().getY()
      let p2x = gradient.getPoint2().getX(), p2y = gradient.getPoint2().getY()
      let dx = p2x - p1x, dy = p2y - p1y
      let len = (dx * dx + dy * dy).squareRoot()
      guard len > 0 else { return }
      let ux = dx / len, uy = dy / len
      let perpx = -uy, perpy = ux

      // Project the shape's bounding box onto the gradient axis and its
      // perpendicular to find the minimal strip range that needs covering —
      // same technique used by the CoreGraphics/GDI backends.
      let b = shape.getBounds()
      let corners: [(Double, Double)] = [
        (Double(b.x), Double(b.y)), (Double(b.x + b.width), Double(b.y)),
        (Double(b.x), Double(b.y + b.height)), (Double(b.x + b.width), Double(b.y + b.height)),
      ]
      var sMin = Double.greatestFiniteMagnitude, sMax = -Double.greatestFiniteMagnitude
      var wMin = Double.greatestFiniteMagnitude, wMax = -Double.greatestFiniteMagnitude
      for (cx, cy) in corners {
        let relx = cx - p1x, rely = cy - p1y
        let s = relx * ux + rely * uy
        let w = relx * perpx + rely * perpy
        sMin = min(sMin, s); sMax = max(sMax, s)
        wMin = min(wMin, w); wMax = max(wMax, w)
      }
      guard sMax > sMin else { return }

      let c1 = gradient.getColor1(), c2 = gradient.getColor2()
      func colorAt(_ s: Double) -> java.awt.Color {
        let t = s / len
        if gradient.isCyclic() {
          let folded = abs(t.truncatingRemainder(dividingBy: 2))
          return lerpColor(c1, c2, folded <= 1 ? folded : 2 - folded)
        }
        return lerpColor(c1, c2, min(1, max(0, t)))
      }

      // Clip precisely to the shape for the duration of the strip fills.
      let savedClip = _clip
      setClip(shape)
      let savedColor = currentColor
      defer {
        setClip(savedClip)
        super.setColor(savedColor)
      }

      let stripCount = 128
      for i in 0..<stripCount {
        let s0 = sMin + (sMax - sMin) * Double(i) / Double(stripCount)
        let s1 = sMin + (sMax - sMin) * Double(i + 1) / Double(stripCount)
        let mid = (s0 + s1) / 2
        // Set the raw fill colour directly (bypassing the `Graphics2D`
        // `setColor` override, which would overwrite `_paint` with a plain
        // `Color` and lose the gradient for subsequent strips).
        super.setColor(colorAt(mid))

        let quad: [(Double, Double)] = [
          (p1x + s0 * ux + wMin * perpx, p1y + s0 * uy + wMin * perpy),
          (p1x + s0 * ux + wMax * perpx, p1y + s0 * uy + wMax * perpy),
          (p1x + s1 * ux + wMax * perpx, p1y + s1 * uy + wMax * perpy),
          (p1x + s1 * ux + wMin * perpx, p1y + s1 * uy + wMin * perpy),
        ]
        let (xs, ys) = transformedIntPoints(quad)
        fillPolygon(xs, ys, xs.count)
      }
    }

    private func lerpColor(_ a: java.awt.Color, _ b: java.awt.Color, _ t: Double) -> java.awt.Color {
      func mix(_ x: Int, _ y: Int) -> Int { Int((Double(x) + (Double(y) - Double(x)) * t).rounded()) }
      return java.awt.Color(mix(a.getRed(), b.getRed()),
                             mix(a.getGreen(), b.getGreen()),
                             mix(a.getBlue(), b.getBlue()),
                             mix(a.getAlpha(), b.getAlpha()))
    }

    /// Fills `shape` by tiling `texture`'s image using core Xlib's native
    /// `FillTiled` fill style (`XCreatePixmap` + `XPutImage` to build the
    /// tile, `XSetTile`/`XSetTSOrigin` to install it, `XFillPolygon` to
    /// paint) — no extension library required.
    ///
    /// - Note: Core X11 tiling always repeats at the tile pixmap's own
    ///   pixel size; there is no native way to stretch the tile to a
    ///   different anchor size. The anchor rectangle's *origin* is honoured
    ///   (via `XSetTSOrigin`) but its width/height are not — this matches
    ///   the common case (`anchor` sized to the image) and is a known
    ///   simplification versus the CoreGraphics/GDI backends.
    private func fillWithTexture(_ shape: any java.awt.Shape, _ texture: java.awt.TexturePaint) {
      guard let pts = flatten(shape), pts.count >= 3 else { return }
      guard let fnCreatePixmap = fnCreatePixmap,
            let fnFreePixmap   = fnFreePixmap,
            let fnSetTile      = fnSetTile,
            let fnSetFillStyle = fnSetFillStyle,
            let fnSetTSOrigin  = fnSetTSOrigin,
            let fnDepth        = fnDefaultDepth,
            let fnScreen       = fnDefaultScreen,
            let fnVisual       = fnDefaultVisual,
            let fnCreateImg    = fnCreateImage,
            let fnPutImg       = fnPutImage
      else { return }

      let img = texture.getImage()
      let tw = img.getWidth(nil), th = img.getHeight(nil)
      guard tw > 0, th > 0 else { return }

      let screen = fnScreen(display)
      let depth  = UInt32(fnDepth(display, screen))
      guard let visual = fnVisual(display, screen) else { return }

      let pixmap = fnCreatePixmap(display, drawable, UInt32(tw), UInt32(th), depth)
      guard pixmap != 0 else { return }
      defer { _ = fnFreePixmap(display, pixmap) }

      // Build a 32-bpp BGRX pixel buffer — same layout as the base class's
      // `blitImage` (no alpha compositing here: pattern-brush/tile fills
      // have no alpha channel to composite against).
      let bytesPerPixel = 4
      let stride = tw * bytesPerPixel
      var pixels = [UInt8](repeating: 0, count: th * stride)
      for y in 0..<th {
        for x in 0..<tw {
          let argb = img.getRGB(x, y)
          let r = (argb >> 16) & 0xFF, g = (argb >> 8) & 0xFF, b = argb & 0xFF
          let idx = y * stride + x * bytesPerPixel
          pixels[idx + 0] = UInt8(b)
          pixels[idx + 1] = UInt8(g)
          pixels[idx + 2] = UInt8(r)
          pixels[idx + 3] = 0
        }
      }

      var wrote = false
      pixels.withUnsafeMutableBytes { buf in
        guard let base = buf.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return }
        guard let ximg = fnCreateImg(display, visual, depth, 2 /* ZPixmap */, 0,
                                      base, UInt32(tw), UInt32(th), 32, 0)
        else { return }
        _ = fnPutImg(display, pixmap, gc, ximg, 0, 0, 0, 0, UInt32(tw), UInt32(th))
        wrote = true
      }
      guard wrote else { return }

      // Align the tile's origin to the anchor rect's top-left corner
      // (through the current transform + integer origin), so the pattern
      // stays visually anchored as the shape moves.
      let anchor = texture.getAnchorRect()
      let originPt = transformedPoint((anchor.getX(), anchor.getY()))
      let tsX = Int32(scaled(Int(originPt.0.rounded()) + originX))
      let tsY = Int32(scaled(Int(originPt.1.rounded()) + originY))

      let savedClip = _clip
      setClip(shape)

      _ = fnSetTile(display, gc, pixmap)
      _ = fnSetFillStyle(display, gc, 1 /* FillTiled */)
      _ = fnSetTSOrigin(display, gc, tsX, tsY)

      let (xs, ys) = transformedIntPoints(pts)
      fillPolygon(xs, ys, xs.count)

      _ = fnSetFillStyle(display, gc, 0 /* FillSolid */)
      setClip(savedClip)
    }
  }
}
#endif
