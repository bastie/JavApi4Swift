/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  /// Describes single-input/single-output operations on `Raster` objects —
  /// mirrors `java.awt.image.RasterOp`.
  ///
  /// All concrete `BufferedImageOp` implementations also conform to `RasterOp`
  /// so they can be applied to a raw `Raster` without a `ColorModel`.
  ///
  /// - Since: Java 1.2
  public protocol RasterOp {

    /// Performs the operation on the source raster, optionally writing into `dst`.
    ///
    /// If `dst` is `nil` the implementation creates a compatible writable raster.
    ///
    /// - Parameters:
    ///   - src: The source `Raster`.
    ///   - dst: An optional pre-allocated destination raster, or `nil`.
    /// - Returns: The filtered `WritableRaster`.
    /// - Throws: `ImagingOpException` if the filter cannot be applied.
    func filter(_ src: Raster, _ dst: WritableRaster?) throws -> WritableRaster

    /// Returns the bounding box of the filtered destination raster.
    func getBounds2D(_ src: Raster) -> java.awt.geom.Rectangle2D

    /// Creates a zeroed destination `WritableRaster` compatible with `src`.
    func createCompatibleDestRaster(_ src: Raster) -> WritableRaster

    /// Returns the rendering hints for this operation, or `nil`.
    func getRenderingHints() -> java.awt.RenderingHints?
  }
}

// MARK: - Default implementations

extension java.awt.image.RasterOp {

  public func getRenderingHints() -> java.awt.RenderingHints? { return nil }

  public func getBounds2D(_ src: java.awt.image.Raster) -> java.awt.geom.Rectangle2D {
    return java.awt.geom.Rectangle2D.Double(
      Double(src.minX), Double(src.minY),
      Double(src.width), Double(src.height)
    )
  }

  public func createCompatibleDestRaster(
    _ src: java.awt.image.Raster
  ) -> java.awt.image.WritableRaster {
    return src.createCompatibleWritableRaster()
  }
}
