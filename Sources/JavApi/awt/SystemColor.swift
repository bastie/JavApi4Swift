/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// Platform imports at file scope (inside the #if guard below, at top level)
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

extension java.awt {

  /// Symbolic colors representing the color of native GUI objects on the system.
  ///
  /// Mirrors `java.awt.SystemColor`. Each constant returns the current platform
  /// color at call time — dynamic changes (e.g. Dark Mode toggle) are reflected
  /// automatically because all accessor methods are overridden to call the OS.
  ///
  /// Unlike plain `Color`, `SystemColor` instances should be compared via
  /// `getRGB()` rather than `==` (which compares stored components captured at
  /// init time, not live values).
  public final class SystemColor: java.awt.Color, @unchecked Sendable {

    // -------------------------------------------------------------------------
    // MARK: Index constants  (Java API field names kept)
    // -------------------------------------------------------------------------

    public static let DESKTOP               = 0
    public static let ACTIVE_CAPTION        = 1
    public static let ACTIVE_CAPTION_TEXT   = 2
    public static let ACTIVE_CAPTION_BORDER = 3
    public static let INACTIVE_CAPTION      = 4
    public static let INACTIVE_CAPTION_TEXT = 5
    public static let INACTIVE_CAPTION_BORDER = 6
    public static let WINDOW                = 7
    public static let WINDOW_BORDER         = 8
    public static let WINDOW_TEXT           = 9
    public static let MENU                  = 10
    public static let MENU_TEXT             = 11
    public static let TEXT                  = 12
    public static let TEXT_TEXT             = 13
    public static let TEXT_HIGHLIGHT        = 14
    public static let TEXT_HIGHLIGHT_TEXT   = 15
    public static let TEXT_INACTIVE_TEXT    = 16
    public static let CONTROL               = 17
    public static let CONTROL_TEXT          = 18
    public static let CONTROL_HIGHLIGHT     = 19
    public static let CONTROL_LT_HIGHLIGHT  = 20
    public static let CONTROL_SHADOW        = 21
    public static let CONTROL_DK_SHADOW     = 22
    public static let SCROLLBAR             = 23
    public static let INFO                  = 24
    public static let INFO_TEXT             = 25

    public static let NUM_COLORS            = 26

    // -------------------------------------------------------------------------
    // MARK: Static color instances  (Java API field names kept)
    // -------------------------------------------------------------------------

    /// Color of the desktop background.
    public static let desktop              = SystemColor(index: DESKTOP)
    /// Background color for the window title bar when active.
    public static let activeCaption        = SystemColor(index: ACTIVE_CAPTION)
    /// Text color for the active window title bar.
    public static let activeCaptionText    = SystemColor(index: ACTIVE_CAPTION_TEXT)
    /// Border color of the active window.
    public static let activeCaptionBorder  = SystemColor(index: ACTIVE_CAPTION_BORDER)
    /// Background color for the window title bar when inactive.
    public static let inactiveCaption      = SystemColor(index: INACTIVE_CAPTION)
    /// Text color for the inactive window title bar.
    public static let inactiveCaptionText  = SystemColor(index: INACTIVE_CAPTION_TEXT)
    /// Border color of the inactive window.
    public static let inactiveCaptionBorder = SystemColor(index: INACTIVE_CAPTION_BORDER)
    /// Window background color.
    public static let window               = SystemColor(index: WINDOW)
    /// Window border color.
    public static let windowBorder         = SystemColor(index: WINDOW_BORDER)
    /// Window text / foreground color.
    public static let windowText           = SystemColor(index: WINDOW_TEXT)
    /// Menu background color.
    public static let menu                 = SystemColor(index: MENU)
    /// Menu text color.
    public static let menuText             = SystemColor(index: MENU_TEXT)
    /// Background color for text components.
    public static let text                 = SystemColor(index: TEXT)
    /// Foreground color for text components.
    public static let textText             = SystemColor(index: TEXT_TEXT)
    /// Background color for selected / highlighted text.
    public static let textHighlight        = SystemColor(index: TEXT_HIGHLIGHT)
    /// Foreground color for selected / highlighted text.
    public static let textHighlightText    = SystemColor(index: TEXT_HIGHLIGHT_TEXT)
    /// Text color for inactive (disabled) text.
    public static let textInactiveText     = SystemColor(index: TEXT_INACTIVE_TEXT)
    /// Background color for controls (buttons etc.).
    public static let control              = SystemColor(index: CONTROL)
    /// Text color for controls.
    public static let controlText          = SystemColor(index: CONTROL_TEXT)
    /// Highlight color of controls (bright edge).
    public static let controlHighlight     = SystemColor(index: CONTROL_HIGHLIGHT)
    /// Light highlight color of controls.
    public static let controlLtHighlight   = SystemColor(index: CONTROL_LT_HIGHLIGHT)
    /// Shadow color of controls (dark edge).
    public static let controlShadow        = SystemColor(index: CONTROL_SHADOW)
    /// Dark shadow color of controls.
    public static let controlDkShadow      = SystemColor(index: CONTROL_DK_SHADOW)
    /// Scrollbar background color.
    public static let scrollbar            = SystemColor(index: SCROLLBAR)
    /// Tooltip / info-popup background color.
    public static let info                 = SystemColor(index: INFO)
    /// Tooltip / info-popup text color.
    public static let infoText             = SystemColor(index: INFO_TEXT)

    // -------------------------------------------------------------------------
    // MARK: Storage
    // -------------------------------------------------------------------------

    private let index: Int

    // -------------------------------------------------------------------------
    // MARK: Init (private — only the static constants should exist)
    // -------------------------------------------------------------------------

    private init(index: Int) {
      self.index = index
      // Bootstrap stored components with the live value so the parent's
      // stored fields aren't meaninglessly zero.
      let rgb = SystemColor.liveRGB(for: index)
      super.init((rgb >> 16) & 0xFF, (rgb >> 8) & 0xFF, rgb & 0xFF)
    }

    // -------------------------------------------------------------------------
    // MARK: Dynamic accessors  (override Color to return live OS values)
    // -------------------------------------------------------------------------

    override public func getRed()   -> Int { (SystemColor.liveRGB(for: index) >> 16) & 0xFF }
    override public func getGreen() -> Int { (SystemColor.liveRGB(for: index) >>  8) & 0xFF }
    override public func getBlue()  -> Int {  SystemColor.liveRGB(for: index)         & 0xFF }
    override public func getAlpha() -> Int { 255 }
    override public func getRGB()   -> Int { 0xFF_00_00_00 | SystemColor.liveRGB(for: index) }

    // -------------------------------------------------------------------------
    // MARK: Platform colour resolution
    // -------------------------------------------------------------------------

    #if canImport(AppKit)

    /// Resolve the system colour for `index` against the current macOS appearance.
    private static func liveRGB(for index: Int) -> Int {
      nsColorToRGB(nsColor(for: index))
    }

    private static func nsColorToRGB(_ color: NSColor) -> Int {
      guard let srgb = color.usingColorSpace(.sRGB) else { return 0x80_80_80 }
      let r = Int((srgb.redComponent   * 255 + 0.5).rounded(.down))
      let g = Int((srgb.greenComponent * 255 + 0.5).rounded(.down))
      let b = Int((srgb.blueComponent  * 255 + 0.5).rounded(.down))
      return (r.clamped(to: 0...255) << 16)
           | (g.clamped(to: 0...255) <<  8)
           |  b.clamped(to: 0...255)
    }

    // swiftlint:disable cyclomatic_complexity
    private static func nsColor(for index: Int) -> NSColor {
      switch index {
      case DESKTOP:                return .underPageBackgroundColor
      case ACTIVE_CAPTION:         return .controlBackgroundColor   // windowFrameColor deprecated macOS 11
      case ACTIVE_CAPTION_TEXT:    return .headerTextColor
      case ACTIVE_CAPTION_BORDER:  return .separatorColor
      case INACTIVE_CAPTION:       return .windowBackgroundColor
      case INACTIVE_CAPTION_TEXT:  return .disabledControlTextColor
      case INACTIVE_CAPTION_BORDER: return .separatorColor
      case WINDOW:                 return .windowBackgroundColor
      case WINDOW_BORDER:          return .separatorColor
      case WINDOW_TEXT:            return .textColor
      case MENU:                   return .controlColor
      case MENU_TEXT:              return .labelColor
      case TEXT:                   return .controlBackgroundColor
      case TEXT_TEXT:              return .textColor
      case TEXT_HIGHLIGHT:         return .selectedTextBackgroundColor
      case TEXT_HIGHLIGHT_TEXT:    return .selectedTextColor
      case TEXT_INACTIVE_TEXT:     return .disabledControlTextColor
      case CONTROL:                return .controlColor
      case CONTROL_TEXT:           return .controlTextColor
      case CONTROL_HIGHLIGHT:      return .highlightColor
      case CONTROL_LT_HIGHLIGHT:   return .highlightColor
      case CONTROL_SHADOW:         return .shadowColor
      case CONTROL_DK_SHADOW:      return .shadowColor
      case SCROLLBAR:              return .controlColor              // scrollBarColor deprecated macOS 11
      case INFO:                   return .controlColor
      case INFO_TEXT:              return .controlTextColor
      default:                     return .controlColor
      }
    }
    // swiftlint:enable cyclomatic_complexity

    #elseif canImport(UIKit)

    private static func liveRGB(for index: Int) -> Int {
      uiColorToRGB(uiColor(for: index))
    }

    private static func uiColorToRGB(_ color: UIColor) -> Int {
      var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
      color.getRed(&r, green: &g, blue: &b, alpha: &a)
      return (Int(r * 255 + 0.5) << 16)
           | (Int(g * 255 + 0.5) <<  8)
           |  Int(b * 255 + 0.5)
    }

    private static func uiColor(for index: Int) -> UIColor {
      switch index {
      case DESKTOP:                return .systemBackground
      case ACTIVE_CAPTION:         return .systemBackground
      case ACTIVE_CAPTION_TEXT:    return .label
      case ACTIVE_CAPTION_BORDER:  return .separator
      case INACTIVE_CAPTION:       return .secondarySystemBackground
      case INACTIVE_CAPTION_TEXT:  return .secondaryLabel
      case INACTIVE_CAPTION_BORDER: return .separator
      case WINDOW:                 return .systemBackground
      case WINDOW_BORDER:          return .separator
      case WINDOW_TEXT:            return .label
      case MENU:                   return .secondarySystemBackground
      case MENU_TEXT:              return .label
      case TEXT:                   return .systemBackground
      case TEXT_TEXT:              return .label
      case TEXT_HIGHLIGHT:         return .systemBlue
      case TEXT_HIGHLIGHT_TEXT:    return .white
      case TEXT_INACTIVE_TEXT:     return .placeholderText
      case CONTROL:                return .systemGray5
      case CONTROL_TEXT:           return .label
      case CONTROL_HIGHLIGHT:      return .systemGray3
      case CONTROL_LT_HIGHLIGHT:   return .systemGray4
      case CONTROL_SHADOW:         return .systemGray2
      case CONTROL_DK_SHADOW:      return .systemGray
      case SCROLLBAR:              return .systemGray5
      case INFO:                   return .systemYellow
      case INFO_TEXT:              return .label
      default:                     return .systemGray5
      }
    }

    #else

    // Linux / headless — reasonable Material-Design-style defaults
    private static let fallbacks: [Int] = [
      0xF0_F0_F0,  // 0  desktop
      0x31_6A_C8,  // 1  activeCaption
      0xFF_FF_FF,  // 2  activeCaptionText
      0x31_6A_C8,  // 3  activeCaptionBorder
      0x80_80_80,  // 4  inactiveCaption
      0xB0_B0_B0,  // 5  inactiveCaptionText
      0x80_80_80,  // 6  inactiveCaptionBorder
      0xFF_FF_FF,  // 7  window
      0x80_80_80,  // 8  windowBorder
      0x00_00_00,  // 9  windowText
      0xDD_DD_DD,  // 10 menu
      0x00_00_00,  // 11 menuText
      0xFF_FF_FF,  // 12 text
      0x00_00_00,  // 13 textText
      0x31_6A_C8,  // 14 textHighlight
      0xFF_FF_FF,  // 15 textHighlightText
      0x80_80_80,  // 16 textInactiveText
      0xDD_DD_DD,  // 17 control
      0x00_00_00,  // 18 controlText
      0xFF_FF_FF,  // 19 controlHighlight
      0xF0_F0_F0,  // 20 controlLtHighlight
      0x88_88_88,  // 21 controlShadow
      0x44_44_44,  // 22 controlDkShadow
      0xDD_DD_DD,  // 23 scrollbar
      0xFF_FF_E1,  // 24 info
      0x00_00_00,  // 25 infoText
    ]

    private static func liveRGB(for index: Int) -> Int {
      index < fallbacks.count ? fallbacks[index] : 0x80_80_80
    }

    #endif
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
