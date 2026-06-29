/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  /// Applies an `AffineTransform` to a `BufferedImage` or `Raster` —
  /// mirrors `java.awt.image.AffineTransformOp`.
  ///
  /// Supported interpolation types:
  /// - `TYPE_NEAREST_NEIGHBOR` — fast, no blending.
  /// - `TYPE_BILINEAR`         — smooth, 2×2 sample blend.
  ///
  /// `TYPE_BICUBIC` is accepted as a constant but falls back to bilinear.
  ///
  /// - Since: Java 1.2
  public final class AffineTransformOp: BufferedImageOp, RasterOp, @unchecked Sendable {

    /// Nearest-neighbour interpolation.
    public static let TYPE_NEAREST_NEIGHBOR: Int = 1
    /// Bilinear interpolation.
    public static let TYPE_BILINEAR:         Int = 2
    /// Bicubic interpolation (falls back to bilinear in this implementation).
    public static let TYPE_BICUBIC:          Int = 3

    public let transform:          java.awt.geom.AffineTransform
    public let interpolationType:  Int
    private let hints:             java.awt.RenderingHints?

    public init(_ transform: java.awt.geom.AffineTransform,
                _ interpolationType: Int,
                _ hints: java.awt.RenderingHints? = nil) {
      self.transform         = transform
      self.interpolationType = interpolationType
      self.hints             = hints
    }

    public init(_ transform: java.awt.geom.AffineTransform,
                _ hints: java.awt.RenderingHints) {
      self.transform         = transform
      self.interpolationType = AffineTransformOp.TYPE_NEAREST_NEIGHBOR
      self.hints             = hints
    }

    public func getTransform() -> java.awt.geom.AffineTransform { transform }
    public func getInterpolationType() -> Int { interpolationType }
    public func getRenderingHints() -> java.awt.RenderingHints? { hints }

    // -------------------------------------------------------------------------
    // MARK: Bounds
    // -------------------------------------------------------------------------

    public func getBounds2D(_ src: BufferedImage) -> java.awt.geom.Rectangle2D {
      getBounds2DForSize(src.getWidth(), src.getHeight())
    }

    public func getBounds2D(_ src: Raster) -> java.awt.geom.Rectangle2D {
      getBounds2DForSize(src.width, src.height)
    }

    private func getBounds2DForSize(_ w: Int, _ h: Int) -> java.awt.geom.Rectangle2D {
      // Transform the four corners and find the bounding box
      let corners = [(0.0, 0.0), (Double(w), 0.0),
                     (Double(w), Double(h)), (0.0, Double(h))]
      var minX = Double.infinity, maxX = -Double.infinity
      var minY = Double.infinity, maxY = -Double.infinity
      for (cx, cy) in corners {
        let tx = transform.getScaleX() * cx + transform.getShearX() * cy + transform.getTranslateX()
        let ty = transform.getShearY() * cx + transform.getScaleY() * cy + transform.getTranslateY()
        minX = min(minX, tx); maxX = max(maxX, tx)
        minY = min(minY, ty); maxY = max(maxY, ty)
      }
      return java.awt.geom.Rectangle2D.Double(minX, minY, maxX - minX, maxY - minY)
    }

    // -------------------------------------------------------------------------
    // MARK: BufferedImageOp
    // -------------------------------------------------------------------------

    public func filter(_ src: BufferedImage,
                       _ dst: BufferedImage?) throws -> BufferedImage {
      let bounds = getBounds2D(src)
      let dw = max(1, Int(bounds.getWidth().rounded()))
      let dh = max(1, Int(bounds.getHeight().rounded()))
      let dest = dst ?? BufferedImage(dw, dh, src.type)

      // Compute the inverse transform for backward mapping
      guard let inv = try? transform.createInverse() else {
        throw ImagingOpException("AffineTransformOp: non-invertible transform")
      }
      let srcW = src.getWidth(), srcH = src.getHeight()
      let ox = bounds.getX(), oy = bounds.getY()

      for y in 0 ..< dh {
        for x in 0 ..< dw {
          let dx = Double(x) + ox
          let dy = Double(y) + oy
          // Map destination pixel back to source
          let sx = inv.getScaleX() * dx + inv.getShearX() * dy + inv.getTranslateX()
          let sy = inv.getShearY() * dx + inv.getScaleY() * dy + inv.getTranslateY()

          let argb: Int
          if interpolationType == AffineTransformOp.TYPE_NEAREST_NEIGHBOR {
            argb = nearestNeighbour(src, sx, sy, srcW, srcH)
          } else {
            argb = bilinear(src, sx, sy, srcW, srcH)
          }
          dest.setRGB(x, y, argb)
        }
      }
      return dest
    }

    // -------------------------------------------------------------------------
    // MARK: RasterOp
    // -------------------------------------------------------------------------

    public func filter(_ src: Raster, _ dst: WritableRaster?) throws -> WritableRaster {
      let bounds = getBounds2D(src)
      let dw = max(1, Int(bounds.getWidth().rounded()))
      let dh = max(1, Int(bounds.getHeight().rounded()))
      let dest = dst ?? src.createCompatibleWritableRaster(dw, dh)

      guard let inv = try? transform.createInverse() else {
        throw ImagingOpException("AffineTransformOp: non-invertible transform")
      }
      let ox = bounds.getX(), oy = bounds.getY()
      let nBands = src.getNumBands()

      for y in 0 ..< dh {
        for x in 0 ..< dw {
          let dx = Double(x) + ox, dy = Double(y) + oy
          let sx = inv.getScaleX() * dx + inv.getShearX() * dy + inv.getTranslateX()
          let sy = inv.getShearY() * dx + inv.getScaleY() * dy + inv.getTranslateY()

          let samples = sampleRaster(src, sx, sy, nBands)
          dest.setPixel(x + dest.minX, y + dest.minY, samples)
        }
      }
      return dest
    }

    public func createCompatibleDestRaster(_ src: Raster) -> WritableRaster {
      let bounds = getBounds2D(src)
      let dw = max(1, Int(bounds.getWidth().rounded()))
      let dh = max(1, Int(bounds.getHeight().rounded()))
      return src.createCompatibleWritableRaster(dw, dh)
    }

    // -------------------------------------------------------------------------
    // MARK: Private interpolation helpers
    // -------------------------------------------------------------------------

    private func nearestNeighbour(_ src: BufferedImage,
                                  _ sx: Double, _ sy: Double,
                                  _ w: Int, _ h: Int) -> Int {
      let ix = Int(sx.rounded()), iy = Int(sy.rounded())
      guard ix >= 0, ix < w, iy >= 0, iy < h else { return 0 }
      return src.getRGB(ix, iy)
    }

    private func bilinear(_ src: BufferedImage,
                          _ sx: Double, _ sy: Double,
                          _ w: Int, _ h: Int) -> Int {
      let x0 = Int(sx), y0 = Int(sy)
      let x1 = min(x0 + 1, w - 1), y1 = min(y0 + 1, h - 1)
      guard x0 >= 0, y0 >= 0, x0 < w, y0 < h else { return 0 }

      let tx = sx - Double(x0), ty = sy - Double(y0)
      func blend(_ tl: Int, _ tr: Int, _ bl: Int, _ br: Int) -> Int {
        let top = Double(tl) * (1 - tx) + Double(tr) * tx
        let bot = Double(bl) * (1 - tx) + Double(br) * tx
        return Int((top * (1 - ty) + bot * ty).rounded())
      }
      func ch(_ argb: Int, _ shift: Int) -> Int { (argb >> shift) & 0xFF }

      let tl = src.getRGB(x0, y0), tr = src.getRGB(x1, y0)
      let bl = src.getRGB(x0, y1), br = src.getRGB(x1, y1)
      let a = blend(ch(tl,24), ch(tr,24), ch(bl,24), ch(br,24))
      let r = blend(ch(tl,16), ch(tr,16), ch(bl,16), ch(br,16))
      let g = blend(ch(tl, 8), ch(tr, 8), ch(bl, 8), ch(br, 8))
      let b = blend(ch(tl, 0), ch(tr, 0), ch(bl, 0), ch(br, 0))
      return (a << 24) | (r << 16) | (g << 8) | b
    }

    private func sampleRaster(_ src: Raster,
                               _ sx: Double, _ sy: Double,
                               _ nBands: Int) -> [Int] {
      let ix = Int(sx.rounded()), iy = Int(sy.rounded())
      guard ix >= 0, ix < src.width, iy >= 0, iy < src.height else {
        return [Int](repeating: 0, count: nBands)
      }
      return src.getPixel(ix + src.minX, iy + src.minY, nil)
    }
  }
}
