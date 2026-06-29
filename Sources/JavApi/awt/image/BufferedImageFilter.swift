/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  /// An `ImageFilter` that adapts a `BufferedImageOp` for use in the
  /// `ImageProducer`/`ImageConsumer` pipeline —
  /// mirrors `java.awt.image.BufferedImageFilter`.
  ///
  /// It accumulates all incoming pixel rows into a `BufferedImage`, applies the
  /// `BufferedImageOp` when `imageComplete` is called, and delivers the result
  /// to the downstream consumer as a single batch of ARGB int pixels.
  ///
  /// - Since: Java 1.2
  public final class BufferedImageFilter: ImageFilter, @unchecked Sendable {

    // -------------------------------------------------------------------------
    // MARK: Fields
    // -------------------------------------------------------------------------

    private let bufferedImageOp: any BufferedImageOp

    // Accumulation state — populated during pixel delivery
    private var srcWidth:  Int = 0
    private var srcHeight: Int = 0
    private var srcModel:  ColorModel = ColorModel.getRGBdefault()
    private var intPixels: [Int] = []

    // -------------------------------------------------------------------------
    // MARK: Constructor
    // -------------------------------------------------------------------------

    /// Creates a filter that applies `op` to the image stream.
    public init(_ op: any BufferedImageOp) {
      self.bufferedImageOp = op
      super.init()
    }

    /// Returns the `BufferedImageOp` used by this filter.
    public func getBufferedImageOp() -> any BufferedImageOp { bufferedImageOp }

    // -------------------------------------------------------------------------
    // MARK: ImageFilter overrides
    // -------------------------------------------------------------------------

    public override func makeInstance() -> ImageFilter {
      BufferedImageFilter(bufferedImageOp)
    }

    public override func setDimensions(_ width: Int, _ height: Int) {
      srcWidth  = max(1, width)
      srcHeight = max(1, height)
      intPixels = [Int](repeating: 0, count: srcWidth * srcHeight)
      consumer?.setDimensions(width, height)
    }

    public override func setColorModel(_ model: ColorModel) {
      srcModel = model
      consumer?.setColorModel(model)
    }

    /// Accumulates byte pixels (palette or grey) by converting them to ARGB.
    public override func setPixels(_ x: Int, _ y: Int, _ w: Int, _ h: Int,
                                   _ model: ColorModel,
                                   _ pixels: [UInt8], _ off: Int, _ scansize: Int) {
      for row in 0 ..< h {
        for col in 0 ..< w {
          let srcIdx = off + row * scansize + col
          guard srcIdx < pixels.count else { continue }
          let pixel = Int(pixels[srcIdx])
          let argb  = model.getRGB(pixel)
          let dstIdx = (y + row) * srcWidth + (x + col)
          if dstIdx < intPixels.count { intPixels[dstIdx] = argb }
        }
      }
    }

    /// Accumulates int (ARGB) pixels directly.
    public override func setPixels(_ x: Int, _ y: Int, _ w: Int, _ h: Int,
                                   _ model: ColorModel,
                                   _ pixels: [Int], _ off: Int, _ scansize: Int) {
      for row in 0 ..< h {
        for col in 0 ..< w {
          let srcIdx = off + row * scansize + col
          guard srcIdx < pixels.count else { continue }
          let argb   = model.getRGB(pixels[srcIdx])
          let dstIdx = (y + row) * srcWidth + (x + col)
          if dstIdx < intPixels.count { intPixels[dstIdx] = argb }
        }
      }
    }

    /// Applies the `BufferedImageOp` and delivers the result downstream.
    public override func imageComplete(_ status: Int) {
      guard status != 1, // IMAGEERROR
            srcWidth > 0, srcHeight > 0,
            let cons = consumer
      else {
        consumer?.imageComplete(status)
        return
      }

      // Build a BufferedImage from the accumulated pixels
      let src = BufferedImage(srcWidth, srcHeight, BufferedImage.TYPE_INT_ARGB)
      for y in 0 ..< srcHeight {
        for x in 0 ..< srcWidth {
          src.setRGB(x, y, intPixels[y * srcWidth + x])
        }
      }

      // Apply the op; on failure, pass through the original
      let dst: BufferedImage
      if let filtered = try? bufferedImageOp.filter(src, nil) {
        dst = filtered
      } else {
        dst = src
      }

      // Deliver the result as int pixels
      let dstW = dst.getWidth(), dstH = dst.getHeight()
      cons.setDimensions(dstW, dstH)
      cons.setColorModel(ColorModel.getRGBdefault())
      cons.setHints(2 | 4) // TOPDOWNLEFTRIGHT | COMPLETESCANLINES

      var outPixels = [Int](repeating: 0, count: dstW)
      for y in 0 ..< dstH {
        for x in 0 ..< dstW { outPixels[x] = dst.getRGB(x, y) }
        cons.setPixels(0, y, dstW, 1,
                       ColorModel.getRGBdefault(),
                       outPixels, 0, dstW)
      }
      cons.imageComplete(3) // STATICIMAGEDONE
    }
  }
}
