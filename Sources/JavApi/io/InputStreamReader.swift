/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.io {

  /// A bridge `Reader` that decodes bytes from an `InputStream` into characters.
  ///
  /// Mirrors `java.io.InputStreamReader` from Java 1.1. Each `read()` call reads
  /// one or more bytes from the underlying `InputStream` and decodes them using
  /// the specified character encoding (default: UTF-8).
  ///
  /// ```swift
  /// let data  = "Héllo".data(using: .utf8)!
  /// let bis   = java.io.ByteArrayInputStream(Array(data))
  /// let isr   = java.io.InputStreamReader(bis)
  /// let first = try isr.read()   // 'H'
  /// ```
  ///
  /// - Since: JavaApi (Java 1.1)
  open class InputStreamReader : Reader, @unchecked Sendable {

    private let inner: java.io.InputStream
    private let encoding: String.Encoding
    private var closed: Bool = false

    /// Byte buffer used to accumulate multi-byte sequences.
    private var byteBuf: [UInt8] = []
    /// Decoded characters waiting to be returned.
    private var charBuf: [Character] = []
    private var charPos: Int = 0

    // MARK: - Initialisers

    /// Creates an `InputStreamReader` using UTF-8 encoding.
    ///
    /// - Parameter stream: The underlying `InputStream`.
    /// - Since: JavaApi (Java 1.1)
    public init(_ stream: java.io.InputStream) {
      inner    = stream
      encoding = .utf8
      super.init()
    }

    /// Creates an `InputStreamReader` using the named charset.
    ///
    /// Supported charset names mirror the Java canonical names:
    /// `"UTF-8"`, `"UTF-16"`, `"ISO-8859-1"`, `"US-ASCII"`, `"UTF-16BE"`, `"UTF-16LE"`.
    ///
    /// - Parameters:
    ///   - stream: The underlying `InputStream`.
    ///   - charsetName: The IANA charset name.
    /// - Throws: `UnsupportedEncodingException` if the charset is not recognised.
    /// - Since: JavaApi (Java 1.1)
    public init(_ stream: java.io.InputStream, _ charsetName: String) throws {
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

    /// Returns the name of the encoding used by this reader.
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

    /// Fills `charBuf` by reading bytes from the inner stream and decoding them.
    /// Returns `false` on EOF.
    private func refill() throws -> Bool {
      // Read a chunk of bytes (up to 512) from the underlying stream.
      var raw = [UInt8](repeating: 0, count: 512)
      let n = try inner.read(&raw, 0, raw.count)
      if n <= 0 { return false }
      byteBuf.append(contentsOf: raw[0..<n])

      // Attempt to decode as many complete characters as possible.
      let data = Data(byteBuf)
      if let str = String(data: data, encoding: encoding) {
        charBuf  = Array(str)
        charPos  = 0
        byteBuf  = []          // all bytes consumed
      } else {
        // Incomplete multi-byte sequence at the end — keep byteBuf for next call.
        // Try progressively shorter slices to find decodable prefix.
        var decodable = byteBuf.count - 1
        var decoded: String? = nil
        while decodable > 0 {
          decoded = String(data: Data(byteBuf[0..<decodable]), encoding: encoding)
          if decoded != nil { break }
          decodable -= 1
        }
        if let s = decoded {
          charBuf  = Array(s)
          charPos  = 0
          byteBuf  = Array(byteBuf[decodable...])
        } else {
          return false   // cannot decode anything yet
        }
      }
      return !charBuf.isEmpty
    }

    // MARK: - Reader overrides

    /// Reads a single character; returns -1 at end of stream.
    /// - Since: JavaApi (Java 1.1)
    public override func read() throws -> Int {
      try ensureOpen()
      if charPos >= charBuf.count {
        guard try refill() else { return -1 }
      }
      let ch = charBuf[charPos]
      charPos += 1
      return Int(ch.unicodeScalars.first?.value ?? 0)
    }

    /// Reads up to `count` characters into `cbuf` starting at `offset`.
    /// - Since: JavaApi (Java 1.1)
    public override func read(_ cbuf: inout [Character], _ offset: Int, _ count: Int) throws -> Int {
      try ensureOpen()
      guard offset >= 0, count >= 0, offset + count <= cbuf.count else {
        throw IndexOutOfBoundsException()
      }
      if count == 0 { return 0 }
      var totalRead = 0
      while totalRead < count {
        if charPos >= charBuf.count {
          guard try refill() else { break }
        }
        let available = charBuf.count - charPos
        let toCopy    = Swift.min(available, count - totalRead)
        cbuf[(offset + totalRead)..<(offset + totalRead + toCopy)] =
          charBuf[charPos..<charPos + toCopy]
        charPos    += toCopy
        totalRead  += toCopy
      }
      return totalRead == 0 ? -1 : totalRead
    }

    /// Returns `true` if characters are buffered or the underlying stream has data.
    /// - Since: JavaApi (Java 1.1)
    public override func ready() throws -> Bool {
      try ensureOpen()
      if charPos < charBuf.count { return true }
      return try inner.available() > 0
    }

    /// Closes the reader and the underlying stream.
    /// - Since: JavaApi (Java 1.1)
    public override func close() throws {
      if !closed {
        closed = true
        try inner.close()
      }
    }
  }
}
