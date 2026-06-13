/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Testing
@testable import JavApi

@Suite("java.awt.geom — Arc2D / QuadCurve2D / CubicCurve2D")
struct JavApi_awt_geom_Curves_Tests {

  // MARK: - Arc2D

  @Test("Arc2D.Double stores frame and angles")
  func arc2D_storesValues() {
    let arc = java.awt.geom.Arc2D.Double(10, 20, 100, 50, 0, 90, java.awt.geom.Arc2D.PIE)
    #expect(arc.getX() == 10)
    #expect(arc.getY() == 20)
    #expect(arc.getWidth() == 100)
    #expect(arc.getHeight() == 50)
    #expect(arc.getAngleStart() == 0)
    #expect(arc.getAngleExtent() == 90)
    #expect(arc.arcType == java.awt.geom.Arc2D.PIE)
  }

  @Test("Arc2D isEmpty for zero-size frame")
  func arc2D_isEmpty() {
    let arc = java.awt.geom.Arc2D.Double(0, 0, 0, 0, 0, 360, java.awt.geom.Arc2D.OPEN)
    #expect(arc.isEmpty())
  }

  @Test("Arc2D containsAngle within 90-degree sweep")
  func arc2D_containsAngle() {
    let arc = java.awt.geom.Arc2D.Double(0, 0, 100, 100, 0, 90, java.awt.geom.Arc2D.OPEN)
    #expect(arc.containsAngle(45))
    #expect(!arc.containsAngle(180))
  }

  @Test("Arc2D containsAngle for full circle")
  func arc2D_fullCircle_containsAnyAngle() {
    let arc = java.awt.geom.Arc2D.Double(0, 0, 100, 100, 0, 360, java.awt.geom.Arc2D.OPEN)
    #expect(arc.containsAngle(0))
    #expect(arc.containsAngle(179))
    #expect(arc.containsAngle(359))
  }

  @Test("Arc2D getBounds returns non-empty rectangle")
  func arc2D_getBounds() {
    let arc = java.awt.geom.Arc2D.Double(10, 10, 80, 80, 0, 90, java.awt.geom.Arc2D.OPEN)
    let b = arc.getBounds()
    #expect(b.width > 0)
    #expect(b.height > 0)
  }

  @Test("Arc2D.Float constructor and type constants")
  func arc2D_float() {
    let arc = java.awt.geom.Arc2D.Float(0, 0, 50, 50, 0, 180, java.awt.geom.Arc2D.CHORD)
    #expect(arc.arcType == java.awt.geom.Arc2D.CHORD)
    #expect(arc.getAngleExtent() == 180)
  }

  // MARK: - QuadCurve2D

  @Test("QuadCurve2D.Double stores control points")
  func quadCurve_storesPoints() {
    let q = java.awt.geom.QuadCurve2D.Double(0, 0, 50, 100, 100, 0)
    #expect(q.getX1() == 0)
    #expect(q.getY1() == 0)
    #expect(q.getCtrlX() == 50)
    #expect(q.getCtrlY() == 100)
    #expect(q.getX2() == 100)
    #expect(q.getY2() == 0)
  }

  @Test("QuadCurve2D getBounds covers all control points")
  func quadCurve_getBounds() {
    let q = java.awt.geom.QuadCurve2D.Double(0, 0, 50, 100, 100, 0)
    let b = q.getBounds()
    #expect(b.x == 0)
    #expect(b.y == 0)
    #expect(b.width >= 100)
    #expect(b.height >= 100)
  }

  @Test("QuadCurve2D getFlatness for straight line is zero")
  func quadCurve_flatness_straightLine() {
    // Control point on the line between P1 and P2
    let q = java.awt.geom.QuadCurve2D.Double(0, 0, 50, 0, 100, 0)
    #expect(q.getFlatness() < 1e-9)
  }

  @Test("QuadCurve2D solveQuadratic finds two roots")
  func quadCurve_solveQuadratic() {
    // x² - 5x + 6 = 0  →  roots 2 and 3
    var res: [Double] = []
    let n = java.awt.geom.QuadCurve2D.solveQuadratic([6, -5, 1], &res)
    #expect(n == 2)
    let sorted = res.sorted()
    #expect(Swift.abs(sorted[0] - 2) < 1e-9)
    #expect(Swift.abs(sorted[1] - 3) < 1e-9)
  }

  @Test("QuadCurve2D.Float setCurve round-trip")
  func quadCurve_float_setCurve() {
    let q = java.awt.geom.QuadCurve2D.Float()
    q.setCurve(1, 2, 3, 4, 5, 6)
    #expect(q.getX1() == 1)
    #expect(q.getCtrlX() == 3)
    #expect(q.getY2() == 6)
  }

  // MARK: - CubicCurve2D

  @Test("CubicCurve2D.Double stores all control points")
  func cubicCurve_storesPoints() {
    let c = java.awt.geom.CubicCurve2D.Double(0, 0, 25, 100, 75, 100, 100, 0)
    #expect(c.getX1() == 0)
    #expect(c.getCtrlX1() == 25)
    #expect(c.getCtrlX2() == 75)
    #expect(c.getX2() == 100)
  }

  @Test("CubicCurve2D getBounds covers control polygon")
  func cubicCurve_getBounds() {
    let c = java.awt.geom.CubicCurve2D.Double(0, 0, 25, 100, 75, 100, 100, 0)
    let b = c.getBounds()
    #expect(b.x == 0)
    #expect(b.y == 0)
    #expect(b.width >= 100)
    #expect(b.height >= 100)
  }

  @Test("CubicCurve2D solveCubic finds three real roots")
  func cubicCurve_solveCubic_threeRoots() {
    // (x-1)(x-2)(x-3) = x³ - 6x² + 11x - 6
    var res: [Double] = []
    let n = java.awt.geom.CubicCurve2D.solveCubic([-6, 11, -6, 1], &res)
    #expect(n == 3)
    let sorted = res.sorted()
    #expect(Swift.abs(sorted[0] - 1) < 1e-6)
    #expect(Swift.abs(sorted[1] - 2) < 1e-6)
    #expect(Swift.abs(sorted[2] - 3) < 1e-6)
  }

  @Test("CubicCurve2D.Float setCurve round-trip")
  func cubicCurve_float_setCurve() {
    let c = java.awt.geom.CubicCurve2D.Float()
    c.setCurve(1, 2, 3, 4, 5, 6, 7, 8)
    #expect(c.getX1() == 1)
    #expect(c.getCtrlX1() == 3)
    #expect(c.getCtrlX2() == 5)
    #expect(c.getX2() == 7)
  }
}
