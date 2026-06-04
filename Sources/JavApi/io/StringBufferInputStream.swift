/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {

  /// An `InputStream` that reads bytes from a `String`.
  ///
  /// Mirrors `java.io.StringBufferInputStream` from Java 1.0. Only the low
  /// 8 bits of each character are used — higher Unicode code points are
  /// silently truncated, matching the original Java behaviour.
  ///
  /// - Since: JavaApi (Java 1.0)
  @available(*, deprecated, message: "as of Java 1.1, use StringReader instead")
  open class StringBufferInputStream : InputStream {

    /// The string supplying bytes to this stream.
    public let buffer: String

    /// The characters of ``buffer`` for indexed access.
    private let chars: [Character]

    /// The current read position.
    public var pos: Int = 0

    /// The number of characters in ``buffer``.
    public var count: Int

    // MARK: - Initialisers

    /// Creates a `StringBufferInputStream` that reads from `s`.
    ///
    /// - Parameter s: The string to read bytes from.
    /// - Since: JavaApi (Java 1.0)
    public init(_ s: String) {
      buffer = s
      chars  = Array(s)
      count  = chars.count
    }

    // MARK: - InputStream overrides

    /// Returns the low 8 bits of the next character, or -1 at end of stream.
    /// - Since: JavaApi (Java 1.0)
    public override func read() throws -> Int {
      guard pos < count else { return -1 }
      let scalar = chars[pos].unicodeScalars.first?.value ?? 0
      pos += 1
      return Int(scalar & 0xFF)
    }

    /// Reads up to `length` bytes into `array` starting at `offset`.
    /// - Since: JavaApi (Java 1.0)
    public override func read(_ array: inout [UInt8], _ offset: Int, _ length: Int) throws -> Int {
      guard offset >= 0, length >= 0, offset + length <= array.count else {
        throw IndexOutOfBoundsException()
      }
      guard length > 0, pos < count else { return -1 }
      let toCopy = Swift.min(length, count - pos)
      for i in 0..<toCopy {
        let scalar = chars[pos + i].unicodeScalars.first?.value ?? 0
        array[offset + i] = UInt8(scalar & 0xFF)
      }
      pos += toCopy
      return toCopy
    }

    /// Returns the number of remaining bytes.
    /// - Since: JavaApi (Java 1.0)
    public override func available() throws -> Int {
      return count - pos
    }

    /// Resets the stream to the beginning.
    /// - Since: JavaApi (Java 1.0)
    public func reset() {
      pos = 0
    }

    /// Skips up to `n` bytes.
    /// - Since: JavaApi (Java 1.0)
    public override func skip(_ n: Int) throws -> Int {
      let toSkip = Swift.min(n, count - pos)
      pos += Swift.max(toSkip, 0)
      return Swift.max(toSkip, 0)
    }
  }
}
