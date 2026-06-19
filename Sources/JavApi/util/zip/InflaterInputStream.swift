/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util.zip {

  /// An input stream that decompresses data using the INFLATE algorithm.
  ///
  /// Wraps any `java.io.InputStream` that delivers compressed data and
  /// transparently decompresses bytes read from it.
  /// Mirrors `java.util.zip.InflaterInputStream` from Java 1.1.
  ///
  /// ```swift
  /// let src = java.io.ByteArrayInputStream(compressedBytes)
  /// let in  = java.util.zip.InflaterInputStream(src)
  /// var buf = [UInt8](repeating: 0, count: 256)
  /// let n   = try in.read(&buf)
  /// ```
  open class InflaterInputStream : java.io.FilterInputStream, @unchecked Sendable {

    /// The embedded decompressor.
    public let inf : java.util.zip.Inflater

    /// Internal read buffer for compressed input.
    public var buf : [UInt8]

    /// Number of valid bytes currently in `buf`.
    internal var bufLen : Int = 0

    private var closed     : Bool = false
    private var reachEOF   : Bool = false

    // MARK: - Init

    /// Creates a new stream with a custom Inflater and buffer size.
    public init(_ in_: java.io.InputStream, _ inf: java.util.zip.Inflater, _ size: Int) {
      self.inf = inf
      self.buf = [UInt8](repeating: 0, count: size)
      super.init(in_)
    }

    /// Creates a new stream with a custom Inflater and default buffer size (512).
    public init(_ in_: java.io.InputStream, _ inf: java.util.zip.Inflater) {
      self.inf = inf
      self.buf = [UInt8](repeating: 0, count: 512)
      super.init(in_)
    }

    /// Creates a new stream with a default Inflater and default buffer size.
    public init(_ in_: java.io.InputStream) {
      self.inf = java.util.zip.Inflater()
      self.buf = [UInt8](repeating: 0, count: 512)
      super.init(in_)
    }

    // MARK: - Read

    /// Returns 0 once EOF is reached, otherwise 1.
    public override func available() throws -> Int {
      return reachEOF ? 0 : 1
    }

    /// Reads a single decompressed byte, or -1 at end of stream.
    public override func read() throws -> Int {
      var single = [UInt8](repeating: 0, count: 1)
      let n = try read(&single, 0, 1)
      return n == -1 ? -1 : Int(single[0])
    }

    /// Reads decompressed bytes into `array`, returns bytes read or -1 at EOF.
    public override func read(_ array: inout [UInt8]) throws -> Int {
      return try read(&array, 0, array.count)
    }

    /// Reads up to `length` decompressed bytes into `array[offset...]`.
    public override func read(_ array: inout [UInt8], _ offset: Int, _ length: Int) throws -> Int {
      guard !closed else { throw java.io.IOException("Stream closed") }
      guard length > 0 else { return 0 }
      if reachEOF { return -1 }

      var totalRead = 0
      while totalRead < length {
        // If inflater needs more input, fill buffer from underlying stream
        if inf.needsInput() {
          let n = try super.read(&buf, 0, buf.count)
          if n == -1 {
            reachEOF = true
            break
          }
          bufLen = n
          inf.setInput(Array(buf[0..<bufLen]))
        }

        // Decompress into caller's buffer
        let n = try inf.inflate(&array, offset + totalRead, length - totalRead)
        totalRead += n

        if inf.finished() {
          reachEOF = true
          break
        }
      }

      return totalRead == 0 && reachEOF ? -1 : totalRead
    }

    // MARK: - Close

    public override func close() throws {
      if !closed {
        inf.end()
        try super.close()
        closed = true
      }
    }
  }
}
