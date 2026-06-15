/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.geom {

  // ---------------------------------------------------------------------------
  // MARK: - Arc2D
  // ---------------------------------------------------------------------------

  /// An arc defined by a bounding rectangle, a start angle, an angular extent,
  /// and a closure type (OPEN, CHORD, PIE).
  ///
  /// Mirrors `java.awt.geom.Arc2D`. Use the concrete inner types
  /// `Arc2D.Float` or `Arc2D.Double` for instances.
  ///
  /// Angles are measured in degrees, counter-clockwise from the positive x-axis
  /// (Java 2D convention).
  ///
  /// - Since: JavaApi > 0.x (Java 1.2)
  public class Arc2D: java.awt.geom.RectangularShape {

    // =========================================================================
    // MARK: - Closure-type constants
    // =========================================================================

    /// The arc is open (no closing lines).
    public static let OPEN:  Int = 0
    /// The arc is closed by a straight line connecting the two endpoints.
    public static let CHORD: Int = 1
    /// The arc is closed by two lines from the endpoints to the centre (pie slice).
    public static let PIE:   Int = 2

    // =========================================================================
    // MARK: - Arc2D.Float
    // =========================================================================

    public class Float: Arc2D {

      public var x: Swift.Float
      public var y: Swift.Float
      public var width:  Swift.Float
      public var height: Swift.Float
      public var start:  Swift.Float
      public var extent: Swift.Float

      public init(_ x: Swift.Float, _ y: Swift.Float,
                  _ w: Swift.Float, _ h: Swift.Float,
                  _ start: Swift.Float, _ extent: Swift.Float,
                  _ type: Int) {
        self.x = x; self.y = y
        self.width = w; self.height = h
        self.start = start; self.extent = extent
        super.init(type: type)
      }

      public override init(type: Int = Arc2D.OPEN) {
        self.x = 0; self.y = 0; self.width = 0; self.height = 0
        self.start = 0; self.extent = 0
        super.init(type: type)
      }

      public override func getX()           -> Swift.Double { Swift.Double(x) }
      public override func getY()           -> Swift.Double { Swift.Double(y) }
      public override func getWidth()       -> Swift.Double { Swift.Double(width) }
      public override func getHeight()      -> Swift.Double { Swift.Double(height) }
      public override func getAngleStart()  -> Swift.Double { Swift.Double(start) }
      public override func getAngleExtent() -> Swift.Double { Swift.Double(extent) }

      public override func setAngleStart(_ a: Swift.Double)  { start  = Swift.Float(a) }
      public override func setAngleExtent(_ e: Swift.Double) { extent = Swift.Float(e) }

      public override func setFrame(_ x: Swift.Double, _ y: Swift.Double,
                                    _ w: Swift.Double, _ h: Swift.Double) {
        self.x = Swift.Float(x); self.y = Swift.Float(y)
        self.width = Swift.Float(w); self.height = Swift.Float(h)
      }
    }

    // =========================================================================
    // MARK: - Arc2D.Double
    // =========================================================================

    public class Double: Arc2D {

      public var x: Swift.Double
      public var y: Swift.Double
      public var width:  Swift.Double
      public var height: Swift.Double
      public var start:  Swift.Double
      public var extent: Swift.Double

      public init(_ x: Swift.Double, _ y: Swift.Double,
                  _ w: Swift.Double, _ h: Swift.Double,
                  _ start: Swift.Double, _ extent: Swift.Double,
                  _ type: Int) {
        self.x = x; self.y = y
        self.width = w; self.height = h
        self.start = start; self.extent = extent
        super.init(type: type)
      }

      public override init(type: Int = Arc2D.OPEN) {
        self.x = 0; self.y = 0; self.width = 0; self.height = 0
        self.start = 0; self.extent = 0
        super.init(type: type)
      }

      public override func getX()           -> Swift.Double { x }
      public override func getY()           -> Swift.Double { y }
      public override func getWidth()       -> Swift.Double { width }
      public override func getHeight()      -> Swift.Double { height }
      public override func getAngleStart()  -> Swift.Double { start }
      public override func getAngleExtent() -> Swift.Double { extent }

      public override func setAngleStart(_ a: Swift.Double)  { start  = a }
      public override func setAngleExtent(_ e: Swift.Double) { extent = e }

      public override func setFrame(_ x: Swift.Double, _ y: Swift.Double,
                                    _ w: Swift.Double, _ h: Swift.Double) {
        self.x = x; self.y = y; self.width = w; self.height = h
      }
    }

    // =========================================================================
    // MARK: - Abstract arc accessors
    // =========================================================================

    private var _type: Int

    public init(type: Int = OPEN) { _type = type }

    /// The closure type: `OPEN`, `CHORD`, or `PIE`.
    public var arcType: Int {
      get { _type }
      set { _type = newValue }
    }

    open func getAngleStart()  -> Swift.Double { fatalError("abstract") }
    open func getAngleExtent() -> Swift.Double { fatalError("abstract") }
    open func setAngleStart(_ a: Swift.Double)  { fatalError("abstract") }
    open func setAngleExtent(_ e: Swift.Double) { fatalError("abstract") }

    /// Sets start and extent together.
    public func setArc(_ x: Swift.Double, _ y: Swift.Double,
                       _ w: Swift.Double, _ h: Swift.Double,
                       _ angSt: Swift.Double, _ angExt: Swift.Double,
                       _ type: Int) {
      setFrame(x, y, w, h)
      setAngleStart(angSt)
      setAngleExtent(angExt)
      _type = type
    }

    // =========================================================================
    // MARK: - RectangularShape
    // =========================================================================

    public override func isEmpty() -> Bool {
      getWidth() <= 0 || getHeight() <= 0
    }

    // =========================================================================
    // MARK: - Angle helpers (Java 2D: CCW from positive x-axis, in degrees)
    // =========================================================================

    /// Converts a Java 2D angle (degrees, CCW, normalised ellipse) to a
    /// standard mathematical angle in radians.
    private func toRadians(_ angleDeg: Swift.Double) -> Swift.Double {
      // Java 2D angles are CCW from the positive x-axis; Swift.cos/sin use radians CCW.
      return -angleDeg * .pi / 180.0
    }

    /// Returns a point on the ellipse at the given angle (degrees).
    public func getStartPoint() -> java.awt.geom.Point2D {
      let rad = toRadians(getAngleStart())
      let cx = getX() + getWidth()  / 2
      let cy = getY() + getHeight() / 2
      let rx = getWidth()  / 2
      let ry = getHeight() / 2
      return java.awt.geom.Point2D.Double(cx + rx * Foundation.cos(rad),
                                          cy + ry * Foundation.sin(rad))
    }

    public func getEndPoint() -> java.awt.geom.Point2D {
      let rad = toRadians(getAngleStart() + getAngleExtent())
      let cx = getX() + getWidth()  / 2
      let cy = getY() + getHeight() / 2
      let rx = getWidth()  / 2
      let ry = getHeight() / 2
      return java.awt.geom.Point2D.Double(cx + rx * Foundation.cos(rad),
                                          cy + ry * Foundation.sin(rad))
    }

    /// Returns `true` if the given angle (degrees) lies within this arc's sweep.
    public func containsAngle(_ angle: Swift.Double) -> Bool {
      let ext = getAngleExtent()
      if Swift.abs(ext) >= 360 { return true }
      // Normalise angle into [start, start+ext]
      var a = angle - getAngleStart()
      // bring a into [0, 360)
      a = a - 360 * Foundation.floor(a / 360)
      let e = ext < 0 ? 360 + ext : ext
      return ext < 0 ? a >= 360 + ext : a <= e
    }

    // =========================================================================
    // MARK: - Shape conformance
    // =========================================================================

    public override func contains(_ px: Swift.Double,
                                   _ py: Swift.Double) -> Bool {
      guard !isEmpty() else { return false }
      let rx = getWidth()  / 2
      let ry = getHeight() / 2
      guard rx > 0, ry > 0 else { return false }
      let cx = getX() + rx
      let cy = getY() + ry

      // Normalise to unit circle
      let nx = (px - cx) / rx
      let ny = (py - cy) / ry
      let distSq = nx * nx + ny * ny

      if distSq > 1.0 { return false }

      // For PIE the centre counts as inside
      if _type == Arc2D.PIE && distSq == 0 { return true }

      // Check angle
      let angleDeg = Foundation.atan2(-ny, nx) * 180 / .pi
      return containsAngle(angleDeg)
    }

    public override func contains(_ x: Swift.Double, _ y: Swift.Double,
                                   _ w: Swift.Double, _ h: Swift.Double) -> Bool {
      return contains(x,     y    )
          && contains(x + w, y    )
          && contains(x,     y + h)
          && contains(x + w, y + h)
    }

    public override func intersects(_ x: Swift.Double, _ y: Swift.Double,
                                     _ w: Swift.Double, _ h: Swift.Double) -> Bool {
      guard !isEmpty(), w > 0, h > 0 else { return false }
      // Cheap bounding-box pre-check
      let bx = getX(), by = getY()
      let bw = getWidth(), bh = getHeight()
      guard x < bx + bw && x + w > bx && y < by + bh && y + h > by else { return false }
      // Full check: any corner of the rectangle inside the arc?
      if contains(x, y) || contains(x+w, y) ||
         contains(x, y+h) || contains(x+w, y+h) { return true }
      // Or any arc point inside the rectangle?
      let sp = getStartPoint()
      let ep = getEndPoint()
      return (sp.getX() >= x && sp.getX() <= x+w && sp.getY() >= y && sp.getY() <= y+h)
          || (ep.getX() >= x && ep.getX() <= x+w && ep.getY() >= y && ep.getY() <= y+h)
    }
  }
}

// Foundation needed for sin/cos/atan2/floor
import Foundation
