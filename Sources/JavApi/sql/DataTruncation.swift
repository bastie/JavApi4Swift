/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.sql {

  /// An exception (or warning) that reports a data truncation error.
  ///
  /// `DataTruncation` is thrown as an exception when data is unexpectedly
  /// truncated on a write, and reported as a warning when data is truncated on
  /// a read.
  ///
  /// Mirrors `java.sql.DataTruncation` (Java 1.1).
  ///
  /// - Since: JavaApi (Java 1.1)
  open class DataTruncation : SQLWarning, @unchecked Sendable {

    private let index      : Int
    private let parameter  : Bool
    private let read       : Bool
    private let dataSize   : Int
    private let transferSize: Int

    /// Creates a `DataTruncation` instance.
    ///
    /// - Parameters:
    ///   - index:        The column or parameter index (1-based).
    ///   - parameter:    `true` if the value was a parameter; `false` for a
    ///                   column value.
    ///   - read:         `true` if a read was truncated; `false` if a write was
    ///                   truncated.
    ///   - dataSize:     The number of bytes of data that should have been
    ///                   transferred. A value of `-1` means the size is unknown.
    ///   - transferSize: The number of bytes of data actually transferred.
    ///                   A value of `-1` means the size is unknown.
    public init(
      _ index: Int,
      _ parameter: Bool,
      _ read: Bool,
      _ dataSize: Int,
      _ transferSize: Int
    ) {
      self.index       = index
      self.parameter   = parameter
      self.read        = read
      self.dataSize    = dataSize
      self.transferSize = transferSize
      super.init("Data truncation", "01004", 0)
    }

    /// The column or parameter index (1-based).
    open func getIndex() -> Int { return index }

    /// Returns `true` if the value was a parameter value; `false` for a column
    /// value.
    open func getParameter() -> Bool { return parameter }

    /// Returns `true` if a read was truncated; `false` if a write was
    /// truncated.
    open func getRead() -> Bool { return read }

    /// The number of bytes of data that should have been transferred, or `-1`
    /// if the size is unknown.
    open func getDataSize() -> Int { return dataSize }

    /// The number of bytes of data actually transferred, or `-1` if the size is
    /// unknown.
    open func getTransferSize() -> Int { return transferSize }
  }
}
