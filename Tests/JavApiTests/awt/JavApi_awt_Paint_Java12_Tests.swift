/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Testing
@testable import JavApi

// =============================================================================
// MARK: - GradientPaint
// =============================================================================

@Suite("java.awt.GradientPaint")
struct JavApi_awt_GradientPaint_Tests {

  @Test("Float-coordinate convenience init is acyclic and stores points/colors")
  func floatInitAcyclic() {
    let red = java.awt.Color(255, 0, 0)
    let blue = java.awt.Color(0, 0, 255)
    let gp = java.awt.GradientPaint(0, 0, red, 10, 10, blue)

    #expect(gp.getPoint1().getX() == 0)
    #expect(gp.getPoint1().getY() == 0)
    #expect(gp.getPoint2().getX() == 10)
    #expect(gp.getPoint2().getY() == 10)
    #expect(gp.getColor1() === red)
    #expect(gp.getColor2() === blue)
    #expect(gp.isCyclic() == false)
  }

  @Test("Float-coordinate convenience init honours explicit cyclic flag")
  func floatInitCyclic() {
    let red = java.awt.Color(255, 0, 0)
    let blue = java.awt.Color(0, 0, 255)
    let gp = java.awt.GradientPaint(0, 0, red, 10, 10, blue, true)

    #expect(gp.isCyclic() == true)
  }

  @Test("Point2D convenience init is acyclic")
  func point2DInitAcyclic() {
    let red = java.awt.Color(255, 0, 0)
    let blue = java.awt.Color(0, 0, 255)
    let p1 = java.awt.geom.Point2D.Double(1, 2)
    let p2 = java.awt.geom.Point2D.Double(3, 4)
    let gp = java.awt.GradientPaint(p1, red, p2, blue)

    #expect(gp.getPoint1().getX() == 1)
    #expect(gp.getPoint1().getY() == 2)
    #expect(gp.getPoint2().getX() == 3)
    #expect(gp.getPoint2().getY() == 4)
    #expect(gp.isCyclic() == false)
  }

  @Test("Designated Point2D init stores the cyclic flag")
  func point2DInitCyclic() {
    let red = java.awt.Color(255, 0, 0)
    let blue = java.awt.Color(0, 0, 255)
    let p1 = java.awt.geom.Point2D.Double(0, 0)
    let p2 = java.awt.geom.Point2D.Double(5, 0)
    let gp = java.awt.GradientPaint(p1, red, p2, blue, true)

    #expect(gp.isCyclic() == true)
  }

  @Test("getTransparency is OPAQUE when both endpoint colors are fully opaque")
  func transparencyOpaque() {
    let red = java.awt.Color(255, 0, 0)
    let blue = java.awt.Color(0, 0, 255)
    let gp = java.awt.GradientPaint(0, 0, red, 10, 10, blue)

    #expect(gp.getTransparency() == java.awt.Color.OPAQUE)
  }

  @Test("getTransparency is TRANSLUCENT when either endpoint color has alpha < 255")
  func transparencyTranslucent() {
    let red = java.awt.Color(255, 0, 0)
    let translucentBlue = java.awt.Color(0, 0, 255, 128)
    let gp = java.awt.GradientPaint(0, 0, red, 10, 10, translucentBlue)

    #expect(gp.getTransparency() == java.awt.Color.TRANSLUCENT)
  }
}

// =============================================================================
// MARK: - TexturePaint
// =============================================================================

@Suite("java.awt.TexturePaint")
struct JavApi_awt_TexturePaint_Tests {

  @Test("stores the image and anchor rectangle, returning them unchanged")
  func imageAndAnchor() {
    let image = java.awt.image.BufferedImage(4, 4, java.awt.image.BufferedImage.TYPE_INT_ARGB)
    let anchor = java.awt.geom.Rectangle2D.Double(1, 2, 4, 4)
    let tp = java.awt.TexturePaint(image, anchor)

    #expect(tp.getImage() === image)
    #expect(tp.getAnchorRect().getX() == 1)
    #expect(tp.getAnchorRect().getY() == 2)
    #expect(tp.getAnchorRect().getWidth() == 4)
    #expect(tp.getAnchorRect().getHeight() == 4)
  }

  @Test("getTransparency reports TRANSLUCENT (conservative, ColorModel has no transparency query)")
  func transparency() {
    let image = java.awt.image.BufferedImage(2, 2, java.awt.image.BufferedImage.TYPE_INT_ARGB)
    let anchor = java.awt.geom.Rectangle2D.Double(0, 0, 2, 2)
    let tp = java.awt.TexturePaint(image, anchor)

    #expect(tp.getTransparency() == java.awt.Color.TRANSLUCENT)
  }
}
