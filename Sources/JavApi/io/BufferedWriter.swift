/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {

  /// A buffering `Writer` that writes text efficiently to a character-output stream.
  ///
  /// Mirrors `java.io.BufferedWriter` from Java 1.1. Wraps any `Writer` and
  /// maintains an internal character buffer (default size 8192). The buffer is
  /// flushed to the underlying writer automatically when full, or explicitly via
  /// `flush()`. `close()` flushes and then closes the underlying writer.
  ///
  /// Use `newLine()` to write a platform-appropriate line separator.
  ///
  /// ```swift
  /// let sw  = java.io.StringWriter()
  /// let bw  = java.io.BufferedWriter(sw)
  /// try bw.write("Hello")
  /// try bw.newLine()
  /// try bw.write("World")
  /// try bw.flush()
  /// print(sw.toString())   // "Hello\nWorld"  (or \r\n on Windows)
  /// ```
  ///
  /// - Since: JavaApi (Java 1.1)
  open class BufferedWriter : Writer, @unchecked Sendable {

    private static let defaultBufferSize = 8192

    private let inner: java.io.Writer
    private var buf: [Character]
    /// Number of characters currently in the buffer.
    private var bufCount: Int = 0
    private var closed: Bool = false

    // MARK: - Initialisers

    /// Creates a `BufferedWriter` wrapping `writer` with the default buffer (8192 chars).
    ///
    /// - Parameter writer: The underlying `Writer`.
    /// - Since: JavaApi (Java 1.1)
    public init(_ writer: java.io.Writer) {
      inner = writer
      buf = Array(repeating: "\u{0}", count: BufferedWriter.defaultBufferSize)
      super.init()
    }

    /// Creates a `BufferedWriter` wrapping `writer` with a custom buffer size.
    ///
    /// - Parameters:
    ///   - writer: The underlying `Writer`.
    ///   - sz: Buffer size in characters.
    /// - Since: JavaApi (Java 1.1)
    public init(_ writer: java.io.Writer, _ sz: Int) throws {
      guard sz > 0 else { throw IllegalArgumentException("Buffer size <= 0") }
      inner = writer
      buf = Array(repeating: "\u{0}", count: sz)
      super.init()
    }

    // MARK: - Private helpers

    private func ensureOpen() throws {
      if closed { throw java.io.IOException("Stream closed") }
    }

    /// Flushes the internal buffer to the underlying writer without flushing it.
    private func flushBuffer() throws {
      if bufCount > 0 {
        try inner.write(buf, 0, bufCount)
        bufCount = 0
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

      // If the incoming data is larger than the buffer, flush and write directly.
      if len >= buf.count {
        try flushBuffer()
        try inner.write(cbuf, offset, len)
        return
      }

      // Fill the buffer, flushing whenever it is full.
      var srcPos = offset
      var remaining = len
      while remaining > 0 {
        let space = buf.count - bufCount
        let toCopy = Swift.min(space, remaining)
        buf[bufCount..<bufCount + toCopy] = cbuf[srcPos..<srcPos + toCopy]
        bufCount  += toCopy
        srcPos    += toCopy
        remaining -= toCopy
        if bufCount == buf.count {
          try flushBuffer()
        }
      }
    }

    /// Writes `len` characters from `str` starting at `offset`.
    /// - Since: JavaApi (Java 1.1)
    public override func write(_ str: String, _ offset: Int, _ len: Int) throws {
      try ensureOpen()
      guard offset >= 0, len >= 0, offset + len <= str.count else {
        throw StringIndexOutOfBoundsException(-1)
      }
      let chars = Array(str)[offset..<offset + len]
      try write(Array(chars), 0, chars.count)
    }

    /// Writes a single character.
    /// - Since: JavaApi (Java 1.1)
    public override func write(_ oneChar: Character) throws {
      try ensureOpen()
      if bufCount == buf.count {
        try flushBuffer()
      }
      buf[bufCount] = oneChar
      bufCount += 1
    }

    /// Writes the platform line separator (`\n` on Unix/macOS, `\r\n` on Windows).
    /// - Since: JavaApi (Java 1.1)
    public func newLine() throws {
      try ensureOpen()
      #if os(Windows)
      try write("\r\n")
      #else
      try write("\n")
      #endif
    }

    /// Flushes the internal buffer and the underlying writer.
    /// - Since: JavaApi (Java 1.1)
    public override func flush() throws {
      try ensureOpen()
      try flushBuffer()
      try inner.flush()
    }

    /// Flushes the buffer and closes the underlying writer.
    /// - Since: JavaApi (Java 1.1)
    public override func close() throws {
      if !closed {
        closed = true
        try flushBuffer()
        try inner.close()
      }
    }
  }
}
