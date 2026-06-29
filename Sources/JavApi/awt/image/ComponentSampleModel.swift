/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  // ---------------------------------------------------------------------------
  // MARK: - ComponentSampleModel
  // ---------------------------------------------------------------------------

  /// Stores pixel samples in separate data array elements, one element per
  /// sample — mirrors `java.awt.image.ComponentSampleModel`.
  ///
  /// Each sample for band `b` at pixel `(x, y)` is located at:
  ///   `bankIndices[b]`, index `bandOffsets[b] + y * scanlineStride + x * pixelStride`
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

  // ---------------------------------------------------------------------------
  // MARK: - PixelInterleavedSampleModel
  // ---------------------------------------------------------------------------

  /// A `ComponentSampleModel` where all bands are stored in a single bank with
  /// pixel samples interleaved (R,G,B,A,R,G,B,A,…) —
  /// mirrors `java.awt.image.PixelInterleavedSampleModel`.
  ///
  /// - Since: Java 1.2
  public final class PixelInterleavedSampleModel: ComponentSampleModel {

    public override init(dataType: Int, width: Int, height: Int,
                pixelStride: Int, scanlineStride: Int,
                bandOffsets: [Int]) {
      super.init(dataType: dataType, width: width, height: height,
                 pixelStride: pixelStride, scanlineStride: scanlineStride,
                 bandOffsets: bandOffsets)
    }
  }

  // ---------------------------------------------------------------------------
  // MARK: - BandedSampleModel
  // ---------------------------------------------------------------------------

  /// A `ComponentSampleModel` where each band is stored in its own data bank —
  /// mirrors `java.awt.image.BandedSampleModel`.
  ///
  /// Layout per band `b`:  bank `b`, index `y * scanlineStride + x`.
  ///
  /// - Since: Java 1.2
  public final class BandedSampleModel: ComponentSampleModel {

    public init(dataType: Int, width: Int, height: Int, numBands: Int) {
      let bankIndices  = Array(0 ..< numBands)
      let bandOffsets  = [Int](repeating: 0, count: numBands)
      super.init(dataType: dataType, width: width, height: height,
                 pixelStride: 1, scanlineStride: width,
                 bankIndices: bankIndices, bandOffsets: bandOffsets)
    }

    public init(dataType: Int, width: Int, height: Int,
                scanlineStride: Int, bankIndices: [Int], bandOffsets: [Int]) {
      super.init(dataType: dataType, width: width, height: height,
                 pixelStride: 1, scanlineStride: scanlineStride,
                 bankIndices: bankIndices, bandOffsets: bandOffsets)
    }

    public override func createDataBuffer() -> DataBuffer {
      let size = scanlineStride * height
      switch dataType {
      case DataBuffer.TYPE_BYTE:
        return DataBufferByte(dataArrays: [[UInt8]](repeating: [UInt8](repeating: 0, count: size),
                                                    count: numBands), size: size)
      case DataBuffer.TYPE_SHORT:
        return DataBufferShort(dataArrays: [[Int16]](repeating: [Int16](repeating: 0, count: size),
                                                     count: numBands), size: size)
      case DataBuffer.TYPE_USHORT:
        return DataBufferUShort(dataArrays: [[UInt16]](repeating: [UInt16](repeating: 0, count: size),
                                                       count: numBands), size: size)
      default:
        return DataBufferInt(dataArrays: [[Int32]](repeating: [Int32](repeating: 0, count: size),
                                                   count: numBands), size: size)
      }
    }
  }

  // ---------------------------------------------------------------------------
  // MARK: - MultiPixelPackedSampleModel
  // ---------------------------------------------------------------------------

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
      // Bits per data element
      let bitsPerElem: Int
      switch dataType {
      case DataBuffer.TYPE_BYTE:   bitsPerElem = 8
      case DataBuffer.TYPE_USHORT: bitsPerElem = 16
      default:                     bitsPerElem = 32
      }
      self.pixelsPerDataElement = bitsPerElem / numberOfBits
      self.pixelBitStride       = numberOfBits
      self.bitMask              = (1 << numberOfBits) - 1
      // scanlineStride in data-elements
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
