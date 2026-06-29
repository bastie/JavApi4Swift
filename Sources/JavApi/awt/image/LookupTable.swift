/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  // ---------------------------------------------------------------------------
  // MARK: - LookupTable (abstract)
  // ---------------------------------------------------------------------------

  /// Abstract base for lookup tables used by `LookupOp` —
  /// mirrors `java.awt.image.LookupTable`.
  ///
  /// - Since: Java 1.2
  open class LookupTable {

    /// Index of the first valid element in each table.
    public let offset: Int

    /// Number of components (tables).
    public let numComponents: Int

    public init(offset: Int, numComponents: Int) {
      self.offset        = offset
      self.numComponents = numComponents
    }

    /// Maps `src` pixel component values to `dst` using the lookup table.
    ///
    /// - Parameters:
    ///   - src: Input component values (one per band).
    ///   - dst: Output component values (same length as `src`), or `nil`.
    /// - Returns: The mapped values.
    open func lookupPixel(_ src: [Int], _ dst: [Int]?) -> [Int] {
      fatalError("abstract")
    }
  }

  // ---------------------------------------------------------------------------
  // MARK: - ByteLookupTable
  // ---------------------------------------------------------------------------

  /// A `LookupTable` backed by `[UInt8]` arrays —
  /// mirrors `java.awt.image.ByteLookupTable`.
  ///
  /// - Since: Java 1.2
  public final class ByteLookupTable: LookupTable {

    private let data: [[UInt8]]

    /// Creates a single-component lookup table.
    public init(offset: Int, data: [UInt8]) {
      self.data = [data]
      super.init(offset: offset, numComponents: 1)
    }

    /// Creates a multi-component lookup table (one array per component).
    public init(offset: Int, data: [[UInt8]]) {
      self.data = data
      super.init(offset: offset, numComponents: data.count)
    }

    /// Returns the raw table for component `component`.
    public func getTable() -> [[UInt8]] { data }

    public override func lookupPixel(_ src: [Int], _ dst: [Int]?) -> [Int] {
      var result = dst ?? [Int](repeating: 0, count: src.count)
      for i in 0 ..< src.count {
        let tableIdx = i < data.count ? i : 0
        let idx = src[i] - offset
        guard idx >= 0, idx < data[tableIdx].count else {
          result[i] = src[i]
          continue
        }
        result[i] = Int(data[tableIdx][idx])
      }
      return result
    }
  }

  // ---------------------------------------------------------------------------
  // MARK: - ShortLookupTable
  // ---------------------------------------------------------------------------

  /// A `LookupTable` backed by `[UInt16]` arrays —
  /// mirrors `java.awt.image.ShortLookupTable`.
  ///
  /// - Since: Java 1.2
  public final class ShortLookupTable: LookupTable {

    private let data: [[UInt16]]

    /// Creates a single-component lookup table.
    public init(offset: Int, data: [UInt16]) {
      self.data = [data]
      super.init(offset: offset, numComponents: 1)
    }

    /// Creates a multi-component lookup table (one array per component).
    public init(offset: Int, data: [[UInt16]]) {
      self.data = data
      super.init(offset: offset, numComponents: data.count)
    }

    /// Returns the raw table for component `component`.
    public func getTable() -> [[UInt16]] { data }

    public override func lookupPixel(_ src: [Int], _ dst: [Int]?) -> [Int] {
      var result = dst ?? [Int](repeating: 0, count: src.count)
      for i in 0 ..< src.count {
        let tableIdx = i < data.count ? i : 0
        let idx = src[i] - offset
        guard idx >= 0, idx < data[tableIdx].count else {
          result[i] = src[i]
          continue
        }
        result[i] = Int(data[tableIdx][idx])
      }
      return result
    }
  }
}
