/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(CoreGraphics)
import CoreGraphics

extension java.awt.geom {

  // ---------------------------------------------------------------------------
  // MARK: - Area
  // ---------------------------------------------------------------------------

  /// An area geometry that supports constructive area geometry (CAG) operations:
  /// `add` (union), `subtract`, `intersect`, and `exclusiveOr`.
  ///
  /// Mirrors `java.awt.geom.Area`. Backed by `CGPath` on Apple platforms.
  /// On platforms without CoreGraphics the class is still available but
  /// geometric operations fall back to bounding-box approximations.
  ///
  /// ```swift
  /// let circle = java.awt.geom.Area(java.awt.geom.Ellipse2D.Double(0, 0, 100, 100))
  /// let rect   = java.awt.geom.Area(java.awt.geom.Rectangle2D.Double(50, 0, 100, 100))
  /// circle.add(rect)                // union
  /// ```
  ///
  /// - Since: JavaApi > 0.x (Java 1.2)
  public final class Area: java.awt.Shape {

    // =========================================================================
    // MARK: - Storage
    // =========================================================================

    /// The underlying mutable path (even-odd fill rule, matching Java's default).
    private var _path: CGMutablePath

    // =========================================================================
    // MARK: - Init
    // =========================================================================

    /// Creates an empty `Area`.
    public init() {
      _path = CGMutablePath()
    }

    /// Creates an `Area` from any `Shape`.
    ///
    /// If the shape is a `Path2D` its `cgPath` is used directly; otherwise the
    /// bounding rectangle is used as an approximation.
    public init(_ shape: any java.awt.Shape) {
      if let p = shape as? java.awt.geom.Path2D {
        _path = p.cgPath.mutableCopy() ?? CGMutablePath()
      } else {
        // Fallback: use bounding rectangle
        let b = shape.getBounds()
        let r = CGRect(x: b.x, y: b.y, width: b.width, height: b.height)
        _path = CGMutablePath()
        _path.addRect(r)
      }
    }

    /// Creates an `Area` from a `java.awt.Rectangle`.
    public convenience init(_ rect: java.awt.Rectangle) {
      let r = CGRect(x: rect.x, y: rect.y, width: rect.width, height: rect.height)
      let mp = CGMutablePath()
      mp.addRect(r)
      self.init()
      _path = mp
    }

    // Private init for internal copies
    private init(path: CGMutablePath) {
      _path = path
    }

    // =========================================================================
    // MARK: - CAG operations
    // =========================================================================

    /// Adds (unions) the specified `Area` to this `Area`.
    ///
    /// Mirrors `java.awt.geom.Area.add(Area)`.
    public func add(_ other: Area) {
      let result = CGMutablePath()
      result.addPath(_path)
      result.addPath(other._path)
      // CGPath union via even-odd: simply combine both paths.
      // For a true union we flatten using the pathByUnion helper when available,
      // otherwise combine paths (sufficient for most rendering use-cases).
      if #available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, visionOS 1.0, *) {
        let union = _path.union(other._path, using: .evenOdd)
        _path = union.mutableCopy() ?? result
      } else {
        _path = result
      }
    }

    /// Subtracts the specified `Area` from this `Area`.
    ///
    /// Mirrors `java.awt.geom.Area.subtract(Area)`.
    ///
    /// - Note: On Apple platforms uses `CGPath.subtracting()` (macOS 10.13+, iOS 11.0+).
    ///   On Windows, Linux, FreeBSD this is currently a no-op.
    ///   TODO: Implement platform-independent boolean polygon subtraction.
    public func subtract(_ other: Area) {
      if #available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, visionOS 1.0, *) {
        let diff = _path.subtracting(other._path, using: .evenOdd)
        _path = diff.mutableCopy() ?? CGMutablePath()
      } else {
        // TODO: Implement platform-independent boolean polygon operations
        // Currently no-op on Windows/Linux/FreeBSD platforms.
        // Options:
        // 1. Use external library (Boost.Geometry, clipper-lib, etc.)
        // 2. Implement Sutherland-Hodgman or Weiler-Atherton algorithm
        // See test: Tests/JavApiTests/JavApi_awt_geom_Area_Tests.swift
      }
    }

    /// Sets this `Area` to the intersection with the specified `Area`.
    ///
    /// Mirrors `java.awt.geom.Area.intersect(Area)`.
    public func intersect(_ other: Area) {
      if #available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, visionOS 1.0, *) {
        let intersection = _path.intersection(other._path, using: .evenOdd)
        _path = intersection.mutableCopy() ?? CGMutablePath()
      } else {
        // Fallback: use bounding-box intersection
        let b1 = getBounds()
        let b2 = other.getBounds()
        let ix = Swift.max(b1.x, b2.x)
        let iy = Swift.max(b1.y, b2.y)
        let iw = Swift.min(b1.x + b1.width,  b2.x + b2.width)  - ix
        let ih = Swift.min(b1.y + b1.height, b2.y + b2.height) - iy
        _path = CGMutablePath()
        if iw > 0 && ih > 0 {
          _path.addRect(CGRect(x: ix, y: iy, width: iw, height: ih))
        }
      }
    }

    /// Sets this `Area` to the exclusive-or of itself and the specified `Area`.
    ///
    /// Mirrors `java.awt.geom.Area.exclusiveOr(Area)`.
    public func exclusiveOr(_ other: Area) {
      if #available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, visionOS 1.0, *) {
        let xor = _path.symmetricDifference(other._path, using: .evenOdd)
        _path = xor.mutableCopy() ?? CGMutablePath()
      } else {
        // Fallback: union (approximate)
        add(other)
      }
    }

    // =========================================================================
    // MARK: - Reset / copy
    // =========================================================================

    /// Removes all geometry, making this `Area` empty.
    public func reset() {
      _path = CGMutablePath()
    }

    /// Returns a copy of this `Area`.
    public func createTransformedArea(_ t: java.awt.geom.AffineTransform) -> Area {
      var cgT = t.toCGAffineTransform()
      let transformed = _path.mutableCopy(using: &cgT) ?? CGMutablePath()
      return Area(path: transformed)
    }

    // =========================================================================
    // MARK: - Queries
    // =========================================================================

    /// Returns `true` if this `Area` encloses no area.
    public func isEmpty() -> Bool {
      _path.isEmpty || _path.boundingBoxOfPath == CGRect.null
    }

    /// Returns `true` if this `Area` is rectangular.
    ///
    /// A path from `CGMutablePath.addRect` produces exactly 5 elements:
    /// moveTo + 3× lineTo + closePath.  More elements mean a non-rectangular shape.
    public func isRectangular() -> Bool {
      var count = 0
      var onlyStraight = true
      _path.applyWithBlock { element in
        count += 1
        let t = element.pointee.type
        if t == .addQuadCurveToPoint || t == .addCurveToPoint {
          onlyStraight = false
        }
      }
      // moveTo(1) + lineTo×3(3) + closePath(1) = 5 for a simple rectangle
      return onlyStraight && count == 5
    }

    /// Returns `true` if this `Area` consists of a single polygonal region.
    public func isSingular() -> Bool {
      var moveCount = 0
      _path.applyWithBlock { element in
        if element.pointee.type == .moveToPoint { moveCount += 1 }
      }
      return moveCount <= 1
    }

    // =========================================================================
    // MARK: - Shape
    // =========================================================================

    public func contains(_ x: Swift.Double, _ y: Swift.Double) -> Bool {
      _path.contains(CGPoint(x: CGFloat(x), y: CGFloat(y)), using: .evenOdd)
    }

    public func contains(_ x: Swift.Double, _ y: Swift.Double,
                          _ w: Swift.Double, _ h: Swift.Double) -> Bool {
      let corners = [
        CGPoint(x: CGFloat(x),     y: CGFloat(y)),
        CGPoint(x: CGFloat(x + w), y: CGFloat(y)),
        CGPoint(x: CGFloat(x),     y: CGFloat(y + h)),
        CGPoint(x: CGFloat(x + w), y: CGFloat(y + h)),
      ]
      return corners.allSatisfy { _path.contains($0, using: .evenOdd) }
    }

    public func intersects(_ x: Swift.Double, _ y: Swift.Double,
                            _ w: Swift.Double, _ h: Swift.Double) -> Bool {
      let rect = CGRect(x: CGFloat(x), y: CGFloat(y),
                        width: CGFloat(w), height: CGFloat(h))
      return _path.boundingBoxOfPath.intersects(rect)
    }

    public func getBounds() -> java.awt.Rectangle {
      let b = _path.boundingBoxOfPath
      if b == CGRect.null { return java.awt.Rectangle(0, 0, 0, 0) }
      return java.awt.Rectangle(
        Int(b.origin.x.rounded(.down)),
        Int(b.origin.y.rounded(.down)),
        Int(b.width.rounded(.up)),
        Int(b.height.rounded(.up))
      )
    }

    /// Returns the double-precision bounding box.
    public func getBounds2D() -> java.awt.geom.Rectangle2D {
      let b = _path.boundingBoxOfPath
      if b == CGRect.null {
        return java.awt.geom.Rectangle2D.Double(0, 0, 0, 0)
      }
      return java.awt.geom.Rectangle2D.Double(
        Swift.Double(b.origin.x), Swift.Double(b.origin.y),
        Swift.Double(b.width),    Swift.Double(b.height)
      )
    }

    // =========================================================================
    // MARK: - CGPath access (Apple-platform extension point)
    // =========================================================================

    /// The underlying `CGPath`. Useful for rendering in CoreGraphics contexts.
    public var cgPath: CGPath { _path }
  }
}

// ---------------------------------------------------------------------------
// MARK: - AffineTransform → CGAffineTransform helper
// ---------------------------------------------------------------------------

fileprivate extension java.awt.geom.AffineTransform {
  func toCGAffineTransform() -> CGAffineTransform {
    CGAffineTransform(
      a:  CGFloat(getScaleX()),  b:  CGFloat(getShearY()),
      c:  CGFloat(getShearX()),  d:  CGFloat(getScaleY()),
      tx: CGFloat(getTranslateX()), ty: CGFloat(getTranslateY())
    )
  }
}

#else

// ---------------------------------------------------------------------------
// MARK: - Stub for non-CoreGraphics platforms
// ---------------------------------------------------------------------------

extension java.awt.geom {

  /// Stub implementation of `Area` for platforms without CoreGraphics.
  ///
  /// CAG operations are not available; geometric queries use bounding boxes.
  public final class Area: java.awt.Shape {

    private var _bounds: java.awt.Rectangle

    public init() { _bounds = java.awt.Rectangle(0, 0, 0, 0) }

    public init(_ shape: any java.awt.Shape) {
      _bounds = shape.getBounds()
    }

    public init(_ rect: java.awt.Rectangle) {
      _bounds = rect
    }

    public func add(_ other: Area) {
      let b = other._bounds
      let x = Swift.min(_bounds.x, b.x)
      let y = Swift.min(_bounds.y, b.y)
      let w = Swift.max(_bounds.x + _bounds.width,  b.x + b.width)  - x
      let h = Swift.max(_bounds.y + _bounds.height, b.y + b.height) - y
      _bounds = java.awt.Rectangle(x, y, w, h)
    }

    public func subtract(_ other: Area) { /* no-op on stub */ }

    public func intersect(_ other: Area) {
      let b = other._bounds
      let ix = Swift.max(_bounds.x, b.x)
      let iy = Swift.max(_bounds.y, b.y)
      let iw = Swift.min(_bounds.x + _bounds.width,  b.x + b.width)  - ix
      let ih = Swift.min(_bounds.y + _bounds.height, b.y + b.height) - iy
      _bounds = iw > 0 && ih > 0 ? java.awt.Rectangle(ix, iy, iw, ih)
                                  : java.awt.Rectangle(0, 0, 0, 0)
    }

    public func exclusiveOr(_ other: Area) { add(other) }

    public func reset() { _bounds = java.awt.Rectangle(0, 0, 0, 0) }

    public func isEmpty() -> Bool { _bounds.width <= 0 || _bounds.height <= 0 }
    public func isRectangular() -> Bool { true }
    public func isSingular() -> Bool { true }

    public func createTransformedArea(_ t: java.awt.geom.AffineTransform) -> Area {
      Area(_bounds)
    }

    public func contains(_ x: Swift.Double, _ y: Swift.Double) -> Bool {
      x >= Double(_bounds.x) && y >= Double(_bounds.y) &&
      x <= Double(_bounds.x + _bounds.width) &&
      y <= Double(_bounds.y + _bounds.height)
    }

    public func contains(_ x: Swift.Double, _ y: Swift.Double,
                          _ w: Swift.Double, _ h: Swift.Double) -> Bool {
      contains(x, y) && contains(x + w, y + h)
    }

    public func intersects(_ x: Swift.Double, _ y: Swift.Double,
                            _ w: Swift.Double, _ h: Swift.Double) -> Bool {
      let bx = Double(_bounds.x), by = Double(_bounds.y)
      let bw = Double(_bounds.width), bh = Double(_bounds.height)
      return x < bx + bw && x + w > bx && y < by + bh && y + h > by
    }

    public func getBounds() -> java.awt.Rectangle { _bounds }

    public func getBounds2D() -> java.awt.geom.Rectangle2D {
      java.awt.geom.Rectangle2D.Double(
        Double(_bounds.x), Double(_bounds.y),
        Double(_bounds.width), Double(_bounds.height)
      )
    }
  }
}

#endif
