/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Fills a shape with a linear color gradient between two points —
  /// mirrors `java.awt.GradientPaint`.
  ///
  /// The gradient runs along the line from `point1` (color `color1`) to
  /// `point2` (color `color2`). Beyond the two points, the gradient either
  /// clamps to the nearest endpoint color (`isCyclic() == false`, the
  /// default) or repeats back and forth (`isCyclic() == true`).
  ///
  /// Rendering support:
  /// - **CoreGraphics** (Apple): `CGGradient` / `drawLinearGradient`.
  /// - **GDI** (Windows): `GradientFill()` (msimg32, classic GDI — no GDI+
  ///   required).
  /// - **X11** (Linux/FreeBSD): no native gradient primitive in core Xlib;
  ///   approximated by filling thin interpolated-color strips.
  ///
  /// - Since: Java 1.2
  public final class GradientPaint: Paint {

    // -------------------------------------------------------------------------
    // MARK: - Fields
    // -------------------------------------------------------------------------

    private let point1: java.awt.geom.Point2D
    private let color1: java.awt.Color
    private let point2: java.awt.geom.Point2D
    private let color2: java.awt.Color
    private let cyclic: Bool

    // -------------------------------------------------------------------------
    // MARK: - Init
    // -------------------------------------------------------------------------

    /// Creates an acyclic gradient between two `Float` coordinate pairs.
    public convenience init(_ x1: Swift.Float, _ y1: Swift.Float, _ color1: java.awt.Color,
                            _ x2: Swift.Float, _ y2: Swift.Float, _ color2: java.awt.Color) {
      self.init(java.awt.geom.Point2D.Float(x1, y1), color1,
                java.awt.geom.Point2D.Float(x2, y2), color2, false)
    }

    /// Creates a gradient between two `Float` coordinate pairs.
    ///
    /// - Parameter cyclic: if `true`, the gradient repeats back and forth
    ///   beyond `point2`; if `false` (default via the other initialiser),
    ///   colors beyond the endpoints clamp to `color1`/`color2`.
    public convenience init(_ x1: Swift.Float, _ y1: Swift.Float, _ color1: java.awt.Color,
                            _ x2: Swift.Float, _ y2: Swift.Float, _ color2: java.awt.Color,
                            _ cyclic: Bool) {
      self.init(java.awt.geom.Point2D.Float(x1, y1), color1,
                java.awt.geom.Point2D.Float(x2, y2), color2, cyclic)
    }

    /// Creates an acyclic gradient between two `Point2D`s.
    public convenience init(_ point1: java.awt.geom.Point2D, _ color1: java.awt.Color,
                            _ point2: java.awt.geom.Point2D, _ color2: java.awt.Color) {
      self.init(point1, color1, point2, color2, false)
    }

    /// Creates a gradient between two `Point2D`s.
    ///
    /// - Precondition: `point1` and `point2` must not be coincident, and
    ///   neither `color` may be `nil` — mirrors Java's
    ///   `IllegalArgumentException` / `NullPointerException` checks.
    public init(_ point1: java.awt.geom.Point2D, _ color1: java.awt.Color,
                _ point2: java.awt.geom.Point2D, _ color2: java.awt.Color,
                _ cyclic: Bool) {
      precondition(point1.getX() != point2.getX() || point1.getY() != point2.getY(),
                   "GradientPaint: points cannot be equal")
      self.point1 = point1
      self.color1 = color1
      self.point2 = point2
      self.color2 = color2
      self.cyclic = cyclic
    }

    // -------------------------------------------------------------------------
    // MARK: - Accessors
    // -------------------------------------------------------------------------

    /// The gradient's starting point.
    public func getPoint1() -> java.awt.geom.Point2D { point1 }

    /// The color at `getPoint1()`.
    public func getColor1() -> java.awt.Color { color1 }

    /// The gradient's ending point.
    public func getPoint2() -> java.awt.geom.Point2D { point2 }

    /// The color at `getPoint2()`.
    public func getColor2() -> java.awt.Color { color2 }

    /// `true` if the gradient repeats (cyclic), `false` if it clamps to
    /// the endpoint colors beyond `point1`/`point2` (acyclic).
    public func isCyclic() -> Bool { cyclic }

    // -------------------------------------------------------------------------
    // MARK: - Transparency
    // -------------------------------------------------------------------------

    /// Returns `TRANSLUCENT` if either endpoint color is non-opaque,
    /// otherwise `OPAQUE`.
    public func getTransparency() -> Int {
      (color1.getAlpha() == 255 && color2.getAlpha() == 255)
        ? java.awt.Color.OPAQUE
        : java.awt.Color.TRANSLUCENT
    }
  }
}
