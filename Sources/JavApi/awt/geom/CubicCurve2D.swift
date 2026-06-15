/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.awt.geom {

  // ---------------------------------------------------------------------------
  // MARK: - CubicCurve2D
  // ---------------------------------------------------------------------------

  /// A cubic Bézier curve defined by four control points.
  ///
  /// Mirrors `java.awt.geom.CubicCurve2D`. Use the concrete inner types
  /// `CubicCurve2D.Float` or `CubicCurve2D.Double` for instances.
  ///
  /// - Since: JavaApi > 0.x (Java 1.2)
  public class CubicCurve2D: java.awt.Shape {

    // =========================================================================
    // MARK: - CubicCurve2D.Float
    // =========================================================================

    public class Float: CubicCurve2D {
      public var x1: Swift.Float, y1: Swift.Float
      public var ctrlx1: Swift.Float, ctrly1: Swift.Float
      public var ctrlx2: Swift.Float, ctrly2: Swift.Float
      public var x2: Swift.Float, y2: Swift.Float

      public init(_ x1: Swift.Float, _ y1: Swift.Float,
                  _ ctrlx1: Swift.Float, _ ctrly1: Swift.Float,
                  _ ctrlx2: Swift.Float, _ ctrly2: Swift.Float,
                  _ x2: Swift.Float, _ y2: Swift.Float) {
        self.x1 = x1; self.y1 = y1
        self.ctrlx1 = ctrlx1; self.ctrly1 = ctrly1
        self.ctrlx2 = ctrlx2; self.ctrly2 = ctrly2
        self.x2 = x2; self.y2 = y2
      }

      public override init() {
        x1 = 0; y1 = 0; ctrlx1 = 0; ctrly1 = 0
        ctrlx2 = 0; ctrly2 = 0; x2 = 0; y2 = 0
      }

      public override func getX1()      -> Swift.Double { Swift.Double(x1) }
      public override func getY1()      -> Swift.Double { Swift.Double(y1) }
      public override func getCtrlX1()  -> Swift.Double { Swift.Double(ctrlx1) }
      public override func getCtrlY1()  -> Swift.Double { Swift.Double(ctrly1) }
      public override func getCtrlX2()  -> Swift.Double { Swift.Double(ctrlx2) }
      public override func getCtrlY2()  -> Swift.Double { Swift.Double(ctrly2) }
      public override func getX2()      -> Swift.Double { Swift.Double(x2) }
      public override func getY2()      -> Swift.Double { Swift.Double(y2) }

      public override func setCurve(_ x1: Swift.Double, _ y1: Swift.Double,
                                    _ cx1: Swift.Double, _ cy1: Swift.Double,
                                    _ cx2: Swift.Double, _ cy2: Swift.Double,
                                    _ x2: Swift.Double, _ y2: Swift.Double) {
        self.x1 = Swift.Float(x1); self.y1 = Swift.Float(y1)
        self.ctrlx1 = Swift.Float(cx1); self.ctrly1 = Swift.Float(cy1)
        self.ctrlx2 = Swift.Float(cx2); self.ctrly2 = Swift.Float(cy2)
        self.x2 = Swift.Float(x2); self.y2 = Swift.Float(y2)
      }
    }

    // =========================================================================
    // MARK: - CubicCurve2D.Double
    // =========================================================================

    public class Double: CubicCurve2D {
      public var x1: Swift.Double, y1: Swift.Double
      public var ctrlx1: Swift.Double, ctrly1: Swift.Double
      public var ctrlx2: Swift.Double, ctrly2: Swift.Double
      public var x2: Swift.Double, y2: Swift.Double

      public init(_ x1: Swift.Double, _ y1: Swift.Double,
                  _ ctrlx1: Swift.Double, _ ctrly1: Swift.Double,
                  _ ctrlx2: Swift.Double, _ ctrly2: Swift.Double,
                  _ x2: Swift.Double, _ y2: Swift.Double) {
        self.x1 = x1; self.y1 = y1
        self.ctrlx1 = ctrlx1; self.ctrly1 = ctrly1
        self.ctrlx2 = ctrlx2; self.ctrly2 = ctrly2
        self.x2 = x2; self.y2 = y2
      }

      public override init() {
        x1 = 0; y1 = 0; ctrlx1 = 0; ctrly1 = 0
        ctrlx2 = 0; ctrly2 = 0; x2 = 0; y2 = 0
      }

      public override func getX1()      -> Swift.Double { x1 }
      public override func getY1()      -> Swift.Double { y1 }
      public override func getCtrlX1()  -> Swift.Double { ctrlx1 }
      public override func getCtrlY1()  -> Swift.Double { ctrly1 }
      public override func getCtrlX2()  -> Swift.Double { ctrlx2 }
      public override func getCtrlY2()  -> Swift.Double { ctrly2 }
      public override func getX2()      -> Swift.Double { x2 }
      public override func getY2()      -> Swift.Double { y2 }

      public override func setCurve(_ x1: Swift.Double, _ y1: Swift.Double,
                                    _ cx1: Swift.Double, _ cy1: Swift.Double,
                                    _ cx2: Swift.Double, _ cy2: Swift.Double,
                                    _ x2: Swift.Double, _ y2: Swift.Double) {
        self.x1 = x1; self.y1 = y1
        self.ctrlx1 = cx1; self.ctrly1 = cy1
        self.ctrlx2 = cx2; self.ctrly2 = cy2
        self.x2 = x2; self.y2 = y2
      }
    }

    // =========================================================================
    // MARK: - Abstract accessors
    // =========================================================================

    public init() {}

    open func getX1()     -> Swift.Double { fatalError("abstract") }
    open func getY1()     -> Swift.Double { fatalError("abstract") }
    open func getCtrlX1() -> Swift.Double { fatalError("abstract") }
    open func getCtrlY1() -> Swift.Double { fatalError("abstract") }
    open func getCtrlX2() -> Swift.Double { fatalError("abstract") }
    open func getCtrlY2() -> Swift.Double { fatalError("abstract") }
    open func getX2()     -> Swift.Double { fatalError("abstract") }
    open func getY2()     -> Swift.Double { fatalError("abstract") }

    open func setCurve(_ x1: Swift.Double, _ y1: Swift.Double,
                       _ cx1: Swift.Double, _ cy1: Swift.Double,
                       _ cx2: Swift.Double, _ cy2: Swift.Double,
                       _ x2: Swift.Double, _ y2: Swift.Double) {
      fatalError("abstract")
    }

    public func getP1()     -> Point2D { Point2D.Double(getX1(), getY1()) }
    public func getP2()     -> Point2D { Point2D.Double(getX2(), getY2()) }
    public func getCtrlP1() -> Point2D { Point2D.Double(getCtrlX1(), getCtrlY1()) }
    public func getCtrlP2() -> Point2D { Point2D.Double(getCtrlX2(), getCtrlY2()) }

    // =========================================================================
    // MARK: - Bézier helpers
    // =========================================================================

    /// Evaluates the cubic Bézier at parameter `t` ∈ [0,1].
    private func evalX(_ t: Swift.Double) -> Swift.Double {
      let mt = 1 - t
      return mt*mt*mt*getX1()
           + 3*mt*mt*t*getCtrlX1()
           + 3*mt*t*t*getCtrlX2()
           + t*t*t*getX2()
    }

    private func evalY(_ t: Swift.Double) -> Swift.Double {
      let mt = 1 - t
      return mt*mt*mt*getY1()
           + 3*mt*mt*t*getCtrlY1()
           + 3*mt*t*t*getCtrlY2()
           + t*t*t*getY2()
    }

    // =========================================================================
    // MARK: - Static utility
    // =========================================================================

    /// Solves the cubic equation `eqn[3]t³ + eqn[2]t² + eqn[1]t + eqn[0] = 0`
    /// and returns the number of roots, which are stored in `res`.
    public static func solveCubic(_ eqn: [Swift.Double], _ res: inout [Swift.Double]) -> Int {
      let d = eqn[3]
      guard Swift.abs(d) > 1e-12 else {
        // Degenerate to quadratic
        return QuadCurve2D.solveQuadratic(eqn, &res)
      }
      let a = eqn[2] / d, b = eqn[1] / d, c = eqn[0] / d
      let p = b - a*a/3
      let q = 2*a*a*a/27 - a*b/3 + c
      let disc = q*q/4 + p*p*p/27
      var nRoots = 0
      if disc > 1e-12 {
        let sqrtDisc = sqrt(disc)
        let u = CubicCurve2D.cbrt(-q/2 + sqrtDisc)
        let v = CubicCurve2D.cbrt(-q/2 - sqrtDisc)
        res.append(u + v - a/3); nRoots = 1
      } else if disc < -1e-12 {
        let m = 2 * sqrt(-p/3)
        let theta = acos(3*q / (p*m)) / 3
        let offset = a / 3
        res.append(m * cos(theta) - offset)
        res.append(m * cos(theta + 2 * .pi/3) - offset)
        res.append(m * cos(theta + 4 * .pi/3) - offset)
        nRoots = 3
      } else {
        let u = CubicCurve2D.cbrt(-q/2)
        res.append(2*u - a/3); res.append(-u - a/3)
        nRoots = 2
      }
      return nRoots
    }

    private static func cbrt(_ x: Swift.Double) -> Swift.Double {
      return x < 0 ? -pow(-x, 1.0/3.0) : pow(x, 1.0/3.0)
    }

    // =========================================================================
    // MARK: - Shape conformance
    // =========================================================================

    public func getBounds() -> java.awt.Rectangle {
      let minX = Swift.min(getX1(), getCtrlX1(), getCtrlX2(), getX2())
      let minY = Swift.min(getY1(), getCtrlY1(), getCtrlY2(), getY2())
      let maxX = Swift.max(getX1(), getCtrlX1(), getCtrlX2(), getX2())
      let maxY = Swift.max(getY1(), getCtrlY1(), getCtrlY2(), getY2())
      return java.awt.Rectangle(Int(minX.rounded(.down)), Int(minY.rounded(.down)),
                                 Int((maxX - minX).rounded(.up)),
                                 Int((maxY - minY).rounded(.up)))
    }

    /// Approximates containment using 32-step adaptive sampling.
    public func contains(_ px: Swift.Double, _ py: Swift.Double) -> Bool {
      // Ray-casting against a sampled polyline approximation
      var crossings = 0
      let steps = 32
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
      let steps = 32
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
