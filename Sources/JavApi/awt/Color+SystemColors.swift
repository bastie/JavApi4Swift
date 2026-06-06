/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// Platform-aware Color extensions for java.awt.Color.
//
// Note: Most system colours (control, text, textHighlight, etc.) are now
// provided by `java.awt.SystemColor` as proper class constants.
// This file keeps only colours that have no direct Java SystemColor equivalent
// but are needed for platform-native rendering.

#if canImport(AppKit)
import AppKit

extension java.awt.Color {
  /// The platform focus-ring colour (macOS: NSColor.keyboardFocusIndicatorColor).
  /// Not part of Java's SystemColor; exposed here as a rendering aid.
  public static var keyboardFocusIndicator: java.awt.Color {
    let ns = NSColor.keyboardFocusIndicatorColor
      .usingColorSpace(.sRGB) ?? NSColor.systemBlue
    return java.awt.Color(
      Int((ns.redComponent   * 255 + 0.5).rounded(.down)),
      Int((ns.greenComponent * 255 + 0.5).rounded(.down)),
      Int((ns.blueComponent  * 255 + 0.5).rounded(.down)))
  }
}

#elseif canImport(UIKit)
import UIKit

extension java.awt.Color {
  /// The platform focus-ring colour (iOS: UIColor.systemBlue).
  public static var keyboardFocusIndicator: java.awt.Color {
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    UIColor.systemBlue.getRed(&r, green: &g, blue: &b, alpha: &a)
    return java.awt.Color(Int(r * 255), Int(g * 255), Int(b * 255))
  }
}

#else
// Linux / headless fallback
extension java.awt.Color {
  public static var keyboardFocusIndicator: java.awt.Color {
    java.awt.Color(0x00, 0x78, 0xD7)
  }
}
#endif
