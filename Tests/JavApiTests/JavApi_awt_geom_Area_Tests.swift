/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Testing
@testable import JavApi

@Suite("java.awt.geom.Area")
struct JavApi_awt_geom_Area_Tests {

  // MARK: - init / isEmpty

  @Test("empty Area is empty")
  func emptyArea_isEmpty() {
    let area = java.awt.geom.Area()
    #expect(area.isEmpty())
  }

  @Test("Area from rectangle is not empty")
  func areaFromRect_isNotEmpty() {
    let rect = java.awt.geom.Rectangle2D.Double(0, 0, 100, 100)
    let area = java.awt.geom.Area(rect)
    #expect(!area.isEmpty())
  }

  // MARK: - contains

  @Test("contains point inside rectangle area")
  func contains_pointInside() {
    let rect = java.awt.geom.Rectangle2D.Double(0, 0, 100, 100)
    let area = java.awt.geom.Area(rect)
    #expect(area.contains(50, 50))
  }

  @Test("does not contain point outside rectangle area")
  func contains_pointOutside() {
    let rect = java.awt.geom.Rectangle2D.Double(0, 0, 100, 100)
    let area = java.awt.geom.Area(rect)
    #expect(!area.contains(150, 150))
  }

  // MARK: - add (union)

  @Test("add expands bounds")
  func add_expandsBounds() {
    let a = java.awt.geom.Area(java.awt.geom.Rectangle2D.Double(0, 0, 50, 50))
    let b = java.awt.geom.Area(java.awt.geom.Rectangle2D.Double(50, 0, 50, 50))
    a.add(b)
    // After union the combined area should contain points from both halves
    #expect(a.contains(25, 25))
    #expect(a.contains(75, 25))
  }

  // MARK: - intersect

  @Test("intersect reduces to overlapping region")
  func intersect_reducesToOverlap() {
    let a = java.awt.geom.Area(java.awt.geom.Rectangle2D.Double(0, 0, 60, 60))
    let b = java.awt.geom.Area(java.awt.geom.Rectangle2D.Double(40, 40, 60, 60))
    a.intersect(b)
    // Overlap is (40,40)-(60,60)
    #expect(a.contains(50, 50))
    #expect(!a.isEmpty())
  }

  @Test("intersect with non-overlapping area yields empty")
  func intersect_noOverlap_isEmpty() {
    let a = java.awt.geom.Area(java.awt.geom.Rectangle2D.Double(0, 0, 40, 40))
    let b = java.awt.geom.Area(java.awt.geom.Rectangle2D.Double(60, 60, 40, 40))
    a.intersect(b)
    #expect(a.isEmpty())
  }

  // MARK: - subtract

  #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
  @Test("subtract removes overlapping region")
  func subtract_removesOverlap() {
    let a = java.awt.geom.Area(java.awt.geom.Rectangle2D.Double(0, 0, 100, 100))
    let b = java.awt.geom.Area(java.awt.geom.Rectangle2D.Double(50, 0, 50, 100))
    a.subtract(b)
    // Left half should still be there, right half removed
    #expect(a.contains(25, 50))
    #expect(!a.contains(75, 50))
  }
  #else
  // TODO: Implement platform-independent Area.subtract() for Windows/Linux/FreeBSD
  //
  // Currently Area.subtract() is only implemented on Apple platforms (macOS, iOS, tvOS,
  // watchOS, visionOS) using CoreGraphics. On Windows, Linux, and FreeBSD it's a no-op.
  //
  // Area needs support via one of:
  // 1. External geometry library (e.g., Boost.Geometry, clipper-lib)
  // 2. Custom boolean polygon operations (Sutherland-Hodgman, Weiler-Atherton)
  //
  // Other affected methods: Area.intersect(), Area.exclusiveOr()
  // See: Sources/JavApi/awt/geom/Area.swift
  #endif

  // MARK: - reset

  @Test("reset makes area empty")
  func reset_makesEmpty() {
    let a = java.awt.geom.Area(java.awt.geom.Rectangle2D.Double(0, 0, 100, 100))
    a.reset()
    #expect(a.isEmpty())
  }

  // MARK: - getBounds

  @Test("getBounds returns correct integer bounds")
  func getBounds_correctBounds() {
    let a = java.awt.geom.Area(java.awt.geom.Rectangle2D.Double(10, 20, 80, 60))
    let b = a.getBounds()
    #expect(b.x == 10)
    #expect(b.y == 20)
    #expect(b.width == 80)
    #expect(b.height == 60)
  }

  // MARK: - isRectangular / isSingular

  @Test("rectangular area isRectangular")
  func isRectangular_trueForRect() {
    let a = java.awt.geom.Area(java.awt.geom.Rectangle2D.Double(0, 0, 50, 50))
    #expect(a.isRectangular())
  }

  @Test("single-shape area isSingular")
  func isSingular_trueForSingleShape() {
    let a = java.awt.geom.Area(java.awt.geom.Rectangle2D.Double(0, 0, 50, 50))
    #expect(a.isSingular())
  }
}
