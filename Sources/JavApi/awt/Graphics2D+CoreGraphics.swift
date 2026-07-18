/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(CoreGraphics)
import CoreGraphics

extension java.awt {
  
  /// Full 2D rendering context — mirrors `java.awt.Graphics2D`.
  ///
  /// Backed by a `CGContext` on Apple platforms. State is tracked in Swift so
  /// that `getTransform()`, `getStroke()`, etc. return meaningful values.
  open class Graphics2D: Graphics {
    
    // =========================================================================
    // MARK: - State
    // =========================================================================
    
    private var _stroke:    any java.awt.Stroke
    private var _paint:     any java.awt.Paint
    private var _composite: any java.awt.Composite
    private var _transform: java.awt.geom.AffineTransform
    private var _hints:     java.awt.RenderingHints
    private var _background: java.awt.Color
    private var _clip:      (any java.awt.Shape)?
    
    // =========================================================================
    // MARK: - Init
    // =========================================================================
    
    public override init(_ context: CGContext) {
      _stroke    = java.awt.BasicStroke()
      _paint     = java.awt.Color.black
      _composite = java.awt.AlphaComposite.SrcOver
      _transform = java.awt.geom.AffineTransform()
      _hints     = java.awt.RenderingHints()
      _background = java.awt.Color.white
      super.init(context)
    }
    
    // =========================================================================
    // MARK: - Stroke
    // =========================================================================
    
    public func getStroke() -> any java.awt.Stroke { _stroke }
    
    /// Sets the current stroke.  When `stroke` is a `BasicStroke` all
    /// CoreGraphics line attributes are applied immediately.
    public func setStroke(_ stroke: any java.awt.Stroke) {
      _stroke = stroke
      if let bs = stroke as? java.awt.BasicStroke {
        bs._apply(to: cgContext)
      }
    }
    
    // =========================================================================
    // MARK: - Paint / Color
    // =========================================================================
    
    public func getPaint() -> any java.awt.Paint { _paint }
    
    public func setPaint(_ paint: any java.awt.Paint) {
      _paint = paint
      if let c = paint as? java.awt.Color { setColor(c) }
    }
    
    public override func getColor() -> java.awt.Color {
      (_paint as? java.awt.Color) ?? java.awt.Color.black
    }
    
    // =========================================================================
    // MARK: - Composite
    // =========================================================================
    
    public func getComposite() -> any java.awt.Composite { _composite }
    
    public func setComposite(_ comp: any java.awt.Composite) {
      _composite = comp
      if let ac = comp as? java.awt.AlphaComposite {
        cgContext.setAlpha(CGFloat(ac.alpha))
        if ac.rule == java.awt.AlphaComposite.CLEAR {
          cgContext.setBlendMode(.clear)
        } else if ac.rule == java.awt.AlphaComposite.XOR {
          cgContext.setBlendMode(.xor)
        } else {
          cgContext.setBlendMode(.normal)
        }
      }
    }
    
    // =========================================================================
    // MARK: - Background
    // =========================================================================
    
    public func getBackground() -> java.awt.Color { _background }
    
    public func setBackground(_ color: java.awt.Color) {
      _background = color
    }
    
    // =========================================================================
    // MARK: - RenderingHints
    // =========================================================================
    
    public func getRenderingHints() -> java.awt.RenderingHints { _hints }
    
    public func setRenderingHints(_ hints: java.awt.RenderingHints) {
      _hints = hints
      applyHints()
    }
    
    public func addRenderingHints(_ hints: java.awt.RenderingHints) {
      _hints.putAll(hints)
      applyHints()
    }
    
    public func getRenderingHint(_ key: java.awt.RenderingHints.Key)
    -> java.awt.RenderingHints.Value? {
      _hints.get(key)
    }
    
    public func setRenderingHint(_ key: java.awt.RenderingHints.Key,
                                 _ value: java.awt.RenderingHints.Value) {
      _hints.put(key, value)
      applyHints()
    }
    
    private func applyHints() {
      // Antialiasing
      if let aa = _hints.get(java.awt.RenderingHints.KEY_ANTIALIASING) {
        cgContext.setShouldAntialias(
          aa == java.awt.RenderingHints.VALUE_ANTIALIAS_ON)
      }
      // Text antialiasing
      if let ta = _hints.get(java.awt.RenderingHints.KEY_TEXT_ANTIALIASING) {
        cgContext.setShouldSmoothFonts(
          ta == java.awt.RenderingHints.VALUE_TEXT_ANTIALIAS_ON)
      }
      // Interpolation quality
      if let interp = _hints.get(java.awt.RenderingHints.KEY_INTERPOLATION) {
        if interp == java.awt.RenderingHints.VALUE_INTERPOLATION_BICUBIC
            || interp == java.awt.RenderingHints.VALUE_INTERPOLATION_BILINEAR {
          cgContext.interpolationQuality = .high
        } else {
          cgContext.interpolationQuality = .none
        }
      }
    }
    
    // =========================================================================
    // MARK: - Transform
    // =========================================================================
    
    public func getTransform() -> java.awt.geom.AffineTransform {
      java.awt.geom.AffineTransform(_transform)
    }
    
    public func setTransform(_ tx: java.awt.geom.AffineTransform) {
      // Reset to identity then apply new transform
      cgContext.concatenate(cgContext.ctm.inverted())
      _transform.setToIdentity()
      transform(tx)
    }
    
    public func transform(_ tx: java.awt.geom.AffineTransform) {
      _transform.concatenate(tx)
      cgContext.concatenate(tx.cgAffineTransform)
    }
    
    public func rotate(_ theta: Double) {
      _transform.rotate(theta)
      cgContext.rotate(by: CGFloat(theta))
    }
    
    public func rotate(_ theta: Double, _ anchorX: Double, _ anchorY: Double) {
      _transform.rotate(theta, anchorX, anchorY)
      cgContext.translateBy(x: CGFloat(anchorX), y: CGFloat(anchorY))
      cgContext.rotate(by: CGFloat(theta))
      cgContext.translateBy(x: CGFloat(-anchorX), y: CGFloat(-anchorY))
    }
    
    public func translate(_ x: Double, _ y: Double) {
      _transform.translate(x, y)
      cgContext.translateBy(x: CGFloat(x), y: CGFloat(y))
    }
    
    public override func translate(_ x: Int, _ y: Int) {
      translate(Double(x), Double(y))
    }
    
    public func scale(_ sx: Double, _ sy: Double) {
      _transform.scale(sx, sy)
      cgContext.scaleBy(x: CGFloat(sx), y: CGFloat(sy))
    }
    
    public func shear(_ shx: Double, _ shy: Double) {
      _transform.shear(shx, shy)
      cgContext.concatenate(
        CGAffineTransform(a: 1, b: CGFloat(shy), c: CGFloat(shx), d: 1, tx: 0, ty: 0))
    }
    
    // =========================================================================
    // MARK: - Clip
    // =========================================================================
    
    public func getClip() -> (any java.awt.Shape)? { _clip }
    
    public func setClip(_ shape: (any java.awt.Shape)?) {
      _clip = shape
      cgContext.resetClip()
      if let s = shape, let path = cgPath(from: s) {
        cgContext.addPath(path)
        cgContext.clip()
      }
    }
    
    public func clip(_ shape: any java.awt.Shape) {
      if let path = cgPath(from: shape) {
        cgContext.addPath(path); cgContext.clip()
      }
    }
    
    public override func clipRect(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {
      cgContext.clip(to: CGRect(x: x, y: y, width: width, height: height))
    }
    
    // =========================================================================
    // MARK: - draw / fill (Shape)
    // =========================================================================
    
    /// Strokes the outline of `shape` using the current `Stroke` and `Paint`.
    public func draw(_ shape: any java.awt.Shape) {
      guard let path = cgPath(from: shape) else { return }
      cgContext.addPath(path)
      cgContext.strokePath()
    }
    
    /// Fills the interior of `shape` using the current `Paint`.
    ///
    /// `Color` fills use CoreGraphics' plain fill color (set via `setPaint`).
    /// `GradientPaint` and `TexturePaint` are special-cased here since they
    /// need the shape clipped first, then a gradient/pattern drawn into the
    /// clipped region.
    public func fill(_ shape: any java.awt.Shape) {
      guard let path = cgPath(from: shape) else { return }

      if let gradient = _paint as? java.awt.GradientPaint {
        fillWithGradient(path, gradient)
        return
      }
      if let texture = _paint as? java.awt.TexturePaint {
        fillWithTexture(path, texture)
        return
      }

      cgContext.addPath(path)
      cgContext.fillPath()
    }

    // =========================================================================
    // MARK: - fill(_:) helpers: GradientPaint / TexturePaint
    // =========================================================================

    /// Fills `path` with a linear gradient between the paint's two points.
    ///
    /// Acyclic gradients use `CGGradient` directly with
    /// `.drawsBeforeStartLocation`/`.drawsAfterEndLocation`, which exactly
    /// matches Java's "clamp to endpoint color" behaviour.
    ///
    /// Cyclic gradients repeat back-and-forth indefinitely in Java. CoreGraphics'
    /// `CGGradient` has no native reflect/repeat extend mode, so this builds a
    /// finite series of alternating `color1`/`color2` stops that fully covers
    /// the shape's bounding box projected onto the gradient axis — since the
    /// fill is clipped to `path`, anything beyond that range is invisible
    /// anyway, making the finite approximation visually exact.
    private func fillWithGradient(_ path: CGPath, _ gradient: java.awt.GradientPaint) {
      cgContext.saveGState()
      defer { cgContext.restoreGState() }
      cgContext.addPath(path)
      cgContext.clip()

      let p1 = CGPoint(x: gradient.getPoint1().getX(), y: gradient.getPoint1().getY())
      let p2 = CGPoint(x: gradient.getPoint2().getX(), y: gradient.getPoint2().getY())
      let c1 = gradient.getColor1()
      let c2 = gradient.getColor2()
      let colorSpace = CGColorSpaceCreateDeviceRGB()

      func components(_ c: java.awt.Color) -> [CGFloat] {
        [CGFloat(c.red), CGFloat(c.green), CGFloat(c.blue), CGFloat(c.alpha)]
      }

      if !gradient.isCyclic() {
        let comps = components(c1) + components(c2)
        guard let cgGradient = CGGradient(colorSpace: colorSpace, colorComponents: comps,
                                          locations: [0, 1], count: 2) else { return }
        cgContext.drawLinearGradient(cgGradient, start: p1, end: p2,
                                     options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
        return
      }

      // Cyclic: figure out how many unit segments (each one half of a
      // reflect cycle) are needed to cover the path's bounding box.
      let dx = p2.x - p1.x, dy = p2.y - p1.y
      let segLenSq = dx * dx + dy * dy
      guard segLenSq > 0 else { return }

      let bbox = path.boundingBoxOfPath
      let corners = [
        CGPoint(x: bbox.minX, y: bbox.minY), CGPoint(x: bbox.maxX, y: bbox.minY),
        CGPoint(x: bbox.minX, y: bbox.maxY), CGPoint(x: bbox.maxX, y: bbox.maxY),
      ]
      let ts = corners.map { corner in
        ((corner.x - p1.x) * dx + (corner.y - p1.y) * dy) / segLenSq
      }
      let tMin = ts.min() ?? 0, tMax = ts.max() ?? 1

      // Clamp the cycle count to a sane maximum — beyond a few dozen
      // reflections the visual result is indistinguishable and this avoids
      // pathological stop counts for near-zero-length gradient vectors.
      let cyclesBefore = min(64, max(0, Int(CGFloat(-tMin).rounded(.up))))
      let cyclesAfter  = min(64, max(0, Int((tMax - 1).rounded(.up))))
      let totalHalfCycles = cyclesBefore + 1 + cyclesAfter

      let extStart = CGPoint(x: p1.x - CGFloat(cyclesBefore) * dx,
                             y: p1.y - CGFloat(cyclesBefore) * dy)
      let extEnd = CGPoint(x: p1.x + CGFloat(totalHalfCycles - cyclesBefore) * dx,
                           y: p1.y + CGFloat(totalHalfCycles - cyclesBefore) * dy)

      var comps: [CGFloat] = []
      var locations: [CGFloat] = []
      for i in 0...totalHalfCycles {
        let t = i - cyclesBefore
        let atColor1 = (abs(t) % 2 == 0)
        comps.append(contentsOf: components(atColor1 ? c1 : c2))
        locations.append(CGFloat(i) / CGFloat(totalHalfCycles))
      }

      guard let cgGradient = CGGradient(colorSpace: colorSpace, colorComponents: comps,
                                        locations: locations,
                                        count: totalHalfCycles + 1) else { return }
      cgContext.drawLinearGradient(cgGradient, start: extStart, end: extEnd,
                                   options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
    }

    /// Fills `path` by tiling the paint's image via a `CGPattern`.
    ///
    /// The `CGImage` is passed to the pattern's draw callback through an
    /// `Unmanaged` reference (CoreGraphics' C-callback API cannot capture
    /// Swift context directly); `releaseInfo` balances the retain once the
    /// pattern is discarded.
    private func fillWithTexture(_ path: CGPath, _ texture: java.awt.TexturePaint) {
      guard let cgImage = texture.getImage().toCGImage() else {
        // No image data available — fall back to a plain path fill using
        // whatever fill color CoreGraphics currently has set.
        cgContext.addPath(path)
        cgContext.fillPath()
        return
      }

      cgContext.saveGState()
      defer { cgContext.restoreGState() }
      cgContext.addPath(path)
      cgContext.clip()

      let anchor = texture.getAnchorRect()
      let tileRect = CGRect(x: anchor.getX(), y: anchor.getY(),
                            width: anchor.getWidth(), height: anchor.getHeight())
      guard tileRect.width > 0, tileRect.height > 0 else { return }

      guard let patternSpace = CGColorSpace(patternBaseSpace: nil) else { return }
      cgContext.setFillColorSpace(patternSpace)

      var callbacks = CGPatternCallbacks(
        version: 0,
        drawPattern: { info, ctx in
          guard let info = info else { return }
          let img = Unmanaged<CGImage>.fromOpaque(info).takeUnretainedValue()
          ctx.draw(img, in: CGRect(x: 0, y: 0,
                                   width: CGFloat(img.width), height: CGFloat(img.height)))
        },
        releaseInfo: { info in
          guard let info = info else { return }
          Unmanaged<CGImage>.fromOpaque(info).release()
        })

      let infoPtr = Unmanaged.passRetained(cgImage).toOpaque()

      guard let pattern = CGPattern(
        info: infoPtr,
        bounds: CGRect(x: 0, y: 0, width: tileRect.width, height: tileRect.height),
        matrix: CGAffineTransform(translationX: tileRect.origin.x, y: tileRect.origin.y),
        xStep: tileRect.width,
        yStep: tileRect.height,
        tiling: .constantSpacingMinimalDistortion,
        isColored: true,
        callbacks: &callbacks
      ) else {
        Unmanaged<CGImage>.fromOpaque(infoPtr).release()
        return
      }

      var alpha: CGFloat = 1.0
      cgContext.setFillPattern(pattern, colorComponents: &alpha)
      cgContext.fill(path.boundingBoxOfPath)
    }
    
    // =========================================================================
    // MARK: - Inherited draw primitives (keep existing + add missing)
    // =========================================================================
    
    public func clearRect(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {
      cgContext.saveGState()
      cgContext.setFillColor(CGColor(
        red: CGFloat(_background.red), green: CGFloat(_background.green),
        blue: CGFloat(_background.blue), alpha: 1))
      cgContext.fill(CGRect(x: x, y: y, width: width, height: height))
      cgContext.restoreGState()
    }
    
    public override func drawRoundRect(_ x: Int, _ y: Int, _ width: Int, _ height: Int, _ arcWidth: Int, _ arcHeight: Int) {
      let path = CGMutablePath()
      path.addRoundedRect(in: CGRect(x: x, y: y, width: width, height: height),
                          cornerWidth:  CGFloat(arcWidth)  / 2,
                          cornerHeight: CGFloat(arcHeight) / 2)
      cgContext.addPath(path); cgContext.strokePath()
    }
    
    public override func fillRoundRect(_ x: Int, _ y: Int,
                              _ width: Int, _ height: Int,
                              _ arcWidth: Int, _ arcHeight: Int) {
      let path = CGMutablePath()
      path.addRoundedRect(in: CGRect(x: x, y: y, width: width, height: height),
                          cornerWidth:  CGFloat(arcWidth)  / 2,
                          cornerHeight: CGFloat(arcHeight) / 2)
      cgContext.addPath(path); cgContext.fillPath()
    }
    
    public func drawArc(_ x: Int, _ y: Int, _ width: Int, _ height: Int,
                        _ startAngle: Int, _ arcAngle: Int) {
      let cx = CGFloat(x + width/2), cy = CGFloat(y + height/2)
      let rx = CGFloat(width) / 2,   ry = CGFloat(height) / 2
      cgContext.saveGState()
      cgContext.translateBy(x: cx, y: cy)
      cgContext.scaleBy(x: rx, y: ry)
      let start = CGFloat(startAngle) * .pi / 180
      let end   = start + CGFloat(arcAngle) * .pi / 180
      cgContext.addArc(center: .zero, radius: 1,
                       startAngle: start, endAngle: end, clockwise: arcAngle < 0)
      cgContext.restoreGState()
      cgContext.strokePath()
    }
    
    public func fillArc(_ x: Int, _ y: Int, _ width: Int, _ height: Int,
                        _ startAngle: Int, _ arcAngle: Int) {
      let cx = CGFloat(x + width/2), cy = CGFloat(y + height/2)
      let rx = CGFloat(width) / 2,   ry = CGFloat(height) / 2
      cgContext.saveGState()
      cgContext.translateBy(x: cx, y: cy)
      cgContext.scaleBy(x: rx, y: ry)
      let start = CGFloat(startAngle) * .pi / 180
      let end   = start + CGFloat(arcAngle) * .pi / 180
      cgContext.addArc(center: .zero, radius: 1,
                       startAngle: start, endAngle: end, clockwise: arcAngle < 0)
      cgContext.restoreGState()
      cgContext.fillPath()
    }
    
    public func drawPolyline(_ xPoints: [Int], _ yPoints: [Int], _ nPoints: Int) {
      guard nPoints > 1 else { return }
      let path = CGMutablePath()
      path.move(to: CGPoint(x: xPoints[0], y: yPoints[0]))
      for i in 1..<nPoints { path.addLine(to: CGPoint(x: xPoints[i], y: yPoints[i])) }
      cgContext.addPath(path); cgContext.strokePath()
    }
    
    public override func drawPolygon(_ xPoints: [Int], _ yPoints: [Int], _ nPoints: Int) {
      guard nPoints > 1 else { return }
      let path = CGMutablePath()
      path.move(to: CGPoint(x: xPoints[0], y: yPoints[0]))
      for i in 1..<nPoints { path.addLine(to: CGPoint(x: xPoints[i], y: yPoints[i])) }
      path.closeSubpath()
      cgContext.addPath(path); cgContext.strokePath()
    }
    
    public override func fillPolygon(_ xPoints: [Int], _ yPoints: [Int], _ nPoints: Int) {
      guard nPoints > 1 else { return }
      let path = CGMutablePath()
      path.move(to: CGPoint(x: xPoints[0], y: yPoints[0]))
      for i in 1..<nPoints { path.addLine(to: CGPoint(x: xPoints[i], y: yPoints[i])) }
      path.closeSubpath()
      cgContext.addPath(path); cgContext.fillPath()
    }
    
    // =========================================================================
    // MARK: - GraphicsContext save / restore
    // =========================================================================
    
    public func saveState()    { cgContext.saveGState()    }
    public func restoreState() { cgContext.restoreGState() }
    
    // =========================================================================
    // MARK: - Private: Shape → CGPath
    // =========================================================================
    
    private func cgPath(from shape: any java.awt.Shape) -> CGPath? {
      if let r = shape as? java.awt.Rectangle {
        return CGPath(rect: r.cgRect, transform: nil)
      }
      if let r2 = shape as? java.awt.geom.Rectangle2D {
        return CGPath(rect: CGRect(x: r2.getX(), y: r2.getY(),
                                   width: r2.getWidth(), height: r2.getHeight()),
                      transform: nil)
      }
      if let e = shape as? java.awt.geom.Ellipse2D {
        return CGPath(ellipseIn: CGRect(x: e.getX(), y: e.getY(),
                                        width: e.getWidth(), height: e.getHeight()),
                      transform: nil)
      }
      if let l = shape as? java.awt.geom.Line2D {
        let p = CGMutablePath()
        p.move(to: CGPoint(x: l.getX1(), y: l.getY1()))
        p.addLine(to: CGPoint(x: l.getX2(), y: l.getY2()))
        return p
      }
      if let path = shape as? java.awt.geom.Path2D {
        return path.cgPath
      }
      return nil
    }
  }
}
#endif
