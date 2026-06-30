/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  /// Stores pixel samples in separate data array elements, one element per
  /// sample — mirrors `java.awt.image.ComponentSampleModel`.
  ///
  /// Each sample for band `b` at pixel `(x, y)` is located at:
  ///   `bankIndices[b]`, index `bandOffsets[b] + y * scanlineStride + x * pixelStride`
  ///
  /// Concrete subclasses: `PixelInterleavedSampleModel`, `BandedSampleModel`.
  ///
  /// - Since: Java 1.2
  open class ComponentSampleModel: SampleModel {

    public let pixelStride:   Int
    public let scanlineStride: Int
    public let bandOffsets:   [Int]
    public let bankIndices:   [Int]

    public init(dataType: Int, width: Int, height: Int,
                pixelStride: Int, scanlineStride: Int,
                bandOffsets: [Int]) {
      self.pixelStride    = pixelStride
      self.scanlineStride = scanlineStride
      self.bandOffsets    = bandOffsets
      self.bankIndices    = [Int](repeating: 0, count: bandOffsets.count)
      super.init(dataType: dataType, width: width, height: height,
                 numBands: bandOffsets.count)
    }

    public init(dataType: Int, width: Int, height: Int,
                pixelStride: Int, scanlineStride: Int,
                bankIndices: [Int], bandOffsets: [Int]) {
      self.pixelStride    = pixelStride
      self.scanlineStride = scanlineStride
      self.bandOffsets    = bandOffsets
      self.bankIndices    = bankIndices
      super.init(dataType: dataType, width: width, height: height,
                 numBands: bandOffsets.count)
    }

    public override func getSample(_ x: Int, _ y: Int, _ b: Int,
                                   _ data: DataBuffer) -> Int {
      let bank = bankIndices[b]
      let idx  = bandOffsets[b] + y * scanlineStride + x * pixelStride
      return data.getElem(bank, idx)
    }

    public override func setSample(_ x: Int, _ y: Int, _ b: Int,
                                   _ s: Int, _ data: DataBuffer) {
      let bank = bankIndices[b]
      let idx  = bandOffsets[b] + y * scanlineStride + x * pixelStride
      data.setElem(bank, idx, s)
    }

    public override func createDataBuffer() -> DataBuffer {
      let maxOffset = bandOffsets.max() ?? 0
      let size = maxOffset + scanlineStride * height
      return DataBufferByte(size: size)
    }
  }
}
