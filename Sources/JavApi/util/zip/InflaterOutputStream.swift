/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util.zip {

  /// An output stream that decompresses data on-the-fly using INFLATE.
  ///
  /// Accepts compressed bytes via `write()` and writes the decompressed
  /// result to the underlying stream.
  /// Mirrors `java.util.zip.InflaterOutputStream` from Java 1.6,
  /// but included here as it complements the Phase-3 stream set.
  open class InflaterOutputStream : java.io.FilterOutputStream, @unchecked Sendable {

    /// The embedded decompressor.
    public let inf : java.util.zip.Inflater

    /// Internal decompression output buffer.
    public var buf : [UInt8]

    private var closed   : Bool = false
    private var finished : Bool = false

    // MARK: - Init

    /// Creates a new stream with a custom Inflater and buffer size.
    public init(_ out: java.io.OutputStream, _ inf: java.util.zip.Inflater, _ size: Int) {
      self.inf = inf
      self.buf = [UInt8](repeating: 0, count: size)
      super.init(out)
    }

    /// Creates a new stream with a custom Inflater and default buffer size (512).
    public init(_ out: java.io.OutputStream, _ inf: java.util.zip.Inflater) {
      self.inf = inf
      self.buf = [UInt8](repeating: 0, count: 512)
      super.init(out)
    }

    /// Creates a new stream with a default Inflater and default buffer size.
    public override init(_ out: java.io.OutputStream) {
      self.inf = java.util.zip.Inflater()
      self.buf = [UInt8](repeating: 0, count: 512)
      super.init(out)
    }

    // MARK: - Write

    public override func write(_ b: Int) throws {
      try write([UInt8(b & 0xFF)], 0, 1)
    }

    public override func write(_ b: [UInt8]) throws {
      try write(b, 0, b.count)
    }

    public override func write(_ b: [UInt8], _ off: Int, _ len: Int) throws {
      guard !closed else { throw java.io.IOException("Stream closed") }
      guard len > 0 else { return }

      inf.setInput(b, off, len)
      try inflate()
    }

    // MARK: - Finish / Close

    /// Flushes any remaining decompressed data to the underlying stream.
    open func finish() throws {
      guard !finished else { return }
      // Drain any remaining output even if no more input
      try inflate()
      finished = true
    }

    public override func close() throws {
      if !closed {
        try finish()
        inf.end()
        try out.close()
        closed = true
      }
    }

    // MARK: - Internal

    private func inflate() throws {
      var n : Int
      repeat {
        n = try inf.inflate(&buf, 0, buf.count)
        if n > 0 {
          try out.write(buf, 0, n)
        }
      } while n > 0 && !inf.finished()
    }
  }
}
