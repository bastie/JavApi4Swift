/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.font {

  // ---------------------------------------------------------------------------
  // MARK: - GlyphVector
  // ---------------------------------------------------------------------------

  /// An immutable collection of glyphs and their positions.
  ///
  /// Mirrors `java.awt.font.GlyphVector`. Obtain an instance via
  /// `Font.createGlyphVector(_:_:)`.
  ///
  /// > Note: This is a stub implementation. Per-glyph outline (`getGlyphOutline`)
  /// > and visual bounds are not yet backed by platform metrics.
  ///
  /// - Since: JavaApi > 0.x (Java 1.2)
  open class GlyphVector {

    /// The font used to create this glyph vector.
    public let font: java.awt.Font

    /// The render context used to create this glyph vector.
    public let frc: FontRenderContext

    /// Glyph codes (one per character in the source string).
    public let glyphCodes: [Int]

    // =========================================================================
    // MARK: - Init
    // =========================================================================

    public init(font: java.awt.Font,
                frc: FontRenderContext,
                glyphCodes: [Int]) {
      self.font       = font
      self.frc        = frc
      self.glyphCodes = glyphCodes
    }

    // =========================================================================
    // MARK: - Basic accessors
    // =========================================================================

    /// Number of glyphs in this vector.
    public func getNumGlyphs() -> Int { glyphCodes.count }

    /// Glyph code at index `glyphIndex`.
    public func getGlyphCode(_ glyphIndex: Int) -> Int {
      guard glyphIndex >= 0, glyphIndex < glyphCodes.count else { return 0 }
      return glyphCodes[glyphIndex]
    }

    /// All glyph codes as an array.
    public func getGlyphCodes(_ beginGlyphIndex: Int,
                               _ numEntries: Int) -> [Int] {
      let start = Swift.max(0, beginGlyphIndex)
      let end   = Swift.min(glyphCodes.count, start + numEntries)
      guard start < end else { return [] }
      return Array(glyphCodes[start..<end])
    }

    // =========================================================================
    // MARK: - Metrics
    // =========================================================================

    /// Logical bounds of the entire glyph vector (baseline-relative).
    ///
    /// - Returns: A `Rectangle2D` with origin at (0, -ascent) and
    ///   width = total advance, height = ascent + descent.
    public func getLogicalBounds() -> java.awt.geom.Rectangle2D {
      let lm      = java.awt.font.DefaultLineMetrics.make(for: font,
                                                          numChars: glyphCodes.count)
      let advance = Swift.Float(glyphCodes.count) * Swift.Float(font.size) * 0.60
      return java.awt.geom.Rectangle2D.Float(
        0,
        -lm.getAscent(),
        advance,
        lm.getAscent() + lm.getDescent())
    }

    /// Visual bounds — same as logical bounds in this stub.
    public func getVisualBounds() -> java.awt.geom.Rectangle2D { getLogicalBounds() }

    // =========================================================================
    // MARK: - Glyph positions
    // =========================================================================

    /// Returns the position of glyph `glyphIndex` as a `Point2D`.
    ///
    /// Positions are spaced by a fixed proportional advance in this stub.
    public func getGlyphPosition(_ glyphIndex: Int) -> java.awt.geom.Point2D {
      let adv = Swift.Double(font.size) * 0.60
      return java.awt.geom.Point2D.Double(adv * Swift.Double(glyphIndex), 0)
    }

    // =========================================================================
    // MARK: - Outline (stub — returns empty path)
    // =========================================================================

    /// Returns the outline of glyph `glyphIndex` as a `Shape`.
    ///
    /// > Note: Returns an empty `Path2D` in this stub implementation.
    public func getGlyphOutline(_ glyphIndex: Int) -> java.awt.Shape {
      java.awt.geom.Path2D.Float()
    }

    /// Returns the outline of the entire glyph vector as a `Shape`.
    ///
    /// > Note: Returns an empty `Path2D` in this stub implementation.
    public func getOutline() -> java.awt.Shape {
      java.awt.geom.Path2D.Float()
    }

    /// Returns the outline translated to `(x, y)`.
    public func getOutline(_ x: Swift.Float, _ y: Swift.Float) -> java.awt.Shape {
      java.awt.geom.Path2D.Float()
    }
  }
}
