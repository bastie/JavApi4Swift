/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  /// Packs multiple one-band pixels into a single data element —
  /// mirrors `java.awt.image.MultiPixelPackedSampleModel`.
  ///
  /// Supports 1, 2, and 4 bits per pixel for TYPE_BYTE or TYPE_INT.
  ///
  /// - Since: Java 1.2
  public final class MultiPixelPackedSampleModel: SampleModel {

    public let numberOfBits:  Int
    public let scanlineStride: Int
    public let dataBitOffset: Int

    private let pixelsPerDataElement: Int
    private let pixelBitStride:       Int
    private let bitMask:              Int

    public init(dataType: Int, width: Int, height: Int, numberOfBits: Int,
                scanlineStride: Int = 0, dataBitOffset: Int = 0) {
      self.numberOfBits    = numberOfBits
      self.dataBitOffset   = dataBitOffset
      let bitsPerElem: Int
      switch dataType {
      case DataBuffer.TYPE_BYTE:   bitsPerElem = 8
      case DataBuffer.TYPE_USHORT: bitsPerElem = 16
      default:                     bitsPerElem = 32
      }
      self.pixelsPerDataElement = bitsPerElem / numberOfBits
      self.pixelBitStride       = numberOfBits
      self.bitMask              = (1 << numberOfBits) - 1
      let defaultStride = (width + pixelsPerDataElement - 1) / pixelsPerDataElement
      self.scanlineStride = scanlineStride == 0 ? defaultStride : scanlineStride
      super.init(dataType: dataType, width: width, height: height, numBands: 1)
    }

    private func bitOffset(x: Int) -> Int {
      dataBitOffset + x * pixelBitStride
    }

    public override func getSample(_ x: Int, _ y: Int, _ b: Int,
                                   _ data: DataBuffer) -> Int {
      let bo      = bitOffset(x: x)
      let elemIdx = y * scanlineStride + bo / (pixelsPerDataElement * numberOfBits)
      let shift   = (pixelsPerDataElement - 1 - (bo / numberOfBits) % pixelsPerDataElement) * numberOfBits
      return (data.getElem(elemIdx) >> shift) & bitMask
    }

    public override func setSample(_ x: Int, _ y: Int, _ b: Int,
                                   _ s: Int, _ data: DataBuffer) {
      let bo      = bitOffset(x: x)
      let elemIdx = y * scanlineStride + bo / (pixelsPerDataElement * numberOfBits)
      let shift   = (pixelsPerDataElement - 1 - (bo / numberOfBits) % pixelsPerDataElement) * numberOfBits
      var elem    = data.getElem(elemIdx)
      elem = (elem & ~(bitMask << shift)) | ((s & bitMask) << shift)
      data.setElem(elemIdx, elem)
    }

    public override func createDataBuffer() -> DataBuffer {
      let size = scanlineStride * height
      switch dataType {
      case DataBuffer.TYPE_BYTE:   return DataBufferByte(size: size)
      case DataBuffer.TYPE_USHORT: return DataBufferUShort(size: size)
      default:                     return DataBufferInt(size: size)
      }
    }

    public override func getNumDataElements() -> Int { 1 }
  }
}
