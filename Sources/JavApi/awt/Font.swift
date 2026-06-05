/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Mirrors `java.awt.Font`.
  ///
  /// Logical font names ("Dialog", "SansSerif", "Serif", "Monospaced",
  /// "DialogInput") are mapped to platform fonts at render time.
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
    }
  }
}
