/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(SwiftUI)
import SwiftUI
#if os(macOS) && canImport(AppKit)
import AppKit
#elseif os(watchOS) && canImport(WatchKit)
import WatchKit
#elseif canImport(UIKit)
import UIKit
#endif

extension java.awt.toolkit.swiftui {

  /// SwiftUI-backed toolkit for Apple platforms (macOS, iOS, tvOS, visionOS).
  ///
  /// Delegates window lifecycle to `_SwiftUIWindowHost`.
  @MainActor
  public final class SwiftUIToolkit: java.awt.Toolkit {

    public static let shared = SwiftUIToolkit()

    private override init() {}

    public override func show(_ window: java.awt.Window) {
#if os(macOS)
      // FileDialog verwaltet seinen eigenen nativen Panel in setVisible —
      // kein _SwiftUIWindowHost-Fenster nötig.
      if window is java.awt.FileDialog { return }
      if let dialog = window as? java.awt.Dialog {
        _SwiftUIWindowHost.shared.openDialog(dialog)
        return
      }
      _SwiftUIWindowHost.shared.openNewWindow(for: window)
#else
      _SwiftUIWindowHost.shared.show(window)
#endif
    }

    public override func hide(_ window: java.awt.Window) {
      _SwiftUIWindowHost.shared.hide(window)
    }

    public override func attachMenuBar(_ menuBar: java.awt.MenuBar?, to frame: java.awt.Frame) {
#if os(macOS)
      _SwiftUIWindowHost.shared.attachMenuBar(menuBar, to: frame)
#endif
    }

    public override func showPopupMenu(_ menu: java.awt.PopupMenu, origin: java.awt.Component, x: Int, y: Int) {
#if os(macOS)
      menu._showNative(origin: origin, x: x, y: y)
#endif
    }

    public override func isFocusOwner(_ component: java.awt.Component) -> Bool {
      return _SwiftUIFocusManager.shared.focusOwner === component
    }

    public override func closeDialog(_ dialog: java.awt.Dialog) {
#if os(macOS)
      _SwiftUIWindowHost.shared.closeDialog(dialog)
#else
      super.closeDialog(dialog)
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
#elseif os(watchOS) && canImport(WatchKit)
      let bounds = WKInterfaceDevice.current().screenBounds
      return java.awt.Dimension(Int(bounds.width), Int(bounds.height))
#elseif os(visionOS)
      // visionOS has no fixed screen — return (0,0) as headless sentinel
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
    /// The base DPI follows the Java AWT convention per platform:
    /// - **macOS**: baseline 72 dpi (historical PostScript/Mac standard),
    ///   multiplied by `backingScaleFactor` (2.0 on Retina → 144 dpi).
    /// - **iOS / tvOS**: baseline 160 dpi (Apple's point-per-inch reference
    ///   for non-Retina iPhone), multiplied by `UIScreen.main.scale`
    ///   (2.0 or 3.0 on Retina → 320 / 480 dpi).
    /// - **watchOS**: baseline 160 dpi × `WKInterfaceDevice.screenScale`.
    /// - **visionOS**: no physical screen; returns a reasonable 96 dpi default.
    ///
    /// The differing baselines (72 vs. 160) reflect the physical pixel densities
    /// of the respective device families and match what `java.awt.Toolkit`
    /// implementations return on those platforms.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public override func getScreenResolution() -> Int {
#if os(macOS) && canImport(AppKit)
      let scale = AppKit.NSScreen.main?.backingScaleFactor ?? 1.0
      return Int(72.0 * scale)
#elseif os(watchOS) && canImport(WatchKit)
      let scale = WKInterfaceDevice.current().screenScale
      return Int(160.0 * scale)
#elseif os(visionOS)
      return 96   // no physical screen concept on visionOS
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
