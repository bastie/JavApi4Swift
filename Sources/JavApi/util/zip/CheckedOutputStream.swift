/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util.zip {

  /// An output stream that maintains a running checksum of all bytes written.
  ///
  /// Wraps any ``java.io.OutputStream`` and updates a ``Checksum`` instance
  /// for every byte that passes through. After writing, call
  /// ``getChecksum()`` to obtain the accumulated value.
  ///
  /// Mirrors `java.util.zip.CheckedOutputStream` (Java 1.1).
  ///
  /// ```swift
  /// let sink = java.io.ByteArrayOutputStream()
  /// let crc  = java.util.zip.CRC32()
  /// let cos  = java.util.zip.CheckedOutputStream(sink, crc)
  /// try cos.write(Array("Hello".utf8), 0, 5)
  /// print(cos.getChecksum().getValue())   // CRC32 of "Hello"
  /// ```
  ///
  /// - Since: Java 1.1
  open class CheckedOutputStream : java.io.FilterOutputStream, @unchecked Sendable {

    private let cksum: any Checksum

    // MARK: - Init

    /// Creates a ``CheckedOutputStream`` that wraps `out` and accumulates
    /// bytes into `cksum`.
    ///
    /// - Parameters:
    ///   - out: the underlying output stream to write to
    ///   - cksum: the checksum to update on every write
    public init(_ out: java.io.OutputStream, _ cksum: any Checksum) {
      self.cksum = cksum
      super.init(out)
    }

    // MARK: - Write

    /// Writes a single byte and updates the checksum.
    ///
    /// - Throws: ``java.io.IOException``
    public override func write(_ b: Int) throws {
      try out.write(b)
      cksum.update(b)
    }

    /// Writes `length` bytes from `b` starting at `offset` and updates the
    /// checksum with all bytes written.
    ///
    /// - Throws: ``java.io.IOException``
    public override func write(_ b: [UInt8], _ offset: Int, _ length: Int) throws {
      try out.write(b, offset, length)
      if length > 0 {
        cksum.update(b, offset, length)
      }
    }

    // MARK: - Checksum

    /// Returns the checksum that has been accumulated so far.
    public func getChecksum() -> any Checksum {
      return cksum
    }
  }
}
