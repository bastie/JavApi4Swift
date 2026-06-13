/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {
  /// A `Raster` that supports writing pixel data.
  ///
  /// Mirrors `java.awt.image.WritableRaster`. The primary entry point for
  /// `BufferedImage.getRaster()`.
  ///
  /// - Since: Java 1.2
  public final class WritableRaster: Raster {
    
    // =========================================================================
    // MARK: - Write access
    // =========================================================================
    
    public func setSample(_ x: Int, _ y: Int, _ b: Int, _ s: Int) {
      sampleModel.setSample(x - minX, y - minY, b, s, dataBuffer)
    }
    
    public func setPixel(_ x: Int, _ y: Int, _ iArray: [Int]) {
      sampleModel.setPixel(x - minX, y - minY, iArray, dataBuffer)
    }
    
    /// Copies a rectangular region from `srcRaster` into this raster.
    public func setRect(_ srcRaster: Raster) {
      setRect(0, 0, srcRaster)
    }
    
    public func setRect(_ dx: Int, _ dy: Int, _ srcRaster: Raster) {
      let w = Swift.min(srcRaster.width,  width  - dx)
      let h = Swift.min(srcRaster.height, height - dy)
      guard w > 0, h > 0 else { return }
      for y in 0 ..< h {
        for x in 0 ..< w {
          let samples = srcRaster.getPixel(srcRaster.minX + x,
                                           srcRaster.minY + y, nil)
          setPixel(minX + dx + x, minY + dy + y, samples)
        }
      }
    }
    
    /// Sets a packed int pixel directly (only valid for `SinglePixelPackedSampleModel`).
    public func setDataElements(_ x: Int, _ y: Int, _ obj: Any) {
      guard let packed = sampleModel as? SinglePixelPackedSampleModel else { return }
      if let pixel = obj as? Int {
        packed.setPixelInt(x - minX, y - minY, pixel, dataBuffer)
      } else if let pixel = obj as? Int32 {
        packed.setPixelInt(x - minX, y - minY, Int(pixel), dataBuffer)
      }
    }
    
    /// Returns the packed int pixel (only valid for `SinglePixelPackedSampleModel`).
    public func getDataElements(_ x: Int, _ y: Int) -> Any? {
      guard let packed = sampleModel as? SinglePixelPackedSampleModel else { return nil }
      return packed.getPixelInt(x - minX, y - minY, dataBuffer)
    }
  }
}
