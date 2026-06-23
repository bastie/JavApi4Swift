/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// =============================================================================
// MARK: - CoreTextFontMetrics  (Apple platforms)
// =============================================================================

#if canImport(CoreText)
import CoreText
import CoreFoundation

extension java.awt.toolkit.swiftui {

  final class _CoreTextFontMetrics: java.awt.FontMetrics {

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
