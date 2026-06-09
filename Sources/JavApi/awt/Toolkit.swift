/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

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
    /// 1. `awt.toolkit` system property — `"Headless"` forces `HeadlessToolkit`
    /// 2. `os.name` system property — macOS / iOS / tvOS / visionOS → `SwiftUIToolkit`,
    ///    everything else → `HeadlessToolkit`
    public static func getDefaultToolkit() -> Toolkit {
      // 1. Explicit override via system property
      let override : String? = try? System.getProperty("awt.toolkit")
      if override != nil {
        switch override {
        case "Headless":
          return HeadlessToolkit()
        default:
          break   // unknown value → fall through to platform default
        }
      }

      // 2. Platform default
      let osName = (try? System.getProperty("os.name")) ?? nil
      switch osName {
      case "macOS", "iOS", "tvOS", "visionOS":
#if canImport(SwiftUI)
        return SwiftUIToolkit.shared
#else
        return HeadlessToolkit()
#endif
      default:
        return HeadlessToolkit()
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
  }
}
