/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util.zip {

  /// An input stream that maintains a running checksum of all bytes read.
  ///
  /// Wraps any ``java.io.InputStream`` and updates a ``Checksum`` instance
  /// for every byte that passes through. After reading, call ``getChecksum()``
  /// to obtain the accumulated value.
  ///
  /// Mirrors `java.util.zip.CheckedInputStream` (Java 1.1).
  ///
  /// ```swift
  /// let raw  = java.io.ByteArrayInputStream(Array("Hello".utf8))
  /// let crc  = java.util.zip.CRC32()
  /// let cis  = java.util.zip.CheckedInputStream(raw, crc)
  /// var buf  = [UInt8](repeating: 0, count: 16)
  /// let n    = try cis.read(&buf, 0, buf.count)
  /// print(cis.getChecksum().getValue())   // CRC32 of "Hello"
  /// ```
  ///
  /// - Since: Java 1.1
  open class CheckedInputStream : java.io.FilterInputStream, @unchecked Sendable {

    private let cksum: any Checksum

    // MARK: - Init

    /// Creates a ``CheckedInputStream`` that wraps `in` and accumulates bytes
    /// into `cksum`.
    ///
    /// - Parameters:
    ///   - in_: the underlying input stream to read from
    ///   - cksum: the checksum to update on every read
    public init(_ in_: java.io.InputStream, _ cksum: any Checksum) {
      self.cksum = cksum
      super.init(in_)
    }

    // MARK: - Read

    /// Reads a single byte and updates the checksum.
    ///
    /// - Returns: the byte read as an `Int` in `0...255`, or `-1` at end-of-stream
    /// - Throws: ``java.io.IOException``
    public override func read() throws -> Int {
      let b = try self.in.read()
      if b != -1 {
        cksum.update(b)
      }
      return b
    }

    /// Reads up to `length` bytes into `array` starting at `offset` and
    /// updates the checksum with all bytes actually read.
    ///
    /// - Returns: the number of bytes read, or `-1` at end-of-stream
    /// - Throws: ``java.io.IOException``
    public override func read(_ array: inout [UInt8], _ offset: Int, _ length: Int) throws -> Int {
      let n = try self.in.read(&array, offset, length)
      if n > 0 {
        cksum.update(array, offset, n)
      }
      return n
    }

    // MARK: - Skip

    /// Skips over and discards `n` bytes, updating the checksum for each
    /// skipped byte.
    ///
    /// Unlike the `FilterInputStream` default, this method reads bytes one
    /// at a time so that the checksum remains accurate.
    ///
    /// - Returns: the actual number of bytes skipped
    /// - Throws: ``java.io.IOException``
    public func skip(_ n: Int64) throws -> Int64 {
      var remaining = n
      var buf = [UInt8](repeating: 0, count: Swift.min(512, Int(n)))
      var skipped: Int64 = 0
      while remaining > 0 {
        let toRead = Int(Swift.min(Int64(buf.count), remaining))
        let read = try self.in.read(&buf, 0, toRead)
        if read == -1 { break }
        cksum.update(buf, 0, read)
        skipped += Int64(read)
        remaining -= Int64(read)
      }
      return skipped
    }

    // MARK: - Checksum

    /// Returns the checksum that has been accumulated so far.
    public func getChecksum() -> any Checksum {
      return cksum
    }
  }
}
