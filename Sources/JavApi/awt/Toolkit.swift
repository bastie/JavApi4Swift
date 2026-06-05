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

    open func show(_ frame: java.awt.Frame) {}
    open func hide(_ frame: java.awt.Frame) {}
  }
}
