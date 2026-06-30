/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  /// `DataBuffer` backed by a `[UInt8]` array.
  ///
  /// Mirrors `java.awt.image.DataBufferByte`.
  ///
  /// - Since: Java 1.2
  public final class DataBufferByte: DataBuffer {

    private var data: [[UInt8]]

    public init(size: Int) {
      self.data = [[UInt8](repeating: 0, count: size)]
      super.init(dataType: DataBuffer.TYPE_BYTE, size: size, numBanks: 1)
    }

    public init(dataArray: [UInt8], size: Int) {
      self.data = [dataArray]
      super.init(dataType: DataBuffer.TYPE_BYTE, size: size, numBanks: 1)
    }

    public init(dataArrays: [[UInt8]], size: Int) {
      self.data = dataArrays
      super.init(dataType: DataBuffer.TYPE_BYTE, size: size, numBanks: dataArrays.count)
    }

    public func getData() -> [UInt8] { data[0] }
    public func getData(bank: Int) -> [UInt8] { data[bank] }

    public override func getElem(_ bank: Int, _ i: Int) -> Int {
      Int(data[bank][i])
    }

    public override func setElem(_ bank: Int, _ i: Int, _ val: Int) {
      data[bank][i] = UInt8(val & 0xFF)
    }
  }
}
