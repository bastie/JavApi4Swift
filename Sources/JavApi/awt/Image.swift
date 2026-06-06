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

    /// Gibt Ressourcen frei.
    open func flush() {}
  }
}
