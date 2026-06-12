/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {

  /// A `FilterInputStream` that tracks the current line number.
  ///
  /// Mirrors `java.io.LineNumberInputStream` from Java 1.0. The line number
  /// starts at 0 and is incremented each time a `\n`, `\r`, or `\r\n`
  /// sequence is encountered. `\r\n` counts as a single line terminator.
  ///
  /// - Since: JavaApi (Java 1.0)
  @available(*, deprecated, message: "as of Java 1.1, use LineNumberReader instead")
  open class LineNumberInputStream : FilterInputStream {

    private var lineNumber: Int = 0
    private var markLineNumber: Int = 0
    private var lastWasCR: Bool = false

    // MARK: - Initialisers

    /// Creates a `LineNumberInputStream` wrapping `inputStream`.
    ///
    /// - Parameter inputStream: The underlying `InputStream`.
    /// - Since: JavaApi (Java 1.0)
    public override init(_ inputStream: java.io.InputStream?) {
      super.init(inputStream)
    }

    // MARK: - Line number access

    /// Returns the current line number (0-based).
    /// - Since: JavaApi (Java 1.0)
    public func getLineNumber() -> Int {
      return lineNumber
    }

    /// Sets the line number to `lineNumber`.
    ///
    /// - Parameter lineNumber: The new line number.
    /// - Since: JavaApi (Java 1.0)
    public func setLineNumber(_ lineNumber: Int) {
      self.lineNumber = lineNumber
    }

    // MARK: - InputStream overrides

    /// Reads a single byte, incrementing the line number at line terminators.
    ///
    /// `\r\n` is treated as a single newline; the `\r` increments the count
    /// and the following `\n` is swallowed.
    ///
    /// - Returns: The byte value (0–255) with `\r` normalised to `\n`, or -1.
    /// - Since: JavaApi (Java 1.0)
    public override func read() throws -> Int {
      var b = try `in`.read()
      if b == 13 {           // '\r'
        lastWasCR = true
        lineNumber += 1
        b = 10               // normalise to '\n'
      } else if b == 10 {    // '\n'
        if lastWasCR {
          lastWasCR = false
          // already counted — read next byte
          return try read()
        }
        lineNumber += 1
        lastWasCR = false
      } else {
        lastWasCR = false
      }
      return b
    }

    /// Reads up to `length` bytes into `array`, counting line terminators.
    /// - Since: JavaApi (Java 1.0)
    public override func read (_ array: inout [UInt8], _ offset: Int, _ length: Int) throws -> Int {
      guard offset >= 0, length >= 0, offset + length <= array.count else {
        throw IOException("", IndexOutOfBoundsException())
      }
      var bytesRead = 0
      while bytesRead < length {
        let b = try read()
        if b == -1 { break }
        array[offset + bytesRead] = UInt8(b)
        bytesRead += 1
      }
      return bytesRead == 0 ? -1 : bytesRead
    }

    /// Marks the current position, saving the line number.
    /// - Parameter readlimit: limit of bytes to read
    /// - Since: Java 1.0
    public func mark(_ readlimit: Int) {
      markLineNumber = lineNumber
      // Note: underlying stream mark not called — FilterInputStream has no mark by default
    }

    /// Resets to the last mark, restoring the line number.
    /// - Since: Java 1.0
    public func reset() throws {
      lineNumber = markLineNumber
      lastWasCR = false
      try `in`.close() // underlying streams without mark support will fail here
    }
  }
}
