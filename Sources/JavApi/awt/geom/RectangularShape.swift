/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.geom {

  // ---------------------------------------------------------------------------
  // MARK: - RectangularShape
  // ---------------------------------------------------------------------------

  /// Abstract base class for shapes whose geometry can be described by a
  /// rectangular frame `(x, y, width, height)`.
  ///
  /// Mirrors `java.awt.geom.RectangularShape`. Concrete subclasses include
  /// `Rectangle2D`, `Ellipse2D`, `Arc2D`, and `RoundRectangle2D`.
  ///
  /// - Since: JavaApi > 0.x (Java 1.2)
  public class RectangularShape: java.awt.Shape {

    // =========================================================================
    // MARK: - Abstract interface
    // =========================================================================

    /// Returns the x coordinate of the upper-left corner of the framing
    /// rectangle.
    open func getX() -> Swift.Double { fatalError("abstract") }

    /// Returns the y coordinate of the upper-left corner of the framing
    /// rectangle.
    open func getY() -> Swift.Double { fatalError("abstract") }

    /// Returns the width of the framing rectangle.
    open func getWidth() -> Swift.Double { fatalError("abstract") }

    /// Returns the height of the framing rectangle.
    open func getHeight() -> Swift.Double { fatalError("abstract") }

    /// Returns `true` if the framing rectangle has zero area.
    open func isEmpty() -> Bool { fatalError("abstract") }

    /// Sets the location and size of the framing rectangle.
    open func setFrame(_ x: Swift.Double, _ y: Swift.Double,
                       _ w: Swift.Double, _ h: Swift.Double) {
      fatalError("abstract")
    }

    // =========================================================================
    // MARK: - Derived frame accessors
    // =========================================================================

    /// Returns the smallest x coordinate of this shape.
    public func getMinX() -> Swift.Double { getX() }

    /// Returns the smallest y coordinate of this shape.
    public func getMinY() -> Swift.Double { getY() }

    /// Returns the largest x coordinate of this shape.
    public func getMaxX() -> Swift.Double { getX() + getWidth() }

    /// Returns the largest y coordinate of this shape.
    public func getMaxY() -> Swift.Double { getY() + getHeight() }

    /// Returns the x coordinate of the centre of this shape.
    public func getCenterX() -> Swift.Double { getX() + getWidth()  / 2 }

    /// Returns the y coordinate of the centre of this shape.
    public func getCenterY() -> Swift.Double { getY() + getHeight() / 2 }

    // =========================================================================
    // MARK: - setFrame variants
    // =========================================================================

    /// Sets the frame from another `RectangularShape`.
    public func setFrame(_ r: RectangularShape) {
      setFrame(r.getX(), r.getY(), r.getWidth(), r.getHeight())
    }

    /// Sets the frame so that the two given points form opposite corners of
    /// the framing rectangle (diagonal).
    public func setFrameFromDiagonal(
      _ x1: Swift.Double, _ y1: Swift.Double,
      _ x2: Swift.Double, _ y2: Swift.Double
    ) {
      let minX = Swift.min(x1, x2), minY = Swift.min(y1, y2)
      setFrame(minX, minY, Swift.max(x1, x2) - minX, Swift.max(y1, y2) - minY)
    }

    /// Sets the frame from two corner `Point2D` values.
    public func setFrameFromDiagonal(
      _ p1: java.awt.geom.Point2D,
      _ p2: java.awt.geom.Point2D
    ) {
      setFrameFromDiagonal(p1.getX(), p1.getY(), p2.getX(), p2.getY())
    }

    /// Sets the frame from a centre point and a corner point.
    public func setFrameFromCenter(
      _ centerX: Swift.Double, _ centerY: Swift.Double,
      _ cornerX: Swift.Double, _ cornerY: Swift.Double
    ) {
      let hw = Swift.abs(cornerX - centerX)
      let hh = Swift.abs(cornerY - centerY)
      setFrame(centerX - hw, centerY - hh, hw * 2, hh * 2)
    }

    /// Sets the frame from a centre `Point2D` and a corner `Point2D`.
    public func setFrameFromCenter(
      _ center: java.awt.geom.Point2D,
      _ corner: java.awt.geom.Point2D
    ) {
      setFrameFromCenter(center.getX(), center.getY(),
                         corner.getX(), corner.getY())
    }

    // =========================================================================
    // MARK: - Shape — default implementations
    // =========================================================================

    /// Abstract — subclasses must override.
    open func contains(_ x: Swift.Double, _ y: Swift.Double) -> Bool {
      fatalError("abstract")
    }

    /// Abstract — subclasses must override.
    open func contains(_ x: Swift.Double, _ y: Swift.Double,
                        _ w: Swift.Double, _ h: Swift.Double) -> Bool {
      fatalError("abstract")
    }

    /// Abstract — subclasses must override.
    open func intersects(_ x: Swift.Double, _ y: Swift.Double,
                          _ w: Swift.Double, _ h: Swift.Double) -> Bool {
      fatalError("abstract")
    }

    /// Returns the integer bounding box derived from the framing rectangle.
    public func getBounds() -> java.awt.Rectangle {
      let x = Int(getMinX().rounded(.down))
      let y = Int(getMinY().rounded(.down))
      let w = Int(getMaxX().rounded(.up)) - x
      let h = Int(getMaxY().rounded(.up)) - y
      return java.awt.Rectangle(x, y, w, h)
    }

    // =========================================================================
    // MARK: - Point / Shape convenience (Shape protocol default extension)
    // =========================================================================

    /// Returns `true` if `point` lies inside this shape.
    public func contains(_ p: java.awt.geom.Point2D) -> Bool {
      contains(p.getX(), p.getY())
    }

    // =========================================================================
    // MARK: - Init guard
    // =========================================================================

    /// Abstract class — use a concrete subclass.
    public init() {}
  }
}
