/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  /// Wraps one or more data arrays that store pixel data for a `Raster`.
  ///
  /// Mirrors `java.awt.image.DataBuffer`.
  /// Concrete subclasses: `DataBufferByte`, `DataBufferShort`, `DataBufferUShort`, `DataBufferInt`.
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
}
