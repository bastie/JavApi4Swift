/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {

  /// A `Reader` that allows characters to be pushed back into the stream.
  ///
  /// Mirrors `java.io.PushbackReader` from Java 1.1. One or more characters that
  /// have already been read can be "un-read" so that the next call to `read()`
  /// returns them again. Character-stream counterpart to ``PushbackInputStream``.
  ///
  /// ```swift
  /// let pr   = java.io.PushbackReader(java.io.StringReader("Hello"))
  /// let ch   = try pr.read()    // 'H'
  /// try pr.unread(ch)           // push 'H' back
  /// let again = try pr.read()   // 'H' again
  /// ```
  ///
  /// - Since: JavaApi (Java 1.1)
  open class PushbackReader : Reader, @unchecked Sendable {

    private let inner: java.io.Reader
    /// Pushback buffer; characters pushed back are stored from the end towards front.
    private var buf: [Character]
    /// Current position in `buf`. `buf.count` means the buffer is empty.
    private var pos: Int
    private var closed: Bool = false

    // MARK: - Initialisers

    /// Creates a `PushbackReader` with a pushback buffer of one character.
    ///
    /// - Parameter reader: The underlying `Reader`.
    /// - Since: JavaApi (Java 1.1)
    public init(_ reader: java.io.Reader) {
      inner = reader
      buf   = [Character](repeating: "\u{0}", count: 1)
      pos   = 1
      super.init()
    }

    /// Creates a `PushbackReader` with the given pushback buffer size.
    ///
    /// - Parameters:
    ///   - reader: The underlying `Reader`.
    ///   - size: Number of characters that may be pushed back.
    /// - Since: JavaApi (Java 1.1)
    public init(_ reader: java.io.Reader, _ size: Int) throws {
      guard size > 0 else { throw IllegalArgumentException("size <= 0") }
      inner = reader
      buf   = [Character](repeating: "\u{0}", count: size)
      pos   = size
      super.init()
    }

    // MARK: - Private helpers

    private func ensureOpen() throws {
      if closed { throw java.io.IOException("Stream closed") }
    }

    // MARK: - Reader overrides

    /// Reads a single character, returning a previously un-read character first.
    ///
    /// - Returns: The character as `Int`, or -1 at end of stream.
    /// - Since: JavaApi (Java 1.1)
    public override func read() throws -> Int {
      try ensureOpen()
      if pos < buf.count {
        let ch = buf[pos]
        pos += 1
        return Int(ch.unicodeScalars.first?.value ?? 0)
      }
      return try inner.read()
    }

    /// Reads up to `len` characters into `cbuf` starting at `offset`,
    /// consuming pushed-back characters first.
    /// - Since: JavaApi (Java 1.1)
    public override func read(_ cbuf: inout [Character], _ offset: Int, _ len: Int) throws -> Int {
      try ensureOpen()
      guard offset >= 0, len >= 0, offset + len <= cbuf.count else {
        throw IndexOutOfBoundsException()
      }
      guard len > 0 else { return 0 }

      var totalRead = 0
      // Drain pushback buffer first.
      let avail = buf.count - pos
      if avail > 0 {
        let toCopy = Swift.min(avail, len)
        cbuf[offset..<offset + toCopy] = buf[pos..<pos + toCopy]
        pos        += toCopy
        totalRead  += toCopy
      }
      // Read remainder from underlying reader.
      if totalRead < len {
        let n = try inner.read(&cbuf, offset + totalRead, len - totalRead)
        if n > 0 { totalRead += n }
      }
      return totalRead == 0 ? -1 : totalRead
    }

    // MARK: - unread

    /// Pushes a single character back into the stream.
    ///
    /// - Parameter c: The character code to push back.
    /// - Throws: `IOException` if the pushback buffer is full.
    /// - Since: JavaApi (Java 1.1)
    public func unread(_ c: Int) throws {
      try ensureOpen()
      guard pos > 0 else { throw java.io.IOException("Pushback buffer is full") }
      guard let scalar = UnicodeScalar(c) else {
        throw java.io.IOException("Invalid character code \(c)")
      }
      pos -= 1
      buf[pos] = Character(scalar)
    }

    /// Pushes all characters in `cbuf` back into the stream.
    ///
    /// - Parameter cbuf: The characters to push back (last element returned first).
    /// - Throws: `IOException` if the pushback buffer has insufficient space.
    /// - Since: JavaApi (Java 1.1)
    public func unread(_ cbuf: [Character]) throws {
      try unread(cbuf, 0, cbuf.count)
    }

    /// Pushes `len` characters from `cbuf` starting at `offset` back into the stream.
    ///
    /// - Parameters:
    ///   - cbuf: Source character array.
    ///   - offset: Start index in `cbuf`.
    ///   - len: Number of characters to push back.
    /// - Throws: `IOException` if the pushback buffer has insufficient space.
    /// - Since: JavaApi (Java 1.1)
    public func unread(_ cbuf: [Character], _ offset: Int, _ len: Int) throws {
      try ensureOpen()
      guard pos >= len else { throw java.io.IOException("Pushback buffer is full") }
      pos -= len
      buf[pos..<pos + len] = cbuf[offset..<offset + len]
    }

    /// Returns `true` if there are pushed-back characters or the underlying reader is ready.
    /// - Since: JavaApi (Java 1.1)
    public override func ready() throws -> Bool {
      try ensureOpen()
      if pos < buf.count { return true }
      return try inner.ready()
    }

    /// `PushbackReader` does not support `mark`/`reset`.
    /// - Since: JavaApi (Java 1.1)
    public override func markSupported() -> Bool { return false }

    /// Always throws — `PushbackReader` does not support `mark`.
    /// - Since: JavaApi (Java 1.1)
    public override func mark(_ readAheadLimit: Int) throws {
      throw java.io.IOException("mark/reset not supported")
    }

    /// Always throws — `PushbackReader` does not support `reset`.
    /// - Since: JavaApi (Java 1.1)
    public override func reset() throws {
      throw java.io.IOException("mark/reset not supported")
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
