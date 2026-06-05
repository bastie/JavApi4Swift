/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.geom {

  // ---------------------------------------------------------------------------
  // MARK: - Line2D
  // ---------------------------------------------------------------------------

  /// An abstract line segment in (x1, y1) → (x2, y2) coordinate space.
  ///
  /// Mirrors `java.awt.geom.Line2D`. Use the concrete inner types
  /// `Line2D.Float` or `Line2D.Double` for instances.
  ///
  /// ```swift
  /// let line = java.awt.geom.Line2D.Double(0, 0, 100, 50)
  /// print(line.ptSegDist(30, 10))
  /// ```
  ///
  /// - Since: JavaApi > 0.x (Java 1.2)
  public class Line2D: java.awt.Shape {

    // =========================================================================
    // MARK: - Line2D.Float
    // =========================================================================

    /// A line segment stored with `Swift.Float` precision.
    public class Float: Line2D {

      public var x1: Swift.Float
      public var y1: Swift.Float
      public var x2: Swift.Float
      public var y2: Swift.Float

      public init(_ x1: Swift.Float, _ y1: Swift.Float,
                  _ x2: Swift.Float, _ y2: Swift.Float) {
        self.x1 = x1; self.y1 = y1; self.x2 = x2; self.y2 = y2
      }

      public convenience init(_ p1: java.awt.geom.Point2D,
                               _ p2: java.awt.geom.Point2D) {
        self.init(Swift.Float(p1.getX()), Swift.Float(p1.getY()),
                  Swift.Float(p2.getX()), Swift.Float(p2.getY()))
      }

      public override init() {
        self.x1 = 0; self.y1 = 0; self.x2 = 0; self.y2 = 0
      }

      public override func getX1() -> Swift.Double { Swift.Double(x1) }
      public override func getY1() -> Swift.Double { Swift.Double(y1) }
      public override func getX2() -> Swift.Double { Swift.Double(x2) }
      public override func getY2() -> Swift.Double { Swift.Double(y2) }

      public override func setLine(_ x1: Swift.Double, _ y1: Swift.Double,
                                   _ x2: Swift.Double, _ y2: Swift.Double) {
        self.x1 = Swift.Float(x1); self.y1 = Swift.Float(y1)
        self.x2 = Swift.Float(x2); self.y2 = Swift.Float(y2)
      }

      /// Sets the line using `Swift.Float` coordinates directly.
      public func setLine(_ x1: Swift.Float, _ y1: Swift.Float,
                          _ x2: Swift.Float, _ y2: Swift.Float) {
        self.x1 = x1; self.y1 = y1; self.x2 = x2; self.y2 = y2
      }
    }

    // =========================================================================
    // MARK: - Line2D.Double
    // =========================================================================

    /// A line segment stored with `Swift.Double` precision.
    public class Double: Line2D {

      public var x1: Swift.Double
      public var y1: Swift.Double
      public var x2: Swift.Double
      public var y2: Swift.Double

      public init(_ x1: Swift.Double, _ y1: Swift.Double,
                  _ x2: Swift.Double, _ y2: Swift.Double) {
        self.x1 = x1; self.y1 = y1; self.x2 = x2; self.y2 = y2
      }

      public convenience init(_ p1: java.awt.geom.Point2D,
                               _ p2: java.awt.geom.Point2D) {
        self.init(p1.getX(), p1.getY(), p2.getX(), p2.getY())
      }

      public  override init() {
        self.x1 = 0; self.y1 = 0; self.x2 = 0; self.y2 = 0
      }

      public override func getX1() -> Swift.Double { x1 }
      public override func getY1() -> Swift.Double { y1 }
      public override func getX2() -> Swift.Double { x2 }
      public override func getY2() -> Swift.Double { y2 }

      public override func setLine(_ x1: Swift.Double, _ y1: Swift.Double,
                                   _ x2: Swift.Double, _ y2: Swift.Double) {
        self.x1 = x1; self.y1 = y1; self.x2 = x2; self.y2 = y2
      }
    }

    // =========================================================================
    // MARK: - Abstract interface
    // =========================================================================

    /// Abstract — implemented by `Float` and `Double`.
    open func getX1() -> Swift.Double { fatalError("abstract") }
    open func getY1() -> Swift.Double { fatalError("abstract") }
    open func getX2() -> Swift.Double { fatalError("abstract") }
    open func getY2() -> Swift.Double { fatalError("abstract") }

    /// Abstract — implemented by `Float` and `Double`.
    open func setLine(_ x1: Swift.Double, _ y1: Swift.Double,
                      _ x2: Swift.Double, _ y2: Swift.Double) {
      fatalError("abstract")
    }

    // =========================================================================
    // MARK: - Concrete mutators
    // =========================================================================

    /// Sets the line from two `Point2D` values.
    public func setLine(_ p1: java.awt.geom.Point2D,
                        _ p2: java.awt.geom.Point2D) {
      setLine(p1.getX(), p1.getY(), p2.getX(), p2.getY())
    }

    /// Sets the line from another `Line2D`.
    public func setLine(_ line: Line2D) {
      setLine(line.getX1(), line.getY1(), line.getX2(), line.getY2())
    }

    // =========================================================================
    // MARK: - Accessors
    // =========================================================================

    /// Returns the start point.
    public func getP1() -> java.awt.geom.Point2D {
      java.awt.geom.Point2D.Double(getX1(), getY1())
    }

    /// Returns the end point.
    public func getP2() -> java.awt.geom.Point2D {
      java.awt.geom.Point2D.Double(getX2(), getY2())
    }

    // =========================================================================
    // MARK: - Orientation (relativeCCW)
    // =========================================================================

    /// Returns the orientation of point `(px, py)` relative to the directed
    /// line segment from `(x1, y1)` to `(x2, y2)`.
    ///
    /// - Returns: `1` (counter-clockwise / left), `-1` (clockwise / right),
    ///   or `0` (collinear or on segment).
    public static func relativeCCW(
      _ x1: Swift.Double, _ y1: Swift.Double,
      _ x2_: Swift.Double, _ y2_: Swift.Double,
      _ px_: Swift.Double, _ py_: Swift.Double
    ) -> Int {
      let x2 = x2_ - x1
      let y2 = y2_ - y1
      var px = px_ - x1
      var py = py_ - y1
      var ccw = px * y2 - py * x2
      if ccw == 0.0 {
        ccw = px * x2 + py * y2
        if ccw > 0.0 {
          px -= x2; py -= y2
          ccw = px * x2 + py * y2
          if ccw < 0.0 { ccw = 0.0 }
        }
      }
      return ccw < 0.0 ? -1 : (ccw > 0.0 ? 1 : 0)
    }

    /// Instance variant — orientation of `(px, py)` relative to this segment.
    public func relativeCCW(_ px: Swift.Double, _ py: Swift.Double) -> Int {
      Line2D.relativeCCW(getX1(), getY1(), getX2(), getY2(), px, py)
    }

    /// Instance variant accepting a `Point2D`.
    public func relativeCCW(_ p: java.awt.geom.Point2D) -> Int {
      relativeCCW(p.getX(), p.getY())
    }

    // =========================================================================
    // MARK: - Intersection test
    // =========================================================================

    /// Returns `true` if segment `(x1,y1)-(x2,y2)` intersects
    /// segment `(x3,y3)-(x4,y4)`.
    public static func linesIntersect(
      _ x1: Swift.Double, _ y1: Swift.Double,
      _ x2: Swift.Double, _ y2: Swift.Double,
      _ x3: Swift.Double, _ y3: Swift.Double,
      _ x4: Swift.Double, _ y4: Swift.Double
    ) -> Bool {
      return (relativeCCW(x1, y1, x2, y2, x3, y3) *
              relativeCCW(x1, y1, x2, y2, x4, y4) <= 0)
          && (relativeCCW(x3, y3, x4, y4, x1, y1) *
              relativeCCW(x3, y3, x4, y4, x2, y2) <= 0)
    }

    /// Returns `true` if this segment intersects segment `(x1,y1)-(x2,y2)`.
    public func intersectsLine(
      _ x1: Swift.Double, _ y1: Swift.Double,
      _ x2: Swift.Double, _ y2: Swift.Double
    ) -> Bool {
      Line2D.linesIntersect(
        getX1(), getY1(), getX2(), getY2(), x1, y1, x2, y2)
    }

    /// Returns `true` if this segment intersects `line`.
    public func intersectsLine(_ line: Line2D) -> Bool {
      intersectsLine(line.getX1(), line.getY1(), line.getX2(), line.getY2())
    }

    // =========================================================================
    // MARK: - Point-to-segment distance
    // =========================================================================

    /// Returns the squared distance from point `(px, py)` to segment
    /// `(x1,y1)-(x2,y2)`.
    public static func ptSegDistSq(
      _ x1: Swift.Double, _ y1: Swift.Double,
      _ x2_: Swift.Double, _ y2_: Swift.Double,
      _ px_: Swift.Double, _ py_: Swift.Double
    ) -> Swift.Double {
      let x2 = x2_ - x1
      let y2 = y2_ - y1
      var px = px_ - x1
      var py = py_ - y1
      var dotprod = px * x2 + py * y2
      let projlenSq: Swift.Double
      if dotprod <= 0.0 {
        projlenSq = 0.0
      } else {
        px = x2 - px; py = y2 - py
        dotprod = px * x2 + py * y2
        projlenSq = dotprod <= 0.0 ? 0.0 : dotprod * dotprod / (x2*x2 + y2*y2)
      }
      let lenSq = px*px + py*py - projlenSq
      return lenSq < 0 ? 0 : lenSq
    }

    /// Returns the distance from point `(px, py)` to segment `(x1,y1)-(x2,y2)`.
    public static func ptSegDist(
      _ x1: Swift.Double, _ y1: Swift.Double,
      _ x2: Swift.Double, _ y2: Swift.Double,
      _ px: Swift.Double, _ py: Swift.Double
    ) -> Swift.Double {
      Math.sqrt(ptSegDistSq(x1, y1, x2, y2, px, py))
    }

    /// Returns the squared distance from `(px, py)` to this segment.
    public func ptSegDistSq(_ px: Swift.Double, _ py: Swift.Double) -> Swift.Double {
      Line2D.ptSegDistSq(getX1(), getY1(), getX2(), getY2(), px, py)
    }

    /// Returns the distance from `(px, py)` to this segment.
    public func ptSegDist(_ px: Swift.Double, _ py: Swift.Double) -> Swift.Double {
      Line2D.ptSegDist(getX1(), getY1(), getX2(), getY2(), px, py)
    }

    /// Returns the squared distance from `point` to this segment.
    public func ptSegDistSq(_ p: java.awt.geom.Point2D) -> Swift.Double {
      ptSegDistSq(p.getX(), p.getY())
    }

    /// Returns the distance from `point` to this segment.
    public func ptSegDist(_ p: java.awt.geom.Point2D) -> Swift.Double {
      ptSegDist(p.getX(), p.getY())
    }

    // =========================================================================
    // MARK: - Point-to-line distance (infinite line)
    // =========================================================================

    /// Returns the squared distance from `(px, py)` to the infinite line
    /// defined by `(x1,y1)-(x2,y2)`.
    public static func ptLineDistSq(
      _ x1: Swift.Double, _ y1: Swift.Double,
      _ x2_: Swift.Double, _ y2_: Swift.Double,
      _ px_: Swift.Double, _ py_: Swift.Double
    ) -> Swift.Double {
      let x2 = x2_ - x1, y2 = y2_ - y1
      let px = px_ - x1, py = py_ - y1
      let dotprod = px * x2 + py * y2
      let projlenSq = dotprod * dotprod / (x2*x2 + y2*y2)
      let lenSq = px*px + py*py - projlenSq
      return lenSq < 0 ? 0 : lenSq
    }

    /// Returns the distance from `(px, py)` to the infinite line.
    public static func ptLineDist(
      _ x1: Swift.Double, _ y1: Swift.Double,
      _ x2: Swift.Double, _ y2: Swift.Double,
      _ px: Swift.Double, _ py: Swift.Double
    ) -> Swift.Double {
      Math.sqrt(ptLineDistSq(x1, y1, x2, y2, px, py))
    }

    /// Returns the squared distance from `(px, py)` to the infinite line
    /// through this segment.
    public func ptLineDistSq(_ px: Swift.Double, _ py: Swift.Double) -> Swift.Double {
      Line2D.ptLineDistSq(getX1(), getY1(), getX2(), getY2(), px, py)
    }

    /// Returns the distance from `(px, py)` to the infinite line through
    /// this segment.
    public func ptLineDist(_ px: Swift.Double, _ py: Swift.Double) -> Swift.Double {
      Line2D.ptLineDist(getX1(), getY1(), getX2(), getY2(), px, py)
    }

    /// Returns the squared distance from `point` to the infinite line.
    public func ptLineDistSq(_ p: java.awt.geom.Point2D) -> Swift.Double {
      ptLineDistSq(p.getX(), p.getY())
    }

    /// Returns the distance from `point` to the infinite line.
    public func ptLineDist(_ p: java.awt.geom.Point2D) -> Swift.Double {
      ptLineDist(p.getX(), p.getY())
    }

    // =========================================================================
    // MARK: - Shape conformance
    // =========================================================================

    /// A line has no interior — always returns `false`.
    public func contains(_ x: Swift.Double, _ y: Swift.Double) -> Bool { false }

    /// A line has no interior — always returns `false`.
    public func contains(_ x: Swift.Double, _ y: Swift.Double,
                          _ w: Swift.Double, _ h: Swift.Double) -> Bool { false }

    /// Returns `true` if this segment intersects the given rectangle.
    public func intersects(_ x: Swift.Double, _ y: Swift.Double,
                            _ w: Swift.Double, _ h: Swift.Double) -> Bool {
      let lx1 = getX1(), ly1 = getY1(), lx2 = getX2(), ly2 = getY2()
      let rx = x, ry = y, rw = x + w, rh = y + h
      // endpoint inside rect
      if lx1 >= rx && lx1 <= rw && ly1 >= ry && ly1 <= rh { return true }
      if lx2 >= rx && lx2 <= rw && ly2 >= ry && ly2 <= rh { return true }
      // segment crosses any rect edge
      return Line2D.linesIntersect(lx1, ly1, lx2, ly2, rx, ry, rw, ry)
          || Line2D.linesIntersect(lx1, ly1, lx2, ly2, rw, ry, rw, rh)
          || Line2D.linesIntersect(lx1, ly1, lx2, ly2, rw, rh, rx, rh)
          || Line2D.linesIntersect(lx1, ly1, lx2, ly2, rx, rh, rx, ry)
    }

    /// Returns the integer bounding box of this segment.
    public func getBounds() -> java.awt.Rectangle {
      let minX = Int(Swift.min(getX1(), getX2()).rounded(.down))
      let minY = Int(Swift.min(getY1(), getY2()).rounded(.down))
      let maxX = Int(Swift.max(getX1(), getX2()).rounded(.up))
      let maxY = Int(Swift.max(getY1(), getY2()).rounded(.up))
      return java.awt.Rectangle(minX, minY, maxX - minX, maxY - minY)
    }

    // =========================================================================
    // MARK: - Init (abstract class guard)
    // =========================================================================

    /// Abstract class — use `Line2D.Float` or `Line2D.Double`.
    fileprivate init() {}
  }
}
