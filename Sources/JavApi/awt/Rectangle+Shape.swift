/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - java.awt.Rectangle: Shape

extension java.awt.Rectangle: java.awt.Shape {

  /// Returns `true` if the point `(px, py)` lies inside this rectangle.
  public func contains(_ px: Double, _ py: Double) -> Bool {
    contains(Int(px), Int(py))
  }

  /// Returns `true` if the rectangle `(x, y, w, h)` lies entirely inside
  /// this rectangle.
  public func contains(_ x: Double, _ y: Double,
                        _ w: Double, _ h: Double) -> Bool {
    guard w > 0, h > 0 else { return false }
    let ix = Int(x.rounded(.down))
    let iy = Int(y.rounded(.down))
    let iw = Int((x + w).rounded(.up)) - ix
    let ih = Int((y + h).rounded(.up)) - iy
    return contains(java.awt.Rectangle(ix, iy, iw, ih))
  }

  /// Returns `true` if this rectangle intersects `(x, y, w, h)`.
  public func intersects(_ x: Double, _ y: Double,
                          _ w: Double, _ h: Double) -> Bool {
    guard w > 0, h > 0 else { return false }
    let ix = Int(x.rounded(.down))
    let iy = Int(y.rounded(.down))
    let iw = Int((x + w).rounded(.up)) - ix
    let ih = Int((y + h).rounded(.up)) - iy
    return intersects(java.awt.Rectangle(ix, iy, iw, ih))
  }

  // getBounds() is already defined on Rectangle and returns Rectangle,
  // which satisfies the Shape protocol requirement.
}
