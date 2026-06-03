/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.io {

  /// An `OutputStream` that writes bytes into an in-memory buffer.
  ///
  /// Mirrors `java.io.ByteArrayOutputStream` from Java 1.0.
  ///
  /// The internal buffer uses `[UInt8]` rather than Java's signed `byte[]`
  /// (`[Int8]`) to improve interoperability with standard Swift APIs such as
  /// `Data` and `String`.  The observable behaviour is identical because
  /// individual byte values are bit-identical between `UInt8` and `Int8`.
  ///
  /// ```swift
  /// let out = java.io.ByteArrayOutputStream()
  /// try out.write(72)   // 'H'
  /// try out.write(105)  // 'i'
  /// print(out.toString())   // Hi
  /// ```
  ///
  /// - Since: JavaApi (Java 1.0)
  open class ByteArrayOutputStream : java.io.OutputStream {

    // MARK: - Buffer

    /// The internal byte buffer. Grows automatically.
    internal var buf: [UInt8]

    /// The number of valid bytes in `buf`.
    internal var count: Int = 0

    // MARK: - Initialisers

    /// Creates a new stream with a default initial capacity of 32 bytes.
    /// - Since: JavaApi (Java 1.0)
    public override init() {
      buf = [UInt8](repeating: 0, count: 32)
      super.init()
    }

    /// Creates a new stream with the given initial capacity.
    ///
    /// - Parameter size: Initial buffer capacity in bytes.
    /// - Since: JavaApi (Java 1.0)
    public init(_ size: Int) {
      buf = [UInt8](repeating: 0, count: max(size, 1))
      super.init()
    }

    // MARK: - Private helpers

    private func ensureCapacity(_ minCapacity: Int) {
      if minCapacity > buf.count {
        let newCapacity = Swift.max(minCapacity, buf.count * 2)
        buf.append(contentsOf: [UInt8](repeating: 0, count: newCapacity - buf.count))
      }
    }

    // MARK: - OutputStream overrides

    /// Writes a single byte (the lowest 8 bits of `b`) to the buffer.
    ///
    /// - Parameter b: The byte value to write; only the lowest 8 bits are used.
    /// - Since: JavaApi (Java 1.0)
    public override func write(_ b: Int) throws {
      ensureCapacity(count + 1)
      buf[count] = UInt8(b & 0xFF)
      count += 1
    }

    /// Writes `length` bytes from `buffer` starting at `pos` into this stream.
    ///
    /// - Parameters:
    ///   - buffer: Source byte array.
    ///   - pos: Start offset in `buffer`.
    ///   - length: Number of bytes to write.
    /// - Throws: `java.lang.IndexOutOfBoundsException` for invalid ranges.
    /// - Since: JavaApi (Java 1.0)
    public override func write(_ buffer: [UInt8], _ pos: Int, _ length: Int) throws {
      guard pos >= 0, length >= 0, pos + length <= buffer.count else {
        throw IndexOutOfBoundsException()
      }
      ensureCapacity(count + length)
      for i in 0..<length {
        buf[count + i] = buffer[pos + i]
      }
      count += length
    }

    /// Writes all bytes from `value` into this stream.
    ///
    /// - Parameter value: The byte array to write.
    /// - Since: JavaApi (Java 1.0)
    public override func write(_ value: [UInt8]) throws {
      try write(value, 0, value.count)
    }

    // MARK: - Java 1.0 API

    /// Writes the complete contents of this stream to `out`.
    ///
    /// - Parameter out: The target `OutputStream`.
    /// - Throws: Any `IOException` thrown by `out`.
    /// - Since: JavaApi (Java 1.0)
    public func writeTo(_ out: java.io.OutputStream) throws {
      try out.write(buf, 0, count)
    }

    /// Resets the stream so it can be reused. The buffer is retained.
    /// - Since: JavaApi (Java 1.0)
    public func reset() {
      count = 0
    }

    /// Returns the current contents of the buffer as a `[UInt8]` array.
    ///
    /// - Returns: A copy of the valid bytes written so far.
    /// - Since: JavaApi (Java 1.0)
    public func toByteArray() -> [UInt8] {
      return Array(buf[0..<count])
    }

    /// Returns the number of bytes written so far.
    /// - Since: JavaApi (Java 1.0)
    public func size() -> Int {
      return count
    }

    /// Returns the buffer contents decoded as a UTF-8 string.
    /// - Since: JavaApi (Java 1.0)
    public func toString() -> String {
      return String(bytes: buf[0..<count], encoding: .utf8) ?? ""
    }

    /// Returns the buffer contents decoded with the given charset name.
    ///
    /// Common IANA names are recognised on all platforms (e.g. `"UTF-8"`,
    /// `"ISO-8859-1"`, `"US-ASCII"`, `"UTF-16"`). Unknown names fall back
    /// to UTF-8.
    ///
    /// - Parameter charsetName: IANA charset name.
    /// - Returns: Decoded string, or an empty string if decoding fails.
    /// - Since: JavaApi (Java 1.0)
    public func toString(_ charsetName: String) -> String {
      let enc = ByteArrayOutputStream.encoding(for: charsetName)
      return String(bytes: buf[0..<count], encoding: enc) ?? ""
    }

    /// Maps a common IANA charset name to a `String.Encoding` without using
    /// CoreFoundation, so the code compiles on Linux as well.
    private static func encoding(for ianaName: String) -> String.Encoding {
      switch ianaName.uppercased() {
      case "UTF-8", "UTF8":               return .utf8
      case "UTF-16", "UTF16":             return .utf16
      case "UTF-16BE", "UTF16BE":         return .utf16BigEndian
      case "UTF-16LE", "UTF16LE":         return .utf16LittleEndian
      case "UTF-32", "UTF32":             return .utf32
      case "UTF-32BE", "UTF32BE":         return .utf32BigEndian
      case "UTF-32LE", "UTF32LE":         return .utf32LittleEndian
      case "US-ASCII", "ASCII":           return .ascii
      case "ISO-8859-1", "LATIN1",
           "ISO-LATIN-1":                 return .isoLatin1
      case "ISO-8859-2", "LATIN2":        return .isoLatin2
      case "WINDOWS-1250", "CP1250":      return .windowsCP1250
      case "WINDOWS-1251", "CP1251":      return .windowsCP1251
      case "WINDOWS-1252", "CP1252":      return .windowsCP1252
      case "WINDOWS-1253", "CP1253":      return .windowsCP1253
      case "WINDOWS-1254", "CP1254":      return .windowsCP1254
      case "SHIFT-JIS", "SHIFT_JIS":      return .shiftJIS
      case "EUC-JP":                      return .japaneseEUC
      default:                            return .utf8
      }
    }

    /// `close()` has no effect on a `ByteArrayOutputStream`.
    public override func close() throws {
      // no-op — buffer remains accessible after close, as in Java
    }
  }
}
