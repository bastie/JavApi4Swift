/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {
  public final class Color : Sendable {
    public let red:   Double  // 0.0 … 1.0
    public let green: Double
    public let blue:  Double
    public let alpha: Double
    
    public static let black   = Color(0, 0, 0)
    public static let BLACK   = black
    public static let white   = Color(255, 255, 255)
    public static let WHITE   = white
    public static let red     = Color(255, 0, 0)
    public static let RED     = red

    public init(_ r: Int, _ g: Int, _ b: Int, _ a: Int = 255) {
      red   = Double(r) / 255.0
      green = Double(g) / 255.0
      blue  = Double(b) / 255.0
      alpha = Double(a) / 255.0
    }
    
    public func getRed()   -> Int { Int(red   * 255) }
    public func getGreen() -> Int { Int(green * 255) }
    public func getBlue()  -> Int { Int(blue  * 255) }
    public func getAlpha() -> Int { Int(alpha * 255) }
    public func getRGB()   -> Int {(getAlpha() << 24) | (getRed() << 16) | (getGreen() << 8) | getBlue()
    }
  }
  
}
