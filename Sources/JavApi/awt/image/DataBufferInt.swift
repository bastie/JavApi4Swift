/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  /// `DataBuffer` backed by an `[Int32]` array (Java `int[]`).
  ///
  /// Mirrors `java.awt.image.DataBufferInt`.
  ///
  /// - Since: Java 1.2
  public final class DataBufferInt: DataBuffer {

    private var data: [[Int32]]

    /// Creates a zero-filled single-bank buffer.
    public init(size: Int) {
      self.data = [[Int32](repeating: 0, count: size)]
      super.init(dataType: DataBuffer.TYPE_INT, size: size, numBanks: 1)
    }

    /// Creates a single-bank buffer wrapping an existing array.
    public init(dataArray: [Int32], size: Int) {
      var arr = dataArray
      if arr.count < size { arr += [Int32](repeating: 0, count: size - arr.count) }
      self.data = [arr]
      super.init(dataType: DataBuffer.TYPE_INT, size: size, numBanks: 1)
    }

    /// Creates a multi-bank buffer.
    public init(dataArrays: [[Int32]], size: Int) {
      self.data = dataArrays
      super.init(dataType: DataBuffer.TYPE_INT, size: size, numBanks: dataArrays.count)
    }

    /// Direct access to the underlying bank array.
    public func getData() -> [Int32] { data[0] }
    public func getData(bank: Int) -> [Int32] { data[bank] }

    public override func getElem(_ bank: Int, _ i: Int) -> Int {
      Int(data[bank][i])
    }

    public override func setElem(_ bank: Int, _ i: Int, _ val: Int) {
      data[bank][i] = Int32(truncatingIfNeeded: val)
    }
  }
}
