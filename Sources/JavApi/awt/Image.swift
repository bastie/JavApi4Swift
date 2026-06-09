/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Abstrakte Basisklasse für Bilder — mirrors `java.awt.Image`.
  ///
  /// Konkrete Unterklassen:
  /// - `java.awt.image.BufferedImage` — In-Memory-Rasterbild
  open class Image {

    public static let SCALE_DEFAULT    = 1
    public static let SCALE_FAST       = 2
    public static let SCALE_SMOOTH     = 4
    public static let SCALE_REPLICATE  = 8
    public static let SCALE_AREA_AVERAGING = 16

    /// Breite in Pixeln, oder -1 wenn noch nicht bekannt.
    open func getWidth(_ observer: ImageObserver? = nil) -> Int  { -1 }
    /// Höhe in Pixeln, oder -1 wenn noch nicht bekannt.
    open func getHeight(_ observer: ImageObserver? = nil) -> Int { -1 }

    /// Returns the `ImageProducer` that produces the pixels for this image.
    ///
    /// - TODO: Concrete subclasses (e.g. `BufferedImage`) should override this
    ///   to return a real producer. The base implementation always returns `nil`.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    open func getSource() -> (any java.awt.image.ImageProducer)? { return nil }

    /// Returns a `Graphics` object that can be used to draw into this image.
    ///
    /// Only off-screen images support this; on-screen images throw
    /// `UnsupportedOperationException` in Java. The base implementation
    /// returns `nil` — override in concrete off-screen subclasses.
    ///
    /// - TODO: Return a real `Graphics` once off-screen rendering is implemented.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    open func getGraphics() -> java.awt.Graphics? { return nil }

    /// Returns a named property of this image.
    ///
    /// Returns `nil` if the property is not defined or not yet available.
    /// Subclasses can override to expose metadata (e.g. DPI, color space).
    ///
    /// - Parameters:
    ///   - name: The property name.
    ///   - observer: An `ImageObserver` to notify when the value is available.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    open func getProperty(_ name: String, _ observer: (any ImageObserver)? = nil) -> AnyObject? {
      return nil
    }

    /// Gibt Ressourcen frei.
    open func flush() {}
  }
}
