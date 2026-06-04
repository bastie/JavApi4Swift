/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.io {

  /// A `FilterInputStream` that reads Java primitive types from a binary stream.
  ///
  /// Mirrors `java.io.DataInputStream` from Java 1.0. All multi-byte values
  /// are read in big-endian byte order, matching Java's specification.
  ///
  /// ```swift
  /// let bytes: [UInt8] = [0x00, 0x00, 0x00, 0x2A]   // int 42
  /// let din = java.io.DataInputStream(java.io.ByteArrayInputStream(bytes))
  /// let value = try din.readInt()   // 42
  /// ```
  ///
  /// - Since: JavaApi (Java 1.0)
  open class DataInputStream : FilterInputStream, DataInput {

    // MARK: - Initialisers

    /// Creates a `DataInputStream` wrapping `inputStream`.
    ///
    /// - Parameter inputStream: The underlying `InputStream`.
    /// - Since: JavaApi (Java 1.0)
    public override init(_ inputStream: java.io.InputStream?) {
      super.init(inputStream)
    }

    // MARK: - Private helpers

    /// Reads exactly `count` bytes, throwing `EOFException` if the stream ends early.
    private func readBytes(_ count: Int) throws -> [UInt8] {
      var buf = [UInt8](repeating: 0, count: count)
      var read = 0
      while read < count {
        let b = try self.read(&buf, read, count - read)
        if b == -1 { throw java.io.EOFException() }
        read += b
      }
      return buf
    }

    // MARK: - DataInput

    /// Reads a `boolean` (1 byte: non-zero = true).
    /// - Since: JavaApi (Java 1.0)
    public func readBoolean() throws -> Bool {
      let b = try `in`.read()
      if b == -1 { throw java.io.EOFException() }
      return b != 0
    }

    /// Reads a signed byte.
    /// - Since: JavaApi (Java 1.0)
    public func readByte() throws -> Int8 {
      let b = try `in`.read()
      if b == -1 { throw java.io.EOFException() }
      return Int8(bitPattern: UInt8(b & 0xFF))
    }

    /// Reads an unsigned byte as `Int` (0–255).
    /// - Since: JavaApi (Java 1.0)
    public func readUnsignedByte() throws -> Int {
      let b = try `in`.read()
      if b == -1 { throw java.io.EOFException() }
      return b & 0xFF
    }

    /// Reads a big-endian `short` (2 bytes).
    /// - Since: JavaApi (Java 1.0)
    public func readShort() throws -> Int16 {
      let buf = try readBytes(2)
      return Int16(bitPattern: UInt16(buf[0]) << 8 | UInt16(buf[1]))
    }

    /// Reads an unsigned big-endian short as `Int` (0–65535).
    /// - Since: JavaApi (Java 1.0)
    public func readUnsignedShort() throws -> Int {
      let buf = try readBytes(2)
      return Int(UInt16(buf[0]) << 8 | UInt16(buf[1]))
    }

    /// Reads a big-endian UTF-16 `char` (2 bytes).
    /// - Since: JavaApi (Java 1.0)
    public func readChar() throws -> Character {
      let buf = try readBytes(2)
      let value = UInt16(buf[0]) << 8 | UInt16(buf[1])
      return Character(UnicodeScalar(value)!)
    }

    /// Reads a big-endian `int` (4 bytes).
    /// - Since: JavaApi (Java 1.0)
    public func readInt() throws -> Int {
      let buf = try readBytes(4)
      let value = UInt32(buf[0]) << 24 | UInt32(buf[1]) << 16
                | UInt32(buf[2]) << 8  | UInt32(buf[3])
      return Int(Int32(bitPattern: value))
    }

    /// Reads a big-endian `long` (8 bytes).
    /// - Since: JavaApi (Java 1.0)
    public func readLong() throws -> Int64 {
      let buf = try readBytes(8)
      var value: UInt64 = 0
      for i in 0..<8 { value = (value << 8) | UInt64(buf[i]) }
      return Int64(bitPattern: value)
    }

    /// Reads a big-endian IEEE 754 `float` (4 bytes).
    /// - Since: JavaApi (Java 1.0)
    public func readFloat() throws -> Float {
      let buf = try readBytes(4)
      let bits = UInt32(buf[0]) << 24 | UInt32(buf[1]) << 16
               | UInt32(buf[2]) << 8  | UInt32(buf[3])
      return Float(bitPattern: bits)
    }

    /// Reads a big-endian IEEE 754 `double` (8 bytes).
    /// - Since: JavaApi (Java 1.0)
    public func readDouble() throws -> Double {
      let buf = try readBytes(8)
      var bits: UInt64 = 0
      for i in 0..<8 { bits = (bits << 8) | UInt64(buf[i]) }
      return Double(bitPattern: bits)
    }

    /// Reads bytes until `\n` or EOF and returns them as a `String`.
    ///
    /// `\r` and `\r\n` are treated as a single line terminator.
    /// - Since: JavaApi (Java 1.0)
    public func readLine() throws -> String {
      var result = ""
      while true {
        let b = try `in`.read()
        if b == -1 || b == 10 { break }   // EOF or '\n'
        if b == 13 { break }               // '\r' — peek at next
        result.append(Character(UnicodeScalar(b)!))
      }
      return result
    }

    /// Reads a string encoded in Java's modified UTF-8 format.
    ///
    /// The first two bytes are a big-endian unsigned length, followed by
    /// that many bytes of modified UTF-8 data.
    /// - Since: JavaApi (Java 1.0)
    public func readUTF() throws -> String {
      let length = try readUnsignedShort()
      let buf = try readBytes(length)
      return String(bytes: buf, encoding: .utf8) ?? ""
    }

    /// Fills `buffer` entirely, throwing `EOFException` if the stream ends early.
    /// - Since: JavaApi (Java 1.0)
    public func readFully(_ buffer: inout [UInt8]) throws {
      try readFully(&buffer, 0, buffer.count)
    }

    /// Fills `length` bytes of `buffer` starting at `offset`.
    /// - Since: JavaApi (Java 1.0)
    public func readFully(_ buffer: inout [UInt8], _ offset: Int, _ length: Int) throws {
      var read = 0
      while read < length {
        let n = try self.read(&buffer, offset + read, length - read)
        if n == -1 { throw java.io.EOFException() }
        read += n
      }
    }

    /// Skips exactly `n` bytes, throwing `EOFException` if the stream ends early.
    /// - Since: JavaApi (Java 1.0)
    public func skipBytes(_ n: Int) throws {
      var skipped = 0
      while skipped < n {
        let s = try skip(n - skipped)
        if s <= 0 { throw java.io.EOFException() }
        skipped += s
      }
    }
  }
}
