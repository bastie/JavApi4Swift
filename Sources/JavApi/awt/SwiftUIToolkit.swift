/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(SwiftUI)
import SwiftUI
#if os(macOS) && canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

extension java.awt {

  /// SwiftUI-backed toolkit for Apple platforms (macOS, iOS, tvOS, visionOS).
  ///
  /// Delegates window lifecycle to `AWTWindowHost`.
  @MainActor
  public final class SwiftUIToolkit: Toolkit {

    public static let shared = SwiftUIToolkit()

    private override init() {}

    public override func show(_ window: java.awt.Window) {
#if os(macOS)
      // FileDialog verwaltet seinen eigenen nativen Panel in setVisible —
      // kein AWTWindowHost-Fenster nötig.
      if window is java.awt.FileDialog { return }
      if let dialog = window as? java.awt.Dialog {
        AWTWindowHost.shared.openDialog(dialog)
        return
      }
      AWTWindowHost.shared.openNewWindow(for: window)
#else
      AWTWindowHost.shared.show(window)
#endif
    }

    public override func hide(_ window: java.awt.Window) {
      AWTWindowHost.shared.hide(window)
    }

    public override func attachMenuBar(_ menuBar: java.awt.MenuBar?, to frame: java.awt.Frame) {
#if os(macOS)
      AWTWindowHost.shared.attachMenuBar(menuBar, to: frame)
#endif
    }

    // -------------------------------------------------------------------------
    // MARK: Screen properties
    // -------------------------------------------------------------------------

    /// Returns the screen size in pixels using `NSScreen` (macOS) or `UIScreen` (iOS/tvOS).
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public override func getScreenSize() -> java.awt.Dimension {
#if os(macOS) && canImport(AppKit)
      if let screen = AppKit.NSScreen.main {
        let frame = screen.frame
        return java.awt.Dimension(Int(frame.width), Int(frame.height))
      }
      return java.awt.Dimension(0, 0)
#elseif canImport(UIKit)
      let bounds = UIScreen.main.bounds
      return java.awt.Dimension(Int(bounds.width), Int(bounds.height))
#else
      return java.awt.Dimension(0, 0)
#endif
    }

    /// Returns the screen resolution in dots-per-inch.
    ///
    /// Uses `NSScreen.main.backingScaleFactor` × 72 on macOS,
    /// `UIScreen.main.scale` × 160 on iOS (baseline 160 dpi).
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public override func getScreenResolution() -> Int {
#if os(macOS) && canImport(AppKit)
      let scale = AppKit.NSScreen.main?.backingScaleFactor ?? 1.0
      return Int(72.0 * scale)
#elseif canImport(UIKit)
      let scale = UIScreen.main.scale
      return Int(160.0 * scale)
#else
      return 72
#endif
    }

    // -------------------------------------------------------------------------
    // MARK: Font list & metrics
    // -------------------------------------------------------------------------

    /// Returns system font family names via AppKit (macOS) or UIKit (iOS).
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public override func getFontList() -> [String] {
#if os(macOS) && canImport(AppKit)
      return AppKit.NSFontManager.shared.availableFontFamilies
#elseif canImport(UIKit)
      return UIFont.familyNames.sorted()
#else
      return super.getFontList()
#endif
    }

    // -------------------------------------------------------------------------
    // MARK: Color model
    // -------------------------------------------------------------------------

    /// Returns the screen color model.
    ///
    /// Modern Apple displays use 32-bit ARGB; we return the standard RGB default.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public override func getColorModel() -> java.awt.image.ColorModel {
      return java.awt.image.ColorModel.getRGBdefault()
    }
  }
}

#endif
