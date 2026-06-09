/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(CoreGraphics)
import CoreGraphics
#endif

// ---------------------------------------------------------------------------
// MARK: - Concrete Path2D subclasses (defined OUTSIDE Path2D to avoid
//         name-shadowing of Swift.Double / Swift.Float inside Path2D)
// ---------------------------------------------------------------------------

extension java.awt.geom {

  /// `Path2D` with double-precision coordinates.
  ///
  /// Mirrors `java.awt.geom.Path2D.Double`.
  public final class Path2DDouble: Path2D {
    public override init(windingRule: Int = Path2D.WIND_NON_ZERO) {
      super.init(windingRule: windingRule)
    }
    public override init(_ other: Path2D) { super.init(other) }
  }

  /// `Path2D` with single-precision coordinates.
  ///
  /// Coordinates are widened to `Swift.Double` internally.
  /// Mirrors `java.awt.geom.Path2D.Float`.
  public class Path2DFloat: Path2D {
    public override init(windingRule: Int = Path2D.WIND_NON_ZERO) {
      super.init(windingRule: windingRule)
    }
    public override init(_ other: Path2D) { super.init(other) }

    public func moveTo(_ x: Swift.Float, _ y: Swift.Float) {
      super.moveTo(Swift.Double(x), Swift.Double(y))
    }
    public func lineTo(_ x: Swift.Float, _ y: Swift.Float) {
      super.lineTo(Swift.Double(x), Swift.Double(y))
    }
    public func quadTo(_ cx: Swift.Float, _ cy: Swift.Float,
                       _ x:  Swift.Float, _ y:  Swift.Float) {
      super.quadTo(Swift.Double(cx), Swift.Double(cy),
                   Swift.Double(x),  Swift.Double(y))
    }
    public func curveTo(_ cx1: Swift.Float, _ cy1: Swift.Float,
                        _ cx2: Swift.Float, _ cy2: Swift.Float,
                        _ x:   Swift.Float, _ y:   Swift.Float) {
      super.curveTo(Swift.Double(cx1), Swift.Double(cy1),
                    Swift.Double(cx2), Swift.Double(cy2),
                    Swift.Double(x),   Swift.Double(y))
    }
  }
}

// ---------------------------------------------------------------------------
// MARK: - Path2D
// ---------------------------------------------------------------------------

extension java.awt.geom {

  /// A general geometric path, storing a sequence of segments.
  ///
  /// Mirrors `java.awt.geom.Path2D`. Use the concrete subtypes
  /// `Path2D.Double` (`Path2DDouble`) or `Path2D.Float` (`Path2DFloat`).
  ///
  /// ```swift
  /// let path = java.awt.geom.Path2D.Double()
  /// path.moveTo(10, 20)
  /// path.lineTo(50, 20)
  /// path.lineTo(30, 60)
  /// path.closePath()
  /// ```
  ///
  /// - Since: JavaApi > 0.x (Java 1.6)
  public class Path2D: java.awt.Shape {

    // =========================================================================
    // MARK: - Winding-rule constants
    // =========================================================================

    /// Non-zero winding rule.
    public static let WIND_NON_ZERO: Int = 0
    /// Even-odd winding rule.
    public static let WIND_EVEN_ODD: Int = 1

    // =========================================================================
    // MARK: - Java-compatible inner-type aliases
    // =========================================================================

    /// `Path2D.Double` — Java-compatible name for `Path2DDouble`.
    public typealias Double = Path2DDouble
    /// `Path2D.Float` — Java-compatible name for `Path2DFloat`.
    public typealias Float  = Path2DFloat

    // =========================================================================
    // MARK: - Segment storage  (uses Swift.Double internally)
    // =========================================================================

    struct Segment {
      enum Kind {
        case moveTo(Swift.Double, Swift.Double)
        case lineTo(Swift.Double, Swift.Double)
        case quadTo(Swift.Double, Swift.Double, Swift.Double, Swift.Double)
        case curveTo(Swift.Double, Swift.Double, Swift.Double, Swift.Double,
                     Swift.Double, Swift.Double)
        case close
      }
      let kind: Kind
    }

    var segments: [Segment] = []

    /// The winding rule used for `contains` tests.
    public private(set) var windingRule: Int

    // =========================================================================
    // MARK: - Init
    // =========================================================================

    public init(windingRule: Int = WIND_NON_ZERO) {
      self.windingRule = windingRule
    }

    /// Copy constructor.
    public init(_ other: Path2D) {
      self.windingRule = other.windingRule
      self.segments    = other.segments
    }

    // =========================================================================
    // MARK: - Path building
    // =========================================================================

    public func moveTo(_ x: Swift.Double, _ y: Swift.Double) {
      segments.append(Segment(kind: .moveTo(x, y)))
    }

    public func lineTo(_ x: Swift.Double, _ y: Swift.Double) {
      segments.append(Segment(kind: .lineTo(x, y)))
    }

    public func quadTo(_ cx: Swift.Double, _ cy: Swift.Double,
                       _ x:  Swift.Double, _ y:  Swift.Double) {
      segments.append(Segment(kind: .quadTo(cx, cy, x, y)))
    }

    public func curveTo(_ cx1: Swift.Double, _ cy1: Swift.Double,
                        _ cx2: Swift.Double, _ cy2: Swift.Double,
                        _ x:   Swift.Double, _ y:   Swift.Double) {
      segments.append(Segment(kind: .curveTo(cx1, cy1, cx2, cy2, x, y)))
    }

    public func closePath() {
      segments.append(Segment(kind: .close))
    }

    /// Appends all segments from `shape`.
    ///
    /// When `connect` is `true` and the path is non-empty, the first moveTo of
    /// `shape` is converted to a lineTo so the paths join seamlessly.
    public func append(_ shape: any java.awt.Shape, connect: Bool) {
      guard let other = shape as? Path2D else { return }
      var first = true
      for seg in other.segments {
        if first && connect && !segments.isEmpty {
          if case .moveTo(let x, let y) = seg.kind {
            segments.append(Segment(kind: .lineTo(x, y)))
            first = false
            continue
          }
        }
        first = false
        segments.append(seg)
      }
    }

    public func reset() {
      segments.removeAll()
    }

    // =========================================================================
    // MARK: - Shape
    // =========================================================================

    public func getBounds() -> java.awt.Rectangle {
      let b = _bounds
      return java.awt.Rectangle(
        Int(b.minX.rounded(.down)),
        Int(b.minY.rounded(.down)),
        Int(b.width.rounded(.up)),
        Int(b.height.rounded(.up)))
    }

    public func contains(_ px: Swift.Double, _ py: Swift.Double) -> Bool {
#if canImport(CoreGraphics)
      let rule: CGPathFillRule = windingRule == Path2D.WIND_EVEN_ODD ? .evenOdd : .winding
      return cgPath.contains(CGPoint(x: px, y: py), using: rule)
#else
      return _bounds.contains(x: px, y: py)
#endif
    }

    public func contains(_ x: Swift.Double, _ y: Swift.Double,
                          _ w: Swift.Double, _ h: Swift.Double) -> Bool {
#if canImport(CoreGraphics)
      let rule: CGPathFillRule = .winding
      let box = cgPath.boundingBoxOfPath
      let rect = CGRect(x: x, y: y, width: w, height: h)
      guard box.contains(rect) else { return false }
      return cgPath.contains(CGPoint(x: x,     y: y),     using: rule) &&
             cgPath.contains(CGPoint(x: x + w, y: y),     using: rule) &&
             cgPath.contains(CGPoint(x: x,     y: y + h), using: rule) &&
             cgPath.contains(CGPoint(x: x + w, y: y + h), using: rule)
#else
      let b = _bounds
      return b.contains(x: x, y: y) && b.contains(x: x + w, y: y + h)
#endif
    }

    public func intersects(_ x: Swift.Double, _ y: Swift.Double,
                            _ w: Swift.Double, _ h: Swift.Double) -> Bool {
#if canImport(CoreGraphics)
      return cgPath.boundingBoxOfPath
        .intersects(CGRect(x: x, y: y, width: w, height: h))
#else
      let b = _bounds
      return b.maxX > x && b.minX < x + w && b.maxY > y && b.minY < y + h
#endif
    }

    // =========================================================================
    // MARK: - Bounds helper
    // =========================================================================

    private struct BBox {
      var minX, minY, maxX, maxY: Swift.Double
      var width:  Swift.Double { maxX - minX }
      var height: Swift.Double { maxY - minY }
      func contains(x: Swift.Double, y: Swift.Double) -> Bool {
        x >= minX && x <= maxX && y >= minY && y <= maxY
      }
    }

    private var _bounds: BBox {
      var xs: [Swift.Double] = []
      var ys: [Swift.Double] = []
      for seg in segments {
        switch seg.kind {
        case .moveTo(let x, let y), .lineTo(let x, let y):
          xs.append(x); ys.append(y)
        case .quadTo(let cx, let cy, let x, let y):
          xs.append(contentsOf: [cx, x]); ys.append(contentsOf: [cy, y])
        case .curveTo(let cx1, let cy1, let cx2, let cy2, let x, let y):
          xs.append(contentsOf: [cx1, cx2, x])
          ys.append(contentsOf: [cy1, cy2, y])
        case .close:
          break
        }
      }
      guard let minX = xs.min(), let maxX = xs.max(),
            let minY = ys.min(), let maxY = ys.max() else {
        return BBox(minX: 0, minY: 0, maxX: 0, maxY: 0)
      }
      return BBox(minX: minX, minY: minY, maxX: maxX, maxY: maxY)
    }

    // =========================================================================
    // MARK: - CoreGraphics bridge
    // =========================================================================

#if canImport(CoreGraphics)
    /// Returns a `CGPath` built from the stored segments.
    public var cgPath: CGPath {
      let p = CGMutablePath()
      for seg in segments {
        switch seg.kind {
        case .moveTo(let x, let y):
          p.move(to: CGPoint(x: CGFloat(x), y: CGFloat(y)))
        case .lineTo(let x, let y):
          p.addLine(to: CGPoint(x: CGFloat(x), y: CGFloat(y)))
        case .quadTo(let cx, let cy, let x, let y):
          p.addQuadCurve(to:      CGPoint(x: CGFloat(x),  y: CGFloat(y)),
                         control: CGPoint(x: CGFloat(cx), y: CGFloat(cy)))
        case .curveTo(let cx1, let cy1, let cx2, let cy2, let x, let y):
          p.addCurve(to:      CGPoint(x: CGFloat(x),   y: CGFloat(y)),
                    control1: CGPoint(x: CGFloat(cx1), y: CGFloat(cy1)),
                    control2: CGPoint(x: CGFloat(cx2), y: CGFloat(cy2)))
        case .close:
          p.closeSubpath()
        }
      }
      return p
    }
#endif
  }
}

// ---------------------------------------------------------------------------
// MARK: - GeneralPath (Java legacy alias for Path2D.Float)
// ---------------------------------------------------------------------------

extension java.awt.geom {

  /// A general geometric path — Java's legacy name for `Path2D.Float`.
  ///
  /// Mirrors `java.awt.geom.GeneralPath`. Prefer `Path2D.Double` for new code.
  ///
  /// - Since: JavaApi > 0.x (Java 1.2)
  public final class GeneralPath: Path2DFloat {

    public override init(windingRule: Int = Path2D.WIND_NON_ZERO) {
      super.init(windingRule: windingRule)
    }

    public override init(_ other: Path2D) { super.init(other) }

    /// Creates a `GeneralPath` from an existing `Shape` by appending it.
    public convenience init(shape: any java.awt.Shape) {
      self.init()
      append(shape, connect: false)
    }
  }
}
