/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  /// Performs a linear rescaling of pixel data:
  /// `output[b] = clamp(input[b] * scaleFactor[b] + offset[b])` —
  /// mirrors `java.awt.image.RescaleOp`.
  ///
  /// If a single scale factor and offset are supplied they apply to all bands
  /// except alpha. If one value per band is supplied they apply individually.
  ///
  /// - Since: Java 1.2
  public final class RescaleOp: BufferedImageOp, RasterOp, @unchecked Sendable {

    private let scaleFactors: [Float]
    private let offsets:      [Float]
    private let hints:        java.awt.RenderingHints?

    /// Creates a per-band rescale operation.
    public init(_ scaleFactors: [Float], _ offsets: [Float],
                _ hints: java.awt.RenderingHints? = nil) {
      self.scaleFactors = scaleFactors
      self.offsets      = offsets
      self.hints        = hints
    }

    /// Creates a single-value rescale applied to all colour bands.
    public init(_ scaleFactor: Float, _ offset: Float,
                _ hints: java.awt.RenderingHints? = nil) {
      self.scaleFactors = [scaleFactor]
      self.offsets      = [offset]
      self.hints        = hints
    }

    public func getScaleFactors(_ scaleFactors: inout [Float]) -> [Float] {
      return self.scaleFactors
    }

    public func getOffsets(_ offsets: inout [Float]) -> [Float] {
      return self.offsets
    }

    public func getNumFactors() -> Int { scaleFactors.count }

    // -------------------------------------------------------------------------
    // MARK: BufferedImageOp
    // -------------------------------------------------------------------------

    public func filter(_ src: BufferedImage,
                       _ dst: BufferedImage?) throws -> BufferedImage {
      let dest = dst ?? createCompatibleDestImage(src, nil)
      let w = src.getWidth(), h = src.getHeight()
      for y in 0 ..< h {
        for x in 0 ..< w {
          let argb = src.getRGB(x, y)
          dest.setRGB(x, y, rescaleARGB(argb))
        }
      }
      return dest
    }

    public func getRenderingHints() -> java.awt.RenderingHints? { hints }

    // -------------------------------------------------------------------------
    // MARK: RasterOp
    // -------------------------------------------------------------------------

    public func filter(_ src: Raster, _ dst: WritableRaster?) throws -> WritableRaster {
      let dest = dst ?? createCompatibleDestRaster(src)
      let numBands = src.getNumBands()
      for y in 0 ..< src.height {
        for x in 0 ..< src.width {
          var samples = src.getPixel(x + src.minX, y + src.minY, nil)
          for b in 0 ..< numBands {
            let fi = b < scaleFactors.count ? b : 0
            let v  = Float(samples[b]) * scaleFactors[fi] + offsets[fi]
            samples[b] = Int(max(0, min(255, v)))
          }
          dest.setPixel(x + src.minX, y + src.minY, samples)
        }
      }
      return dest
    }

    public func createCompatibleDestRaster(_ src: Raster) -> WritableRaster {
      src.createCompatibleWritableRaster()
    }

    // -------------------------------------------------------------------------
    // MARK: Private helpers
    // -------------------------------------------------------------------------

    private func rescaleARGB(_ argb: Int) -> Int {
      let a = (argb >> 24) & 0xFF
      let r = rescaleComponent((argb >> 16) & 0xFF, band: 0)
      let g = rescaleComponent((argb >>  8) & 0xFF, band: 1)
      let b = rescaleComponent( argb        & 0xFF, band: 2)
      return (a << 24) | (r << 16) | (g << 8) | b
    }

    private func rescaleComponent(_ v: Int, band: Int) -> Int {
      let fi = band < scaleFactors.count ? band : 0
      let out = Float(v) * scaleFactors[fi] + offsets[fi]
      return Int(max(0, min(255, out)))
    }
  }
}
