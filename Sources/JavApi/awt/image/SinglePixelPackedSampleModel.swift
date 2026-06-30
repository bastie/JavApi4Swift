/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  /// Stores each pixel as a single packed `int` (e.g. ARGB).
  ///
  /// Mirrors `java.awt.image.SinglePixelPackedSampleModel`.
  ///
  /// - Since: Java 1.2
  public final class SinglePixelPackedSampleModel: SampleModel {

    public let bitMasks:   [Int]
    public let bitOffsets: [Int]
    public let scanlineStride: Int

    public init(dataType: Int, width: Int, height: Int,
                scanlineStride: Int, bitMasks: [Int]) {
      self.bitMasks       = bitMasks
      self.scanlineStride = scanlineStride
      self.bitOffsets = bitMasks.map { mask -> Int in
        guard mask != 0 else { return 0 }
        var m = mask, offset = 0
        while (m & 1) == 0 { m >>= 1; offset += 1 }
        return offset
      }
      super.init(dataType: dataType, width: width, height: height,
                 numBands: bitMasks.count)
    }

    public convenience init(dataType: Int, width: Int, height: Int,
                            bitMasks: [Int]) {
      self.init(dataType: dataType, width: width, height: height,
                scanlineStride: width, bitMasks: bitMasks)
    }

    public override func getSample(_ x: Int, _ y: Int, _ b: Int,
                                   _ data: DataBuffer) -> Int {
      let pixel = data.getElem(y * scanlineStride + x)
      return (pixel & bitMasks[b]) >> bitOffsets[b]
    }

    public override func setSample(_ x: Int, _ y: Int, _ b: Int,
                                   _ s: Int, _ data: DataBuffer) {
      let idx   = y * scanlineStride + x
      var pixel = data.getElem(idx)
      pixel = (pixel & ~bitMasks[b]) | ((s << bitOffsets[b]) & bitMasks[b])
      data.setElem(idx, pixel)
    }

    /// Returns the packed pixel value at `(x, y)`.
    public func getPixelInt(_ x: Int, _ y: Int, _ data: DataBuffer) -> Int {
      data.getElem(y * scanlineStride + x)
    }

    /// Sets the packed pixel value at `(x, y)`.
    public func setPixelInt(_ x: Int, _ y: Int, _ pixel: Int,
                            _ data: DataBuffer) {
      data.setElem(y * scanlineStride + x, pixel)
    }

    public override func createDataBuffer() -> DataBuffer {
      DataBufferInt(size: scanlineStride * height)
    }

    public override func getNumDataElements() -> Int { 1 }
  }
}
