/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {

  /// A buffering `Reader` that reads text efficiently from a character-input stream.
  ///
  /// Mirrors `java.io.BufferedReader` from Java 1.1. Wraps any `Reader` and
  /// maintains an internal character buffer (default size 8192). Also provides
  /// `readLine()` which handles `\n`, `\r`, and `\r\n` terminators.
  ///
  /// ```swift
  /// let br = java.io.BufferedReader(java.io.StringReader("line1\nline2"))
  /// let first = try br.readLine()   // "line1"
  /// let second = try br.readLine()  // "line2"
  /// let eof    = try br.readLine()  // nil
  /// ```
  ///
  /// - Since: Java 1.1
  open class BufferedReader : Reader, @unchecked Sendable {
    public typealias Readable = BufferedReader

    private static let defaultBufferSize = 8192

    private let inner: java.io.Reader
    private var buf: [Character]
    /// Number of valid characters in `buf`.
    private var bufCount: Int = 0
    /// Current read position inside `buf`.
    private var bufPos: Int = 0
    /// Mark position inside `buf` (-1 = no mark).
    private var markPos: Int = -1
    /// Maximum characters that can be read before the mark is invalidated.
    private var markLimit: Int = 0
    private var closed: Bool = false

    // MARK: - Initialisers

    /// Creates a `BufferedReader` wrapping `reader` with the default buffer (8192 chars).
    ///
    /// - Parameter reader: The underlying `Reader`.
    /// - Since: Java 1.1
    public init(_ reader: java.io.Reader) {
      inner = reader
      buf = Array(repeating: "\u{0}", count: BufferedReader.defaultBufferSize)
      super.init()
    }

    /// Creates a `BufferedReader` wrapping `reader` with a custom buffer size.
    ///
    /// - Parameters:
    ///   - reader: The underlying `Reader`.
    ///   - sz: Buffer size in characters.
    /// - Since: Java 1.1
    public init(_ reader: java.io.Reader, _ sz: Int) throws {
      guard sz > 0 else { throw IllegalArgumentException("Buffer size <= 0") }
      inner = reader
      buf = Array(repeating: "\u{0}", count: sz)
      super.init()
    }

    // MARK: - Private helpers

    private func ensureOpen() throws {
      if closed { throw java.io.IOException("Stream closed") }
    }

    /// Refills `buf` from the underlying reader.
    /// Returns `false` when EOF is reached.
    private func fill() throws -> Bool {
      // Compact: if a mark is active, shift unread + marked data to the front.
      if markPos >= 0 {
        let keep = bufCount - markPos
        if keep > 0 {
          buf.withUnsafeMutableBufferPointer { ptr in
            ptr.baseAddress!.advanced(by: 0)
              .update(from: ptr.baseAddress!.advanced(by: markPos), count: keep)
          }
        }
        bufPos  = keep - (bufCount - bufPos)   // recalculate read position
        markPos = 0
        bufCount = keep
      } else {
        bufPos   = 0
        bufCount = 0
      }

      let n = try inner.read(&buf, bufCount, buf.count - bufCount)
      if n <= 0 { return false }
      bufCount += n
      return true
    }

    // MARK: - Reader overrides

    /// Reads a single character; returns -1 at end of stream.
    /// - Since: Java 1.1
    public override func read() throws -> Int {
      try ensureOpen()
      if bufPos >= bufCount {
        guard try fill() else { return -1 }
      }
      let ch = buf[bufPos]
      bufPos += 1
      return Int(ch.unicodeScalars.first?.value ?? 0)
    }

    /// Reads up to `count` characters into `buf` starting at `offset`.
    /// - Since: Java 1.1
    public override func read(_ cbuf: inout [Character], _ offset: Int, _ count: Int) throws -> Int {
      try ensureOpen()
      guard offset >= 0, count >= 0, offset + count <= cbuf.count else {
        throw IndexOutOfBoundsException()
      }
      if count == 0 { return 0 }

      var totalRead = 0
      while totalRead < count {
        // If buffer is empty, refill.
        if bufPos >= bufCount {
          // For large reads that bypass the buffer entirely:
          if totalRead > 0 { break }
          let n = try inner.read(&cbuf, offset, count)
          return n
        }
        let available = bufCount - bufPos
        let toCopy    = Swift.min(available, count - totalRead)
        cbuf[(offset + totalRead)..<(offset + totalRead + toCopy)] =
          buf[bufPos..<bufPos + toCopy]
        bufPos    += toCopy
        totalRead += toCopy
      }
      return totalRead == 0 ? -1 : totalRead
    }

    /// Reads a line of text, stripping the line terminator (`\n`, `\r`, `\r\n`).
    ///
    /// - Returns: The line content, or `nil` at end of stream.
    /// - Since: Java 1.1
    public func readLine() throws -> String? {
      try ensureOpen()
      var line = ""
      var gotChar = false
      var lastWasCR = false

      while true {
        if bufPos >= bufCount {
          guard try fill() else {
            return gotChar ? line : nil
          }
        }
        let ch = buf[bufPos]
        bufPos += 1
        gotChar = true

        if ch == "\r" {
          lastWasCR = true
          return line
        }
        if ch == "\n" {
          if lastWasCR {
            // \r\n — the \r already returned the line; skip the \n silently.
            lastWasCR = false
            continue
          }
          return line
        }
        lastWasCR = false
        line.append(ch)
      }
    }

    /// Returns `true` if there is buffered data or the underlying reader is ready.
    /// - Since: Java 1.1
    public override func ready() throws -> Bool {
      try ensureOpen()
      if bufPos < bufCount { return true }
      return try inner.ready()
    }

    /// Returns `true` — `BufferedReader` supports `mark`/`reset`.
    /// - Since: Java 1.1
    public override func markSupported() -> Bool { return true }

    /// Marks the current position; the mark is valid while fewer than
    /// `readAheadLimit` additional characters are read.
    ///
    /// - Parameter readAheadLimit: Maximum look-ahead before the mark is invalidated.
    /// - Since: Java 1.1
    public override func mark(_ readAheadLimit: Int) throws {
      guard readAheadLimit >= 0 else {
        throw IllegalArgumentException("Read-ahead limit < 0")
      }
      try ensureOpen()
      // Grow the buffer if the look-ahead exceeds its current size.
      if readAheadLimit > buf.count {
        var newBuf = Array(repeating: Character("\u{0}"), count: readAheadLimit)
        let valid = bufCount - bufPos
        newBuf[0..<valid] = buf[bufPos..<bufCount]
        buf      = newBuf
        bufCount = valid
        bufPos   = 0
      }
      markPos   = bufPos
      markLimit = readAheadLimit
    }

    /// Resets the stream to the last mark.
    /// - Since: Java 1.1
    public override func reset() throws {
      try ensureOpen()
      guard markPos >= 0 else {
        throw java.io.IOException("Stream not marked")
      }
      bufPos = markPos
    }

    /// Skips up to `count` characters.
    /// - Since: Java 1.1
    public override func skip(_ count: Int64) throws -> Int64 {
      guard count >= 0 else { throw IllegalArgumentException("skip value is negative") }
      try ensureOpen()
      var remaining = count
      while remaining > 0 {
        if bufPos >= bufCount {
          guard try fill() else { break }
        }
        let available = Int64(bufCount - bufPos)
        let toSkip    = Swift.min(remaining, available)
        bufPos    += Int(toSkip)
        remaining -= toSkip
      }
      return count - remaining
    }

    /// Closes the reader and the underlying stream.
    /// - Since: Java 1.1
    public override func close() throws {
      if !closed {
        closed = true
        try inner.close()
      }
    }
  }
}
