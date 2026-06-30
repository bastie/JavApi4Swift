/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  /// Defines how pixel samples are stored in a `DataBuffer`.
  ///
  /// Mirrors `java.awt.image.SampleModel`.
  /// Concrete subclasses: `SinglePixelPackedSampleModel`, `ComponentSampleModel`
  /// (and its subclasses `PixelInterleavedSampleModel`, `BandedSampleModel`),
  /// `MultiPixelPackedSampleModel`.
  ///
  /// - Since: Java 1.2
  open class SampleModel {

    public let width:     Int
    public let height:    Int
    public let numBands:  Int
    public let dataType:  Int

    public init(dataType: Int, width: Int, height: Int, numBands: Int) {
      self.dataType = dataType
      self.width    = width
      self.height   = height
      self.numBands = numBands
    }

    /// Returns the sample for band `b` at pixel `(x, y)`.
    open func getSample(_ x: Int, _ y: Int, _ b: Int, _ data: DataBuffer) -> Int {
      fatalError("abstract")
    }

    /// Sets the sample for band `b` at pixel `(x, y)`.
    open func setSample(_ x: Int, _ y: Int, _ b: Int, _ s: Int, _ data: DataBuffer) {
      fatalError("abstract")
    }

    /// Returns all samples for pixel `(x, y)` into `iArray` (or a new array).
    open func getPixel(_ x: Int, _ y: Int, _ iArray: [Int]?, _ data: DataBuffer) -> [Int] {
      var result = iArray ?? [Int](repeating: 0, count: numBands)
      for b in 0 ..< numBands { result[b] = getSample(x, y, b, data) }
      return result
    }

    /// Sets all samples for pixel `(x, y)` from `iArray`.
    open func setPixel(_ x: Int, _ y: Int, _ iArray: [Int], _ data: DataBuffer) {
      for b in 0 ..< numBands { setSample(x, y, b, iArray[b], data) }
    }

    /// Returns the number of data elements needed to transfer one pixel.
    open func getNumDataElements() -> Int { numBands }

    /// Creates a compatible `DataBuffer` for this model.
    open func createDataBuffer() -> DataBuffer {
      DataBufferInt(size: width * height)
    }
  }
}
