/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if !canImport(CoreGraphics)

extension java.awt {
  open class Graphics2D: Graphics {
    private var _transform = java.awt.geom.AffineTransform()
    private var _hints     = java.awt.RenderingHints()

    open func getTransform() -> java.awt.geom.AffineTransform {
      java.awt.geom.AffineTransform(_transform)
    }
    open func setTransform(_ tx: java.awt.geom.AffineTransform) {
      _transform.setToIdentity(); _transform.concatenate(tx)
    }
    open func transform(_ tx: java.awt.geom.AffineTransform) {
      _transform.concatenate(tx)
    }
    open func rotate(_ theta: Double) { _transform.rotate(theta) }
    open func rotate(_ theta: Double, _ ax: Double, _ ay: Double) { _transform.rotate(theta, ax, ay) }
    open func translate(_ x: Double, _ y: Double) { _transform.translate(x, y) }
    open override func translate(_ x: Int, _ y: Int) { translate(Double(x), Double(y)) }
    open func scale(_ sx: Double, _ sy: Double) { _transform.scale(sx, sy) }
    open func shear(_ shx: Double, _ shy: Double) { _transform.shear(shx, shy) }

    open func setStroke(_ stroke: any java.awt.Stroke) {}
    open func getStroke() -> any java.awt.Stroke { java.awt.BasicStroke() }
    open func setPaint(_ paint: any java.awt.Paint) {}
    open func getPaint() -> any java.awt.Paint { java.awt.Color.black }
    open func setComposite(_ comp: any java.awt.Composite) {}
    open func getComposite() -> any java.awt.Composite { java.awt.AlphaComposite.SrcOver }
    open func setBackground(_ color: java.awt.Color) {}
    open func getBackground() -> java.awt.Color { java.awt.Color.white }
    public override func getColor() -> java.awt.Color { java.awt.Color.black}
    open func setRenderingHint(_ key: java.awt.RenderingHints.Key, _ value: java.awt.RenderingHints.Value) { _hints.put(key, value) }
    open func getRenderingHint(_ key: java.awt.RenderingHints.Key) -> java.awt.RenderingHints.Value? { _hints.get(key) }
    open func getRenderingHints() -> java.awt.RenderingHints { _hints }

    open func draw(_ shape: any java.awt.Shape) {}
    open func fill(_ shape: any java.awt.Shape) {}
    open func clearRect(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {}
    open func getClip() -> (any java.awt.Shape)? { nil }
    open func setClip(_ shape: (any java.awt.Shape)?) {}
    open func clip(_ shape: any java.awt.Shape) {}
    open override func clipRect(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {}
    open func saveState() {}
    open func restoreState() {}
  }
}
#endif
