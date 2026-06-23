/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.text {

  /// A collection of well-known attribute keys and convenience accessors for
  /// styled text.
  ///
  /// `StyleConstants` defines the standard keys used by `AttributeSet`,
  /// `SimpleAttributeSet`, and `StyledDocument`.  Each key is a `String`
  /// constant; the typed getter/setter pairs read and write values into any
  /// `SimpleAttributeSet`.
  ///
  /// ## Character attributes
  ///
  /// | Key | Type | Default |
  /// |-----|------|---------|
  /// | `FontFamily` | `String` | `"SansSerif"` |
  /// | `FontSize`   | `Int`    | `12`          |
  /// | `Bold`       | `Bool`   | `false`       |
  /// | `Italic`     | `Bool`   | `false`       |
  /// | `Underline`  | `Bool`   | `false`       |
  /// | `StrikeThrough` | `Bool` | `false`     |
  /// | `Foreground` | `java.awt.Color` | black |
  /// | `Background` | `java.awt.Color` | white |
  ///
  /// ## Paragraph attributes
  ///
  /// | Key | Type | Default |
  /// |-----|------|---------|
  /// | `Alignment`    | `Int`   | `ALIGN_LEFT` |
  /// | `LineSpacing`  | `Float` | `0`          |
  /// | `SpaceAbove`   | `Float` | `0`          |
  /// | `SpaceBelow`   | `Float` | `0`          |
  /// | `FirstLineIndent` | `Float` | `0`       |
  /// | `LeftIndent`   | `Float` | `0`          |
  /// | `RightIndent`  | `Float` | `0`          |
  ///
  /// - Since: Java 1.2
  @MainActor
  public enum StyleConstants {

    // -------------------------------------------------------------------------
    // MARK: Alignment constants
    // -------------------------------------------------------------------------

    public static let ALIGN_LEFT      = 0
    public static let ALIGN_CENTER    = 1
    public static let ALIGN_RIGHT     = 2
    public static let ALIGN_JUSTIFIED = 3

    // -------------------------------------------------------------------------
    // MARK: Attribute key names
    // -------------------------------------------------------------------------

    public static let FontFamily      = "font-family"
    public static let FontSize        = "font-size"
    public static let Bold            = "font-weight-bold"
    public static let Italic          = "font-style-italic"
    public static let Underline       = "text-decoration-underline"
    public static let StrikeThrough   = "text-decoration-strikethrough"
    public static let Superscript     = "superscript"
    public static let Subscript       = "subscript"
    public static let Foreground      = "foreground"
    public static let Background      = "background"
    // Paragraph
    public static let Alignment       = "paragraph-alignment"
    public static let LineSpacing     = "line-spacing"
    public static let SpaceAbove      = "space-above"
    public static let SpaceBelow      = "space-below"
    public static let FirstLineIndent = "first-line-indent"
    public static let LeftIndent      = "left-indent"
    public static let RightIndent     = "right-indent"

    // -------------------------------------------------------------------------
    // MARK: Character attribute — font family
    // -------------------------------------------------------------------------

    public static func getFontFamily(_ a: javax.swing.text.AttributeSet) -> String {
      return a.getAttribute(FontFamily) as? String ?? "SansSerif"
    }
    public static func setFontFamily(_ a: javax.swing.text.SimpleAttributeSet, _ family: String) {
      a.addAttribute(FontFamily, family)
    }

    // -------------------------------------------------------------------------
    // MARK: Character attribute — font size
    // -------------------------------------------------------------------------

    public static func getFontSize(_ a: javax.swing.text.AttributeSet) -> Int {
      return a.getAttribute(FontSize) as? Int ?? 12
    }
    public static func setFontSize(_ a: javax.swing.text.SimpleAttributeSet, _ size: Int) {
      a.addAttribute(FontSize, size)
    }

    // -------------------------------------------------------------------------
    // MARK: Character attribute — bold
    // -------------------------------------------------------------------------

    public static func isBold(_ a: javax.swing.text.AttributeSet) -> Bool {
      return a.getAttribute(Bold) as? Bool ?? false
    }
    public static func setBold(_ a: javax.swing.text.SimpleAttributeSet, _ bold: Bool) {
      a.addAttribute(Bold, bold)
    }

    // -------------------------------------------------------------------------
    // MARK: Character attribute — italic
    // -------------------------------------------------------------------------

    public static func isItalic(_ a: javax.swing.text.AttributeSet) -> Bool {
      return a.getAttribute(Italic) as? Bool ?? false
    }
    public static func setItalic(_ a: javax.swing.text.SimpleAttributeSet, _ italic: Bool) {
      a.addAttribute(Italic, italic)
    }

    // -------------------------------------------------------------------------
    // MARK: Character attribute — underline
    // -------------------------------------------------------------------------

    public static func isUnderline(_ a: javax.swing.text.AttributeSet) -> Bool {
      return a.getAttribute(Underline) as? Bool ?? false
    }
    public static func setUnderline(_ a: javax.swing.text.SimpleAttributeSet, _ underline: Bool) {
      a.addAttribute(Underline, underline)
    }

    // -------------------------------------------------------------------------
    // MARK: Character attribute — strikethrough
    // -------------------------------------------------------------------------

    public static func isStrikeThrough(_ a: javax.swing.text.AttributeSet) -> Bool {
      return a.getAttribute(StrikeThrough) as? Bool ?? false
    }
    public static func setStrikeThrough(_ a: javax.swing.text.SimpleAttributeSet, _ strike: Bool) {
      a.addAttribute(StrikeThrough, strike)
    }

    // -------------------------------------------------------------------------
    // MARK: Character attribute — superscript / subscript
    // -------------------------------------------------------------------------

    public static func isSuperscript(_ a: javax.swing.text.AttributeSet) -> Bool {
      return a.getAttribute(Superscript) as? Bool ?? false
    }
    public static func setSuperscript(_ a: javax.swing.text.SimpleAttributeSet, _ sup: Bool) {
      a.addAttribute(Superscript, sup)
    }

    public static func isSubscript(_ a: javax.swing.text.AttributeSet) -> Bool {
      return a.getAttribute(Subscript) as? Bool ?? false
    }
    public static func setSubscript(_ a: javax.swing.text.SimpleAttributeSet, _ sub: Bool) {
      a.addAttribute(Subscript, sub)
    }

    // -------------------------------------------------------------------------
    // MARK: Character attribute — foreground / background color
    // -------------------------------------------------------------------------

    public static func getForeground(_ a: javax.swing.text.AttributeSet) -> java.awt.Color {
      return a.getAttribute(Foreground) as? java.awt.Color ?? java.awt.Color.black
    }
    public static func setForeground(_ a: javax.swing.text.SimpleAttributeSet,
                                     _ color: java.awt.Color) {
      a.addAttribute(Foreground, color)
    }

    public static func getBackground(_ a: javax.swing.text.AttributeSet) -> java.awt.Color {
      return a.getAttribute(Background) as? java.awt.Color ?? java.awt.Color.white
    }
    public static func setBackground(_ a: javax.swing.text.SimpleAttributeSet,
                                     _ color: java.awt.Color) {
      a.addAttribute(Background, color)
    }

    // -------------------------------------------------------------------------
    // MARK: Paragraph attribute — alignment
    // -------------------------------------------------------------------------

    public static func getAlignment(_ a: javax.swing.text.AttributeSet) -> Int {
      return a.getAttribute(Alignment) as? Int ?? ALIGN_LEFT
    }
    public static func setAlignment(_ a: javax.swing.text.SimpleAttributeSet, _ align: Int) {
      a.addAttribute(Alignment, align)
    }

    // -------------------------------------------------------------------------
    // MARK: Paragraph attribute — spacing
    // -------------------------------------------------------------------------

    public static func getLineSpacing(_ a: javax.swing.text.AttributeSet) -> Float {
      return a.getAttribute(LineSpacing) as? Float ?? 0
    }
    public static func setLineSpacing(_ a: javax.swing.text.SimpleAttributeSet, _ s: Float) {
      a.addAttribute(LineSpacing, s)
    }

    public static func getSpaceAbove(_ a: javax.swing.text.AttributeSet) -> Float {
      return a.getAttribute(SpaceAbove) as? Float ?? 0
    }
    public static func setSpaceAbove(_ a: javax.swing.text.SimpleAttributeSet, _ s: Float) {
      a.addAttribute(SpaceAbove, s)
    }

    public static func getSpaceBelow(_ a: javax.swing.text.AttributeSet) -> Float {
      return a.getAttribute(SpaceBelow) as? Float ?? 0
    }
    public static func setSpaceBelow(_ a: javax.swing.text.SimpleAttributeSet, _ s: Float) {
      a.addAttribute(SpaceBelow, s)
    }

    // -------------------------------------------------------------------------
    // MARK: Paragraph attribute — indentation
    // -------------------------------------------------------------------------

    public static func getFirstLineIndent(_ a: javax.swing.text.AttributeSet) -> Float {
      return a.getAttribute(FirstLineIndent) as? Float ?? 0
    }
    public static func setFirstLineIndent(_ a: javax.swing.text.SimpleAttributeSet, _ i: Float) {
      a.addAttribute(FirstLineIndent, i)
    }

    public static func getLeftIndent(_ a: javax.swing.text.AttributeSet) -> Float {
      return a.getAttribute(LeftIndent) as? Float ?? 0
    }
    public static func setLeftIndent(_ a: javax.swing.text.SimpleAttributeSet, _ i: Float) {
      a.addAttribute(LeftIndent, i)
    }

    public static func getRightIndent(_ a: javax.swing.text.AttributeSet) -> Float {
      return a.getAttribute(RightIndent) as? Float ?? 0
    }
    public static func setRightIndent(_ a: javax.swing.text.SimpleAttributeSet, _ i: Float) {
      a.addAttribute(RightIndent, i)
    }
  }
}
