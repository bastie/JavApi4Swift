/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.geom {

  // ---------------------------------------------------------------------------
  // MARK: - Rectangle2D
  // ---------------------------------------------------------------------------

  /// An abstract double-precision rectangle.
  ///
  /// Mirrors `java.awt.geom.Rectangle2D`. Use the concrete inner types
  /// `Rectangle2D.Float` or `Rectangle2D.Double` for instances.
  ///
  /// `java.awt.Rectangle` is the integer-precision counterpart.
  ///
  /// - Since: JavaApi > 0.x (Java 1.2)
  public class Rectangle2D: java.awt.geom.RectangularShape {

    // =========================================================================
    // MARK: - Outcode constants
    // =========================================================================

    /// Indicates that a point lies to the left of the rectangle.
    public static let OUT_LEFT:   Int = 1
    /// Indicates that a point lies above the rectangle.
    public static let OUT_TOP:    Int = 2
    /// Indicates that a point lies to the right of the rectangle.
    public static let OUT_RIGHT:  Int = 4
    /// Indicates that a point lies below the rectangle.
    public static let OUT_BOTTOM: Int = 8

    // =========================================================================
    // MARK: - Rectangle2D.Float
    // =========================================================================

    /// A rectangle stored with `Swift.Float` precision.
    public class Float: Rectangle2D {

      public var x: Swift.Float
      public var y: Swift.Float
      public var width:  Swift.Float
      public var height: Swift.Float

      public init(_ x: Swift.Float, _ y: Swift.Float,
                  _ w: Swift.Float, _ h: Swift.Float) {
        self.x = x; self.y = y; self.width = w; self.height = h
      }

      public override init() { self.x = 0; self.y = 0; self.width = 0; self.height = 0 }

      public override func getX()      -> Swift.Double { Swift.Double(x) }
      public override func getY()      -> Swift.Double { Swift.Double(y) }
      public override func getWidth()  -> Swift.Double { Swift.Double(width) }
      public override func getHeight() -> Swift.Double { Swift.Double(height) }

      public override func setFrame(_ x: Swift.Double, _ y: Swift.Double,
                                    _ w: Swift.Double, _ h: Swift.Double) {
        self.x = Swift.Float(x); self.y = Swift.Float(y)
        self.width = Swift.Float(w); self.height = Swift.Float(h)
      }

      /// Sets the rectangle using `Swift.Float` coordinates directly.
      public func setRect(_ x: Swift.Float, _ y: Swift.Float,
                          _ w: Swift.Float, _ h: Swift.Float) {
        self.x = x; self.y = y; self.width = w; self.height = h
      }

      public override func createIntersection(_ r: Rectangle2D) -> Rectangle2D {
        let result = Rectangle2D.Float()
        Rectangle2D.intersect(self, r, result)
        return result
      }

      public override func createUnion(_ r: Rectangle2D) -> Rectangle2D {
        let result = Rectangle2D.Float()
        Rectangle2D.union(self, r, result)
        return result
      }
    }

    // =========================================================================
    // MARK: - Rectangle2D.Double
    // =========================================================================

    /// A rectangle stored with `Swift.Double` precision.
    public class Double: Rectangle2D {

      public var x: Swift.Double
      public var y: Swift.Double
      public var width:  Swift.Double
      public var height: Swift.Double

      public init(_ x: Swift.Double, _ y: Swift.Double,
                  _ w: Swift.Double, _ h: Swift.Double) {
        self.x = x; self.y = y; self.width = w; self.height = h
      }

      public override init() { self.x = 0; self.y = 0; self.width = 0; self.height = 0 }

      public override func getX()      -> Swift.Double { x }
      public override func getY()      -> Swift.Double { y }
      public override func getWidth()  -> Swift.Double { width }
      public override func getHeight() -> Swift.Double { height }

      public override func setFrame(_ x: Swift.Double, _ y: Swift.Double,
                                    _ w: Swift.Double, _ h: Swift.Double) {
        self.x = x; self.y = y; self.width = w; self.height = h
      }

      /// Sets the rectangle with `Swift.Double` coordinates directly.
      public override func setRect(_ x: Swift.Double, _ y: Swift.Double,
                          _ w: Swift.Double, _ h: Swift.Double) {
        self.x = x; self.y = y; self.width = w; self.height = h
      }

      public override func createIntersection(_ r: Rectangle2D) -> Rectangle2D {
        let result = Rectangle2D.Double()
        Rectangle2D.intersect(self, r, result)
        return result
      }

      public override func createUnion(_ r: Rectangle2D) -> Rectangle2D {
        let result = Rectangle2D.Double()
        Rectangle2D.union(self, r, result)
        return result
      }
    }

    // =========================================================================
    // MARK: - Abstract interface
    // =========================================================================

    /// Returns a new `Rectangle2D` representing the intersection of this
    /// rectangle and `r`.
    open func createIntersection(_ r: Rectangle2D) -> Rectangle2D {
      fatalError("abstract")
    }

    /// Returns a new `Rectangle2D` representing the union of this rectangle
    /// and `r`.
    open func createUnion(_ r: Rectangle2D) -> Rectangle2D {
      fatalError("abstract")
    }

    // =========================================================================
    // MARK: - RectangularShape overrides
    // =========================================================================

    public override func isEmpty() -> Bool {
      getWidth() <= 0 || getHeight() <= 0
    }

    // =========================================================================
    // MARK: - setRect
    // =========================================================================

    /// Sets the bounds from double-precision values.
    public func setRect(_ x: Swift.Double, _ y: Swift.Double,
                        _ w: Swift.Double, _ h: Swift.Double) {
      setFrame(x, y, w, h)
    }

    /// Copies the bounds from another `Rectangle2D`.
    public func setRect(_ r: Rectangle2D) {
      setFrame(r.getX(), r.getY(), r.getWidth(), r.getHeight())
    }

    // =========================================================================
    // MARK: - Outcode
    // =========================================================================

    /// Returns a bitmask indicating where `(px, py)` lies relative to this
    /// rectangle, using the `OUT_*` constants.
    public func outcode(_ px: Swift.Double, _ py: Swift.Double) -> Int {
      var out = 0
      let w = getWidth(), h = getHeight()
      if w <= 0 {
        out |= Rectangle2D.OUT_LEFT | Rectangle2D.OUT_RIGHT
      } else if px < getX() {
        out |= Rectangle2D.OUT_LEFT
      } else if px > getX() + w {
        out |= Rectangle2D.OUT_RIGHT
      }
      if h <= 0 {
        out |= Rectangle2D.OUT_TOP | Rectangle2D.OUT_BOTTOM
      } else if py < getY() {
        out |= Rectangle2D.OUT_TOP
      } else if py > getY() + h {
        out |= Rectangle2D.OUT_BOTTOM
      }
      return out
    }

    /// Returns a bitmask indicating where `point` lies relative to this
    /// rectangle.
    public func outcode(_ p: java.awt.geom.Point2D) -> Int {
      outcode(p.getX(), p.getY())
    }

    // =========================================================================
    // MARK: - Shape conformance
    // =========================================================================

    public override func contains(_ x: Swift.Double, _ y: Swift.Double) -> Bool {
      guard !isEmpty() else { return false }
      return x >= getX() && y >= getY()
          && x <  getX() + getWidth()
          && y <  getY() + getHeight()
    }

    public override func contains(_ x: Swift.Double, _ y: Swift.Double,
                                   _ w: Swift.Double, _ h: Swift.Double) -> Bool {
      guard !isEmpty(), w > 0, h > 0 else { return false }
      return x >= getX() && y >= getY()
          && (x + w) <= getX() + getWidth()
          && (y + h) <= getY() + getHeight()
    }

    public override func intersects(_ x: Swift.Double, _ y: Swift.Double,
                                     _ w: Swift.Double, _ h: Swift.Double) -> Bool {
      guard !isEmpty(), w > 0, h > 0 else { return false }
      return x + w > getX() && y + h > getY()
          && x < getX() + getWidth()
          && y < getY() + getHeight()
    }

    // =========================================================================
    // MARK: - Line intersection
    // =========================================================================

    /// Returns `true` if the line segment `(x1,y1)-(x2,y2)` intersects this
    /// rectangle.
    public func intersectsLine(_ x1: Swift.Double, _ y1: Swift.Double,
                                _ x2: Swift.Double, _ y2: Swift.Double) -> Bool {
      var out1 = outcode(x1, y1)
      var out2 = outcode(x2, y2)
      while true {
        if out1 | out2 == 0 { return true }          // both inside
        if out1 & out2 != 0 { return false }          // trivially outside
        let out = out1 != 0 ? out1 : out2
        var xi = x1, yi = y1
        if out & Rectangle2D.OUT_TOP != 0 {
          xi = x1 + (x2 - x1) * (getY() - y1) / (y2 - y1)
          yi = getY()
        } else if out & Rectangle2D.OUT_BOTTOM != 0 {
          xi = x1 + (x2 - x1) * (getY() + getHeight() - y1) / (y2 - y1)
          yi = getY() + getHeight()
        } else if out & Rectangle2D.OUT_RIGHT != 0 {
          yi = y1 + (y2 - y1) * (getX() + getWidth() - x1) / (x2 - x1)
          xi = getX() + getWidth()
        } else if out & Rectangle2D.OUT_LEFT != 0 {
          yi = y1 + (y2 - y1) * (getX() - x1) / (x2 - x1)
          xi = getX()
        }
        if out == out1 {
          out1 = outcode(xi, yi)
        } else {
          out2 = outcode(xi, yi)
        }
      }
    }

    /// Returns `true` if `line` intersects this rectangle.
    public func intersectsLine(_ line: java.awt.geom.Line2D) -> Bool {
      intersectsLine(line.getX1(), line.getY1(), line.getX2(), line.getY2())
    }

    // =========================================================================
    // MARK: - add
    // =========================================================================

    /// Expands this rectangle to include the point `(px, py)`.
    public func add(_ px: Swift.Double, _ py: Swift.Double) {
      let x1 = Swift.min(getX(), px),      y1 = Swift.min(getY(), py)
      let x2 = Swift.max(getX() + getWidth(), px)
      let y2 = Swift.max(getY() + getHeight(), py)
      setFrame(x1, y1, x2 - x1, y2 - y1)
    }

    /// Expands this rectangle to include `point`.
    public func add(_ p: java.awt.geom.Point2D) { add(p.getX(), p.getY()) }

    /// Expands this rectangle to include `r`.
    public func add(_ r: Rectangle2D) {
      let x1 = Swift.min(getX(), r.getX())
      let y1 = Swift.min(getY(), r.getY())
      let x2 = Swift.max(getX() + getWidth(),  r.getX() + r.getWidth())
      let y2 = Swift.max(getY() + getHeight(), r.getY() + r.getHeight())
      setFrame(x1, y1, x2 - x1, y2 - y1)
    }

    // =========================================================================
    // MARK: - Static set operations
    // =========================================================================

    /// Stores the intersection of `src1` and `src2` into `dest`.
    public static func intersect(_ src1: Rectangle2D,
                                  _ src2: Rectangle2D,
                                  _ dest: Rectangle2D) {
      let x1 = Swift.max(src1.getX(), src2.getX())
      let y1 = Swift.max(src1.getY(), src2.getY())
      let x2 = Swift.min(src1.getX() + src1.getWidth(),
                          src2.getX() + src2.getWidth())
      let y2 = Swift.min(src1.getY() + src1.getHeight(),
                          src2.getY() + src2.getHeight())
      dest.setFrame(x1, y1, x2 - x1, y2 - y1)
    }

    /// Stores the union of `src1` and `src2` into `dest`.
    public static func union(_ src1: Rectangle2D,
                              _ src2: Rectangle2D,
                              _ dest: Rectangle2D) {
      let x1 = Swift.min(src1.getX(), src2.getX())
      let y1 = Swift.min(src1.getY(), src2.getY())
      let x2 = Swift.max(src1.getX() + src1.getWidth(),
                          src2.getX() + src2.getWidth())
      let y2 = Swift.max(src1.getY() + src1.getHeight(),
                          src2.getY() + src2.getHeight())
      dest.setFrame(x1, y1, x2 - x1, y2 - y1)
    }
  }
}
