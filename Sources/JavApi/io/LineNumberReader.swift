/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {

  /// A buffered `Reader` that tracks the current line number.
  ///
  /// Mirrors `java.io.LineNumberReader` from Java 1.1. Replaces the deprecated
  /// ``LineNumberInputStream``. The line number starts at 0 and is incremented
  /// each time a `\n`, `\r`, or `\r\n` sequence is encountered.
  ///
  /// ```swift
  /// let reader = java.io.LineNumberReader(java.io.StringReader("line1\nline2\n"))
  /// _ = try reader.readLine()   // "line1", lineNumber → 1
  /// _ = try reader.readLine()   // "line2", lineNumber → 2
  /// ```
  ///
  /// - Since: JavaApi (Java 1.1)
  open class LineNumberReader : Reader, @unchecked Sendable {

    private let inner: java.io.Reader
    private var lineNumber: Int = 0
    private var markLineNumber: Int = 0
    private var lastWasCR: Bool = false
    private var pushback: Character? = nil

    // MARK: - Initialisers

    /// Creates a `LineNumberReader` wrapping `reader` with a default buffer.
    ///
    /// - Parameter reader: The underlying `Reader`.
    /// - Since: JavaApi (Java 1.1)
    public init(_ reader: java.io.Reader) {
      inner = reader
      super.init()
    }

    /// Creates a `LineNumberReader` wrapping `reader` with the given buffer size.
    ///
    /// - Parameters:
    ///   - reader: The underlying `Reader`.
    ///   - sz: Buffer size hint (currently ignored — no internal buffering).
    /// - Since: JavaApi (Java 1.1)
    public init(_ reader: java.io.Reader, _ sz: Int) {
      inner = reader
      super.init()
    }

    // MARK: - Line number access

    /// Returns the current line number.
    /// - Since: JavaApi (Java 1.1)
    public func getLineNumber() -> Int { return lineNumber }

    /// Sets the current line number.
    ///
    /// - Parameter lineNumber: The new line number.
    /// - Since: JavaApi (Java 1.1)
    public func setLineNumber(_ lineNumber: Int) {
      self.lineNumber = lineNumber
    }

    // MARK: - Reader overrides

    /// Reads a single character, incrementing the line number at line terminators.
    ///
    /// `\r\n` is treated as a single newline. Returns `\n` for all terminators.
    ///
    /// - Returns: The character as `Int`, or -1 at end of stream.
    /// - Since: JavaApi (Java 1.1)
    public override func read() throws -> Int {
      if let pb = pushback {
        pushback = nil
        return Int(pb.unicodeScalars.first?.value ?? 0)
      }
      let c = try inner.read()
      if c == -1 { return -1 }
      let ch = Character(UnicodeScalar(c)!)
      if ch == "\r" {
        lastWasCR = true
        lineNumber += 1
        return Int(Character("\n").unicodeScalars.first!.value)
      }
      if ch == "\n" {
        if lastWasCR {
          lastWasCR = false
          return try read()  // skip \n after \r
        }
        lineNumber += 1
      } else {
        lastWasCR = false
      }
      return c
    }

    /// Reads up to `count` characters into `buf` starting at `offset`.
    /// - Since: JavaApi (Java 1.1)
    public override func read(_ buf: inout [Character], _ offset: Int, _ count: Int) throws -> Int {
      guard offset >= 0, count >= 0, offset + count <= buf.count else {
        throw IndexOutOfBoundsException()
      }
      var read = 0
      while read < count {
        let c = try self.read()
        if c == -1 { break }
        buf[offset + read] = Character(UnicodeScalar(c)!)
        read += 1
      }
      return read == 0 ? -1 : read
    }

    /// Reads a full line, stripping the line terminator.
    ///
    /// - Returns: The line content, or `nil` at end of stream.
    /// - Since: JavaApi (Java 1.1)
    public func readLine() throws -> String? {
      var line = ""
      var gotChar = false
      while true {
        let c = try read()
        if c == -1 { return gotChar ? line : nil }
        let ch = Character(UnicodeScalar(c)!)
        if ch == "\n" { return line }
        line.append(ch)
        gotChar = true
      }
    }

    /// Returns `true` — delegates to the underlying reader.
    /// - Since: JavaApi (Java 1.1)
    public override func markSupported() -> Bool { return true }

    /// Marks the current stream position and saves the line number.
    /// - Since: JavaApi (Java 1.1)
    public override func mark(_ readLimit: Int) throws {
      markLineNumber = lineNumber
      try inner.mark(readLimit)
    }

    /// Resets to the last mark, restoring the line number.
    /// - Since: JavaApi (Java 1.1)
    public override func reset() throws {
      lineNumber = markLineNumber
      lastWasCR = false
      pushback = nil
      try inner.reset()
    }

    /// Skips up to `count` characters.
    /// - Since: JavaApi (Java 1.1)
    public override func skip(_ count: Int64) throws -> Int64 {
      return try inner.skip(count)
    }

    /// Closes the underlying reader.
    /// - Since: JavaApi (Java 1.1)
    public override func close() throws {
      try inner.close()
    }
  }
}
