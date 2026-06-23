/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  /// An image filter that scales images using area-averaging interpolation.
  ///
  /// Extends ``ReplicateScaleFilter`` with a higher-quality algorithm: when
  /// scaling *down*, each output pixel is the weighted average of all source
  /// pixels that contribute to it, producing smoother results than nearest-
  /// neighbour replication.  When scaling *up*, the filter falls back to
  /// nearest-neighbour (same as the superclass) because there are no extra
  /// source pixels to average over.
  ///
  /// ```swift
  /// let filter = java.awt.image.AreaAveragingScaleFilter(80, 60)
  /// let scaled = java.awt.image.FilteredImageSource(original.getSource(), filter)
  /// ```
  ///
  /// Mirrors `java.awt.image.AreaAveragingScaleFilter` (Java 1.1).
  ///
  /// - Since: Java 1.1
  public class AreaAveragingScaleFilter: ReplicateScaleFilter {

    // MARK: - Pixel accumulation buffers

    /// Accumulated ARGB int pixels for the complete source image.
    /// Populated incrementally as `setPixels` calls arrive.
    private var accum:    [Int]  = []
    private var accumSet: Bool   = false

    // MARK: - Constructor

    /// Creates a filter that scales to exactly (`width` × `height`) pixels
    /// using area averaging.
    ///
    /// - Parameters:
    ///   - width:  target width,  or -1 to derive from aspect ratio
    ///   - height: target height, or -1 to derive from aspect ratio
    public override init(_ width: Int, _ height: Int) {
      super.init(width, height)
    }

    // MARK: - setHints

    /// Overrides the hint flags to request sequential, top-down delivery so
    /// that pixel accumulation is straightforward.
    override public func setHints(_ hints: Int) {
      // We need all pixels before we can average, so request sequential order.
      consumer?.setHints(Self.TOPDOWNLEFTRIGHT |
                         Self.COMPLETESCANLINES |
                         Self.SINGLEPASS        |
                         Self.SINGLEFRAME)
    }

    // MARK: - Pixel accumulation helpers

    private func ensureAccum() {
      if !accumSet && srcWidth > 0 && srcHeight > 0 {
        accum    = [Int](repeating: 0, count: srcWidth * srcHeight)
        accumSet = true
      }
    }

    // MARK: - setPixels (byte variant) — accumulate into int buffer

    override public func setPixels(_ x: Int, _ y: Int, _ w: Int, _ h: Int,
                                    _ model: ColorModel,
                                    _ pixels: [UInt8], _ off: Int, _ scansize: Int) {
      ensureAccum()
      guard accumSet else { return }
      for row in 0 ..< h {
        for col in 0 ..< w {
          let srcIdx  = off + row * scansize + col
          let dstIdx  = (y + row) * srcWidth + (x + col)
          accum[dstIdx] = model.getRGB(Int(pixels[srcIdx]))
        }
      }
    }

    // MARK: - setPixels (int variant) — accumulate into int buffer

    override public func setPixels(_ x: Int, _ y: Int, _ w: Int, _ h: Int,
                                    _ model: ColorModel,
                                    _ pixels: [Int], _ off: Int, _ scansize: Int) {
      ensureAccum()
      guard accumSet else { return }
      let isDefault = model === ColorModel.getRGBdefault()
      for row in 0 ..< h {
        for col in 0 ..< w {
          let srcIdx = off + row * scansize + col
          let dstIdx = (y + row) * srcWidth + (x + col)
          accum[dstIdx] = isDefault ? pixels[srcIdx] : model.getRGB(pixels[srcIdx])
        }
      }
    }

    // MARK: - imageComplete — perform area-averaging and flush to consumer

    override public func imageComplete(_ status: Int) {
      // Only average-scale on a successful, complete delivery.
      if status == Self.STATICIMAGEDONE && accumSet
         && srcWidth > 0 && srcHeight > 0
         && destWidth > 0 && destHeight > 0 {

        let scaleDown = destWidth < srcWidth || destHeight < srcHeight

        if scaleDown {
          // Area-averaging pass
          var out = [Int](repeating: 0, count: destWidth * destHeight)
          let scaleX = Double(srcWidth)  / Double(destWidth)
          let scaleY = Double(srcHeight) / Double(destHeight)

          for dy in 0 ..< destHeight {
            let sy0 = Int( Double(dy)     * scaleY)
            let sy1 = Int((Double(dy + 1) * scaleY).rounded(.up))
            let clampedSy1 = Swift.min(sy1, srcHeight)

            for dx in 0 ..< destWidth {
              let sx0 = Int( Double(dx)     * scaleX)
              let sx1 = Int((Double(dx + 1) * scaleX).rounded(.up))
              let clampedSx1 = Swift.min(sx1, srcWidth)

              var sumA = 0, sumR = 0, sumG = 0, sumB = 0, count = 0
              for sy in sy0 ..< clampedSy1 {
                for sx in sx0 ..< clampedSx1 {
                  let rgb = accum[sy * srcWidth + sx]
                  sumA += (rgb >> 24) & 0xFF
                  sumR += (rgb >> 16) & 0xFF
                  sumG += (rgb >>  8) & 0xFF
                  sumB +=  rgb        & 0xFF
                  count += 1
                }
              }
              if count > 0 {
                out[dy * destWidth + dx] =
                  ((sumA / count) << 24) |
                  ((sumR / count) << 16) |
                  ((sumG / count) <<  8) |
                   (sumB / count)
              }
            }
          }

          let rgbDefault = ColorModel.getRGBdefault()
          consumer?.setDimensions(destWidth, destHeight)
          consumer?.setColorModel(rgbDefault)
          consumer?.setHints(Self.TOPDOWNLEFTRIGHT |
                             Self.COMPLETESCANLINES |
                             Self.SINGLEPASS        |
                             Self.SINGLEFRAME)
          consumer?.setPixels(0, 0, destWidth, destHeight,
                              rgbDefault, out, 0, destWidth)
        } else {
          // Upscaling: nearest-neighbour via superclass logic
          let rgbDefault = ColorModel.getRGBdefault()
          consumer?.setDimensions(destWidth, destHeight)
          consumer?.setColorModel(rgbDefault)
          consumer?.setHints(Self.TOPDOWNLEFTRIGHT |
                             Self.COMPLETESCANLINES |
                             Self.SINGLEPASS        |
                             Self.SINGLEFRAME)
          var out = [Int](repeating: 0, count: destWidth * destHeight)
          for dy in 0 ..< destHeight {
            let sy = srcrows[dy]
            for dx in 0 ..< destWidth {
              let sx = srccols[dx]
              out[dy * destWidth + dx] = accum[sy * srcWidth + sx]
            }
          }
          consumer?.setPixels(0, 0, destWidth, destHeight,
                              rgbDefault, out, 0, destWidth)
        }
      }

      consumer?.imageComplete(status)
    }

    // MARK: - makeInstance

    override public func makeInstance() -> ImageFilter {
      AreaAveragingScaleFilter(destWidth, destHeight)
    }
  }
}
