/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util.zip {

  /// An output stream that compresses data using the DEFLATE algorithm.
  ///
  /// Wraps any `java.io.OutputStream` and transparently compresses bytes
  /// written to it.  Mirrors `java.util.zip.DeflaterOutputStream` from Java 1.1.
  ///
  /// ```swift
  /// let sink = java.io.ByteArrayOutputStream()
  /// let out  = java.util.zip.DeflaterOutputStream(sink)
  /// try out.write(Array("Hello".utf8))
  /// try out.finish()
  /// try out.close()
  /// let compressed = sink.toByteArray()
  /// ```
  open class DeflaterOutputStream : java.io.FilterOutputStream, @unchecked Sendable {

    /// The embedded compressor.
    public let def : java.util.zip.Deflater

    /// Internal write buffer (default 512 bytes, matching Java's default).
    public var buf : [UInt8]

    private var closed      : Bool    = false
    private var finished    : Bool    = false
    /// Accumulated uncompressed input — flushed when finish() is called.
    private var pendingInput : [UInt8] = []

    // MARK: - Init

    /// Creates a new stream with a custom Deflater and buffer size.
    /// - Parameters:
    ///   - out: Destination stream
    ///   - def: Deflater to use
    ///   - size: Internal buffer size in bytes
    public init(_ out: java.io.OutputStream, _ def: java.util.zip.Deflater, _ size: Int) {
      self.def = def
      self.buf = [UInt8](repeating: 0, count: size)
      super.init(out)
    }

    /// Creates a new stream with a custom Deflater and default buffer size (512).
    /// - Parameters:
    ///   - out: Destination stream
    ///   - def: Deflater to use
    public init(_ out: java.io.OutputStream, _ def: java.util.zip.Deflater) {
      self.def = def
      self.buf = [UInt8](repeating: 0, count: 512)
      super.init(out)
    }

    /// Creates a new stream with a default Deflater and default buffer size.
    /// - Parameter out: Destination stream
    public override init(_ out: java.io.OutputStream) {
      self.def = java.util.zip.Deflater()
      self.buf = [UInt8](repeating: 0, count: 512)
      super.init(out)
    }

    // MARK: - Write

    /// Writes a single byte to the compressed stream.
    public override func write(_ b: Int) throws {
      try write([UInt8(b & 0xFF)], 0, 1)
    }

    /// Writes all bytes of `b` to the compressed stream.
    public override func write(_ b: [UInt8]) throws {
      try write(b, 0, b.count)
    }

    /// Writes `len` bytes from `b` starting at `off` to the compressed stream.
    public override func write(_ b: [UInt8], _ off: Int, _ len: Int) throws {
      guard !closed else { throw java.io.IOException("Stream closed") }
      guard len > 0 else { return }
      // Accumulate input; compression happens on finish() so the Deflater
      // can see the full input and produce a single well-formed DEFLATE stream.
      pendingInput.append(contentsOf: b[off..<(off + len)])
    }

    // MARK: - Finish / Close

    /// Finishes writing compressed data without closing the underlying stream.
    /// Must be called before `close()` if data is to be fully flushed.
    open func finish() throws {
      guard !finished else { return }
      // Feed all accumulated input to the Deflater at once, then drain.
      if !pendingInput.isEmpty {
        def.setInput(pendingInput, 0, pendingInput.count)
        pendingInput = []
      }
      def.finish()
      while true {
        let n = try deflate()
        if def.finished() || n == 0 { break }
      }
      finished = true
    }

    /// Finishes and closes the stream.
    public override func close() throws {
      if !closed {
        try finish()
        try out.close()
        closed = true
      }
    }

    // MARK: - Internal

    /// Drains available compressed output into the underlying stream.
    /// Returns total bytes written to the underlying stream.
    @discardableResult
    private func deflate() throws -> Int {
      var total = 0
      var n : Int
      repeat {
        n = def.deflate(&buf, 0, buf.count)
        if n > 0 {
          try out.write(buf, 0, n)
          total += n
        }
      } while n == buf.count  // keep draining while buffer was full
      return total
    }
  }
}
