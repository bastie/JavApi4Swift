/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Describes the collection of `GraphicsDevice` objects and `Font` objects
  /// available on a particular platform.
  ///
  /// ```swift
  /// let env = java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment()
  /// let screen = env.getDefaultScreenDevice()
  /// ```
  ///
  /// - Since: Java 1.2
  open class GraphicsEnvironment {

    // =========================================================================
    // MARK: - Singleton / factory
    // =========================================================================

    nonisolated(unsafe) private static var _localEnvironment: java.awt.GraphicsEnvironment?

    /// Returns the local `GraphicsEnvironment`.
    ///
    /// The concrete type is chosen at runtime. When running headless (no
    /// display available) a minimal stub is returned.
    public static func getLocalGraphicsEnvironment() -> java.awt.GraphicsEnvironment {
      if let env = _localEnvironment { return env }
      let env = java.awt.toolkit.headless._HeadlessGraphicsEnvironment()
      _localEnvironment = env
      return env
    }

    // =========================================================================
    // MARK: - Init (protected in Java — use factory)
    // =========================================================================

    public init() {}

    // =========================================================================
    // MARK: - Headless detection
    // =========================================================================

    /// Returns `true` if the local graphics environment is headless.
    public static func isHeadless() -> Bool {
      return getLocalGraphicsEnvironment().isHeadlessInstance()
    }

    /// Returns `true` if this environment is headless (no display).
    open func isHeadlessInstance() -> Bool { return false }

    // =========================================================================
    // MARK: - Devices
    // =========================================================================

    /// Returns an array of all screen devices in this environment.
    open func getScreenDevices() -> [java.awt.GraphicsDevice] {
      fatalError("getScreenDevices() must be overridden by a concrete GraphicsEnvironment")
    }

    /// Returns the default screen device.
    open func getDefaultScreenDevice() -> java.awt.GraphicsDevice {
      fatalError("getDefaultScreenDevice() must be overridden by a concrete GraphicsEnvironment")
    }

    // =========================================================================
    // MARK: - Fonts
    // =========================================================================

    /// Returns an array of all fonts available in this environment.
    open func getAllFonts() -> [java.awt.Font] {
      return getAvailableFontFamilyNames().map {
        java.awt.Font($0, java.awt.Font.PLAIN, 1)
      }
    }

    /// Returns the names of all font families available in this environment.
    open func getAvailableFontFamilyNames() -> [String] {
      return []
    }
  }

}
