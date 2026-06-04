/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.io {

  /// A `FilterOutputStream` that writes Java primitive types to a binary stream.
  ///
  /// Mirrors `java.io.DataOutputStream` from Java 1.0. All multi-byte values
  /// are written in big-endian byte order, matching Java's specification.
  ///
  /// ```swift
  /// let buf = java.io.ByteArrayOutputStream()
  /// let dout = java.io.DataOutputStream(buf)
  /// try dout.writeInt(42)
  /// // buf.toByteArray() == [0x00, 0x00, 0x00, 0x2A]
  /// ```
  ///
  /// - Since: JavaApi (Java 1.0)
  open class DataOutputStream : FilterOutputStream, DataOutput {

    /// The number of bytes written so far.
    public private(set) var written: Int = 0

    // MARK: - Initialisers

    /// Creates a `DataOutputStream` wrapping `outputStream`.
    ///
    /// - Parameter outputStream: The underlying `OutputStream`.
    /// - Since: JavaApi (Java 1.0)
    public override init(_ outputStream: OutputStream) {
      super.init(outputStream)
    }

    // MARK: - Private helpers

    private func writeRaw(_ bytes: [UInt8]) throws {
      try out.write(bytes)
      written += bytes.count
    }

    // MARK: - OutputStream overrides

    public override func write(_ b: Int) throws {
      try out.write(b)
      written += 1
    }

    public override func write(_ b: [UInt8]) throws {
      try out.write(b)
      written += b.count
    }

    public override func write(_ buffer: [UInt8], _ pos: Int, _ length: Int) throws {
      try out.write(buffer, pos, length)
      written += length
    }

    // MARK: - DataOutput

    /// Writes the lowest 8 bits of `b`.
    /// - Since: JavaApi (Java 1.0)
    public func writeByte(_ v: Int) throws {
      try write(v & 0xFF)
    }

    /// Writes a `boolean` as a single byte (1 = true, 0 = false).
    /// - Since: JavaApi (Java 1.0)
    public func writeBoolean(_ v: Bool) throws {
      try write(v ? 1 : 0)
    }

    /// Writes `v` as two big-endian bytes.
    /// - Since: JavaApi (Java 1.0)
    public func writeShort(_ v: Int) throws {
      try writeRaw([UInt8((v >> 8) & 0xFF), UInt8(v & 0xFF)])
    }

    /// Writes `v` as two big-endian bytes (UTF-16 char).
    /// - Since: JavaApi (Java 1.0)
    public func writeChar(_ v: Int) throws {
      try writeShort(v)
    }

    /// Writes `v` as four big-endian bytes.
    /// - Since: JavaApi (Java 1.0)
    public func writeInt(_ v: Int) throws {
      let u = UInt32(bitPattern: Int32(truncatingIfNeeded: v))
      try writeRaw([
        UInt8((u >> 24) & 0xFF),
        UInt8((u >> 16) & 0xFF),
        UInt8((u >>  8) & 0xFF),
        UInt8( u        & 0xFF)
      ])
    }

    /// Writes `v` as eight big-endian bytes.
    /// - Since: JavaApi (Java 1.0)
    public func writeLong(_ v: Int64) throws {
      let u = UInt64(bitPattern: v)
      try writeRaw([
        UInt8((u >> 56) & 0xFF), UInt8((u >> 48) & 0xFF),
        UInt8((u >> 40) & 0xFF), UInt8((u >> 32) & 0xFF),
        UInt8((u >> 24) & 0xFF), UInt8((u >> 16) & 0xFF),
        UInt8((u >>  8) & 0xFF), UInt8( u         & 0xFF)
      ])
    }

    /// Writes `v` as a 4-byte big-endian IEEE 754 float.
    /// - Since: JavaApi (Java 1.0)
    public func writeFloat(_ v: Float) throws {
      let bits = v.bitPattern
      try writeRaw([
        UInt8((bits >> 24) & 0xFF),
        UInt8((bits >> 16) & 0xFF),
        UInt8((bits >>  8) & 0xFF),
        UInt8( bits         & 0xFF)
      ])
    }

    /// Writes `v` as an 8-byte big-endian IEEE 754 double.
    /// - Since: JavaApi (Java 1.0)
    public func writeDouble(_ v: Double) throws {
      let bits = v.bitPattern
      try writeRaw([
        UInt8((bits >> 56) & 0xFF), UInt8((bits >> 48) & 0xFF),
        UInt8((bits >> 40) & 0xFF), UInt8((bits >> 32) & 0xFF),
        UInt8((bits >> 24) & 0xFF), UInt8((bits >> 16) & 0xFF),
        UInt8((bits >>  8) & 0xFF), UInt8( bits         & 0xFF)
      ])
    }

    /// Writes the characters of `s` as bytes (low 8 bits of each char).
    /// - Since: JavaApi (Java 1.0)
    public func writeBytes(_ s: String) throws {
      for ch in s.unicodeScalars {
        try write(Int(ch.value) & 0xFF)
      }
    }

    /// Writes each character of `s` as two big-endian bytes (UTF-16).
    /// - Since: JavaApi (Java 1.0)
    public func writeChars(_ s: String) throws {
      for ch in s.unicodeScalars {
        try writeChar(Int(ch.value))
      }
    }

    /// Writes `s` in Java's modified UTF-8 encoding.
    ///
    /// Encodes `s` as UTF-8, then writes a 2-byte big-endian length prefix
    /// followed by the UTF-8 bytes.
    /// - Since: JavaApi (Java 1.0)
    public func writeUTF(_ s: String) throws {
      let bytes = [UInt8](s.utf8)
      let length = bytes.count
      guard length <= 65535 else {
        throw java.io.UTFDataFormatException("String too long for writeUTF: \(length) bytes")
      }
      try writeShort(length)
      try writeRaw(bytes)
    }

    /// Returns the total number of bytes written so far.
    /// - Since: JavaApi (Java 1.0)
    public func size() -> Int {
      return written
    }
  }
}
