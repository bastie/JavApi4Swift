/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

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
}
