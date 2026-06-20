/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Describes a graphics device available in a particular graphics environment.
  ///
  /// Mirrors `java.awt.GraphicsDevice`. Typical devices are screens, printers,
  /// and off-screen image buffers. Obtain instances via `GraphicsEnvironment`.
  ///
  /// - Since: JavaApi > 0.x (Java 1.2)
  open class GraphicsDevice {

    // =========================================================================
    // MARK: - Type constants
    // =========================================================================

    /// A raster screen device.
    public static let TYPE_RASTER_SCREEN  = 0
    /// A printer device.
    public static let TYPE_PRINTER        = 1
    /// An off-screen image buffer device.
    public static let TYPE_IMAGE_BUFFER   = 2

    // =========================================================================
    // MARK: - Init
    // =========================================================================

    public init() {}

    // =========================================================================
    // MARK: - Identity
    // =========================================================================

    /// Returns a string identifying this device in the local graphics environment.
    open func getIDstring() -> String {
      return "Unknown"
    }

    /// Returns the type of this device (`TYPE_RASTER_SCREEN`, `TYPE_PRINTER`,
    /// or `TYPE_IMAGE_BUFFER`).
    open func getType() -> Int {
      return java.awt.GraphicsDevice.TYPE_RASTER_SCREEN
    }

    // =========================================================================
    // MARK: - Configurations
    // =========================================================================

    /// Returns all `GraphicsConfiguration` objects associated with this device.
    open func getConfigurations() -> [java.awt.GraphicsConfiguration] {
      return [getDefaultConfiguration()]
    }

    /// Returns the default `GraphicsConfiguration` for this device.
    open func getDefaultConfiguration() -> java.awt.GraphicsConfiguration {
      fatalError("getDefaultConfiguration() must be overridden by a concrete GraphicsDevice")
    }

    // =========================================================================
    // MARK: - Full-screen (stub)
    // =========================================================================

    /// Returns `true` if this device supports full-screen exclusive mode.
    open func isFullScreenSupported() -> Bool { return false }

    /// Returns the `Window` currently in full-screen mode, or `nil`.
    open func getFullScreenWindow() -> java.awt.Window? { return nil }

    /// Enters or exits full-screen exclusive mode.
    @MainActor
    open func setFullScreenWindow(_ w: java.awt.Window?) {
      // stub — platform implementations override this
    }
  }
}
