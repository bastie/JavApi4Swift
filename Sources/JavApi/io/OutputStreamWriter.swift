/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.io {

  /// A bridge `Writer` that encodes characters into bytes and writes them to an `OutputStream`.
  ///
  /// Mirrors `java.io.OutputStreamWriter` from Java 1.1. Characters written to
  /// this writer are encoded using the specified charset (default: UTF-8) and
  /// forwarded to the underlying `OutputStream`.
  ///
  /// Wrap with `BufferedWriter` for efficient operation:
  /// ```swift
  /// let osw = java.io.OutputStreamWriter(someOutputStream)
  /// let bw  = java.io.BufferedWriter(osw)
  /// try bw.write("Hello, World!")
  /// try bw.flush()
  /// ```
  ///
  /// - Since: JavaApi (Java 1.1)
  open class OutputStreamWriter : Writer, @unchecked Sendable {

    private let inner: java.io.OutputStream
    private let encoding: String.Encoding
    private var closed: Bool = false

    // MARK: - Initialisers

    /// Creates an `OutputStreamWriter` using UTF-8 encoding.
    ///
    /// - Parameter stream: The underlying `OutputStream`.
    /// - Since: JavaApi (Java 1.1)
    public init(_ stream: java.io.OutputStream) {
      inner    = stream
      encoding = .utf8
      super.init()
    }

    /// Creates an `OutputStreamWriter` using the named charset.
    ///
    /// Supported charset names mirror the Java canonical names:
    /// `"UTF-8"`, `"UTF-16"`, `"ISO-8859-1"`, `"US-ASCII"`, `"UTF-16BE"`, `"UTF-16LE"`.
    ///
    /// - Parameters:
    ///   - stream: The underlying `OutputStream`.
    ///   - charsetName: The IANA charset name.
    /// - Throws: `UnsupportedEncodingException` if the charset is not recognised.
    /// - Since: JavaApi (Java 1.1)
    public init(_ stream: java.io.OutputStream, _ charsetName: String) throws {
      inner = stream
      switch charsetName.uppercased() {
      case "UTF-8", "UTF8":              encoding = .utf8
      case "UTF-16", "UTF16":            encoding = .utf16
      case "UTF-16BE", "UTF16BE":        encoding = .utf16BigEndian
      case "UTF-16LE", "UTF16LE":        encoding = .utf16LittleEndian
      case "ISO-8859-1", "ISO8859-1",
           "LATIN-1", "LATIN1":          encoding = .isoLatin1
      case "US-ASCII", "ASCII":          encoding = .ascii
      default:
        throw java.io.UnsupportedEncodingException(charsetName)
      }
      super.init()
    }

    // MARK: - Private helpers

    private func ensureOpen() throws {
      if closed { throw java.io.IOException("Stream closed") }
    }

    /// Returns the name of the encoding used by this writer.
    /// - Since: JavaApi (Java 1.1)
    public func getEncoding() -> String {
      switch encoding {
      case .utf8:              return "UTF-8"
      case .utf16:             return "UTF-16"
      case .utf16BigEndian:    return "UTF-16BE"
      case .utf16LittleEndian: return "UTF-16LE"
      case .isoLatin1:         return "ISO-8859-1"
      case .ascii:             return "US-ASCII"
      default:                 return "UTF-8"
      }
    }

    // MARK: - Writer overrides

    /// Writes `len` characters from `cbuf` starting at `offset`.
    /// - Since: JavaApi (Java 1.1)
    public override func write(_ cbuf: [Character], _ offset: Int, _ len: Int) throws {
      try ensureOpen()
      guard offset >= 0, len >= 0, offset + len <= cbuf.count else {
        throw IndexOutOfBoundsException()
      }
      if len == 0 { return }
      let str  = String(cbuf[offset..<offset + len])
      try writeString(str)
    }

    /// Writes the entire string `str`.
    /// - Since: JavaApi (Java 1.1)
    public override func write(_ str: String) throws {
      try ensureOpen()
      try writeString(str)
    }

    /// Writes `len` characters from `str` starting at `offset`.
    /// - Since: JavaApi (Java 1.1)
    public override func write(_ str: String, _ offset: Int, _ len: Int) throws {
      try ensureOpen()
      guard offset >= 0, len >= 0, offset + len <= str.count else {
        throw StringIndexOutOfBoundsException(-1)
      }
      try writeString(str.substring(offset, offset + len))
    }

    /// Writes a single character.
    /// - Since: JavaApi (Java 1.1)
    public override func write(_ oneChar: Character) throws {
      try ensureOpen()
      try writeString(String(oneChar))
    }

    /// Encodes `str` and writes the resulting bytes to the underlying stream.
    private func writeString(_ str: String) throws {
      guard let data = str.data(using: encoding) else {
        throw java.io.IOException("Cannot encode string with \(getEncoding())")
      }
      let bytes = [UInt8](data)
      try inner.write(bytes, 0, bytes.count)
    }

    /// Flushes the underlying stream.
    /// - Since: JavaApi (Java 1.1)
    public override func flush() throws {
      try ensureOpen()
      try inner.flush()
    }

    /// Flushes and closes the underlying stream.
    /// - Since: JavaApi (Java 1.1)
    public override func close() throws {
      if !closed {
        closed = true
        try inner.flush()
        try inner.close()
      }
    }
  }
}
