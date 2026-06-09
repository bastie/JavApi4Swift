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
  public final class Graphics2D: Graphics {

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
        bs.apply(to: cgContext)
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

    public func getColor() -> java.awt.Color {
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
    public func fill(_ shape: any java.awt.Shape) {
      guard let path = cgPath(from: shape) else { return }
      cgContext.addPath(path)
      cgContext.fillPath()
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

    public func drawRoundRect(_ x: Int, _ y: Int,
                               _ width: Int, _ height: Int,
                               _ arcWidth: Int, _ arcHeight: Int) {
      let path = CGMutablePath()
      path.addRoundedRect(in: CGRect(x: x, y: y, width: width, height: height),
                          cornerWidth:  CGFloat(arcWidth)  / 2,
                          cornerHeight: CGFloat(arcHeight) / 2)
      cgContext.addPath(path); cgContext.strokePath()
    }

    public func fillRoundRect(_ x: Int, _ y: Int,
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

#else  // platforms without CoreGraphics — stub 

extension java.awt {
  public final class Graphics2D: Graphics {
    private var _transform = java.awt.geom.AffineTransform()
    private var _hints     = java.awt.RenderingHints()

    public func getTransform() -> java.awt.geom.AffineTransform {
      java.awt.geom.AffineTransform(_transform)
    }
    public func setTransform(_ tx: java.awt.geom.AffineTransform) {
      _transform.setToIdentity(); _transform.concatenate(tx)
    }
    public func transform(_ tx: java.awt.geom.AffineTransform) {
      _transform.concatenate(tx)
    }
    public func rotate(_ theta: Double) { _transform.rotate(theta) }
    public func rotate(_ theta: Double, _ ax: Double, _ ay: Double) { _transform.rotate(theta, ax, ay) }
    public func translate(_ x: Double, _ y: Double) { _transform.translate(x, y) }
    public override func translate(_ x: Int, _ y: Int) { translate(Double(x), Double(y)) }
    public func scale(_ sx: Double, _ sy: Double) { _transform.scale(sx, sy) }
    public func shear(_ shx: Double, _ shy: Double) { _transform.shear(shx, shy) }

    public func setStroke(_ stroke: any java.awt.Stroke) {}
    public func getStroke() -> any java.awt.Stroke { java.awt.BasicStroke() }
    public func setPaint(_ paint: any java.awt.Paint) {}
    public func getPaint() -> any java.awt.Paint { java.awt.Color.black }
    public func setComposite(_ comp: any java.awt.Composite) {}
    public func getComposite() -> any java.awt.Composite { java.awt.AlphaComposite.SrcOver }
    public func setBackground(_ color: java.awt.Color) {}
    public func getBackground() -> java.awt.Color { java.awt.Color.white }
    public func setRenderingHint(_ key: java.awt.RenderingHints.Key, _ value: java.awt.RenderingHints.Value) { _hints.put(key, value) }
    public func getRenderingHint(_ key: java.awt.RenderingHints.Key) -> java.awt.RenderingHints.Value? { _hints.get(key) }
    public func getRenderingHints() -> java.awt.RenderingHints { _hints }

    public func draw(_ shape: any java.awt.Shape) {}
    public func fill(_ shape: any java.awt.Shape) {}
    public func clearRect(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {}
    public func getClip() -> (any java.awt.Shape)? { nil }
    public func setClip(_ shape: (any java.awt.Shape)?) {}
    public func clip(_ shape: any java.awt.Shape) {}
    public override func clipRect(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {}
    public func saveState() {}
    public func restoreState() {}
  }
}
#endif
