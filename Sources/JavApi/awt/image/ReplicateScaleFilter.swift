/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  /// An image filter that scales images using the nearest-neighbour algorithm.
  ///
  /// Pass a `ReplicateScaleFilter` instance to `FilteredImageSource` to
  /// produce a scaled version of an image:
  ///
  /// ```swift
  /// let filter = java.awt.image.ReplicateScaleFilter(160, 120)
  /// let scaled = java.awt.image.FilteredImageSource(original.getSource(), filter)
  /// ```
  ///
  /// Pixels are replicated (or dropped) to match the target dimensions —
  /// no interpolation is performed.  For smoother results use
  /// ``AreaAveragingScaleFilter`` instead.
  ///
  /// Mirrors `java.awt.image.ReplicateScaleFilter` (Java 1.1).
  ///
  /// - Since: Java 1.1
  open class ReplicateScaleFilter: ImageFilter {

    // MARK: - Target dimensions (set in constructor)

    /// Target width in pixels (-1 = preserve aspect from height).
    public var destWidth:  Int
    /// Target height in pixels (-1 = preserve aspect from width).
    public var destHeight: Int

    // MARK: - Source dimensions (filled in by setDimensions)

    /// Source image width, set when the producer calls `setDimensions`.
    public var srcWidth:  Int = -1
    /// Source image height, set when the producer calls `setDimensions`.
    public var srcHeight: Int = -1

    // MARK: - Derived mapping tables

    /// `srcrows[dy]` = the source row index for destination row `dy`.
    internal var srcrows: [Int] = []
    /// `srccols[dx]` = the source column index for destination column `dx`.
    internal var srccols: [Int] = []

    // MARK: - Constructor

    /// Creates a filter that scales to exactly (`width` × `height`) pixels.
    ///
    /// Pass `-1` for one dimension to have it computed from the aspect ratio
    /// of the source image (the same behaviour as Java).
    ///
    /// - Parameters:
    ///   - width:  target width,  or -1 to derive from aspect ratio
    ///   - height: target height, or -1 to derive from aspect ratio
    public init(_ width: Int, _ height: Int) {
      self.destWidth  = width
      self.destHeight = height
      super.init()
    }

    // MARK: - ImageFilter overrides

    /// Receives the source dimensions, resolves any `-1` target dimension from
    /// the aspect ratio, builds the row/column mapping tables, and reports the
    /// target size to the downstream consumer.
    override open func setDimensions(_ width: Int, _ height: Int) {
      srcWidth  = width
      srcHeight = height

      // Resolve -1 dimensions using aspect ratio
      if destWidth  == -1 { destWidth  = Swift.max(1, width  * destHeight / height) }
      if destHeight == -1 { destHeight = Swift.max(1, height * destWidth  / width)  }

      // Build nearest-neighbour mapping tables
      srccols = (0 ..< destWidth).map  { dx in dx * srcWidth  / destWidth  }
      srcrows = (0 ..< destHeight).map { dy in dy * srcHeight / destHeight }

      consumer?.setDimensions(destWidth, destHeight)
    }

    /// Scales a rectangle of byte pixels and forwards the result.
    override open func setPixels(_ x: Int, _ y: Int, _ w: Int, _ h: Int,
                                  _ model: ColorModel,
                                  _ pixels: [UInt8], _ off: Int, _ scansize: Int) {
      guard srcWidth > 0 && srcHeight > 0 else { return }

      // Determine which destination rows fall within this source strip
      let dy1 = srcrows.firstIndex { $0 >= y } ?? destHeight
      let dy2 = (srcrows.lastIndex  { $0 < y + h } ?? -1) + 1

      guard dy1 < dy2 else { return }

      // Build output for rows dy1..<dy2, all destination columns
      var outPixels = [UInt8](repeating: 0, count: (dy2 - dy1) * destWidth)
      for dy in dy1 ..< dy2 {
        let sy = srcrows[dy] - y          // row offset within this strip
        let outRow = (dy - dy1) * destWidth
        for dx in 0 ..< destWidth {
          let sx = srccols[dx]
          outPixels[outRow + dx] = pixels[off + sy * scansize + sx]
        }
      }

      consumer?.setPixels(0, dy1, destWidth, dy2 - dy1,
                          model, outPixels, 0, destWidth)
    }

    /// Scales a rectangle of int pixels and forwards the result.
    override open func setPixels(_ x: Int, _ y: Int, _ w: Int, _ h: Int,
                                  _ model: ColorModel,
                                  _ pixels: [Int], _ off: Int, _ scansize: Int) {
      guard srcWidth > 0 && srcHeight > 0 else { return }

      let dy1 = srcrows.firstIndex { $0 >= y } ?? destHeight
      let dy2 = (srcrows.lastIndex  { $0 < y + h } ?? -1) + 1

      guard dy1 < dy2 else { return }

      var outPixels = [Int](repeating: 0, count: (dy2 - dy1) * destWidth)
      for dy in dy1 ..< dy2 {
        let sy = srcrows[dy] - y
        let outRow = (dy - dy1) * destWidth
        for dx in 0 ..< destWidth {
          let sx = srccols[dx]
          outPixels[outRow + dx] = pixels[off + sy * scansize + sx]
        }
      }

      consumer?.setPixels(0, dy1, destWidth, dy2 - dy1,
                          model, outPixels, 0, destWidth)
    }

    // MARK: - makeInstance

    override open func makeInstance() -> ImageFilter {
      ReplicateScaleFilter(destWidth, destHeight)
    }
  }
}
