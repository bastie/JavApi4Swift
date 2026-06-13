/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  /// Wraps one or more data arrays that store pixel data for a `Raster`.
  ///
  /// Mirrors `java.awt.image.DataBuffer`. Only the `TYPE_INT` variant is fully
  /// implemented here; `TYPE_BYTE`, `TYPE_SHORT`, and `TYPE_USHORT` stubs
  /// are provided for API compatibility.
  ///
  /// - Since: Java 1.2
  open class DataBuffer {

    // =========================================================================
    // MARK: - Type constants
    // =========================================================================

    /// Unsigned byte data.
    public static let TYPE_BYTE:   Int = 0
    /// Unsigned short data.
    public static let TYPE_USHORT: Int = 1
    /// Signed short data.
    public static let TYPE_SHORT:  Int = 2
    /// Signed int data.
    public static let TYPE_INT:    Int = 3
    /// Single-precision float data.
    public static let TYPE_FLOAT:  Int = 4
    /// Double-precision data.
    public static let TYPE_DOUBLE: Int = 5
    /// Undefined type.
    public static let TYPE_UNDEFINED: Int = 32

    // =========================================================================
    // MARK: - Fields
    // =========================================================================

    public let dataType: Int
    public let size:     Int
    public let numBanks: Int

    public init(dataType: Int, size: Int, numBanks: Int = 1) {
      self.dataType = dataType
      self.size     = size
      self.numBanks = numBanks
    }

    // =========================================================================
    // MARK: - Abstract element access
    // =========================================================================

    /// Returns element `i` from bank 0.
    open func getElem(_ i: Int) -> Int { getElem(0, i) }

    /// Returns element `i` from the specified bank.
    open func getElem(_ bank: Int, _ i: Int) -> Int { fatalError("abstract") }

    /// Sets element `i` in bank 0.
    open func setElem(_ i: Int, _ val: Int) { setElem(0, i, val) }

    /// Sets element `i` in the specified bank.
    open func setElem(_ bank: Int, _ i: Int, _ val: Int) { fatalError("abstract") }

    /// Returns element `i` as `Double`.
    open func getElemDouble(_ i: Int) -> Double { Double(getElem(i)) }

    /// Sets element `i` from a `Double`.
    open func setElemDouble(_ i: Int, _ val: Double) { setElem(i, Int(val)) }

    /// Returns element `i` as `Float`.
    open func getElemFloat(_ i: Int) -> Float { Float(getElem(i)) }

    /// Sets element `i` from a `Float`.
    open func setElemFloat(_ i: Int, _ val: Float) { setElem(i, Int(val)) }
  }

  // ---------------------------------------------------------------------------
  // MARK: - DataBufferInt
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // MARK: - DataBufferByte
  // ---------------------------------------------------------------------------

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
