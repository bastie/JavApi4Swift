/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  // ---------------------------------------------------------------------------
  // MARK: - Polygon
  // ---------------------------------------------------------------------------

  /// A closed polygon defined by a sequence of (x, y) vertices.
  ///
  /// Mirrors `java.awt.Polygon` from Java 1.0.
  ///
  /// ```swift
  /// let p = java.awt.Polygon(
  ///     xpoints: [10, 50, 30],
  ///     ypoints: [80, 80, 20],
  ///     npoints: 3)
  /// print(p.contains(30, 60))  // → true
  /// ```
  ///
  /// - Since: Java 1.0
  public class Polygon: Shape {

    // -------------------------------------------------------------------------
    // MARK: Public fields (Java field names kept for porting fidelity)
    // -------------------------------------------------------------------------

    /// Number of vertices that are valid in `xpoints` and `ypoints`.
    public var npoints: Int

    /// X-coordinates of the vertices.
    public var xpoints: [Int]

    /// Y-coordinates of the vertices.
    public var ypoints: [Int]

    /// Cached bounding box, invalidated whenever the polygon changes.
    public private(set) var bounds: java.awt.Rectangle? = nil

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    /// Creates an empty polygon with no vertices.
    public init() {
      npoints = 0
      xpoints = []
      ypoints = []
    }

    /// Creates a polygon from the given vertex arrays.
    ///
    /// - Parameters:
    ///   - xpoints: Array of X-coordinates.
    ///   - ypoints: Array of Y-coordinates.
    ///   - npoints: Number of valid entries in the arrays (must be ≤ array lengths).
    public init(xpoints: [Int], ypoints: [Int], npoints: Int) {
      precondition(npoints <= xpoints.count && npoints <= ypoints.count,
                   "npoints exceeds array length")
      self.npoints = npoints
      self.xpoints = xpoints
      self.ypoints = ypoints
    }

    // -------------------------------------------------------------------------
    // MARK: Vertex manipulation
    // -------------------------------------------------------------------------

    /// Appends a vertex at `(x, y)` and invalidates the cached bounding box.
    public func addPoint(_ x: Int, _ y: Int) {
      xpoints.append(x)
      ypoints.append(y)
      npoints += 1
      bounds = nil
    }

    /// Moves the polygon by `(dx, dy)`.
    public func translate(_ dx: Int, _ dy: Int) {
      for i in 0..<npoints {
        xpoints[i] += dx
        ypoints[i] += dy
      }
      bounds = nil
    }

    /// Resets all vertices.
    public func reset() {
      npoints = 0
      xpoints = []
      ypoints = []
      bounds = nil
    }

    // -------------------------------------------------------------------------
    // MARK: Shape — bounding box
    // -------------------------------------------------------------------------

    /// Returns the axis-aligned bounding box of the polygon.
    public func getBounds() -> java.awt.Rectangle {
      if let cached = bounds { return cached }
      guard npoints > 0 else {
        let r = java.awt.Rectangle(0, 0, 0, 0)
        bounds = r
        return r
      }
      var minX = xpoints[0], maxX = xpoints[0]
      var minY = ypoints[0], maxY = ypoints[0]
      for i in 1..<npoints {
        minX = Swift.min(minX, xpoints[i])
        maxX = Swift.max(maxX, xpoints[i])
        minY = Swift.min(minY, ypoints[i])
        maxY = Swift.max(maxY, ypoints[i])
      }
      let r = java.awt.Rectangle(minX, minY, maxX - minX, maxY - minY)
      bounds = r
      return r
    }

    // -------------------------------------------------------------------------
    // MARK: Shape — hit testing
    // -------------------------------------------------------------------------

    /// Returns `true` if the point `(x, y)` is inside the polygon.
    ///
    /// Uses the ray-casting algorithm (even-odd rule), matching Java's behaviour.
    public func contains(_ px: Double, _ py: Double) -> Bool {
      guard npoints >= 3 else { return false }
      var inside = false
      var j = npoints - 1
      for i in 0..<npoints {
        let xi = Double(xpoints[i]), yi = Double(ypoints[i])
        let xj = Double(xpoints[j]), yj = Double(ypoints[j])
        if ((yi > py) != (yj > py)) &&
           (px < (xj - xi) * (py - yi) / (yj - yi) + xi) {
          inside.toggle()
        }
        j = i
      }
      return inside
    }

    /// Returns `true` if the integer point `(x, y)` is inside the polygon.
    public func contains(_ x: Int, _ y: Int) -> Bool {
      contains(Double(x), Double(y))
    }

    /// Returns `true` if `(x, y, w, h)` lies entirely inside the polygon.
    public func contains(_ x: Double, _ y: Double,
                         _ w: Double, _ h: Double) -> Bool {
      contains(x, y) &&
      contains(x + w, y) &&
      contains(x, y + h) &&
      contains(x + w, y + h)
    }

    /// Returns `true` if the bounding boxes intersect (fast conservative test).
    public func intersects(_ x: Double, _ y: Double,
                           _ w: Double, _ h: Double) -> Bool {
      let b = getBounds()
      return !(x + w < Double(b.x) ||
               x > Double(b.x + b.width) ||
               y + h < Double(b.y) ||
               y > Double(b.y + b.height))
    }
  }
}
