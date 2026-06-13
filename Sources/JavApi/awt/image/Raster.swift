/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  // ---------------------------------------------------------------------------
  // MARK: - Raster
  // ---------------------------------------------------------------------------

  /// A rectangular grid of pixels stored in a `DataBuffer` and interpreted by
  /// a `SampleModel`.
  ///
  /// Mirrors `java.awt.image.Raster`. Use `WritableRaster` to modify pixel data.
  ///
  /// - Since: Java 1.2
  open class Raster {

    public let sampleModel: SampleModel
    public let dataBuffer:  DataBuffer
    public let width:       Int
    public let height:      Int
    /// Origin of this raster within its parent coordinate system.
    public let minX:        Int
    public let minY:        Int

    public init(sampleModel: SampleModel, dataBuffer: DataBuffer,
                minX: Int = 0, minY: Int = 0) {
      self.sampleModel = sampleModel
      self.dataBuffer  = dataBuffer
      self.width       = sampleModel.width
      self.height      = sampleModel.height
      self.minX        = minX
      self.minY        = minY
    }

    // =========================================================================
    // MARK: - Factory methods
    // =========================================================================

    /// Creates a `WritableRaster` with packed int storage (e.g. ARGB).
    public static func createPackedRaster(dataType: Int,
                                          width: Int, height: Int,
                                          bandMasks: [Int],
                                          location: java.awt.Point? = nil) -> WritableRaster {
      let sm = SinglePixelPackedSampleModel(
        dataType: dataType, width: width, height: height, bitMasks: bandMasks)
      let db = DataBufferInt(size: width * height)
      return WritableRaster(sampleModel: sm, dataBuffer: db,
                            minX: location?.x ?? 0, minY: location?.y ?? 0)
    }

    /// Creates an interleaved `WritableRaster` (one band per byte).
    public static func createInterleavedRaster(dataType: Int,
                                               width: Int, height: Int,
                                               numBands: Int,
                                               location: java.awt.Point? = nil) -> WritableRaster {
      // Default ARGB packed model for TYPE_INT; byte model otherwise
      let bandMasks: [Int]
      switch numBands {
      case 4: bandMasks = [0x00FF0000, 0x0000FF00, 0x000000FF, Int(bitPattern: 0xFF000000)]
      case 3: bandMasks = [0x00FF0000, 0x0000FF00, 0x000000FF]
      default: bandMasks = [0xFF]
      }
      let sm = SinglePixelPackedSampleModel(
        dataType: dataType, width: width, height: height, bitMasks: bandMasks)
      let db = DataBufferInt(size: width * height)
      return WritableRaster(sampleModel: sm, dataBuffer: db,
                            minX: location?.x ?? 0, minY: location?.y ?? 0)
    }

    // =========================================================================
    // MARK: - Sample access
    // =========================================================================

    public func getNumBands() -> Int { sampleModel.numBands }

    public func getSample(_ x: Int, _ y: Int, _ b: Int) -> Int {
      sampleModel.getSample(x - minX, y - minY, b, dataBuffer)
    }

    public func getPixel(_ x: Int, _ y: Int, _ iArray: [Int]?) -> [Int] {
      sampleModel.getPixel(x - minX, y - minY, iArray, dataBuffer)
    }

    /// Returns a sub-raster (read-only view) without copying data.
    public func createChild(parentX: Int, parentY: Int,
                            width: Int, height: Int,
                            childMinX: Int, childMinY: Int) -> Raster {
      Raster(sampleModel: sampleModel, dataBuffer: dataBuffer,
             minX: childMinX, minY: childMinY)
    }

    /// Returns a `WritableRaster` with the same model and a fresh `DataBuffer`.
    public func createCompatibleWritableRaster() -> WritableRaster {
      let db = sampleModel.createDataBuffer()
      return WritableRaster(sampleModel: sampleModel, dataBuffer: db)
    }

    /// Returns a `WritableRaster` with the same model and a fresh `DataBuffer`
    /// of the given size.
    public func createCompatibleWritableRaster(_ w: Int, _ h: Int) -> WritableRaster {
      let sm: SampleModel
      if let packed = sampleModel as? SinglePixelPackedSampleModel {
        sm = SinglePixelPackedSampleModel(
          dataType: packed.dataType, width: w, height: h,
          scanlineStride: w, bitMasks: packed.bitMasks)
      } else {
        sm = SampleModel(dataType: sampleModel.dataType,
                         width: w, height: h,
                         numBands: sampleModel.numBands)
      }
      let db = sm.createDataBuffer()
      return WritableRaster(sampleModel: sm, dataBuffer: db)
    }
  }
}
