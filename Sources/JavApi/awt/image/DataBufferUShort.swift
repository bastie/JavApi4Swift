/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  /// `DataBuffer` backed by a `[UInt16]` array (Java unsigned `short[]`).
  ///
  /// Mirrors `java.awt.image.DataBufferUShort`.
  ///
  /// - Since: Java 1.2
  public final class DataBufferUShort: DataBuffer {

    private var data: [[UInt16]]

    public init(size: Int) {
      self.data = [[UInt16](repeating: 0, count: size)]
      super.init(dataType: DataBuffer.TYPE_USHORT, size: size, numBanks: 1)
    }

    public init(dataArray: [UInt16], size: Int) {
      self.data = [dataArray]
      super.init(dataType: DataBuffer.TYPE_USHORT, size: size, numBanks: 1)
    }

    public init(dataArrays: [[UInt16]], size: Int) {
      self.data = dataArrays
      super.init(dataType: DataBuffer.TYPE_USHORT, size: size, numBanks: dataArrays.count)
    }

    public func getData() -> [UInt16] { data[0] }
    public func getData(bank: Int) -> [UInt16] { data[bank] }

    public override func getElem(_ bank: Int, _ i: Int) -> Int {
      Int(data[bank][i])
    }

    public override func setElem(_ bank: Int, _ i: Int, _ val: Int) {
      data[bank][i] = UInt16(val & 0xFFFF)
    }
  }
}
