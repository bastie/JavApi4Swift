/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// =============================================================================
// MARK: - java.awt.FontMetrics  (abstract base)
// =============================================================================

extension java.awt {

  /// Mirrors `java.awt.FontMetrics`.
  ///
  /// Obtain an instance via `Graphics.getFontMetrics()` or
  /// `Graphics.getFontMetrics(font)`.
  ///
  /// The concrete subclass is chosen at compile time:
  /// - Apple platforms (CoreText available) → `CoreTextFontMetrics`
  /// - All others                           → `HeadlessFontMetrics`
  open class FontMetrics {

    /// Platform-specific factory registered at startup (e.g. by X11Toolkit).
    /// Called by `make(for:)` on Linux/FreeBSD to return Xft-backed metrics so
    /// that hit-testing and caret positioning agree with actual rendering.
    /// Must be nonisolated-safe (no MainActor dependency).
    nonisolated(unsafe) static var _platformFactory: ((java.awt.Font) -> java.awt.FontMetrics?)? = nil

    public let font: java.awt.Font

    public init(_ font: java.awt.Font) {
      self.font = font
    }

    // -------------------------------------------------------------------------
    // MARK: Font accessor
    // -------------------------------------------------------------------------

    public func getFont() -> java.awt.Font { font }

    // -------------------------------------------------------------------------
    // MARK: Vertical metrics — override in subclasses
    // -------------------------------------------------------------------------

    /// Distance from baseline to top of tallest glyph.
    open func getAscent()   -> Int { Int(Double(font.size) * 0.75) }

    /// Distance from baseline to bottom of lowest descender.
    open func getDescent()  -> Int { Int(Double(font.size) * 0.20) }

    /// Recommended extra space between lines.
    open func getLeading()  -> Int { Int(Double(font.size) * 0.10) }

    /// Total line height = ascent + descent + leading.
    public final func getHeight() -> Int { getAscent() + getDescent() + getLeading() }

    /// Maximum ascent over all glyphs.
    open func getMaxAscent()  -> Int { getAscent()  }

    /// Maximum descent over all glyphs.
    open func getMaxDescent() -> Int { getDescent() }

    /// Width of the widest glyph (-1 if unknown).
    open func getMaxAdvance() -> Int { -1 }

    // -------------------------------------------------------------------------
    // MARK: Horizontal metrics — override in subclasses
    // -------------------------------------------------------------------------

    /// Advance width of a single character.
    open func charWidth(_ ch: Character) -> Int {
      Int(Double(font.size) * 0.60)
    }

    /// Advance width of `length` chars from `data` starting at `offset`.
    open func charsWidth(_ data: [Character], _ offset: Int, _ length: Int) -> Int {
      var w = 0
      for i in offset ..< offset + length { w += charWidth(data[i]) }
      return w
    }

    /// Advance width of a String.
    open func stringWidth(_ str: String) -> Int {
      str.reduce(0) { $0 + charWidth($1) }
    }

    /// Widths of the first 256 Unicode scalar values (0–255).
    public func getWidths() -> [Int] {
      (0 ..< 256).map { i -> Int in
        guard let scalar = Unicode.Scalar(i) else { return charWidth(" ") }
        return charWidth(Character(scalar))
      }
    }
  }
}

// =============================================================================
// MARK: - CoreTextFontMetrics  (Apple platforms)
// =============================================================================

#if canImport(CoreText)
import CoreText
import CoreFoundation

extension java.awt {

  final class CoreTextFontMetrics: FontMetrics {

    private let ctFont: CTFont

    override init(_ font: java.awt.Font) {
      let cfName = font.platformName as CFString
      self.ctFont = CTFontCreateWithName(cfName, CGFloat(font.size), nil)
      super.init(font)
    }

    // -------------------------------------------------------------------------
    // MARK: Vertical metrics from CTFont
    // -------------------------------------------------------------------------

    override func getAscent()      -> Int { Int(CTFontGetAscent(ctFont).rounded(.up))   }
    override func getDescent()     -> Int { Int(CTFontGetDescent(ctFont).rounded(.up))  }
    override func getLeading()     -> Int { Int(CTFontGetLeading(ctFont).rounded(.up))  }
    override func getMaxAscent()   -> Int { getAscent()  }
    override func getMaxDescent()  -> Int { getDescent() }

    override func getMaxAdvance() -> Int {
      var advances = CGSize.zero
      // Use 'M' (em square) as proxy for max advance
      var glyph: CGGlyph = 0
      var uchar: UniChar = UniChar(("M" as Character).asciiValue ?? 77)
      CTFontGetGlyphsForCharacters(ctFont, &uchar, &glyph, 1)
      CTFontGetAdvancesForGlyphs(ctFont, .horizontal, &glyph, &advances, 1)
      return Int(advances.width.rounded(.up))
    }

    // -------------------------------------------------------------------------
    // MARK: Horizontal metrics via CTLine
    // -------------------------------------------------------------------------

    override func stringWidth(_ str: String) -> Int {
      guard !str.isEmpty else { return 0 }
      let attrs = [kCTFontAttributeName: ctFont] as CFDictionary
      let cfStr = str as CFString
      guard let attrStr = CFAttributedStringCreate(kCFAllocatorDefault, cfStr, attrs) else {
        return super.stringWidth(str)
      }
      let line = CTLineCreateWithAttributedString(attrStr)
      return Int(CTLineGetTypographicBounds(line, nil, nil, nil).rounded(.up))
    }

    override func charWidth(_ ch: Character) -> Int {
      stringWidth(String(ch))
    }
  }
}

#endif   // canImport(CoreText)

// =============================================================================
// MARK: - Factory helper
// =============================================================================

extension java.awt.FontMetrics {

  /// Returns the best available FontMetrics for `font` on this platform.
  static func make(for font: java.awt.Font) -> java.awt.FontMetrics {
#if canImport(CoreText)
    return java.awt.CoreTextFontMetrics(font)
#elseif os(Windows)
    return java.awt.toolkit.gdi._GDIFontMetrics(font)
#elseif os(Linux) || os(FreeBSD)
    // Use platform-registered factory if available (set by X11Toolkit at startup),
    // so hit-testing/caret agree with Xft rendering. Falls back to headless.
    if let fm = java.awt.FontMetrics._platformFactory?(font) { return fm }
    return java.awt.FontMetrics(font)
#else
    return java.awt.FontMetrics(font)   // headless approximation
#endif
  }
}
