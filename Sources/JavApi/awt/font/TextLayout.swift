/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation
#if canImport(CoreText)
import CoreText // module-level import inside conditional compilation
#endif
extension java.awt.font {

  // ---------------------------------------------------------------------------
  // MARK: - TextHitInfo
  // ---------------------------------------------------------------------------

  /// Identifies a character position in a `TextLayout` together with a bias
  /// (leading or trailing edge).
  ///
  /// Mirrors `java.awt.font.TextHitInfo`.
  ///
  /// - Since: JavaApi > 0.x (Java 1.2)
  public struct TextHitInfo {

    /// Index of the character that was hit (0-based).
    public let charIndex: Int

    /// `true` if the hit is on the leading (left) edge of the character.
    public let isLeadingEdge: Bool

    private init(charIndex: Int, isLeadingEdge: Bool) {
      self.charIndex    = charIndex
      self.isLeadingEdge = isLeadingEdge
    }

    /// Creates a hit on the leading edge of character `charIndex`.
    public static func leading(_ charIndex: Int)  -> TextHitInfo {
      TextHitInfo(charIndex: charIndex, isLeadingEdge: true)
    }

    /// Creates a hit on the trailing edge of character `charIndex`.
    public static func trailing(_ charIndex: Int) -> TextHitInfo {
      TextHitInfo(charIndex: charIndex, isLeadingEdge: false)
    }

    /// The insertion index: leading → charIndex, trailing → charIndex + 1.
    public func getInsertionIndex() -> Int {
      isLeadingEdge ? charIndex : charIndex + 1
    }
  }

  // ---------------------------------------------------------------------------
  // MARK: - TextLayout
  // ---------------------------------------------------------------------------

  /// An immutable, styled piece of text laid out in a single direction.
  ///
  /// Mirrors `java.awt.font.TextLayout`. Supports measuring, hit-testing, and
  /// (on Apple platforms) drawing via CoreText.
  ///
  /// Current limitations:
  /// - Single font, left-to-right text only.
  /// - Glyph advance widths are approximated on non-Apple platforms.
  ///
  /// - Since: JavaApi > 0.x (Java 1.2)
  public final class TextLayout {

    // =========================================================================
    // MARK: - Stored state
    // =========================================================================

    private let text:    String
    private let font:    java.awt.Font
    private let frc:     FontRenderContext
    private let metrics: LineMetrics

    // Per-character advance widths (computed once, cached).
    private let advances: [Swift.Float]

    // =========================================================================
    // MARK: - Initialisers
    // =========================================================================

    /// Creates a `TextLayout` for `string` rendered with `font` in context `frc`.
    public init(_ string: String,
                _ font:   java.awt.Font,
                _ frc:    FontRenderContext) {
      self.text    = string
      self.font    = font
      self.frc     = frc
      self.metrics = DefaultLineMetrics.make(for: font, numChars: string.count)
      self.advances = TextLayout.computeAdvances(string: string,
                                                  font: font,
                                                  frc: frc)
    }

    // =========================================================================
    // MARK: - Metrics
    // =========================================================================

    /// Total advance width of the text.
    public func getAdvance() -> Swift.Float {
      advances.reduce(0, +)
    }

    /// Visible advance (same as `getAdvance()` for LTR single-font text).
    public func getVisibleAdvance() -> Swift.Float { getAdvance() }

    /// Ascent from the baseline (positive upward).
    public func getAscent()  -> Swift.Float { metrics.getAscent()  }

    /// Descent below the baseline (positive downward).
    public func getDescent() -> Swift.Float { metrics.getDescent() }

    /// Recommended extra space between lines.
    public func getLeading() -> Swift.Float { metrics.getLeading() }

    // =========================================================================
    // MARK: - Bounds
    // =========================================================================

    /// Returns the bounding rectangle of this layout in baseline-relative coords.
    ///
    /// Origin is at the leftmost point of the baseline; the rectangle extends
    /// upward by `ascent` and downward by `descent`.
    public func getBounds() -> java.awt.geom.Rectangle2D {
      java.awt.geom.Rectangle2D.Float(
        0,
        -metrics.getAscent(),
        getAdvance(),
        metrics.getAscent() + metrics.getDescent())
    }

    // =========================================================================
    // MARK: - Hit testing
    // =========================================================================

    /// Returns the `TextHitInfo` for the point `(x, y)` relative to the
    /// origin of this layout.
    ///
    /// `y` is ignored (single-line layout). `x` is measured along the baseline.
    public func hitTestChar(_ x: Swift.Float,
                            _ y: Swift.Float) -> TextHitInfo {
      var cumulative: Swift.Float = 0
      for (i, adv) in advances.enumerated() {
        let midX = cumulative + adv / 2
        if x <= midX {
          return .leading(i)
        }
        cumulative += adv
      }
      return .trailing(advances.count - 1)
    }

    // =========================================================================
    // MARK: - Caret
    // =========================================================================

    /// Returns the x-position of the caret before character `offset`.
    public func getCaretX(at offset: Int) -> Swift.Float {
      let clamped = Swift.min(offset, advances.count)
      return advances.prefix(clamped).reduce(0, +)
    }

    /// Returns a two-element array `[x, angle]` for the caret at `hitInfo`.
    ///
    /// Angle is always 0.0 for LTR text.
    public func getCaretInfo(_ hitInfo: TextHitInfo) -> [Swift.Float] {
      let x = getCaretX(at: hitInfo.getInsertionIndex())
      return [x, 0.0]
    }

    // =========================================================================
    // MARK: - Drawing
    // =========================================================================

    /// Draws this layout at `(x, y)` into `g`.
    ///
    /// `x`, `y` give the origin of the baseline.
    public func draw(_ g: java.awt.Graphics, _ x: Swift.Float, _ y: Swift.Float) {
      g.setFont(font)
      g.drawString(text, Int(x.rounded()), Int(y.rounded()))
    }

    // =========================================================================
    // MARK: - Private helpers
    // =========================================================================

    /// Computes per-character advance widths.
    private static func computeAdvances(string: String,
                                         font:   java.awt.Font,
                                         frc:    FontRenderContext) -> [Swift.Float] {
#if canImport(CoreText)
      return computeAdvancesCT(string: string, font: font)
#else
      return computeAdvancesProportional(string: string, font: font)
#endif
    }

#if canImport(CoreText)
    private static func computeAdvancesCT(string: String,
                                           font:   java.awt.Font) -> [Swift.Float] {
      let ctFont = CTFontCreateWithName(font.platformName as CFString,
                                        CGFloat(font.size), nil)
      var result: [Swift.Float] = []
      result.reserveCapacity(string.count)
      for ch in string {
        let s     = String(ch) as CFString
        let attr  = [kCTFontAttributeName: ctFont] as CFDictionary
        let aStr  = CFAttributedStringCreate(nil, s, attr)!
        let line  = CTLineCreateWithAttributedString(aStr)
        result.append(Swift.Float(CTLineGetTypographicBounds(line, nil, nil, nil)))
      }
      return result
    }
#endif

    private static func computeAdvancesProportional(string: String,
                                                     font:   java.awt.Font) -> [Swift.Float] {
      let base = Swift.Float(font.size) * 0.60
      return string.map { _ in base }
    }
  }
}
