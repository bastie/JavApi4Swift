/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if os(Windows)
import WinSDK

extension java.awt {

  /// Full 2D rendering context for Windows — mirrors `java.awt.Graphics2D`.
  ///
  /// Subclasses `_GDIRenderTarget`, inheriting the HDC, color/font handling,
  /// and all primitive drawing (`drawLine`, `fillRect`, `drawImage`,
  /// `clipRect`, `save`/`restore`, ...) and adding the `Graphics2D`-level
  /// API: `Paint`/`Stroke`/`Composite`/`AffineTransform`/`RenderingHints`
  /// state, plus `draw(Shape)`/`fill(Shape)` built by flattening the shape
  /// into a polygon and routing through the inherited
  /// `drawPolygon`/`fillPolygon` calls.
  ///
  /// ### Paint support
  /// - `Color` → solid fill, exact (`setColor`/`setPaint` keep each other in
  ///   sync, matching Java's specified behaviour that `setColor` also
  ///   updates the current `Paint`).
  /// - `GradientPaint` → `GradientFill` (msimg32) in triangle mode, built
  ///   from a series of quads along the gradient axis (see
  ///   `fillWithGradient(_:_:)`); msimg32.lib is linked explicitly in
  ///   `Package.swift` since the WinSDK overlay does not auto-link it.
  /// - `TexturePaint` → `CreatePatternBrush` from a `CreateDIBSection`-backed
  ///   `HBITMAP` (see `fillWithTexture(_:_:)` / `bufferedImageToHBITMAP(_:)`).
  ///
  /// ### Stroke support
  /// Width/cap/join are applied via a dedicated `ExtCreatePen` "geometric"
  /// pen (`PS_GEOMETRIC`), kept separate from the base class's plain
  /// `CreatePen` solid pen so the base's own color/pen bookkeeping in
  /// `_GDIRenderTarget` is left untouched. See `applyStrokePen()` for the
  /// pen-swap/lifetime reasoning. Dash patterns are not applied.
  ///
  /// ### Shape clipping
  /// Rectangular clips (`Rectangle`/`Rectangle2D`) go through the inherited
  /// rectangle-based `clipRect` (`IntersectClipRect`). Arbitrary shapes are
  /// clipped precisely via a GDI region built from the flattened polygon
  /// (`CreatePolygonRgn` / `SelectClipRgn`).
  ///
  /// ### Known limitations (first implementation)
  /// - `Stroke` dash patterns are not rendered (only width/cap/join).
  /// - `Composite`/alpha blending is stored but not applied to shape
  ///   drawing (classic GDI pens/brushes have no alpha channel; `AlphaBlend`
  ///   is only used for image blits in the base class).
  /// - `RenderingHints` are stored but do not affect rendering.
  /// - `clip(_:)` intersection with an existing non-rectangular clip falls
  ///   back to bounding-box intersection rather than true polygon
  ///   intersection.
  /// - Only affects shape-based `draw(_:)`/`fill(_:)`; the inherited
  ///   primitive calls (`drawLine`, `fillRect`, `drawString`, `drawImage`, …)
  ///   are only translation-aware (via the base class's `SetViewportOrgEx`
  ///   call) — they have no way to represent rotation/scale/shear.
  ///
  /// - Since: Java 1.2
  open class Graphics2D: java.awt.toolkit.gdi._GDIRenderTarget {

    // =========================================================================
    // MARK: - State
    // =========================================================================

    private var _stroke:    any java.awt.Stroke
    private var _paint:     any java.awt.Paint
    private var _composite: any java.awt.Composite
    private var _transform: java.awt.geom.AffineTransform
    private var _hints:     java.awt.RenderingHints
    private var _clip:      (any java.awt.Shape)?

    /// The dedicated "geometric" pen (`ExtCreatePen`) used to render the
    /// current `Stroke`'s width/cap/join, kept separate from the base
    /// class's own plain `hPen`. See `applyStrokePen()`.
    private var strokePen: HPEN?

    /// Active GDI clip region for a non-rectangular clip, or `nil` when the
    /// clip is unset or rectangular (handled by the inherited rectangle
    /// clip instead). Must be destroyed whenever replaced or cleared.
    private var currentRegion: HRGN?

    /// Graphics2D-level save/restore stack, layered on top of the base
    /// class's own `SaveDC`/`RestoreDC` stack.
    private var g2dSaveStack: [(any java.awt.Stroke, any java.awt.Paint,
                                any java.awt.Composite, java.awt.geom.AffineTransform,
                                (any java.awt.Shape)?)] = []

    // =========================================================================
    // MARK: - Init
    // =========================================================================

    public override init(hdc: HDC) {
      _stroke    = java.awt.BasicStroke(1.0)
      _paint     = java.awt.Color.black
      _composite = java.awt.AlphaComposite.SrcOver
      _transform = java.awt.geom.AffineTransform()
      _hints     = java.awt.RenderingHints()
      super.init(hdc: hdc)
      applyStrokePen()
    }

    deinit {
      // Deselect our custom stroke pen back to the base class's own
      // original pen (`oldPen`) *before* `super.deinit` runs, so it isn't
      // the currently-selected object when `super.deinit` deletes
      // `hPen`/`hBrush` — GDI refuses to delete a currently-selected
      // object.
      if let sp = strokePen {
        if let op = oldPen { SelectObject(hdc, op) }
        DeleteObject(sp)
      }
      if let r = currentRegion { DeleteObject(r) }
    }

    // =========================================================================
    // MARK: - Stroke
    // =========================================================================

    public func getStroke() -> any java.awt.Stroke { _stroke }

    /// Sets the current stroke. When `stroke` is a `BasicStroke`, its width,
    /// cap, and join are applied immediately via `applyStrokePen()`.
    /// Dash patterns are stored but not applied (see type-level docs).
    public func setStroke(_ stroke: any java.awt.Stroke) {
      _stroke = stroke
      applyStrokePen()
    }

    /// (Re-)creates the GDI pen used for stroking, based on the current
    /// `_stroke` (width/cap/join) and current color (`_paint` as `Color`),
    /// and selects it into the HDC in place of whatever pen is currently
    /// selected (initially the base class's plain `hPen` from `setColor`,
    /// or a previous `strokePen`).
    ///
    /// ### Pen lifetime reasoning
    /// GDI refuses to delete a pen that is currently selected into a DC.
    /// Each call here either:
    /// - swaps out the base class's still-owned `hPen` (left idle, not
    ///   deleted — the base class deletes it itself on the next `setColor`
    ///   or in its own `deinit`), or
    /// - swaps out and immediately deletes the *previous* `strokePen`
    ///   (safe, since it is no longer the selected object once the new pen
    ///   is selected).
    private func applyStrokePen() {
      guard let bs = _stroke as? java.awt.BasicStroke else { return }
      let color = (_paint as? java.awt.Color) ?? java.awt.Color.black
      let r = DWORD(color.getRed())
      let g = DWORD(color.getGreen())
      let b = DWORD(color.getBlue())
      let colorRef = COLORREF(r | (g << 8) | (b << 16))

      let width = DWORD(max(1, Int(bs.lineWidth.rounded())))

      let capFlag: DWORD
      switch bs.endCap {
      case .butt:   capFlag = DWORD(PS_ENDCAP_FLAT)
      case .round:  capFlag = DWORD(PS_ENDCAP_ROUND)
      case .square: capFlag = DWORD(PS_ENDCAP_SQUARE)
      }
      let joinFlag: DWORD
      switch bs.lineJoin {
      case .miter: joinFlag = DWORD(PS_JOIN_MITER)
      case .round: joinFlag = DWORD(PS_JOIN_ROUND)
      case .bevel: joinFlag = DWORD(PS_JOIN_BEVEL)
      }

      var lb = LOGBRUSH()
      lb.lbStyle = DWORD(BS_SOLID)
      lb.lbColor = colorRef
      lb.lbHatch = 0

      // PS_GEOMETRIC pens support real width + cap + join (unlike the
      // cosmetic 1px pens `CreatePen` makes in the base class).
      let style = DWORD(PS_GEOMETRIC) | capFlag | joinFlag | DWORD(PS_SOLID)
      guard let newPen = ExtCreatePen(style, width, &lb, 0, nil) else { return }

      SelectObject(hdc, newPen)
      if let sp = strokePen { DeleteObject(sp) }
      strokePen = newPen
    }

    // =========================================================================
    // MARK: - Paint / Color
    // =========================================================================

    public func getPaint() -> any java.awt.Paint { _paint }

    public func setPaint(_ paint: any java.awt.Paint) {
      _paint = paint
      if let c = paint as? java.awt.Color {
        super.setColor(c)
        applyStrokePen()
      }
    }

    /// Mirrors Java's specified behaviour: `Graphics.setColor` also updates
    /// the current `Paint` on a `Graphics2D`.
    public override func setColor(_ color: java.awt.Color) {
      super.setColor(color)
      _paint = color
      applyStrokePen()
    }

    public override func getColor() -> java.awt.Color {
      (_paint as? java.awt.Color) ?? java.awt.Color.black
    }

    // =========================================================================
    // MARK: - Composite
    // =========================================================================

    /// Classic GDI pens/brushes have no alpha channel — the composite rule
    /// is stored for API completeness but does not affect shape rendering.
    public func getComposite() -> any java.awt.Composite { _composite }
    public func setComposite(_ comp: any java.awt.Composite) { _composite = comp }

    // =========================================================================
    // MARK: - Background
    // =========================================================================

    private var _background: java.awt.Color = java.awt.Color.white
    public func getBackground() -> java.awt.Color { _background }
    public func setBackground(_ color: java.awt.Color) { _background = color }

    // =========================================================================
    // MARK: - RenderingHints
    // =========================================================================

    /// Stored only — classic GDI drawing has no antialiasing/interpolation
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
    ///   go through the base class's `SetViewportOrgEx`-based translation
    ///   only — they have no way to represent rotation/scale/shear. This is
    ///   an inherent limitation of the underlying `_GDIRenderTarget`
    ///   primitive layer, not something this class can paper over.
    public func rotate(_ theta: Double) { _transform.rotate(theta) }
    public func rotate(_ theta: Double, _ anchorX: Double, _ anchorY: Double) {
      _transform.rotate(theta, anchorX, anchorY)
    }
    public func scale(_ sx: Double, _ sy: Double) { _transform.scale(sx, sy) }
    public func shear(_ shx: Double, _ shy: Double) { _transform.shear(shx, shy) }

    /// `Double`-precision translate — matches `Graphics2D.translate(double,double)`.
    ///
    /// Updates both `_transform` (used by shape-based `draw`/`fill`) and
    /// forwards to the inherited `Int`-typed `translate` (used by primitive
    /// calls like `drawLine`/`fillRect` via `SetViewportOrgEx`), so all
    /// drawing on this context — not just `Shape`-based — reflects the
    /// translation. Sub-pixel remainders are lost when folded into the
    /// integer viewport origin.
    public func translate(_ tx: Double, _ ty: Double) {
      _transform.translate(tx, ty)
      super.translate(Int(tx.rounded()), Int(ty.rounded()))
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
      _clip = java.awt.Rectangle(x, y, w, h)
    }

    private func destroyRegionIfNeeded() {
      if let r = currentRegion {
        DeleteObject(r)
        currentRegion = nil
      }
    }

    /// Applies `_clip` to the HDC: rectangles go through the fast, exact
    /// rectangle path; arbitrary shapes get a precise region built from the
    /// flattened polygon.
    private func applyShapeClip() {
      destroyRegionIfNeeded()

      guard let shape = _clip else {
        SelectClipRgn(hdc, nil)
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
      guard let pts = flatten(shape), pts.count >= 3 else {
        // Fallback: bounding-box clip when the shape type isn't one
        // `flatten(_:)` recognises.
        let b = shape.getBounds()
        super.clipRect(b.x, b.y, b.width, b.height)
        return
      }
      let winPoints: [POINT] = pts.map { p in
        let tp = transformedPoint(p)
        return POINT(x: LONG(tp.0.rounded()), y: LONG(tp.1.rounded()))
      }
      guard let region = winPoints.withUnsafeBufferPointer({ buf in
        CreatePolygonRgn(buf.baseAddress, Int32(winPoints.count), WINDING)
      }) else { return }
      currentRegion = region
      SelectClipRgn(hdc, region)
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
      // `RestoreDC` (called by `super.restore()`) rolls back the native
      // selected-pen state to whatever was active when `save()` was
      // called, which deselects (but does not delete) our current
      // `strokePen`. It's now safe — and necessary, to avoid leaking it —
      // to delete it here before re-deriving the correct pen below.
      if let sp = strokePen { DeleteObject(sp); strokePen = nil }
      _stroke = s; _paint = p; _composite = c; _transform = t; _clip = cl
      applyStrokePen()
    }

    // =========================================================================
    // MARK: - Shape → polygon flattening
    // =========================================================================
    //
    // Classic GDI has no direct way to fill/stroke an arbitrary Path2D with
    // a non-rectangular clip and custom cap/join in one call, so every
    // Shape is flattened into a polygon (straight-line approximation)
    // before being handed to the inherited `drawPolygon`/`fillPolygon`
    // calls. Curve subdivision uses a fixed step count — matches the
    // pragmatic quality level already used in the X11 backend
    // (Graphics2D+X11.swift).

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

    /// Converts a flattened point list into `Int` coordinate arrays
    /// (applies `_transform`, then hands back logical Ints — the inherited
    /// `drawPolygon`/`fillPolygon` apply the viewport origin themselves via
    /// GDI's `SetViewportOrgEx`).
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
    /// `Stroke` width/cap/join are applied via `applyStrokePen()`'s
    /// `ExtCreatePen` pen, already selected into the HDC; dash patterns are
    /// not rendered (see type-level docs).
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
    ///
    /// `GradientPaint`/`TexturePaint` are special-cased below; everything
    /// else (in practice, `Color`) uses the plain brush-fill path.
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
    // MARK: - fill(_:) helpers: GradientPaint / TexturePaint
    // =========================================================================

    /// Fills `shape` with a linear gradient using `GradientFill` (msimg32),
    /// in `GRADIENT_FILL_TRIANGLE` mode.
    ///
    /// `GradientFill`'s rect mode only supports axis-aligned (horizontal or
    /// vertical) gradients, so an arbitrary-direction gradient is instead
    /// built as a series of thin quads (2 triangles each) running along the
    /// `point1`→`point2` axis, wide enough to cover the shape's bounding box
    /// in the perpendicular direction. Colors are evaluated per quad edge in
    /// **logical** (pre-transform) space so the gradient direction rotates
    /// and scales together with the shape; only the final vertex positions
    /// are transformed to device coordinates.
    ///
    /// Cyclic gradients reuse the same finite-reflection-count approach as
    /// the CoreGraphics backend (`Graphics2D+CoreGraphics.swift`): enough
    /// half-cycles are generated to cover the shape's bounding box, which is
    /// visually exact once clipped to the shape.
    private func fillWithGradient(_ shape: any java.awt.Shape, _ gradient: java.awt.GradientPaint) {
      guard let pts = flatten(shape), pts.count >= 3 else { return }

      let p1x = gradient.getPoint1().getX(), p1y = gradient.getPoint1().getY()
      let p2x = gradient.getPoint2().getX(), p2y = gradient.getPoint2().getY()
      let dx = p2x - p1x, dy = p2y - p1y
      let len = (dx * dx + dy * dy).squareRoot()
      guard len > 0 else { return }
      let ux = dx / len, uy = dy / len
      let perpx = -uy, perpy = ux

      // Project the shape's bounding box corners onto the gradient axis (s)
      // and the perpendicular axis (w), both in logical space.
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

      let c1 = gradient.getColor1(), c2 = gradient.getColor2()

      func colorAt(_ s: Double) -> java.awt.Color {
        let t = s / len
        if gradient.isCyclic() {
          let tt = abs(t.truncatingRemainder(dividingBy: 2))
          let folded = tt <= 1 ? tt : 2 - tt
          return lerpColor(c1, c2, folded)
        } else {
          return lerpColor(c1, c2, min(1, max(0, t)))
        }
      }

      var stops: [Double]
      if gradient.isCyclic() {
        let tMin = sMin / len, tMax = sMax / len
        let before = min(64, max(0, Int((-tMin).rounded(.up))))
        let after  = min(64, max(0, Int((tMax - 1).rounded(.up))))
        stops = stride(from: -before, through: 1 + after, by: 1).map { Double($0) * len }
      } else {
        stops = [sMin, 0, len, sMax].filter { $0 >= sMin && $0 <= sMax }
        stops = Array(Set(stops)).sorted()
      }
      guard stops.count >= 2 else { return }

      // Clip to the exact shape via a temporary GDI region (mirrors
      // `applyShapeClip`'s approach), restored via SaveDC/RestoreDC.
      let savedDC = SaveDC(hdc)
      defer { if savedDC != 0 { RestoreDC(hdc, savedDC) } }

      let winPoints: [POINT] = pts.map { p in
        let tp = transformedPoint(p)
        return POINT(x: LONG(tp.0.rounded()), y: LONG(tp.1.rounded()))
      }
      if let region = winPoints.withUnsafeBufferPointer({ buf in
        CreatePolygonRgn(buf.baseAddress, Int32(winPoints.count), WINDING)
      }) {
        SelectClipRgn(hdc, region)
        DeleteObject(region)   // SelectClipRgn copies the region; safe to delete now.
      }

      for i in 0..<(stops.count - 1) {
        let s0 = stops[i], s1 = stops[i + 1]
        let col0 = colorAt(s0), col1 = colorAt(s1)

        let logicalCorners: [(Double, Double)] = [
          (p1x + s0 * ux + wMin * perpx, p1y + s0 * uy + wMin * perpy),
          (p1x + s0 * ux + wMax * perpx, p1y + s0 * uy + wMax * perpy),
          (p1x + s1 * ux + wMax * perpx, p1y + s1 * uy + wMax * perpy),
          (p1x + s1 * ux + wMin * perpx, p1y + s1 * uy + wMin * perpy),
        ]
        let deviceCorners = logicalCorners.map { transformedPoint($0) }

        var verts: [TRIVERTEX] = (0..<4).map { idx in
          triVertex(x: deviceCorners[idx].0, y: deviceCorners[idx].1,
                   color: idx < 2 ? col0 : col1)
        }
        var tris: [GRADIENT_TRIANGLE] = [
          GRADIENT_TRIANGLE(Vertex1: 0, Vertex2: 1, Vertex3: 2),
          GRADIENT_TRIANGLE(Vertex1: 0, Vertex2: 2, Vertex3: 3),
        ]
        verts.withUnsafeMutableBufferPointer { vbuf in
          tris.withUnsafeMutableBufferPointer { tbuf in
            _ = GradientFill(hdc, vbuf.baseAddress, UInt32(vbuf.count),
                             UnsafeMutableRawPointer(tbuf.baseAddress), UInt32(tbuf.count),
                             DWORD(GRADIENT_FILL_TRIANGLE))
          }
        }
      }
    }

    /// Linearly interpolates between two `Color`s at `t` (0…1).
    private func lerpColor(_ a: java.awt.Color, _ b: java.awt.Color, _ t: Double) -> java.awt.Color {
      java.awt.Color(
        Int((Double(a.getRed())   + (Double(b.getRed())   - Double(a.getRed()))   * t).rounded()),
        Int((Double(a.getGreen()) + (Double(b.getGreen()) - Double(a.getGreen())) * t).rounded()),
        Int((Double(a.getBlue())  + (Double(b.getBlue())  - Double(a.getBlue()))  * t).rounded()))
    }

    /// Builds a `TRIVERTEX` for `GradientFill` at device coordinates `(x, y)`.
    /// `COLOR16` components are 16-bit, so 8-bit color components are
    /// shifted left by 8 (classic GDI has no alpha for shape fills, so
    /// `Alpha` is left at full opacity).
    private func triVertex(x: Double, y: Double, color: java.awt.Color) -> TRIVERTEX {
      var v = TRIVERTEX()
      v.x     = LONG(x.rounded())
      v.y     = LONG(y.rounded())
      v.Red   = COLOR16(color.getRed())   << 8
      v.Green = COLOR16(color.getGreen()) << 8
      v.Blue  = COLOR16(color.getBlue())  << 8
      v.Alpha = 0xFFFF
      return v
    }

    /// Fills `shape` by tiling the paint's image via `CreatePatternBrush`.
    ///
    /// The image is converted to a top-down 32bpp BGR `HBITMAP` (classic GDI
    /// pattern brushes have no alpha channel — same limitation already
    /// documented for `Composite` above). `SetBrushOrgEx` aligns the tile
    /// origin to the paint's anchor rectangle so tiling starts at the
    /// correct position, matching Java's anchor-rect semantics.
    private func fillWithTexture(_ shape: any java.awt.Shape, _ texture: java.awt.TexturePaint) {
      guard let pts = flatten(shape), pts.count >= 3 else { return }
      guard let hBitmap = Graphics2D.bufferedImageToHBITMAP(texture.getImage()) else { return }
      defer { DeleteObject(hBitmap) }
      guard let brush = CreatePatternBrush(hBitmap) else { return }
      defer { DeleteObject(brush) }

      let savedDC = SaveDC(hdc)
      defer { if savedDC != 0 { RestoreDC(hdc, savedDC) } }

      let anchor = texture.getAnchorRect()
      let originDevice = transformedPoint((anchor.getX(), anchor.getY()))
      var oldOrg = POINT()
      SetBrushOrgEx(hdc, INT32(originDevice.0.rounded()), INT32(originDevice.1.rounded()), &oldOrg)

      let oldBrush = SelectObject(hdc, brush)
      let (xs, ys) = transformedIntPoints(pts)
      fillPolygon(xs, ys, xs.count)
      SelectObject(hdc, oldBrush)
    }

    /// Converts a `BufferedImage` to a top-down 32bpp BGR `HBITMAP` via
    /// `CreateDIBSection`, reading pixels through `getRGB(_:_:)`. Mirrors the
    /// conversion already used for icon creation in
    /// `_Win32WindowHost.swift`'s `_makeHIconFromPNG`, minus premultiplication
    /// (pattern brushes have no alpha channel to premultiply against).
    private static func bufferedImageToHBITMAP(_ image: java.awt.image.BufferedImage) -> HBITMAP? {
      let w = image.getWidth(nil), h = image.getHeight(nil)
      guard w > 0, h > 0 else { return nil }

      var pixels = [UInt8](repeating: 0, count: w * h * 4)
      for row in 0..<h {
        for col in 0..<w {
          let argb = image.getRGB(col, row)
          let i = (row * w + col) * 4
          pixels[i + 0] = UInt8((argb >>  0) & 0xFF)   // B
          pixels[i + 1] = UInt8((argb >>  8) & 0xFF)   // G
          pixels[i + 2] = UInt8((argb >> 16) & 0xFF)   // R
          pixels[i + 3] = 0xFF
        }
      }

      var bmi = BITMAPINFO()
      bmi.bmiHeader.biSize        = DWORD(MemoryLayout<BITMAPINFOHEADER>.size)
      bmi.bmiHeader.biWidth       = LONG(w)
      bmi.bmiHeader.biHeight      = -LONG(h)   // top-down
      bmi.bmiHeader.biPlanes      = 1
      bmi.bmiHeader.biBitCount    = 32
      bmi.bmiHeader.biCompression = DWORD(BI_RGB)

      let screenDC = GetDC(nil)
      defer { ReleaseDC(nil, screenDC) }

      var bits: UnsafeMutableRawPointer? = nil
      guard let hBitmap = CreateDIBSection(screenDC, &bmi, UINT(DIB_RGB_COLORS), &bits, nil, 0),
            let bits else { return nil }

      pixels.withUnsafeBytes { raw in
        bits.copyMemory(from: raw.baseAddress!, byteCount: w * h * 4)
      }
      return hBitmap
    }
  }
}
#endif
