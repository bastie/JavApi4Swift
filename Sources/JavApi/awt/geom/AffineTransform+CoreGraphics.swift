/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(CoreGraphics)
import CoreGraphics

extension java.awt.geom.AffineTransform {

  /// Converts to a `CGAffineTransform`.
  ///
  /// CGAffineTransform column-major layout:
  /// `a = m00, b = m10, c = m01, d = m11, tx = m02, ty = m12`
  public var cgAffineTransform: CGAffineTransform {
    CGAffineTransform(a:  CGFloat(m00), b:  CGFloat(m10),
                      c:  CGFloat(m01), d:  CGFloat(m11),
                      tx: CGFloat(m02), ty: CGFloat(m12))
  }

  /// Creates an `AffineTransform` from a `CGAffineTransform`.
  public convenience init(_ cg: CGAffineTransform) {
    self.init(Double(cg.a),  Double(cg.b),
              Double(cg.c),  Double(cg.d),
              Double(cg.tx), Double(cg.ty))
  }
}
#endif
