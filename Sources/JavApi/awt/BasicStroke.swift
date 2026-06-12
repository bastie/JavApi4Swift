/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(CoreGraphics)
import CoreGraphics
#endif

extension java.awt {

  // ---------------------------------------------------------------------------
  // MARK: - BasicStroke
  // ---------------------------------------------------------------------------
  
  /// Defines the rendering attributes for the outline of a shape.
  ///
  /// Mirrors `java.awt.BasicStroke`.  On Apple platforms the stroke attributes
  /// map directly onto `CGContext` line-rendering calls; see
  /// `Graphics2D.setStroke(_:)` for how they are applied.
  ///
  /// ```swift
  /// let stroke = Java.awt.BasicStroke(
  ///     2.5,
  ///     cap:  .round,
  ///     join: .miter,
  ///     miterLimit: 10.0,
  ///     dash: [6.0, 3.0],
  ///     dashPhase: 0.0)
  /// g2d.setStroke(stroke)
  /// ```
  ///
  /// - Since: Java 1.2
  public final class BasicStroke: java.awt.Stroke {
    
    // =========================================================================
    // MARK: - Cap styles  (java.awt.BasicStroke constants)
    // =========================================================================
    
    public enum Cap: Int {
      /// Ends unclosed sub-paths with no added decoration.
      case butt   = 0   // BasicStroke.CAP_BUTT
                        /// Ends unclosed sub-paths with a round decoration.
      case round  = 1   // BasicStroke.CAP_ROUND
                        /// Ends unclosed sub-paths with a square projection.
      case square = 2   // BasicStroke.CAP_SQUARE
      
#if canImport(CoreGraphics)
      var cgLineCap: CGLineCap {
        switch self {
        case .butt:   return .butt
        case .round:  return .round
        case .square: return .square
        }
      }
#endif
    }
    
    // =========================================================================
    // MARK: - Join styles
    // =========================================================================
    
    public enum Join: Int {
      /// Joins path segments with a sharp (mitered) corner.
      case miter = 0   // BasicStroke.JOIN_MITER
                       /// Joins path segments with a round corner.
      case round = 1   // BasicStroke.JOIN_ROUND
                       /// Joins path segments by connecting the outer corners with a straight line.
      case bevel = 2   // BasicStroke.JOIN_BEVEL
      
#if canImport(CoreGraphics)
      var cgLineJoin: CGLineJoin {
        switch self {
        case .miter: return .miter
        case .round: return .round
        case .bevel: return .bevel
        }
      }
#endif
    }
    
    // =========================================================================
    // MARK: - Java integer constants (for source-level porting compatibility)
    // =========================================================================
    
    public static let CAP_BUTT   = 0
    public static let CAP_ROUND  = 1
    public static let CAP_SQUARE = 2
    
    public static let JOIN_MITER = 0
    public static let JOIN_ROUND = 1
    public static let JOIN_BEVEL = 2
    
    // =========================================================================
    // MARK: - Properties
    // =========================================================================
    
    /// Pen width in user-space units.
    public let lineWidth:   Float
    
    /// Line-cap decoration style.
    public let endCap:      Cap
    
    /// Line-join decoration style.
    public let lineJoin:    Join
    
    /// Limit of miter joins (only used when `lineJoin == .miter`).
    public let miterLimit:  Float
    
    /// Dash pattern array, or `nil` for a solid stroke.
    ///
    /// Alternating elements specify opaque and transparent lengths.
    public let dashArray:   [Float]?
    
    /// Offset into the dash pattern at which to begin stroking.
    public let dashPhase:   Float
    
    // =========================================================================
    // MARK: - Constructors  (mirrors Java's overloaded constructors)
    // =========================================================================
    
    /// Full constructor — matches `BasicStroke(float, int, int, float, float[], float)`.
    public init(
      _ lineWidth:  Float,
      cap:          Cap    = .square,
      join:         Join   = .miter,
      miterLimit:   Float  = 10.0,
      dash:         [Float]? = nil,
      dashPhase:    Float  = 0.0
    ) {
      self.lineWidth  = lineWidth
      self.endCap     = cap
      self.lineJoin   = join
      self.miterLimit = miterLimit
      self.dashArray  = dash
      self.dashPhase  = dashPhase
    }
    
    /// Creates a solid stroke with the given width, cap, join, and miter limit.
    public convenience init(
      _ lineWidth: Float,
      cap:         Cap,
      join:        Join,
      miterLimit:  Float
    ) {
      self.init(lineWidth, cap: cap, join: join,
                miterLimit: miterLimit, dash: nil, dashPhase: 0)
    }
    
    /// Creates a solid stroke with the given width, cap, and join.
    public convenience init(_ lineWidth: Float, cap: Cap, join: Join) {
      self.init(lineWidth, cap: cap, join: join, miterLimit: 10.0)
    }
    
    /// Creates a solid stroke with the given width and default cap/join.
    public convenience init(_ lineWidth: Float) {
      self.init(lineWidth, cap: .square, join: .miter)
    }
    
    /// Creates a solid stroke with width 1.0 and default cap/join.
    public convenience init() {
      self.init(1.0)
    }
    
    // =========================================================================
    // MARK: - Java int-based convenience constructors (porting helpers)
    // =========================================================================
    
    /// Accepts raw Java `int` constants so ported code compiles unchanged.
    ///
    /// ```swift
    /// // Java: new BasicStroke(2f, BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND)
    /// Java.awt.BasicStroke(2, capInt: 1, joinInt: 1)
    /// ```
    public convenience init(
      _ lineWidth: Float,
      capInt:      Int,
      joinInt:     Int,
      miterLimit:  Float = 10.0,
      dash:        [Float]? = nil,
      dashPhase:   Float = 0.0
    ) {
      self.init(
        lineWidth,
        cap:        Cap(rawValue: capInt)   ?? .square,
        join:       Join(rawValue: joinInt) ?? .miter,
        miterLimit: miterLimit,
        dash:       dash,
        dashPhase:  dashPhase)
    }
    
    // =========================================================================
    // MARK: - Stroke
    // =========================================================================

    /// Returns the stroked outline of `shape` as a new `Shape`.
    ///
    /// On Apple platforms the stroked path is produced via `CGPath.copy(strokingWithWidth:…)`.
    /// On other platforms a `GeneralPath` copy of the original shape is returned as a
    /// best-effort approximation.
    public func createStrokedShape(_ shape: any java.awt.Shape) -> any java.awt.Shape {
#if canImport(CoreGraphics)
      // Obtain a CGPath for the input shape, stroke it with our attributes,
      // then wrap the result in a Path2D so callers get a proper java.awt.Shape.
      if let source = cgPathFrom(shape: shape) {
        let stroked = source.copy(
          strokingWithWidth:  CGFloat(lineWidth),
          lineCap:            endCap.cgLineCap,
          lineJoin:           lineJoin.cgLineJoin,
          miterLimit:         CGFloat(miterLimit),
          transform:          .identity)
        return cgPathToPath2D(stroked)
      }
#endif
      // Fallback: return a GeneralPath copy of the original shape.
      let result = java.awt.geom.GeneralPath(shape: shape)
      return result
    }

#if canImport(CoreGraphics)
    /// Converts a `java.awt.Shape` to `CGPath`, covering all known concrete types.
    private func cgPathFrom(shape: any java.awt.Shape) -> CGPath? {
      if let r = shape as? java.awt.Rectangle {
        return CGPath(rect: r.cgRect, transform: nil)
      }
      if let r2 = shape as? java.awt.geom.Rectangle2D {
        return CGPath(rect: CGRect(x: r2.getX(), y: r2.getY(),
                                   width: r2.getWidth(), height: r2.getHeight()),
                      transform: nil)
      }
      if let e = shape as? java.awt.geom.Ellipse2D {
        return CGPath(ellipseIn: CGRect(x: e.getX(), y: e.getY(),
                                        width: e.getWidth(), height: e.getHeight()),
                      transform: nil)
      }
      if let l = shape as? java.awt.geom.Line2D {
        let p = CGMutablePath()
        p.move(to: CGPoint(x: l.getX1(), y: l.getY1()))
        p.addLine(to: CGPoint(x: l.getX2(), y: l.getY2()))
        return p
      }
      if let path = shape as? java.awt.geom.Path2D {
        return path.cgPath
      }
      return nil
    }

    /// Wraps a `CGPath` in a `Path2D.Double` by re-applying each element.
    private func cgPathToPath2D(_ cgPath: CGPath) -> java.awt.geom.Path2D.Double {
      let result = java.awt.geom.Path2D.Double()
      cgPath.applyWithBlock { element in
        let pts = element.pointee.points
        switch element.pointee.type {
        case .moveToPoint:
          result.moveTo(Swift.Double(pts[0].x), Swift.Double(pts[0].y))
        case .addLineToPoint:
          result.lineTo(Swift.Double(pts[0].x), Swift.Double(pts[0].y))
        case .addQuadCurveToPoint:
          result.quadTo(Swift.Double(pts[0].x), Swift.Double(pts[0].y),
                        Swift.Double(pts[1].x), Swift.Double(pts[1].y))
        case .addCurveToPoint:
          result.curveTo(Swift.Double(pts[0].x), Swift.Double(pts[0].y),
                         Swift.Double(pts[1].x), Swift.Double(pts[1].y),
                         Swift.Double(pts[2].x), Swift.Double(pts[2].y))
        case .closeSubpath:
          result.closePath()
        @unknown default:
          break
        }
      }
      return result
    }
#endif

    // =========================================================================
    // MARK: - CoreGraphics bridge
    // =========================================================================
    
#if canImport(CoreGraphics)
    
    /// Applies all stroke attributes to `context`.
    ///
    /// Call this from `Graphics2D.setStroke(_:)` so the next draw call
    /// uses the correct pen style.
    internal func _apply(to context: CGContext) {
      context.setLineWidth(CGFloat(lineWidth))
      context.setLineCap(endCap.cgLineCap)
      context.setLineJoin(lineJoin.cgLineJoin)
      context.setMiterLimit(CGFloat(miterLimit))
      
      if let dash = dashArray, !dash.isEmpty {
        context.setLineDash(
          phase:   CGFloat(dashPhase),
          lengths: dash.map { CGFloat($0) })
      } else {
        context.setLineDash(phase: 0, lengths: [])   // solid
      }
    }
#endif
  }
}
