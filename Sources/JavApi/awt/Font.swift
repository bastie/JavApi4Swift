/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Mirrors `java.awt.Font`.
  ///
  /// Logical font names ("Dialog", "SansSerif", "Serif", "Monospaced",
  /// "DialogInput") are mapped to platform fonts at render time.
  ///
  /// - Since: Java 1.0
  public final class Font: Sendable {

    // -------------------------------------------------------------------------
    // MARK: Style constants
    // -------------------------------------------------------------------------

    public static let PLAIN  = 0
    public static let BOLD   = 1
    public static let ITALIC = 2

    // -------------------------------------------------------------------------
    // MARK: Stored properties
    // -------------------------------------------------------------------------

    public let name:  String
    public let style: Int
    public let size:  Int

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    public init(_ name: String, _ style: Int, _ size: Int) {
      self.name  = name
      self.style = style
      self.size  = size
    }

    // -------------------------------------------------------------------------
    // MARK: Accessors
    // -------------------------------------------------------------------------

    public func getName()  -> String { name  }
    public func getStyle() -> Int    { style }
    public func getSize()  -> Int    { size  }

    public func isBold()   -> Bool { style & Font.BOLD   != 0 }
    public func isItalic() -> Bool { style & Font.ITALIC != 0 }
    public func isPlain()  -> Bool { style == Font.PLAIN      }

    // -------------------------------------------------------------------------
    // MARK: Derive
    // -------------------------------------------------------------------------

    public func deriveFont(_ style: Int)  -> Font { Font(name, style, size)      }
    public func deriveFont(_ size: Float) -> Font { Font(name, style, Int(size)) }
    public func deriveFont(_ style: Int, _ size: Float) -> Font {
      Font(name, style, Int(size))
    }

    // -------------------------------------------------------------------------
    // MARK: Platform PostScript name
    // -------------------------------------------------------------------------

    /// Returns a PostScript / CTFont name for this logical or physical font.
    internal var platformName: String {
#if os(Windows)
      // Windows font name mappings — "Segoe UI" has broad Unicode coverage
      // including geometric shapes (◀▶▲▼ etc.) needed for UI buttons.
      switch name {
      case "Dialog", "SansSerif": return "Segoe UI"
      case "Serif":               return "Georgia"
      case "Monospaced", "DialogInput": return "Courier New"
      default:                    return name
      }
#else
      switch name {
      case "Dialog", "SansSerif":
        switch style {
        case Font.BOLD | Font.ITALIC: return "Helvetica-BoldOblique"
        case Font.BOLD:               return "Helvetica-Bold"
        case Font.ITALIC:             return "Helvetica-Oblique"
        default:                      return "Helvetica"
        }
      case "Serif":
        switch style {
        case Font.BOLD | Font.ITALIC: return "Times-BoldItalic"
        case Font.BOLD:               return "Times-Bold"
        case Font.ITALIC:             return "Times-Italic"
        default:                      return "Times-Roman"
        }
      case "Monospaced", "DialogInput":
        switch style {
        case Font.BOLD | Font.ITALIC: return "Courier-BoldOblique"
        case Font.BOLD:               return "Courier-Bold"
        case Font.ITALIC:             return "Courier-Oblique"
        default:                      return "Courier"
        }
      default:
        // Physical font name — append style suffix if needed
        if isBold() && isItalic() { return "\(name)-BoldItalic" }
        if isBold()               { return "\(name)-Bold"       }
        if isItalic()             { return "\(name)-Italic"      }
        return name
      }
#endif
    }

    // -------------------------------------------------------------------------
    // MARK: LineMetrics / FontRenderContext (Java 1.2)
    // -------------------------------------------------------------------------

    // -------------------------------------------------------------------------
    // MARK: GlyphVector (Java 1.2)
    // -------------------------------------------------------------------------

    /// Creates a `GlyphVector` by mapping each character to its glyph code.
    ///
    /// In this stub the glyph code equals the Unicode scalar value of each
    /// character. Full shaping (ligatures, mark positioning) is not performed.
    ///
    /// - Since: Java 1.2
    public func createGlyphVector(_ frc: java.awt.font.FontRenderContext,
                                  _ str: String) -> java.awt.font.GlyphVector {
      let codes = str.unicodeScalars.map { Int($0.value) }
      return java.awt.font.GlyphVector(font: self, frc: frc, glyphCodes: codes)
    }

    /// Creates a `GlyphVector` from an explicit array of glyph codes.
    ///
    /// - Since: Java 1.2
    public func createGlyphVector(_ frc: java.awt.font.FontRenderContext,
                                  _ glyphCodes: [Int]) -> java.awt.font.GlyphVector {
      java.awt.font.GlyphVector(font: self, frc: frc, glyphCodes: glyphCodes)
    }

    // -------------------------------------------------------------------------
    // MARK: LineMetrics / FontRenderContext (Java 1.2)
    // -------------------------------------------------------------------------

    /// Returns `LineMetrics` for the given string in the given render context.
    ///
    /// - Since: Java 1.2
    public func getLineMetrics(_ str: String,
                               _ frc: java.awt.font.FontRenderContext) -> java.awt.font.LineMetrics {
      java.awt.font.DefaultLineMetrics.make(for: self, numChars: str.count)
    }

    /// Returns `LineMetrics` for a character sub-range.
    ///
    /// - Since: Java 1.2
    public func getLineMetrics(_ str: String,
                               _ beginIndex: Int, _ limit: Int,
                               _ frc: java.awt.font.FontRenderContext) -> java.awt.font.LineMetrics {
      let count = Swift.max(0, limit - beginIndex)
      return java.awt.font.DefaultLineMetrics.make(for: self, numChars: count)
    }
  }
}
