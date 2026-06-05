/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.awt {
  public final class Color: Sendable {

    // -------------------------------------------------------------------------
    // MARK: Components  (0.0 … 1.0)
    // -------------------------------------------------------------------------

    public let red:   Double
    public let green: Double
    public let blue:  Double
    public let alpha: Double

    // -------------------------------------------------------------------------
    // MARK: Standard color constants  (Java field names kept)
    // -------------------------------------------------------------------------

    public static let black     = Color(0,   0,   0  )
    public static let BLACK     = black
    public static let blue      = Color(0,   0,   255)
    public static let BLUE      = blue
    public static let cyan      = Color(0,   255, 255)
    public static let CYAN      = cyan
    public static let darkGray  = Color(64,  64,  64 )
    public static let DARK_GRAY = darkGray
    public static let gray      = Color(128, 128, 128)
    public static let GRAY      = gray
    public static let green     = Color(0,   255, 0  )
    public static let GREEN     = green
    public static let lightGray  = Color(192, 192, 192)
    public static let LIGHT_GRAY = lightGray
    public static let magenta   = Color(255, 0,   255)
    public static let MAGENTA   = magenta
    public static let orange    = Color(255, 200, 0  )
    public static let ORANGE    = orange
    public static let pink      = Color(255, 175, 175)
    public static let PINK      = pink
    public static let red       = Color(255, 0,   0  )
    public static let RED       = red
    public static let white     = Color(255, 255, 255)
    public static let WHITE     = white
    public static let yellow    = Color(255, 255, 0  )
    public static let YELLOW    = yellow

    // -------------------------------------------------------------------------
    // MARK: Constructors
    // -------------------------------------------------------------------------

    /// Creates a color from 0–255 RGB(A) integer components.
    public init(_ r: Int, _ g: Int, _ b: Int, _ a: Int = 255) {
      red   = Double(r.clamped(to: 0...255)) / 255.0
      green = Double(g.clamped(to: 0...255)) / 255.0
      blue  = Double(b.clamped(to: 0...255)) / 255.0
      alpha = Double(a.clamped(to: 0...255)) / 255.0
    }

    /// Creates a color from a packed `0xRRGGBB` integer (alpha = 255).
    public convenience init(rgb: Int) {
      self.init((rgb >> 16) & 0xFF, (rgb >> 8) & 0xFF, rgb & 0xFF)
    }

    /// Creates a color from a packed ARGB integer.
    ///
    /// - Parameter rgba: Packed value `0xAARRGGBB`.
    /// - Parameter hasAlpha: When `true` the high byte is used as alpha;
    ///   otherwise alpha is 255.
    public convenience init(rgba: Int, hasAlpha: Bool) {
      if hasAlpha {
        self.init((rgba >> 16) & 0xFF,
                  (rgba >>  8) & 0xFF,
                   rgba        & 0xFF,
                  (rgba >> 24) & 0xFF)
      } else {
        self.init(rgb: rgba)
      }
    }

    /// Parses a hex color string (`"#RRGGBB"`, `"0xRRGGBB"`, or decimal).
    /// - Throws: `IllegalArgumentException` if the string cannot be parsed.
    /// - Returns Color instance
    public static func decode(_ nm: String) throws -> Color {
      let trimmed = nm.trimmingCharacters(in: .whitespaces)
      var hex = trimmed
      if hex.hasPrefix("#")  { hex = String(hex.dropFirst()) }
      else if hex.lowercased().hasPrefix("0x") { hex = String(hex.dropFirst(2)) }
      guard let value = Int(hex, radix: 16) else {
        throw IllegalArgumentException("Color.decode: cannot parse '\(nm)'")
      }
      return Color(rgb: value)
    }

    // -------------------------------------------------------------------------
    // MARK: Component accessors
    // -------------------------------------------------------------------------

    public func getRed()   -> Int { Int((red   * 255).rounded()) }
    public func getGreen() -> Int { Int((green * 255).rounded()) }
    public func getBlue()  -> Int { Int((blue  * 255).rounded()) }
    public func getAlpha() -> Int { Int((alpha * 255).rounded()) }

    /// - Returns the color as a packed `0xAARRGGBB` integer.
    public func getRGB() -> Int {
      (getAlpha() << 24) | (getRed() << 16) | (getGreen() << 8) | getBlue()
    }

    /// - Returns the RGB components as a `[Float]` array (length 3, 0.0–1.0).
    public func getRGBComponents() -> [Float] {
      [Float(red), Float(green), Float(blue)]
    }

    /// - Returns the RGBA components as a `[Float]` array (length 4, 0.0–1.0).
    public func getRGBAComponents() -> [Float] {
      [Float(red), Float(green), Float(blue), Float(alpha)]
    }

    // -------------------------------------------------------------------------
    // MARK: Brightness
    // -------------------------------------------------------------------------

    private static let FACTOR: Double = 0.7

    /// - Returns a brighter version of this color.
    public func brighter() -> Color {
      var r = getRed(), g = getGreen(), b = getBlue()
      let i = Int((1.0 / (1.0 - Color.FACTOR)).rounded())
      if r == 0 && g == 0 && b == 0 { return Color(i, i, i) }
      if r > 0 && r < i { r = i }
      if g > 0 && g < i { g = i }
      if b > 0 && b < i { b = i }
      return Color(Swift.min(Int(Double(r) / Color.FACTOR), 255),
                   Swift.min(Int(Double(g) / Color.FACTOR), 255),
                   Swift.min(Int(Double(b) / Color.FACTOR), 255),
                   getAlpha())
    }

    /// - Returns a darker version of this color.
    public func darker() -> Color {
      Color(Swift.max(Int(Double(getRed())   * Color.FACTOR), 0),
            Swift.max(Int(Double(getGreen()) * Color.FACTOR), 0),
            Swift.max(Int(Double(getBlue())  * Color.FACTOR), 0),
            getAlpha())
    }

    // -------------------------------------------------------------------------
    // MARK: HSB support
    // -------------------------------------------------------------------------

    /// Converts RGB (0–255) to HSB.
    ///
    /// - Returns: `[hue, saturation, brightness]` each in range 0.0–1.0.
    public static func RGBtoHSB(_ r: Int, _ g: Int, _ b: Int) -> [Float] {
      let cmax = Swift.max(r, g, b)
      let cmin = Swift.min(r, g, b)
      let brightness = Float(cmax) / 255.0
      let saturation: Float = cmax != 0
        ? Float(cmax - cmin) / Float(cmax) : 0
      let hue: Float
      if saturation == 0 {
        hue = 0
      } else {
        let rc = Float(cmax - r) / Float(cmax - cmin)
        let gc = Float(cmax - g) / Float(cmax - cmin)
        let bc = Float(cmax - b) / Float(cmax - cmin)
        var h: Float
        if r == cmax      { h = bc - gc }
        else if g == cmax { h = 2 + rc - bc }
        else              { h = 4 + gc - rc }
        h /= 6
        hue = h < 0 ? h + 1 : h
      }
      return [hue, saturation, brightness]
    }

    /// Converts HSB values (0.0–1.0) to a packed `0xRRGGBB` integer.
    public static func HSBtoRGB(_ hue: Float, _ saturation: Float,
                                 _ brightness: Float) -> Int {
      var r = 0, g = 0, b = 0
      if saturation == 0 {
        let v = Int(brightness * 255 + 0.5)
        r = v; g = v; b = v
      } else {
        let h = (hue - Foundation.floor(hue)) * 6.0
        let f = h - Foundation.floor(h)
        let p = brightness * (1 - saturation)
        let q = brightness * (1 - saturation * f)
        let t = brightness * (1 - saturation * (1 - f))
        switch Int(h) {
        case 0: r = Int(brightness*255+0.5); g = Int(t*255+0.5); b = Int(p*255+0.5)
        case 1: r = Int(q*255+0.5); g = Int(brightness*255+0.5); b = Int(p*255+0.5)
        case 2: r = Int(p*255+0.5); g = Int(brightness*255+0.5); b = Int(t*255+0.5)
        case 3: r = Int(p*255+0.5); g = Int(q*255+0.5); b = Int(brightness*255+0.5)
        case 4: r = Int(t*255+0.5); g = Int(p*255+0.5); b = Int(brightness*255+0.5)
        default: r = Int(brightness*255+0.5); g = Int(p*255+0.5); b = Int(q*255+0.5)
        }
      }
      return 0xFF_00_00_00 | (r << 16) | (g << 8) | b
    }

    /// Creates a `Color` from HSB values (0.0–1.0 each).
    public static func getHSBColor(_ h: Float, _ s: Float,
                                    _ b: Float) -> Color {
      Color(rgb: HSBtoRGB(h, s, b) & 0x00_FF_FF_FF)
    }
  }
}

// -------------------------------------------------------------------------
// MARK: - Helpers
// -------------------------------------------------------------------------

private extension Int {
  func clamped(to range: ClosedRange<Int>) -> Int {
    Swift.max(range.lowerBound, Swift.min(range.upperBound, self))
  }
}
