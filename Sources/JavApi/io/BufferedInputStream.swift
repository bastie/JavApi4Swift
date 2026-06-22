/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.io {

  /// A `FilterInputStream` that buffers bytes read from the underlying stream.
  ///
  /// Mirrors `java.io.BufferedInputStream` from Java 1.0. Bytes are read
  /// from the underlying `InputStream` in chunks into an internal `[UInt8]`
  /// buffer, reducing the number of individual read calls.
  ///
  /// `mark()` and `reset()` are supported up to the limit set by
  /// ``mark(_:)``.
  ///
  /// ```swift
  /// let file   = java.io.FileInputStream("data.bin")
  /// let buffered = java.io.BufferedInputStream(file)
  /// let first  = try buffered.read()   // reads a full buffer chunk internally
  /// ```
  ///
  /// - Since: Java 1.0
  open class BufferedInputStream : FilterInputStream {

    // MARK: - Fields (public, matching Java spec)

    /// The internal byte buffer.
    /// - Note: protected in Java
    public var buf: [UInt8]

    /// The number of valid bytes in ``buf``.
    /// - Note: protected in Java
    public var count: Int = 0

    /// The current read position within ``buf``.
    /// - Note: protected in Java
    public var pos: Int = 0

    /// The position of the last `mark()` call, or -1 if not marked.
    /// - Note: protected in Java
    public var markpos: Int = -1

    /// The maximum look-ahead allowed after a `mark()` call.
    /// - Note: protected in Java
    public var marklimit: Int = 0

    private var closed: Bool = false

    // MARK: - Default buffer size

    private static let defaultBufferSize = 8192

    // MARK: - Initialisers

    /// Creates a `BufferedInputStream` with the default buffer size (8192 bytes).
    ///
    /// - Parameter inputStream: The underlying `InputStream` to buffer.
    ///
    /// - Since: Java 1.0
    public init(_ inputStream: java.io.InputStream) {
      buf = [UInt8](repeating: 0, count: BufferedInputStream.defaultBufferSize)
      super.init(inputStream)
    }

    /// Creates a `BufferedInputStream` with the given buffer size.
    ///
    /// - Parameters:
    ///   - inputStream: The underlying `InputStream` to buffer.
    ///   - size: Buffer size in bytes.
    ///
    /// - Since: Java 1.0
    public init(_ inputStream: java.io.InputStream, _ size: Int) {
      buf = [UInt8](repeating: 0, count: max(size, 1))
      super.init(inputStream)
    }

    // MARK: - Private helpers

    private func ensureOpen() throws {
      if closed { throw java.io.IOException("Stream closed") }
    }

    /// Fills the buffer from the underlying stream.
    private func fill() throws {
      try ensureOpen()
      if markpos < 0 {
        // No mark — reset to start of buffer
        pos = 0
      }
      else {
        if pos >= buf.count {
          if marklimit > buf.count {
            // Grow buffer to accommodate mark look-ahead
            let valid = count - markpos
            let newSize = max(marklimit, valid * 2)
            var newBuf = [UInt8](repeating: 0, count: newSize)
            if valid > 0 {
              newBuf[0..<valid] = buf[markpos..<count]
            }
            buf = newBuf
            pos = valid
            markpos = 0
          }
          else {
            // Mark expired — discard it
            markpos = -1
            pos = 0
          }
        }
      }
      count = pos
      let read = try `in`.read(&buf, pos, buf.count - pos)
      if read > 0 { count = pos + read }
    }

    /// Reads a single byte from the buffer, refilling from the underlying
    /// stream if necessary.
    ///
    /// - Returns: The byte value (0–255), or -1 at end of stream.
    /// - Since: Java 1.0
    public override func read() throws -> Int {
      try ensureOpen()
      if pos >= count { try fill() }
      guard pos < count else { return -1 }
      let byte = Int(buf[pos])
      pos += 1
      return byte
    }

    /// Reads up to `length` bytes into `array` starting at `offset`.
    ///
    /// - Parameters:
    ///   - array: Destination buffer.
    ///   - offset: Start index in `array`.
    ///   - length: Maximum number of bytes to read.
    ///
    /// - Returns: Number of bytes actually read, or -1 at end of stream.
    ///
    /// - Since: Java 1.0
    public override func read(_ array: inout [UInt8], _ offset: Int, _ length: Int) throws -> Int {
      guard offset >= 0, length >= 0, offset + length <= array.count else {
        throw IndexOutOfBoundsException()
      }
      guard length > 0 else { return 0 }

      var bytesRead = 0
      while bytesRead < length {
        if pos >= count {
          try fill()
          if pos >= count { break }  // EOF
        }
        let available = count - pos
        let toCopy = Swift.min(length - bytesRead, available)
        array[offset + bytesRead..<offset + bytesRead + toCopy] = buf[pos..<pos + toCopy]
        pos += toCopy
        bytesRead += toCopy
      }
      return bytesRead == 0 ? -1 : bytesRead
    }

    /// - Returns: Returns an estimate of the number of bytes available without blocking.
    ///
    /// - Since: Java 1.0
    public override func available() throws -> Int {
      let inAvailable = try `in`.available()
      return (count - pos) + inAvailable
    }

    /// Skips up to `n` bytes.
    ///
    /// - Parameter n: Maximum number of bytes to skip.
    /// - Returns: Actual number of bytes skipped.
    /// 
    /// - Since: Java 1.0
    public override func skip(_ n: Int) throws -> Int {
      var remaining = n
      var skipped = 0
      while remaining > 0 {
        if pos >= count {
          try fill()
          if pos >= count { break }  // EOF
        }
        let available = count - pos
        let toSkip = Swift.min(remaining, available)
        pos += toSkip
        skipped += toSkip
        remaining -= toSkip
      }
      return skipped
    }

    // MARK: - Mark / Reset

    /// Returns `true` — `BufferedInputStream` always supports `mark`/`reset`.
    /// - Since: JavaApi (Java 1.0)
    public func markSupported() -> Bool { return true }

    /// Marks the current position in the stream.
    ///
    /// - Parameter readlimit: Maximum bytes that may be read before the mark
    ///   becomes invalid.
    /// - Since: JavaApi (Java 1.0)
    public func mark(_ readlimit: Int) {
      marklimit = readlimit
      markpos = pos
    }

    /// Resets the stream to the last marked position.
    ///
    /// - Throws: `java.io.IOException` if the mark has been invalidated.
    /// - Since: JavaApi (Java 1.0)
    public func reset() throws {
      guard markpos >= 0 else {
        throw java.io.IOException("Resetting to invalid mark")
      }
      pos = markpos
    }

    /// Closes this stream and the underlying `InputStream`.
    /// - Since: JavaApi (Java 1.0)
    public override func close() throws {
      guard !closed else { return }
      closed = true
      try `in`.close()
    }
  }
}
