/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.font {

  // ---------------------------------------------------------------------------
  // MARK: - TextAttribute
  // ---------------------------------------------------------------------------

  /// Defines attribute keys used with `AttributedString` and `AttributedCharacterIterator`.
  ///
  /// Mirrors `java.awt.font.TextAttribute`. Each constant is a `String` key
  /// identifying a text attribute (Java uses `AttributedCharacterIterator.Attribute`
  /// objects; here plain `String` constants serve the same purpose).
  ///
  /// - Since: JavaApi > 0.x (Java 1.2)
  public enum TextAttribute {

    // =========================================================================
    // MARK: - Font selection
    // =========================================================================

    /// The font family name. Value: `String` (e.g. `"Dialog"`, `"Serif"`).
    public static let FAMILY = "java.awt.font.TextAttribute.family"

    /// The font weight. Value: one of the `WEIGHT_*` constants (`Float`).
    public static let WEIGHT = "java.awt.font.TextAttribute.weight"

    /// Extra-light weight (0.5).
    public static let WEIGHT_EXTRA_LIGHT: Swift.Float = 0.5
    /// Light weight (0.75).
    public static let WEIGHT_LIGHT:       Swift.Float = 0.75
    /// Demi-light weight (0.875).
    public static let WEIGHT_DEMILIGHT:   Swift.Float = 0.875
    /// Regular weight (1.0).
    public static let WEIGHT_REGULAR:     Swift.Float = 1.0
    /// Semi-bold weight (1.25).
    public static let WEIGHT_SEMIBOLD:    Swift.Float = 1.25
    /// Medium weight (1.5).
    public static let WEIGHT_MEDIUM:      Swift.Float = 1.5
    /// Demi-bold weight (1.75).
    public static let WEIGHT_DEMIBOLD:    Swift.Float = 1.75
    /// Bold weight (2.0).
    public static let WEIGHT_BOLD:        Swift.Float = 2.0
    /// Heavy weight (2.25).
    public static let WEIGHT_HEAVY:       Swift.Float = 2.25
    /// Extra-bold weight (2.5).
    public static let WEIGHT_EXTRABOLD:   Swift.Float = 2.5
    /// Ultra-bold weight (2.75).
    public static let WEIGHT_ULTRABOLD:   Swift.Float = 2.75

    /// The font width/stretch. Value: one of the `WIDTH_*` constants (`Float`).
    public static let WIDTH = "java.awt.font.TextAttribute.width"

    public static let WIDTH_CONDENSED:       Swift.Float = 0.75
    public static let WIDTH_SEMI_CONDENSED:  Swift.Float = 0.875
    public static let WIDTH_REGULAR:         Swift.Float = 1.0
    public static let WIDTH_SEMI_EXTENDED:   Swift.Float = 1.25
    public static let WIDTH_EXTENDED:        Swift.Float = 1.5

    /// The font posture (italic). Value: one of the `POSTURE_*` constants (`Float`).
    public static let POSTURE = "java.awt.font.TextAttribute.posture"

    /// Regular (upright) posture.
    public static let POSTURE_REGULAR: Swift.Float = 0.0
    /// Oblique (italic) posture.
    public static let POSTURE_OBLIQUE: Swift.Float = 0.20

    /// The font size in points. Value: `Float`.
    public static let SIZE = "java.awt.font.TextAttribute.size"

    /// Scaling factor applied to the font. Value: `Float`.
    public static let TRANSFORM = "java.awt.font.TextAttribute.transform"

    /// Superscript / subscript. Value: one of the `SUPERSCRIPT_*` constants (`Int`).
    public static let SUPERSCRIPT = "java.awt.font.TextAttribute.superscript"

    /// Standard superscript.
    public static let SUPERSCRIPT_SUPER: Int = 1
    /// Standard subscript.
    public static let SUPERSCRIPT_SUB:   Int = -1
    /// No superscript / subscript (default).
    public static let SUPERSCRIPT_NONE:  Int = 0

    /// The `Font` object itself. Value: `java.awt.Font`.
    public static let FONT = "java.awt.font.TextAttribute.font"

    /// An embedded graphic. Value: `GraphicAttribute` (not yet implemented).
    public static let CHAR_REPLACEMENT = "java.awt.font.TextAttribute.charReplacement"

    // =========================================================================
    // MARK: - Paint / colour
    // =========================================================================

    /// Foreground paint. Value: `java.awt.Color`.
    public static let FOREGROUND = "java.awt.font.TextAttribute.foreground"

    /// Background paint. Value: `java.awt.Color`.
    public static let BACKGROUND = "java.awt.font.TextAttribute.background"

    /// Whether the background should be swapped with the foreground (highlight).
    /// Value: `Bool`.
    public static let SWAP_COLORS = "java.awt.font.TextAttribute.swapColors"

    public static let SWAP_COLORS_ON = true

    // =========================================================================
    // MARK: - Decorations
    // =========================================================================

    /// Underline style. Value: one of the `UNDERLINE_*` constants (`Int`).
    public static let UNDERLINE = "java.awt.font.TextAttribute.underline"

    /// Standard single underline.
    public static let UNDERLINE_ON: Int = 0
    /// No underline (default / absent key).
    public static let UNDERLINE_NONE: Int = -1

    /// Whether strikethrough is applied. Value: `Bool`.
    public static let STRIKETHROUGH = "java.awt.font.TextAttribute.strikethrough"

    public static let STRIKETHROUGH_ON = true

    // =========================================================================
    // MARK: - Layout / BiDi
    // =========================================================================

    /// Reading direction. Value: one of the `RUN_DIRECTION_*` constants (`Bool`).
    public static let RUN_DIRECTION = "java.awt.font.TextAttribute.runDirection"

    public static let RUN_DIRECTION_LTR = false
    public static let RUN_DIRECTION_RTL = true

    /// Bidi embedding level (override). Value: `Int` (-15…15).
    public static let BIDI_EMBEDDING = "java.awt.font.TextAttribute.bidiEmbedding"

    /// Justification fraction. Value: `Float` 0.0 … 1.0.
    public static let JUSTIFICATION = "java.awt.font.TextAttribute.justification"

    public static let JUSTIFICATION_FULL: Swift.Float = 1.0
    public static let JUSTIFICATION_NONE: Swift.Float = 0.0

    // =========================================================================
    // MARK: - Input method / language
    // =========================================================================

    /// Input method highlight object. Value: opaque object (stub — `AnyObject?`).
    public static let INPUT_METHOD_HIGHLIGHT = "java.awt.font.TextAttribute.inputMethodHighlight"

    /// Input method underline. Value: `Int` (same constants as `UNDERLINE`).
    public static let INPUT_METHOD_UNDERLINE = "java.awt.font.TextAttribute.inputMethodUnderline"

    public static let UNDERLINE_LOW_ONE_PIXEL:    Int = 1
    public static let UNDERLINE_LOW_TWO_PIXEL:    Int = 2
    public static let UNDERLINE_LOW_DOTTED:       Int = 3
    public static let UNDERLINE_LOW_GRAY:         Int = 4
    public static let UNDERLINE_LOW_DASHED:       Int = 5

    /// Language tag (IETF BCP 47). Value: `String`.
    public static let LANGUAGE = "java.awt.font.TextAttribute.language"

    // =========================================================================
    // MARK: - Numeric shaping (stub)
    // =========================================================================

    /// Numeric shaper. Value: `Int` (shaper flags — not yet fully implemented).
    public static let NUMERIC_SHAPING = "java.awt.font.TextAttribute.numericShaping"

    // =========================================================================
    // MARK: - Kerning / ligatures / tracking (Java 6+, included for completeness)
    // =========================================================================

    public static let KERNING = "java.awt.font.TextAttribute.kerning"
    public static let KERNING_ON: Int = 1

    public static let LIGATURES = "java.awt.font.TextAttribute.ligatures"
    public static let LIGATURES_ON: Int = 1

    /// Inter-character spacing adjustment. Value: `Float`.
    public static let TRACKING = "java.awt.font.TextAttribute.tracking"

    public static let TRACKING_TIGHT:  Swift.Float = -0.04
    public static let TRACKING_LOOSE:  Swift.Float =  0.04
  }
}
