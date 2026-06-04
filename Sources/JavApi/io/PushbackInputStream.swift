/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {

  /// A `FilterInputStream` that allows bytes to be pushed back into the stream.
  ///
  /// Mirrors `java.io.PushbackInputStream` from Java 1.0. One or more bytes
  /// that have already been read can be "un-read" so that the next call to
  /// `read()` returns them again.
  ///
  /// ```swift
  /// let stream   = java.io.ByteArrayInputStream([65, 66, 67])
  /// let pushback = java.io.PushbackInputStream(stream)
  /// let first    = try pushback.read()   // 65 ('A')
  /// try pushback.unread(first)           // push 'A' back
  /// let again    = try pushback.read()   // 65 ('A') again
  /// ```
  ///
  /// - Since: JavaApi (Java 1.0)
  open class PushbackInputStream : FilterInputStream {

    /// The pushback buffer. Bytes are stored from the end towards the front.
    internal var buf: [UInt8]

    /// The current position in the pushback buffer.
    /// `buf.count` means the buffer is empty.
    internal var pos: Int

    // MARK: - Initialisers

    /// Creates a `PushbackInputStream` with a pushback buffer of one byte.
    ///
    /// - Parameter inputStream: The underlying `InputStream`.
    /// - Since: JavaApi (Java 1.0)
    public init(_ inputStream: java.io.InputStream) {
      buf = [UInt8](repeating: 0, count: 1)
      pos = 1
      super.init(inputStream)
    }

    /// Creates a `PushbackInputStream` with the given pushback buffer size.
    ///
    /// - Parameters:
    ///   - inputStream: The underlying `InputStream`.
    ///   - size: Number of bytes that may be pushed back.
    /// - Since: JavaApi (Java 1.0)
    public init(_ inputStream: java.io.InputStream, _ size: Int) {
      buf = [UInt8](repeating: 0, count: max(size, 1))
      pos = buf.count
      super.init(inputStream)
    }

    // MARK: - read

    /// Reads a single byte, returning a previously un-read byte first if available.
    ///
    /// - Returns: The byte value (0–255), or -1 at end of stream.
    /// - Since: JavaApi (Java 1.0)
    public override func read() throws -> Int {
      if pos < buf.count {
        let byte = Int(buf[pos])
        pos += 1
        return byte
      }
      return try `in`.read()
    }

    /// Reads up to `length` bytes, consuming pushed-back bytes first.
    /// - Since: JavaApi (Java 1.0)
    public override func read(_ array: inout [UInt8], _ offset: Int, _ length: Int) throws -> Int {
      guard offset >= 0, length >= 0, offset + length <= array.count else {
        throw IndexOutOfBoundsException()
      }
      guard length > 0 else { return 0 }

      var bytesRead = 0
      // First drain the pushback buffer
      let avail = buf.count - pos
      if avail > 0 {
        let toCopy = Swift.min(avail, length)
        array[offset..<offset + toCopy] = buf[pos..<pos + toCopy]
        pos += toCopy
        bytesRead += toCopy
      }
      // Then read from underlying stream if more needed
      if bytesRead < length {
        let fromStream = try `in`.read(&array, offset + bytesRead, length - bytesRead)
        if fromStream > 0 { bytesRead += fromStream }
      }
      return bytesRead == 0 ? -1 : bytesRead
    }

    // MARK: - unread

    /// Pushes a single byte back into the stream.
    ///
    /// - Parameter b: The byte to push back (only the lowest 8 bits are used).
    /// - Throws: `java.io.IOException` if the pushback buffer is full.
    /// - Since: JavaApi (Java 1.0)
    public func unread(_ b: Int) throws {
      guard pos > 0 else {
        throw java.io.IOException("Push back buffer is full")
      }
      pos -= 1
      buf[pos] = UInt8(b & 0xFF)
    }

    /// Pushes an array of bytes back into the stream.
    ///
    /// - Parameter b: The bytes to push back.
    /// - Throws: `java.io.IOException` if the pushback buffer has insufficient space.
    /// - Since: JavaApi (Java 1.0)
    public func unread(_ b: [UInt8]) throws {
      try unread(b, 0, b.count)
    }

    /// Pushes `length` bytes from `b` starting at `offset` back into the stream.
    ///
    /// - Parameters:
    ///   - b: Source byte array.
    ///   - offset: Start index in `b`.
    ///   - length: Number of bytes to push back.
    /// - Throws: `java.io.IOException` if the pushback buffer has insufficient space.
    /// - Since: JavaApi (Java 1.0)
    public func unread(_ b: [UInt8], _ offset: Int, _ length: Int) throws {
      guard pos >= length else {
        throw java.io.IOException("Push back buffer is full")
      }
      pos -= length
      buf[pos..<pos + length] = b[offset..<offset + length]
    }

    // MARK: - available

    /// Returns the number of bytes available (pushed-back + underlying stream).
    /// - Since: JavaApi (Java 1.0)
    public override func available() throws -> Int {
      return (buf.count - pos) + (try `in`.available())
    }
  }
}
