/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  // ---------------------------------------------------------------------------
  // MARK: - Shape
  // ---------------------------------------------------------------------------

  /// Describes the contract for objects that represent a geometric shape.
  ///
  /// Mirrors `java.awt.Shape`. Methods that depend on `Rectangle2D`,
  /// `PathIterator`, or `AffineTransform` will be added once those types
  /// are available.
  ///
  /// - Since: JavaApi > 0.x (Java 1.0)
  public protocol Shape: AnyObject {

    /// Returns `true` if the point `(x, y)` lies inside this shape.
    func contains(_ x: Double, _ y: Double) -> Bool

    /// Returns `true` if the rectangle `(x, y, w, h)` lies entirely inside
    /// this shape.
    func contains(_ x: Double, _ y: Double, _ w: Double, _ h: Double) -> Bool

    /// Returns `true` if this shape intersects the rectangle `(x, y, w, h)`.
    func intersects(_ x: Double, _ y: Double, _ w: Double, _ h: Double) -> Bool

    /// Returns the integer bounding box of this shape.
    func getBounds() -> java.awt.Rectangle
  }
}

// MARK: - Default implementations
extension java.awt.Shape {

  /// Returns `true` if the given point lies inside this shape.
  public func contains(_ p: java.awt.geom.Point2D) -> Bool {
    contains(p.getX(), p.getY())
  }
}
