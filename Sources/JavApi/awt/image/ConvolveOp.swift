/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  /// Convolves a `BufferedImage` or `Raster` with a `Kernel` —
  /// mirrors `java.awt.image.ConvolveOp`.
  ///
  /// Edge handling is controlled by `edgeCondition`:
  /// - `EDGE_ZERO_FILL` — fills out-of-bounds samples with zero.
  /// - `EDGE_NO_OP`     — copies source pixels unchanged at the border.
  ///
  /// Only the colour channels (R, G, B) are convolved; alpha is copied through.
  ///
  /// - Since: Java 1.2
  public final class ConvolveOp: BufferedImageOp, RasterOp, @unchecked Sendable {

    /// Border pixels are set to zero.
    public static let EDGE_ZERO_FILL: Int = 0
    /// Border pixels are copied from the source unchanged.
    public static let EDGE_NO_OP:     Int = 1

    public let kernel:        Kernel
    public let edgeCondition: Int
    private  let hints:       java.awt.RenderingHints?

    public init(_ kernel: Kernel,
                _ edgeCondition: Int = EDGE_NO_OP,
                _ hints: java.awt.RenderingHints? = nil) {
      self.kernel        = kernel
      self.edgeCondition = edgeCondition
      self.hints         = hints
    }

    public func getKernel()  -> Kernel { kernel }
    public func getRenderingHints() -> java.awt.RenderingHints? { hints }

    // -------------------------------------------------------------------------
    // MARK: BufferedImageOp
    // -------------------------------------------------------------------------

    public func filter(_ src: BufferedImage,
                       _ dst: BufferedImage?) throws -> BufferedImage {
      let dest = dst ?? createCompatibleDestImage(src, nil)
      let w = src.getWidth(), h = src.getHeight()
      let kw = kernel.width,  kh = kernel.height
      let kx = kernel.xOrigin, ky = kernel.yOrigin

      for y in 0 ..< h {
        for x in 0 ..< w {
          // Determine whether we are at the border
          let atBorder = x < kx || x >= w - (kw - 1 - kx)
                      || y < ky || y >= h - (kh - 1 - ky)

          if atBorder {
            switch edgeCondition {
            case ConvolveOp.EDGE_ZERO_FILL:
              dest.setRGB(x, y, 0)
            default: // EDGE_NO_OP
              dest.setRGB(x, y, src.getRGB(x, y))
            }
            continue
          }

          var sr: Float = 0, sg: Float = 0, sb: Float = 0
          for ky2 in 0 ..< kh {
            for kx2 in 0 ..< kw {
              let coeff = kernel.getElement(kx2, ky2)
              guard coeff != 0 else { continue }
              let px = x + kx2 - kx
              let py = y + ky2 - ky
              let argb = src.getRGB(px, py)
              sr += coeff * Float((argb >> 16) & 0xFF)
              sg += coeff * Float((argb >>  8) & 0xFF)
              sb += coeff * Float( argb        & 0xFF)
            }
          }
          let a  = (src.getRGB(x, y) >> 24) & 0xFF
          let ri = Int(max(0, min(255, sr)))
          let gi = Int(max(0, min(255, sg)))
          let bi = Int(max(0, min(255, sb)))
          dest.setRGB(x, y, (a << 24) | (ri << 16) | (gi << 8) | bi)
        }
      }
      return dest
    }

    // -------------------------------------------------------------------------
    // MARK: RasterOp
    // -------------------------------------------------------------------------

    public func filter(_ src: Raster, _ dst: WritableRaster?) throws -> WritableRaster {
      let dest   = dst ?? createCompatibleDestRaster(src)
      let w      = src.width,  h  = src.height
      let kw     = kernel.width, kh = kernel.height
      let kxO    = kernel.xOrigin, kyO = kernel.yOrigin
      let nBands = src.getNumBands()

      for y in 0 ..< h {
        for x in 0 ..< w {
          let atBorder = x < kxO || x >= w - (kw - 1 - kxO)
                      || y < kyO || y >= h - (kh - 1 - kyO)

          if atBorder {
            switch edgeCondition {
            case ConvolveOp.EDGE_ZERO_FILL:
              dest.setPixel(x + src.minX, y + src.minY,
                            [Int](repeating: 0, count: nBands))
            default:
              dest.setPixel(x + src.minX, y + src.minY,
                            src.getPixel(x + src.minX, y + src.minY, nil))
            }
            continue
          }

          var acc = [Float](repeating: 0, count: nBands)
          for ky2 in 0 ..< kh {
            for kx2 in 0 ..< kw {
              let coeff = kernel.getElement(kx2, ky2)
              guard coeff != 0 else { continue }
              let px = x + src.minX + kx2 - kxO
              let py = y + src.minY + ky2 - kyO
              let samples = src.getPixel(px, py, nil)
              for b in 0 ..< nBands { acc[b] += coeff * Float(samples[b]) }
            }
          }
          let out = acc.map { Int(max(0, min(255, $0))) }
          dest.setPixel(x + src.minX, y + src.minY, out)
        }
      }
      return dest
    }

    public func createCompatibleDestRaster(_ src: Raster) -> WritableRaster {
      src.createCompatibleWritableRaster()
    }
  }
}
