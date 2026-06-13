/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  /// Maps pixel values to ARGB color components — mirrors `java.awt.image.ColorModel`.
  ///
  /// This is the abstract base class for all color models.  Concrete subclasses
  /// (`DirectColorModel`, `IndexColorModel`) provide the actual pixel-to-color
  /// mapping.
  ///
  /// - Since: Java 1.0
  open class ColorModel {

    // -------------------------------------------------------------------------
    // MARK: Fields
    // -------------------------------------------------------------------------

    /// Number of bits per pixel.
    public let pixel_bits: Int

    // -------------------------------------------------------------------------
    // MARK: Constructor
    // -------------------------------------------------------------------------

    public init(_ bits: Int) {
      self.pixel_bits = bits
    }

    // -------------------------------------------------------------------------
    // MARK: Abstract methods (override in subclasses)
    // -------------------------------------------------------------------------

    /// Returns the red component (0–255) for the given pixel value.
    open func getRed(_ pixel: Int) -> Int { 0 }

    /// Returns the green component (0–255) for the given pixel value.
    open func getGreen(_ pixel: Int) -> Int { 0 }

    /// Returns the blue component (0–255) for the given pixel value.
    open func getBlue(_ pixel: Int) -> Int { 0 }

    /// Returns the alpha component (0–255) for the given pixel value.
    open func getAlpha(_ pixel: Int) -> Int { 255 }

    /// Returns the packed ARGB value for the given pixel.
    open func getRGB(_ pixel: Int) -> Int {
      (getAlpha(pixel) << 24)
        | (getRed(pixel)   << 16)
        | (getGreen(pixel) <<  8)
        |  getBlue(pixel)
    }

    // -------------------------------------------------------------------------
    // MARK: Static factory
    // -------------------------------------------------------------------------

    /// The default RGB color model (8 bits per channel, packed ARGB).
    nonisolated(unsafe) public static var RGBdefault: ColorModel = DirectColorModel (32, 0x00FF0000, 0x0000FF00, 0x000000FF, Int(bitPattern: 0xFF000000))

    /// Returns the default RGB color model.
    public static func getRGBdefault() -> ColorModel { RGBdefault }
  }
}
