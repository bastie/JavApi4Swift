/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.awt.geom {

  // ---------------------------------------------------------------------------
  // MARK: - QuadCurve2D
  // ---------------------------------------------------------------------------

  /// A quadratic Bézier curve defined by a start point, one control point,
  /// and an end point.
  ///
  /// Mirrors `java.awt.geom.QuadCurve2D`. Use the concrete inner types
  /// `QuadCurve2D.Float` or `QuadCurve2D.Double` for instances.
  ///
  /// - Since: JavaApi > 0.x (Java 1.2)
  public class QuadCurve2D: java.awt.Shape {

    // =========================================================================
    // MARK: - QuadCurve2D.Float
    // =========================================================================

    public class Float: QuadCurve2D {
      public var x1: Swift.Float, y1: Swift.Float
      public var ctrlx: Swift.Float, ctrly: Swift.Float
      public var x2: Swift.Float, y2: Swift.Float

      public init(_ x1: Swift.Float, _ y1: Swift.Float,
                  _ ctrlx: Swift.Float, _ ctrly: Swift.Float,
                  _ x2: Swift.Float, _ y2: Swift.Float) {
        self.x1 = x1; self.y1 = y1
        self.ctrlx = ctrlx; self.ctrly = ctrly
        self.x2 = x2; self.y2 = y2
      }

      public override init() { x1 = 0; y1 = 0; ctrlx = 0; ctrly = 0; x2 = 0; y2 = 0 }

      public override func getX1()     -> Swift.Double { Swift.Double(x1) }
      public override func getY1()     -> Swift.Double { Swift.Double(y1) }
      public override func getCtrlX()  -> Swift.Double { Swift.Double(ctrlx) }
      public override func getCtrlY()  -> Swift.Double { Swift.Double(ctrly) }
      public override func getX2()     -> Swift.Double { Swift.Double(x2) }
      public override func getY2()     -> Swift.Double { Swift.Double(y2) }

      public override func setCurve(_ x1: Swift.Double, _ y1: Swift.Double,
                                    _ cx: Swift.Double, _ cy: Swift.Double,
                                    _ x2: Swift.Double, _ y2: Swift.Double) {
        self.x1 = Swift.Float(x1); self.y1 = Swift.Float(y1)
        self.ctrlx = Swift.Float(cx); self.ctrly = Swift.Float(cy)
        self.x2 = Swift.Float(x2); self.y2 = Swift.Float(y2)
      }
    }

    // =========================================================================
    // MARK: - QuadCurve2D.Double
    // =========================================================================

    public class Double: QuadCurve2D {
      public var x1: Swift.Double, y1: Swift.Double
      public var ctrlx: Swift.Double, ctrly: Swift.Double
      public var x2: Swift.Double, y2: Swift.Double

      public init(_ x1: Swift.Double, _ y1: Swift.Double,
                  _ ctrlx: Swift.Double, _ ctrly: Swift.Double,
                  _ x2: Swift.Double, _ y2: Swift.Double) {
        self.x1 = x1; self.y1 = y1
        self.ctrlx = ctrlx; self.ctrly = ctrly
        self.x2 = x2; self.y2 = y2
      }

      public override init() { x1 = 0; y1 = 0; ctrlx = 0; ctrly = 0; x2 = 0; y2 = 0 }

      public override func getX1()    -> Swift.Double { x1 }
      public override func getY1()    -> Swift.Double { y1 }
      public override func getCtrlX() -> Swift.Double { ctrlx }
      public override func getCtrlY() -> Swift.Double { ctrly }
      public override func getX2()    -> Swift.Double { x2 }
      public override func getY2()    -> Swift.Double { y2 }

      public override func setCurve(_ x1: Swift.Double, _ y1: Swift.Double,
                                    _ cx: Swift.Double, _ cy: Swift.Double,
                                    _ x2: Swift.Double, _ y2: Swift.Double) {
        self.x1 = x1; self.y1 = y1
        self.ctrlx = cx; self.ctrly = cy
        self.x2 = x2; self.y2 = y2
      }
    }

    // =========================================================================
    // MARK: - Abstract accessors
    // =========================================================================

    public init() {}

    open func getX1()    -> Swift.Double { fatalError("abstract") }
    open func getY1()    -> Swift.Double { fatalError("abstract") }
    open func getCtrlX() -> Swift.Double { fatalError("abstract") }
    open func getCtrlY() -> Swift.Double { fatalError("abstract") }
    open func getX2()    -> Swift.Double { fatalError("abstract") }
    open func getY2()    -> Swift.Double { fatalError("abstract") }

    open func setCurve(_ x1: Swift.Double, _ y1: Swift.Double,
                       _ cx: Swift.Double, _ cy: Swift.Double,
                       _ x2: Swift.Double, _ y2: Swift.Double) {
      fatalError("abstract")
    }

    public func getP1()    -> Point2D { Point2D.Double(getX1(), getY1()) }
    public func getP2()    -> Point2D { Point2D.Double(getX2(), getY2()) }
    public func getCtrlPt() -> Point2D { Point2D.Double(getCtrlX(), getCtrlY()) }

    // =========================================================================
    // MARK: - Bézier evaluation
    // =========================================================================

    private func evalX(_ t: Swift.Double) -> Swift.Double {
      let mt = 1 - t
      return mt*mt*getX1() + 2*mt*t*getCtrlX() + t*t*getX2()
    }

    private func evalY(_ t: Swift.Double) -> Swift.Double {
      let mt = 1 - t
      return mt*mt*getY1() + 2*mt*t*getCtrlY() + t*t*getY2()
    }

    // =========================================================================
    // MARK: - Static utility
    // =========================================================================

    /// Solves the quadratic equation `eqn[2]t² + eqn[1]t + eqn[0] = 0`.
    /// Returns the number of roots; roots are stored in `res`.
    public static func solveQuadratic(_ eqn: [Swift.Double],
                                      _ res: inout [Swift.Double]) -> Int {
      let a = eqn[2], b = eqn[1], c = eqn[0]
      guard Swift.abs(a) > 1e-12 else {
        // Linear
        guard Swift.abs(b) > 1e-12 else { return 0 }
        res.append(-c / b)
        return 1
      }
      let disc = b*b - 4*a*c
      if disc < 0 { return 0 }
      if disc == 0 { res.append(-b / (2*a)); return 1 }
      let sqrtDisc = sqrt(disc)
      res.append((-b + sqrtDisc) / (2*a))
      res.append((-b - sqrtDisc) / (2*a))
      return 2
    }

    /// Returns the squared flatness (maximum distance² from the control point
    /// to the baseline).
    public func getFlatnessSq() -> Swift.Double {
      let dx = getX2() - getX1(), dy = getY2() - getY1()
      let len2 = dx*dx + dy*dy
      guard len2 > 0 else {
        let ex = getCtrlX() - getX1(), ey = getCtrlY() - getY1()
        return ex*ex + ey*ey
      }
      let t = ((getCtrlX() - getX1()) * dx + (getCtrlY() - getY1()) * dy) / len2
      let px = getX1() + t * dx - getCtrlX()
      let py = getY1() + t * dy - getCtrlY()
      return px*px + py*py
    }

    public func getFlatness() -> Swift.Double { sqrt(getFlatnessSq()) }

    // =========================================================================
    // MARK: - Shape conformance
    // =========================================================================

    public func getBounds() -> java.awt.Rectangle {
      let minX = Swift.min(getX1(), getCtrlX(), getX2())
      let minY = Swift.min(getY1(), getCtrlY(), getY2())
      let maxX = Swift.max(getX1(), getCtrlX(), getX2())
      let maxY = Swift.max(getY1(), getCtrlY(), getY2())
      return java.awt.Rectangle(Int(minX.rounded(.down)), Int(minY.rounded(.down)),
                                 Int((maxX - minX).rounded(.up)),
                                 Int((maxY - minY).rounded(.up)))
    }

    public func contains(_ px: Swift.Double, _ py: Swift.Double) -> Bool {
      var crossings = 0
      let steps = 16
      var prevX = getX1(), prevY = getY1()
      for i in 1...steps {
        let t = Swift.Double(i) / Swift.Double(steps)
        let cx = evalX(t), cy = evalY(t)
        if (prevY <= py && cy > py) || (cy <= py && prevY > py) {
          let ix = prevX + (py - prevY) * (cx - prevX) / (cy - prevY)
          if px < ix { crossings += 1 }
        }
        prevX = cx; prevY = cy
      }
      return crossings % 2 != 0
    }

    public func contains(_ x: Swift.Double, _ y: Swift.Double,
                          _ w: Swift.Double, _ h: Swift.Double) -> Bool {
      return contains(x, y) && contains(x+w, y) &&
             contains(x, y+h) && contains(x+w, y+h)
    }

    public func intersects(_ x: Swift.Double, _ y: Swift.Double,
                            _ w: Swift.Double, _ h: Swift.Double) -> Bool {
      let b = getBounds()
      guard Swift.Double(b.x) < x+w && Swift.Double(b.x+b.width) > x &&
            Swift.Double(b.y) < y+h && Swift.Double(b.y+b.height) > y else { return false }
      let steps = 16
      var prevX = getX1(), prevY = getY1()
      for i in 1...steps {
        let t = Swift.Double(i) / Swift.Double(steps)
        let cx = evalX(t), cy = evalY(t)
        if cx >= x && cx <= x+w && cy >= y && cy <= y+h { return true }
        prevX = cx; prevY = cy
      }
      _ = prevX; _ = prevY
      return false
    }
  }
}
