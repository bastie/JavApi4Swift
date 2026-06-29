/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  /// Applies a `LookupTable` to each pixel component —
  /// mirrors `java.awt.image.LookupOp`.
  ///
  /// The alpha channel is passed through unchanged when the lookup table
  /// has fewer entries than bands (i.e. 3 tables for an ARGB image).
  ///
  /// - Since: Java 1.2
  public final class LookupOp: BufferedImageOp, RasterOp, @unchecked Sendable {

    private let table:  LookupTable
    private let hints:  java.awt.RenderingHints?

    public init(_ table: LookupTable, _ hints: java.awt.RenderingHints? = nil) {
      self.table = table
      self.hints = hints
    }

    public func getTable() -> LookupTable { table }

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
          dest.setRGB(x, y, lookupARGB(argb))
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
      let srcIn  = [Int](repeating: 0, count: numBands)
      for y in 0 ..< src.height {
        for x in 0 ..< src.width {
          let px = x + src.minX, py = y + src.minY
          var samples = src.getPixel(px, py, nil)
          let mapped  = table.lookupPixel(samples, srcIn)
          // Pass through any bands beyond the table's numComponents
          for b in 0 ..< numBands {
            samples[b] = b < mapped.count ? mapped[b] : samples[b]
          }
          dest.setPixel(px, py, samples)
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

    private func lookupARGB(_ argb: Int) -> Int {
      let a = (argb >> 24) & 0xFF
      let r = (argb >> 16) & 0xFF
      let g = (argb >>  8) & 0xFF
      let b =  argb        & 0xFF

      let n = table.numComponents
      let mapped = table.lookupPixel(n >= 4 ? [r, g, b, a] : [r, g, b], nil)
      let mr = mapped.count > 0 ? mapped[0] : r
      let mg = mapped.count > 1 ? mapped[1] : g
      let mb = mapped.count > 2 ? mapped[2] : b
      let ma = n >= 4 ? (mapped.count > 3 ? mapped[3] : a) : a
      return (ma << 24) | (mr << 16) | (mg << 8) | mb
    }
  }
}
