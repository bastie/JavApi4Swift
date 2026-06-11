/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#elseif canImport(Android)
import Android
#elseif canImport(WinSDK)
import WinSDK
#else
// Fallback for platforms without a known C stdlib module (e.g. WASM, Bionic)
@_silgen_name("exit") func exit(_ code: Int32) -> Never
#endif

extension java.awt {

  /// Abstract base class for AWT platform toolkits.
  ///
  /// Mirrors `java.awt.Toolkit`. The concrete implementation is chosen at
  /// runtime based on the `awt.toolkit` system property (override) or
  /// `os.name` (platform default).
  ///
  /// ### Usage
  /// ```swift
  /// let toolkit = java.awt.Toolkit.getDefaultToolkit()
  /// toolkit.show(myFrame)
  /// ```
  @MainActor
  open class Toolkit {

    // -------------------------------------------------------------------------
    // MARK: Factory
    // -------------------------------------------------------------------------

    /// Returns the platform-appropriate Toolkit.
    ///
    /// Resolution order:
    /// 1. `awt.toolkit` system property:
    ///    - `"Headless"` → `HeadlessToolkit`
    ///    - `"SwiftUI"`  → `SwiftUIToolkit` (Apple platforms) or `HeadlessToolkit`
    ///    - `"GDI"` → `GDIToolkit` (Windows) or `HeadlessToolkit`
    ///    - `"X11"` → `X11Toolkit` (Linux / FreeBSD) or `HeadlessToolkit`
    /// 2. `os.name` system property — macOS / iOS / tvOS / visionOS → `SwiftUIToolkit`,
    ///    Windows → `GDIToolkit`, Linux / FreeBSD → `X11Toolkit`, everything else → `HeadlessToolkit`
    public static func getDefaultToolkit() -> Toolkit {
      // 1. Explicit override via system property
      let override : String? = try? System.getProperty("awt.toolkit")
      if override != nil {
        switch override {
        case "Headless":
          return java.awt.toolkit.HeadlessToolkit()
        case "SwiftUI":
#if canImport(SwiftUI)
          return java.awt.toolkit.swiftui.SwiftUIToolkit.shared
#else
          return java.awt.toolkit.HeadlessToolkit()
#endif
        case "GDI":
#if os(Windows)
          return java.awt.toolkit.gdi.GDIToolkit.shared
#else
          return java.awt.toolkit.HeadlessToolkit()
#endif
        case "X11":
#if os(Linux) || os(FreeBSD)
          return java.awt.toolkit.x11.X11Toolkit.shared
#else
          return java.awt.toolkit.HeadlessToolkit()
#endif
        default:
          break   // unknown value → fall through to platform default
        }
      }

      // 2. Platform default
      let osName = (try? System.getProperty("os.name")) ?? nil
      switch osName {
      case "macOS", "iOS", "tvOS", "visionOS":
#if canImport(SwiftUI)
        return java.awt.toolkit.swiftui.SwiftUIToolkit.shared
#else
        return java.awt.toolkit.HeadlessToolkit()
#endif
      case "Windows":
#if os(Windows)
        return java.awt.toolkit.gdi.GDIToolkit.shared
#else
        return java.awt.toolkit.HeadlessToolkit()
#endif
      case "Linux", "FreeBSD":
#if os(Linux) || os(FreeBSD)
        return java.awt.toolkit.x11.X11Toolkit.shared
#else
        return java.awt.toolkit.HeadlessToolkit()
#endif
      default:
        return java.awt.toolkit.HeadlessToolkit()
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Window lifecycle — override in subclasses
    // -------------------------------------------------------------------------

    open func show(_ window: java.awt.Window) {}
    open func hide(_ window: java.awt.Window) {}

    /// Bindet eine `MenuBar` an einen `Frame`.
    /// Plattform-Implementierungen überschreiben diese Methode.
    open func attachMenuBar(_ menuBar: MenuBar?, to frame: Frame) {}

    /// Closes a `Dialog` and tears down any platform-modal loop or sheet.
    ///
    /// The base implementation falls back to `hide(_:)`.
    /// Override in platform-specific subclasses for proper modal teardown
    /// (e.g. ending an `NSApp.runModal` loop or an AppKit sheet).
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.1)
    open func closeDialog(_ dialog: Dialog) {
      hide(dialog)
    }

    // -------------------------------------------------------------------------
    // MARK: Screen properties
    // -------------------------------------------------------------------------

    /// Returns the screen size in pixels.
    ///
    /// Override in platform-specific subclasses. The base implementation
    /// returns a zero-size `Dimension`.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    open func getScreenSize() -> Dimension {
      return Dimension(0, 0)
    }

    /// Returns the screen resolution in dots-per-inch.
    ///
    /// Override in platform-specific subclasses. The base implementation
    /// returns 72 (a common default).
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    open func getScreenResolution() -> Int {
      return 72
    }

    /// Synchronizes this toolkit's graphics state.
    ///
    /// On most modern platforms this is a no-op. Override in subclasses
    /// that buffer drawing operations.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    open func sync() {}

    // -------------------------------------------------------------------------
    // MARK: Color model
    // -------------------------------------------------------------------------

    /// Returns the `ColorModel` of the screen (default: 24-bit RGB).
    /// Override in platform subclasses for accurate screen color depth.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    open func getColorModel() -> java.awt.image.ColorModel {
      return java.awt.image.ColorModel.getRGBdefault()
    }

    // -------------------------------------------------------------------------
    // MARK: Font list & metrics
    // -------------------------------------------------------------------------

    /// Returns the names of the available fonts on this platform.
    ///
    /// On Apple platforms returns system font family names via AppKit/UIKit;
    /// elsewhere returns the five logical AWT font names.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    open func getFontList() -> [String] {
      return ["Dialog", "DialogInput", "Monospaced", "SansSerif", "Serif"]
    }

    /// Returns the `FontMetrics` for the specified font.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    open func getFontMetrics(_ font: java.awt.Font) -> java.awt.FontMetrics {
      return java.awt.FontMetrics(font)
    }

    // -------------------------------------------------------------------------
    // MARK: Application lifecycle
    // -------------------------------------------------------------------------

    /// Java 1.0–style entry point: shows `frame` and starts the platform
    /// event loop.
    ///
    /// Internally calls `frame.setVisible(true)` and then `runEventLoop()`.
    /// Prefer `EventQueue.invokeLater` (Java 1.1 style) for new code.
    ///
    /// - Since: JavaApi > 0.19.1
    open func run(frame: Frame) {
      frame.setVisible(true)
      runEventLoop()
    }

    /// Drains the `EventQueue` and enters the platform's native event loop.
    ///
    /// Called implicitly by `run(frame:)` and — on platforms that need an
    /// explicit loop start — directly from `@main`.
    ///
    /// The base implementation (headless / Linux) only drains pending
    /// `EventQueue` runnables and returns immediately.
    /// Platform toolkits (`SwiftUIToolkit`, `Direct2DToolkit`) override this
    /// to additionally block in their native event loop.
    ///
    /// - Since: JavaApi > 0.19.1
    open func runEventLoop() {
      java.awt.EventQueue.drainAndMarkRunning()
    }

    /// Terminates the application cleanly.
    ///
    /// Delegates to the platform-appropriate mechanism:
    /// - **macOS/iOS**: `NSApp.terminate(nil)`
    /// - **Windows**: `PostQuitMessage(0)` — exits the Win32 message loop
    /// - **Headless / Linux**: `exit(0)`
    ///
    /// Call this instead of platform-specific APIs so that application code
    /// stays free of `#if canImport(AppKit)` / `#if os(Windows)` guards.
    ///
    /// - Since: JavaApi > 0.19.1
    open func terminate() {
      exit(0)
    }

    // -------------------------------------------------------------------------
    // MARK: Image loading
    // -------------------------------------------------------------------------

    /// Loads a named image resource from the application bundle.
    ///
    /// Override in platform-specific subclasses to load images via native APIs
    /// (e.g. `NSImage` on macOS, `UIImage` on iOS).  The base implementation
    /// always returns `nil`.
    ///
    /// - Parameter name: The resource name (without extension), looked up in
    ///   the module bundle's `Assets.xcassets/AppIcon.appiconset` or as a
    ///   top-level named image.
    /// - Returns: A `java.awt.Image` ready for use with `Graphics.drawImage`,
    ///   or `nil` if the image could not be found or loaded.
    ///
    /// - Since: JavaApi > 0.19.1
    open func loadImage(named name: String) -> java.awt.Image? {
      return nil
    }

    // -------------------------------------------------------------------------
    // MARK: PopupMenu
    // -------------------------------------------------------------------------

    /// Shows a `PopupMenu` at position `(x, y)` relative to `origin`.
    ///
    /// The base implementation is a no-op. Override in platform-specific
    /// subclasses to display a native context menu.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.1)
    open func showPopupMenu(_ menu: PopupMenu, origin: Component, x: Int, y: Int) {}

    // -------------------------------------------------------------------------
    // MARK: Focus
    // -------------------------------------------------------------------------

    /// Returns `true` if `component` currently holds keyboard focus.
    ///
    /// The base implementation always returns `false` (headless / unknown platform).
    /// Override in platform-specific subclasses to query the native focus system.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.1)
    open func isFocusOwner(_ component: Component) -> Bool {
      return false
    }
  }
}
