/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  /// `DataBuffer` backed by a `[Int16]` array (Java signed `short[]`).
  ///
  /// Mirrors `java.awt.image.DataBufferShort`.
  ///
  /// - Since: Java 1.2
  public final class DataBufferShort: DataBuffer {

    private var data: [[Int16]]

    public init(size: Int) {
      self.data = [[Int16](repeating: 0, count: size)]
      super.init(dataType: DataBuffer.TYPE_SHORT, size: size, numBanks: 1)
    }

    public init(dataArray: [Int16], size: Int) {
      self.data = [dataArray]
      super.init(dataType: DataBuffer.TYPE_SHORT, size: size, numBanks: 1)
    }

    public init(dataArrays: [[Int16]], size: Int) {
      self.data = dataArrays
      super.init(dataType: DataBuffer.TYPE_SHORT, size: size, numBanks: dataArrays.count)
    }

    public func getData() -> [Int16] { data[0] }
    public func getData(bank: Int) -> [Int16] { data[bank] }

    public override func getElem(_ bank: Int, _ i: Int) -> Int {
      Int(data[bank][i])
    }

    public override func setElem(_ bank: Int, _ i: Int, _ val: Int) {
      data[bank][i] = Int16(truncatingIfNeeded: val)
    }
  }
}
