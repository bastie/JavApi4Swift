/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {

  /// A `Reader` whose source is a `String`.
  ///
  /// Mirrors `java.io.StringReader` from Java 1.1. Replaces the deprecated
  /// ``StringBufferInputStream``.
  ///
  /// ```swift
  /// let reader = java.io.StringReader("Hello, World!")
  /// let ch = try reader.read()   // 72 ('H')
  /// ```
  ///
  /// - Since: JavaApi (Java 1.1)
  open class StringReader : Reader, @unchecked Sendable {

    private let source: [Character]
    private var pos: Int = 0
    private var markPos: Int = 0
    private var closed: Bool = false

    // MARK: - Initialisers

    /// Creates a `StringReader` that reads from `s`.
    ///
    /// - Parameter s: The string to read from.
    /// - Since: JavaApi (Java 1.1)
    public init(_ s: String) {
      source = Array(s)
      super.init()
    }

    // MARK: - Reader overrides

    private func ensureOpen() throws {
      if closed { throw java.io.IOException("Stream closed") }
    }

    /// Reads a single character, or -1 at end of string.
    /// - Since: JavaApi (Java 1.1)
    public override func read() throws -> Int {
      try ensureOpen()
      guard pos < source.count else { return -1 }
      let ch = source[pos]
      pos += 1
      return Int(ch.unicodeScalars.first?.value ?? 0)
    }

    /// Reads up to `count` characters into `buf` starting at `offset`.
    /// - Since: JavaApi (Java 1.1)
    public override func read(_ buf: inout [Character], _ offset: Int, _ count: Int) throws -> Int {
      try ensureOpen()
      guard offset >= 0, count >= 0, offset + count <= buf.count else {
        throw IndexOutOfBoundsException()
      }
      guard count > 0, pos < source.count else { return -1 }
      let toCopy = Swift.min(count, source.count - pos)
      buf[offset..<offset + toCopy] = source[pos..<pos + toCopy]
      pos += toCopy
      return toCopy
    }

    /// Returns `true` — a `StringReader` is always ready to read.
    /// - Since: JavaApi (Java 1.1)
    public override func ready() throws -> Bool {
      try ensureOpen()
      return true
    }

    /// Returns `true` — `StringReader` supports `mark`/`reset`.
    /// - Since: JavaApi (Java 1.1)
    public override func markSupported() -> Bool { return true }

    /// Marks the current position.
    ///
    /// - Parameter readLimit: Ignored — there is no limit on a `StringReader`.
    /// - Since: JavaApi (Java 1.1)
    public override func mark(_ readLimit: Int) throws {
      try ensureOpen()
      markPos = pos
    }

    /// Resets to the last marked position (or the beginning if `mark` was never called).
    /// - Since: JavaApi (Java 1.1)
    public override func reset() throws {
      try ensureOpen()
      pos = markPos
    }

    /// Skips up to `count` characters.
    /// - Since: JavaApi (Java 1.1)
    public override func skip(_ count: Int64) throws -> Int64 {
      try ensureOpen()
      let available = Int64(source.count - pos)
      let toSkip = Swift.min(count, available)
      pos += Int(Swift.max(toSkip, 0))
      return Swift.max(toSkip, 0)
    }

    /// Closes the reader; subsequent reads throw `IOException`.
    /// - Since: JavaApi (Java 1.1)
    public override func close() throws {
      closed = true
    }
  }
}
