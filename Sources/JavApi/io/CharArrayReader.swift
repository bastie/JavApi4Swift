/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {

  /// A `Reader` whose source is a character array.
  ///
  /// Mirrors `java.io.CharArrayReader` from Java 1.1. Counterpart to
  /// ``CharArrayWriter``.
  ///
  /// ```swift
  /// let chars: [Character] = Array("Hello")
  /// let reader = java.io.CharArrayReader(chars)
  /// let ch = try reader.read()   // 72 ('H')
  /// ```
  ///
  /// - Since: Java 1.1
  open class CharArrayReader : Reader, @unchecked Sendable {
    public typealias Readable = CharArrayReader

    private var buf: [Character]
    private var pos: Int
    private var count: Int
    private var markPos: Int = 0
    private var closed: Bool = false

    // MARK: - Initialisers

    /// Creates a `CharArrayReader` over the entire array.
    ///
    /// - Parameter buf: The character array to read from (copied by reference).
    /// - Since: Java 1.1
    public init(_ buf: [Character]) {
      self.buf   = buf
      self.pos   = 0
      self.count = buf.count
      super.init()
    }

    /// Creates a `CharArrayReader` over a sub-range of the array.
    ///
    /// - Parameters:
    ///   - buf: The character array to read from.
    ///   - offset: Index of the first character to read.
    ///   - length: Number of characters to make available.
    /// - Since: Java 1.1
    public init(_ buf: [Character], _ offset: Int, _ length: Int) {
      self.buf   = buf
      self.pos   = offset
      self.count = Swift.min(offset + length, buf.count)
      self.markPos = offset
      super.init()
    }

    // MARK: - Private helpers

    private func ensureOpen() throws {
      if closed { throw java.io.IOException("Stream closed") }
    }

    // MARK: - Reader overrides

    /// Reads a single character; returns -1 at end of array.
    /// - Since: Java 1.1
    public override func read() throws -> Int {
      try ensureOpen()
      guard pos < count else { return -1 }
      let ch = buf[pos]
      pos += 1
      return Int(ch.unicodeScalars.first?.value ?? 0)
    }

    /// Reads up to `len` characters into `cbuf` starting at `offset`.
    /// - Since: Java 1.1
    public override func read(_ cbuf: inout [Character], _ offset: Int, _ len: Int) throws -> Int {
      try ensureOpen()
      guard offset >= 0, len >= 0, offset + len <= cbuf.count else {
        throw IndexOutOfBoundsException()
      }
      guard pos < count else { return -1 }
      let toCopy = Swift.min(len, count - pos)
      cbuf[offset..<offset + toCopy] = buf[pos..<pos + toCopy]
      pos += toCopy
      return toCopy
    }

    /// Skips up to `n` characters.
    /// - Since: Java 1.1
    public override func skip(_ n: Int64) throws -> Int64 {
      try ensureOpen()
      let available = Int64(count - pos)
      let toSkip    = Swift.min(Swift.max(n, 0), available)
      pos += Int(toSkip)
      return toSkip
    }

    /// Returns `true` — a `CharArrayReader` is always ready.
    /// - Since: Java 1.1
    public override func ready() throws -> Bool {
      try ensureOpen()
      return pos < count
    }

    /// Returns `true` — `CharArrayReader` supports `mark`/`reset`.
    /// - Since: Java 1.1
    public override func markSupported() -> Bool { return true }

    /// Marks the current position.
    ///
    /// - Parameter readAheadLimit: Ignored — no limit on a `CharArrayReader`.
    /// - Since: Java 1.1
    public override func mark(_ readAheadLimit: Int) throws {
      try ensureOpen()
      markPos = pos
    }

    /// Resets to the last marked position.
    /// - Since: Java 1.1
    public override func reset() throws {
      try ensureOpen()
      pos = markPos
    }

    /// Closes the reader.
    /// - Since: Java 1.1
    public override func close() throws {
      closed = true
    }
  }
}
