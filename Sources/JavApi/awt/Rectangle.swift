/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.awt {
  
  // ---------------------------------------------------------------------------
  // MARK: - Rectangle
  // ---------------------------------------------------------------------------
  
  /// An integer-precision rectangle specifying an area in a coordinate space.
  ///
  /// Mirrors `java.awt.Rectangle`, which also implements
  /// `java.awt.Shape` and `java.awt.geom.RectangularShape`.
  ///
  /// ```swift
  /// let r = Java.awt.Rectangle(10, 20, 200, 100)
  /// print(r.width)          // → 200
  /// print(r.contains(15, 25)) // → true
  /// ```
  public class Rectangle: Equatable {
    
    // -------------------------------------------------------------------------
    // MARK: Fields  (Java field names kept for porting fidelity)
    // -------------------------------------------------------------------------
    
    public var x:      Int
    public var y:      Int
    public var width:  Int
    public var height: Int
    
    // =========================================================================
    // MARK: - Constructors
    // =========================================================================
    
    /// Creates a rectangle at (0, 0) with zero size.
    @MainActor public static let zero = Rectangle(0, 0, 0, 0)
    
    /// Creates a rectangle with the given origin and size.
    public init(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {
      self.x      = x
      self.y      = y
      self.width  = width
      self.height = height
    }
    
    /// Creates a rectangle at (0, 0) with the given size.
    public convenience init(_ width: Int, _ height: Int) {
      self.init(0, 0, width, height)
    }
    
    /// Creates a zero rectangle at origin (0, 0).
    public convenience init() {
      self.init(0, 0, 0, 0)
    }
    
    // =========================================================================
    // MARK: - Geometry
    // =========================================================================
    
    /// Returns the x-coordinate of the right edge.
    public var maxX: Int { x + width }
    
    /// Returns the y-coordinate of the bottom edge.
    public var maxY: Int { y + height }
    
    /// Returns `true` if the rectangle has zero area.
    public func isEmpty() -> Bool { width <= 0 || height <= 0 }
    
    /// Returns the location (top-left corner) as a `Java.awt.Point`.
    public func getLocation() -> java.awt.Point {
      java.awt.Point(x, y)
    }
    
    /// Sets the location to the given point.
    public func setLocation(_ p: java.awt.Point) {
      x = p.x; y = p.y
    }
    
    /// Sets the location to `(x, y)`.
    public func setLocation(_ x: Int, _ y: Int) {
      self.x = x; self.y = y
    }
    
    /// Returns the size as a `Java.awt.Dimension`.
    public func getSize() -> java.awt.Dimension {
      java.awt.Dimension(width, height)
    }
    
    /// Sets the size from a `Java.awt.Dimension`.
    public func setSize(_ d: java.awt.Dimension) {
      width = d.width; height = d.height
    }
    
    /// Sets the size to `(width, height)`.
    public func setSize(_ width: Int, _ height: Int) {
      self.width = width; self.height = height
    }
    
    /// Moves the rectangle to `(x, y)` — alias for `setLocation`.
    public func move(_ x: Int, _ y: Int) {
      setLocation(x, y)
    }
    
    /// Resizes the rectangle — alias for `setSize`.
    public func resize(_ width: Int, _ height: Int) {
      setSize(width, height)
    }
    
    /// Repositions and resizes in one call.
    public func reshape(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {
      self.x = x; self.y = y; self.width = width; self.height = height
    }
    
    // =========================================================================
    // MARK: - Hit testing
    // =========================================================================
    
    /// Returns `true` if `(px, py)` lies inside (or on the edge of) this rectangle.
    public func contains(_ px: Int, _ py: Int) -> Bool {
      guard !isEmpty() else { return false }
      return px >= x && px < maxX && py >= y && py < maxY
    }
    
    /// Returns `true` if `point` lies inside this rectangle.
    public func contains(_ point: java.awt.Point) -> Bool {
      contains(point.x, point.y)
    }
    
    /// Returns `true` if the given rectangle is entirely inside this rectangle.
    public func contains(_ rect: Rectangle) -> Bool {
      guard !isEmpty(), !rect.isEmpty() else { return false }
      return rect.x >= x && rect.y >= y
      && rect.maxX <= maxX && rect.maxY <= maxY
    }
    
    /// Returns `true` if this rectangle intersects `rect`.
    public func intersects(_ rect: Rectangle) -> Bool {
      guard !isEmpty(), !rect.isEmpty() else { return false }
      return rect.x < maxX && rect.maxX > x
      && rect.y < maxY && rect.maxY > y
    }
    
    // =========================================================================
    // MARK: - Set operations
    // =========================================================================
    
    /// Returns the intersection of this rectangle and `rect`.
    /// If they do not intersect, returns an empty rectangle.
    public func intersection(_ rect: Rectangle) -> Rectangle {
      let ix = Swift.max(x, rect.x)
      let iy = Swift.max(y, rect.y)
      let iw = Swift.min(maxX, rect.maxX) - ix
      let ih = Swift.min(maxY, rect.maxY) - iy
      return iw > 0 && ih > 0 ? Rectangle(ix, iy, iw, ih) : Rectangle()
    }
    
    /// Returns the smallest rectangle that contains both this rectangle and `rect`.
    public func union(_ rect: Rectangle) -> Rectangle {
      if isEmpty() { return rect }
      if rect.isEmpty() { return self }
      let ux = Swift.min(x, rect.x)
      let uy = Swift.min(y, rect.y)
      let uw = Swift.max(maxX, rect.maxX) - ux
      let uh = Swift.max(maxY, rect.maxY) - uy
      return Rectangle(ux, uy, uw, uh)
    }
    
    /// Expands this rectangle to include the point `(px, py)`.
    public func add(_ px: Int, _ py: Int) {
      let r = union(Rectangle(px, py, 0, 0))
      reshape(r.x, r.y, r.width, r.height)
    }
    
    /// Expands this rectangle to include `point`.
    public func add(_ point: java.awt.Point) { add(point.x, point.y) }
    
    /// Expands this rectangle to include `rect`.
    public func add(_ rect: Rectangle) {
      let r = union(rect)
      reshape(r.x, r.y, r.width, r.height)
    }
    
    /// Grows this rectangle by `h` horizontally and `v` vertically on each side.
    public func grow(_ h: Int, _ v: Int) {
      x      -= h; y      -= v
      width  += 2 * h
      height += 2 * v
    }
    
    // =========================================================================
    // MARK: - Equatable
    // =========================================================================
    
    public static func == (lhs: Rectangle, rhs: Rectangle) -> Bool {
      lhs.x == rhs.x && lhs.y == rhs.y
      && lhs.width == rhs.width && lhs.height == rhs.height
    }
  }
}
