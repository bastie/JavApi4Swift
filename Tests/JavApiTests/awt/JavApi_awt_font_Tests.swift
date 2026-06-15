/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Testing
@testable import JavApi

@Suite("java.awt.font")
struct JavApi_awt_font_Tests {

  // MARK: - FontRenderContext

  @Test("FontRenderContext default init has unset hints")
  func frc_defaultHints() {
    let frc = java.awt.font.FontRenderContext()
    #expect(!frc.isAntiAliased())
    #expect(!frc.usesFractionalMetrics())
    #expect(frc.getAntiAliasingHint()      == java.awt.font.FontRenderContext.AA_DEFAULT)
    #expect(frc.getFractionalMetricsHint() == java.awt.font.FontRenderContext.FM_DEFAULT)
  }

  @Test("FontRenderContext AA_ON / FM_ON")
  func frc_explicitHints() {
    let frc = java.awt.font.FontRenderContext(
      antiAliasing: java.awt.font.FontRenderContext.AA_ON,
      fractionalMetrics: java.awt.font.FontRenderContext.FM_ON)
    #expect(frc.isAntiAliased())
    #expect(frc.usesFractionalMetrics())
  }

  @Test("FontRenderContext equals")
  func frc_equals() {
    let a = java.awt.font.FontRenderContext(antiAliasing: java.awt.font.FontRenderContext.AA_ON,
                                            fractionalMetrics: java.awt.font.FontRenderContext.FM_OFF)
    let b = java.awt.font.FontRenderContext(antiAliasing: java.awt.font.FontRenderContext.AA_ON,
                                            fractionalMetrics: java.awt.font.FontRenderContext.FM_OFF)
    let c = java.awt.font.FontRenderContext()
    #expect(a.equals(b))
    #expect(!a.equals(c))
  }

  // MARK: - LineMetrics

  @Test("LineMetrics proportional values for size 12")
  func lineMetrics_proportional() {
    let font = java.awt.Font("Dialog", java.awt.Font.PLAIN, 12)
    let frc  = java.awt.font.FontRenderContext()
    let lm   = font.getLineMetrics("Hello", frc)
    #expect(lm.getNumChars() == 5)
    #expect(lm.getAscent()  > 0)
    #expect(lm.getDescent() > 0)
    #expect(lm.getLeading() >= 0)
    // height = ascent + descent + leading
    #expect(Swift.abs(lm.getHeight() - (lm.getAscent() + lm.getDescent() + lm.getLeading())) < 0.001)
  }

  @Test("LineMetrics strikethrough and underline are non-zero")
  func lineMetrics_decorations() {
    let font = java.awt.Font("Serif", java.awt.Font.BOLD, 16)
    let frc  = java.awt.font.FontRenderContext()
    let lm   = font.getLineMetrics("Test", frc)
    #expect(lm.getStrikethroughThickness() > 0)
    #expect(lm.getUnderlineThickness()     > 0)
  }

  @Test("LineMetrics sub-range numChars")
  func lineMetrics_subRange() {
    let font = java.awt.Font("Monospaced", java.awt.Font.PLAIN, 10)
    let frc  = java.awt.font.FontRenderContext()
    let lm   = font.getLineMetrics("Hello World", 0, 5, frc)
    #expect(lm.getNumChars() == 5)
  }

  // MARK: - TextLayout

  @Test("TextLayout advance is positive")
  func textLayout_advance() {
    let font = java.awt.Font("Dialog", java.awt.Font.PLAIN, 12)
    let frc  = java.awt.font.FontRenderContext()
    let tl   = java.awt.font.TextLayout("Hello", font, frc)
    #expect(tl.getAdvance() > 0)
  }

  @Test("TextLayout metrics match LineMetrics")
  func textLayout_metrics() {
    let font = java.awt.Font("Dialog", java.awt.Font.PLAIN, 12)
    let frc  = java.awt.font.FontRenderContext()
    let tl   = java.awt.font.TextLayout("Hi", font, frc)
    let lm   = font.getLineMetrics("Hi", frc)
    #expect(Swift.abs(tl.getAscent()  - lm.getAscent())  < 0.001)
    #expect(Swift.abs(tl.getDescent() - lm.getDescent()) < 0.001)
  }

  @Test("TextLayout getBounds width equals advance")
  func textLayout_bounds() {
    let font = java.awt.Font("Dialog", java.awt.Font.PLAIN, 12)
    let frc  = java.awt.font.FontRenderContext()
    let tl   = java.awt.font.TextLayout("ABC", font, frc)
    let b    = tl.getBounds()
    #expect(Swift.abs(Swift.Double(tl.getAdvance()) - b.getWidth()) < 0.1)
  }

  @Test("TextLayout hitTestChar at x=0 returns leading edge of first char")
  func textLayout_hitTest_start() {
    let font = java.awt.Font("Monospaced", java.awt.Font.PLAIN, 10)
    let frc  = java.awt.font.FontRenderContext()
    let tl   = java.awt.font.TextLayout("ABC", font, frc)
    let hit  = tl.hitTestChar(0, 0)
    #expect(hit.charIndex == 0)
    #expect(hit.isLeadingEdge)
  }

  @Test("TextLayout hitTestChar at end returns trailing edge of last char")
  func textLayout_hitTest_end() {
    let font = java.awt.Font("Monospaced", java.awt.Font.PLAIN, 10)
    let frc  = java.awt.font.FontRenderContext()
    let tl   = java.awt.font.TextLayout("ABC", font, frc)
    let hit  = tl.hitTestChar(tl.getAdvance() + 100, 0)
    #expect(hit.charIndex == 2)
    #expect(!hit.isLeadingEdge)
  }

  @Test("TextLayout getCaretX at 0 is 0")
  func textLayout_caretX_start() {
    let font = java.awt.Font("Dialog", java.awt.Font.PLAIN, 12)
    let frc  = java.awt.font.FontRenderContext()
    let tl   = java.awt.font.TextLayout("Hello", font, frc)
    #expect(tl.getCaretX(at: 0) == 0)
  }

  @Test("TextLayout getCaretX at end equals advance")
  func textLayout_caretX_end() {
    let font = java.awt.Font("Dialog", java.awt.Font.PLAIN, 12)
    let frc  = java.awt.font.FontRenderContext()
    let tl   = java.awt.font.TextLayout("Hi", font, frc)
    #expect(Swift.abs(tl.getCaretX(at: 2) - tl.getAdvance()) < 0.001)
  }

  // MARK: - TextHitInfo

  @Test("TextHitInfo leading insertion index equals charIndex")
  func hitInfo_leading() {
    let h = java.awt.font.TextHitInfo.leading(3)
    #expect(h.charIndex == 3)
    #expect(h.isLeadingEdge)
    #expect(h.getInsertionIndex() == 3)
  }

  @Test("TextHitInfo trailing insertion index is charIndex + 1")
  func hitInfo_trailing() {
    let h = java.awt.font.TextHitInfo.trailing(3)
    #expect(h.charIndex == 3)
    #expect(!h.isLeadingEdge)
    #expect(h.getInsertionIndex() == 4)
  }

  // MARK: - GlyphVector

  @Test("Font.createGlyphVector glyph count matches string length")
  func glyphVector_count() {
    let font = java.awt.Font("Dialog", java.awt.Font.PLAIN, 12)
    let frc  = java.awt.font.FontRenderContext()
    let gv   = font.createGlyphVector(frc, "ABC")
    #expect(gv.getNumGlyphs() == 3)
  }

  @Test("GlyphVector glyph code for 'A' is 65")
  func glyphVector_glyphCode() {
    let font = java.awt.Font("Dialog", java.awt.Font.PLAIN, 12)
    let frc  = java.awt.font.FontRenderContext()
    let gv   = font.createGlyphVector(frc, "A")
    #expect(gv.getGlyphCode(0) == 65)  // Unicode scalar for 'A'
  }

  @Test("GlyphVector getLogicalBounds width is positive")
  func glyphVector_bounds() {
    let font = java.awt.Font("Dialog", java.awt.Font.PLAIN, 12)
    let frc  = java.awt.font.FontRenderContext()
    let gv   = font.createGlyphVector(frc, "Hi")
    #expect(gv.getLogicalBounds().getWidth() > 0)
  }

  @Test("GlyphVector glyph position x increases with index")
  func glyphVector_positions() {
    let font = java.awt.Font("Monospaced", java.awt.Font.PLAIN, 10)
    let frc  = java.awt.font.FontRenderContext()
    let gv   = font.createGlyphVector(frc, "AB")
    let x0   = gv.getGlyphPosition(0).getX()
    let x1   = gv.getGlyphPosition(1).getX()
    #expect(x1 > x0)
  }

  // MARK: - TextAttribute

  @Test("TextAttribute key constants are unique strings")
  func textAttribute_keys() {
    let keys: [String] = [
      java.awt.font.TextAttribute.FAMILY,
      java.awt.font.TextAttribute.WEIGHT,
      java.awt.font.TextAttribute.POSTURE,
      java.awt.font.TextAttribute.SIZE,
      java.awt.font.TextAttribute.FOREGROUND,
      java.awt.font.TextAttribute.UNDERLINE,
      java.awt.font.TextAttribute.STRIKETHROUGH,
    ]
    let unique = Set(keys)
    #expect(unique.count == keys.count)
  }

  @Test("TextAttribute WEIGHT_BOLD is 2.0")
  func textAttribute_weightBold() {
    #expect(java.awt.font.TextAttribute.WEIGHT_BOLD == 2.0)
  }

  @Test("TextAttribute POSTURE_REGULAR is 0.0, POSTURE_OBLIQUE is 0.2")
  func textAttribute_posture() {
    #expect(java.awt.font.TextAttribute.POSTURE_REGULAR == 0.0)
    #expect(java.awt.font.TextAttribute.POSTURE_OBLIQUE == 0.20)
  }

  @Test("TextAttribute SUPERSCRIPT constants")
  func textAttribute_superscript() {
    #expect(java.awt.font.TextAttribute.SUPERSCRIPT_SUPER ==  1)
    #expect(java.awt.font.TextAttribute.SUPERSCRIPT_SUB   == -1)
    #expect(java.awt.font.TextAttribute.SUPERSCRIPT_NONE  ==  0)
  }
}
