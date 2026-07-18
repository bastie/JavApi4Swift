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
  /// - Any other `Paint` (e.g. a future `GradientPaint`/`TexturePaint`) is
  ///   stored by `setPaint` but `fill(_:)` currently only special-cases
  ///   `Color` — extend the type switch in `fill(_:)` once those classes
  ///   exist.
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
    /// Only solid `Color` paints render today — see type-level docs for
    /// `GradientPaint`/`TexturePaint` status.
    public func fill(_ shape: any java.awt.Shape) {
      guard _paint is java.awt.Color else { return }
      guard let pts = flatten(shape), pts.count >= 3 else { return }
      let (xs, ys) = transformedIntPoints(pts)
      fillPolygon(xs, ys, xs.count)
    }
  }
}
#endif
