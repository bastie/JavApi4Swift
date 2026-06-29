/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  /// Converts the colour space of a `BufferedImage` or `Raster` —
  /// mirrors `java.awt.image.ColorConvertOp`.
  ///
  /// **Supported conversions in this implementation:**
  /// - `TYPE_INT_RGB` / `TYPE_INT_ARGB` ↔ `TYPE_BYTE_GRAY`
  /// - All other combinations: pixels are copied unchanged (identity stub).
  ///
  /// Full `ColorSpace`/`ICC_Profile` support is planned for Java 2D Phase 2.
  ///
  /// - Since: Java 1.2
  public final class ColorConvertOp: BufferedImageOp, RasterOp, @unchecked Sendable {

    private let srcType:  Int?   // nil = infer from source
    private let dstType:  Int
    private let hints:    java.awt.RenderingHints?

    /// Creates an op that converts to the given `BufferedImage` type constant.
    ///
    /// - Parameters:
    ///   - dstType: The target image type, e.g. `BufferedImage.TYPE_BYTE_GRAY`.
    public init(dstType: Int, hints: java.awt.RenderingHints? = nil) {
      self.srcType = nil
      self.dstType = dstType
      self.hints   = hints
    }

    /// Creates an op that converts from `srcType` to `dstType`.
    public init(srcType: Int, dstType: Int,
                hints: java.awt.RenderingHints? = nil) {
      self.srcType = srcType
      self.dstType = dstType
      self.hints   = hints
    }

    public func getRenderingHints() -> java.awt.RenderingHints? { hints }

    // -------------------------------------------------------------------------
    // MARK: BufferedImageOp
    // -------------------------------------------------------------------------

    public func filter(_ src: BufferedImage,
                       _ dst: BufferedImage?) throws -> BufferedImage {
      let dest = dst ?? createCompatibleDestImage(src, nil)
      let w = src.getWidth(), h = src.getHeight()
      let effectiveSrc = srcType ?? src.type
      let effectiveDst = dstType

      for y in 0 ..< h {
        for x in 0 ..< w {
          let argb = src.getRGB(x, y)
          dest.setRGB(x, y, convert(argb, from: effectiveSrc, to: effectiveDst))
        }
      }
      return dest
    }

    public func createCompatibleDestImage(_ src: BufferedImage,
                                          _ destCM: ColorModel?) -> BufferedImage {
      BufferedImage(src.getWidth(), src.getHeight(), dstType)
    }

    // -------------------------------------------------------------------------
    // MARK: RasterOp (identity pass-through — no ColorModel info available)
    // -------------------------------------------------------------------------

    public func filter(_ src: Raster, _ dst: WritableRaster?) throws -> WritableRaster {
      let dest = dst ?? createCompatibleDestRaster(src)
      for y in 0 ..< src.height {
        for x in 0 ..< src.width {
          let px = x + src.minX, py = y + src.minY
          dest.setPixel(x + dest.minX, y + dest.minY,
                        src.getPixel(px, py, nil))
        }
      }
      return dest
    }

    public func createCompatibleDestRaster(_ src: Raster) -> WritableRaster {
      src.createCompatibleWritableRaster()
    }

    // -------------------------------------------------------------------------
    // MARK: Private conversion logic
    // -------------------------------------------------------------------------

    private func convert(_ argb: Int, from srcT: Int, to dstT: Int) -> Int {
      // sRGB → Grayscale
      if dstT == BufferedImage.TYPE_BYTE_GRAY {
        let r = (argb >> 16) & 0xFF
        let g = (argb >>  8) & 0xFF
        let b =  argb        & 0xFF
        // Luminance weights per ITU-R BT.601
        let gray = Int(0.299 * Double(r) + 0.587 * Double(g) + 0.114 * Double(b))
        let a = (argb >> 24) & 0xFF
        return (a << 24) | (gray << 16) | (gray << 8) | gray
      }
      // Grayscale → sRGB: gray channel is in bits 0–7
      if srcT == BufferedImage.TYPE_BYTE_GRAY
          && (dstT == BufferedImage.TYPE_INT_RGB || dstT == BufferedImage.TYPE_INT_ARGB) {
        let gray = argb & 0xFF
        let a    = dstT == BufferedImage.TYPE_INT_ARGB ? 0xFF : ((argb >> 24) & 0xFF)
        return (a << 24) | (gray << 16) | (gray << 8) | gray
      }
      // Identity for unsupported combinations
      return argb
    }
  }
}
