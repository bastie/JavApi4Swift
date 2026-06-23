/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Describes the characteristics of a graphics destination.
  ///
  /// Mirrors `java.awt.GraphicsConfiguration`. Each `GraphicsDevice` may have
  /// multiple configurations (e.g. different colour depths or display modes).
  ///
  /// - Since: JavaApi > 0.x (Java 1.2)
  open class GraphicsConfiguration {

    // =========================================================================
    // MARK: - Init
    // =========================================================================

    public init() {}

    // =========================================================================
    // MARK: - Device
    // =========================================================================

    /// Returns the `GraphicsDevice` associated with this configuration.
    open func getDevice() -> java.awt.GraphicsDevice {
      fatalError("getDevice() must be overridden by a concrete GraphicsConfiguration")
    }

    // =========================================================================
    // MARK: - Bounds
    // =========================================================================

    /// Returns the bounds of this `GraphicsConfiguration` in device space.
    open func getBounds() -> java.awt.Rectangle {
      return java.awt.Rectangle(0, 0, 0, 0)
    }

    // =========================================================================
    // MARK: - Transform (stub — AffineTransform available in java.awt.geom)
    // =========================================================================

    // createCompatibleImage / getDefaultTransform / getNormalizingTransform are
    // deferred until ColorModel and BufferedImage are available.
  }
}
