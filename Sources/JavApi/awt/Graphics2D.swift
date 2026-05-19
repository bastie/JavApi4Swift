/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(CoreGraphics)
import CoreGraphics

extension java.awt {
  
  /// java.awt.Graphics2D — Subklasse mit erweitertem API
  public final class Graphics2D: Graphics {
    public func setStroke(_ stroke: BasicStroke) {
      cgContext.setLineWidth(CGFloat(stroke.lineWidth))
    }
    
    public func rotate(_ theta: Double) {
      cgContext.rotate(by: CGFloat(theta))
    }
    
    public func translate(_ x: Double, _ y: Double) {
      cgContext.translateBy(x: CGFloat(x), y: CGFloat(y))
    }
    
    public func scale(_ sx: Double, _ sy: Double) {
      cgContext.scaleBy(x: CGFloat(sx), y: CGFloat(sy))
    }
  }
}
#endif
