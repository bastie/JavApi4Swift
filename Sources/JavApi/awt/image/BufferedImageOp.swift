/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  /// Describes single-input/single-output operations performed on
  /// `BufferedImage` objects — mirrors `java.awt.image.BufferedImageOp`.
  ///
  /// Implementations include `RescaleOp`, `LookupOp`, `ConvolveOp`,
  /// `AffineTransformOp`, `BandCombineOp`, and `ColorConvertOp`.
  ///
  /// - Since: Java 1.2
  public protocol BufferedImageOp {

    /// Performs the operation on the source image, optionally writing to `dst`.
    ///
    /// If `dst` is `nil` the implementation creates a compatible destination
    /// image via `createCompatibleDestImage(_:_:)`.
    ///
    /// - Parameters:
    ///   - src: The source `BufferedImage`.
    ///   - dst: An optional pre-allocated destination image, or `nil`.
    /// - Returns: The filtered `BufferedImage`.
    /// - Throws: `ImagingOpException` if the filter cannot be applied.
    func filter(_ src: BufferedImage, _ dst: BufferedImage?) throws -> BufferedImage

    /// Returns the bounding box of the filtered destination image for a given
    /// source image.
    func getBounds2D(_ src: BufferedImage) -> java.awt.geom.Rectangle2D

    /// Creates a zeroed destination image with the correct size and
    /// `ColorModel` for the given source.
    ///
    /// - Parameters:
    ///   - src: The source `BufferedImage`.
    ///   - destCM: The desired `ColorModel` for the destination, or `nil` to
    ///             use a default compatible model.
    func createCompatibleDestImage(_ src: BufferedImage,
                                   _ destCM: ColorModel?) -> BufferedImage

    /// Returns the rendering hints for this operation, or `nil`.
    func getRenderingHints() -> java.awt.RenderingHints?
  }
}

// MARK: - Default implementations

extension java.awt.image.BufferedImageOp {

  public func getRenderingHints() -> java.awt.RenderingHints? { return nil }

  public func getBounds2D(_ src: java.awt.image.BufferedImage) -> java.awt.geom.Rectangle2D {
    return java.awt.geom.Rectangle2D.Double(
      Double(0), Double(0),
      Double(src.getWidth()), Double(src.getHeight())
    )
  }

  public func createCompatibleDestImage(
    _ src: java.awt.image.BufferedImage,
    _ destCM: java.awt.image.ColorModel?
  ) -> java.awt.image.BufferedImage {
    return java.awt.image.BufferedImage(src.getWidth(), src.getHeight(), src.type)
  }
}
