/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.geom {

  // ---------------------------------------------------------------------------
  // MARK: - Ellipse2D
  // ---------------------------------------------------------------------------

  /// An abstract ellipse defined by its bounding rectangle `(x, y, w, h)`.
  ///
  /// Mirrors `java.awt.geom.Ellipse2D`. Use the concrete inner types
  /// `Ellipse2D.Float` or `Ellipse2D.Double` for instances.
  ///
  /// ```swift
  /// let e = java.awt.geom.Ellipse2D.Double(0, 0, 100, 60)
  /// print(e.contains(50, 30))   // → true  (centre)
  /// print(e.contains(0, 0))     // → false (corner of bounding box)
  /// ```
  ///
  /// - Since: JavaApi > 0.x (Java 1.2)
  public class Ellipse2D: java.awt.geom.RectangularShape {

    // =========================================================================
    // MARK: - Ellipse2D.Float
    // =========================================================================

    /// An ellipse stored with `Swift.Float` precision.
    public class Float: Ellipse2D {

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
    }

    // =========================================================================
    // MARK: - Ellipse2D.Double
    // =========================================================================

    /// An ellipse stored with `Swift.Double` precision.
    public class Double: Ellipse2D {

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
    }

    // =========================================================================
    // MARK: - RectangularShape overrides
    // =========================================================================

    public override func isEmpty() -> Bool {
      getWidth() <= 0 || getHeight() <= 0
    }

    // =========================================================================
    // MARK: - Shape conformance
    // =========================================================================

    /// Returns `true` if `(px, py)` lies inside the ellipse.
    ///
    /// Uses the normalised ellipse equation:
    /// `((px - cx) / rx)² + ((py - cy) / ry)² <= 1`
    public override func contains(_ px: Swift.Double,
                                   _ py: Swift.Double) -> Bool {
      guard !isEmpty() else { return false }
      let ellw = getWidth(), ellh = getHeight()
      // normalise to unit circle centred at (0.5, 0.5)
      let normx = (px - getX()) / ellw - 0.5
      let normy = (py - getY()) / ellh - 0.5
      return normx * normx + normy * normy < 0.25
    }

    /// Returns `true` if the rectangle `(x, y, w, h)` lies entirely inside
    /// this ellipse.
    public override func contains(_ x: Swift.Double, _ y: Swift.Double,
                                   _ w: Swift.Double, _ h: Swift.Double) -> Bool {
      return contains(x,     y    )
          && contains(x + w, y    )
          && contains(x,     y + h)
          && contains(x + w, y + h)
    }

    /// Returns `true` if this ellipse intersects the rectangle `(x, y, w, h)`.
    ///
    /// Uses the normalised nearest-point algorithm from the Java2D reference
    /// implementation: normalises the rectangle into the ellipse's coordinate
    /// space and checks whether the nearest corner is within the unit circle.
    public override func intersects(_ x: Swift.Double, _ y: Swift.Double,
                                     _ w: Swift.Double, _ h: Swift.Double) -> Bool {
      guard !isEmpty(), w > 0, h > 0 else { return false }
      let ellw = getWidth(), ellh = getHeight()
      guard ellw > 0, ellh > 0 else { return false }

      // Normalise rectangle edges to ellipse space (centre = 0.5)
      let normx  = (x       - getX()) / ellw - 0.5
      let normxw = normx + w / ellw
      let normy  = (y       - getY()) / ellh - 0.5
      let normyh = normy + h / ellh

      // Nearest point on the normalised rectangle to the ellipse centre (0,0)
      let nearx: Swift.Double = normx  > 0 ? normx  : (normxw < 0 ? normxw : 0)
      let neary: Swift.Double = normy  > 0 ? normy  : (normyh < 0 ? normyh : 0)

      return nearx * nearx + neary * neary < 0.25
    }
  }
}
