/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util.zip {

  /// An input stream that compresses data on-the-fly using DEFLATE.
  ///
  /// Reads uncompressed bytes from the underlying stream and delivers
  /// compressed bytes to the caller.
  /// Mirrors `java.util.zip.DeflaterInputStream` from Java 1.6,
  /// but included here as it complements the Phase-3 stream set.
  open class DeflaterInputStream : java.io.FilterInputStream, @unchecked Sendable {

    /// The embedded compressor.
    public let def : java.util.zip.Deflater

    /// Internal read buffer for uncompressed input.
    public var buf : [UInt8]

    /// Compressed output buffer waiting to be returned to caller.
    private var outBuf      : [UInt8] = []
    private var outOff      : Int     = 0
    private var closed      : Bool    = false
    private var reachEOF    : Bool    = false
    /// Accumulated uncompressed input — compression is deferred until the
    /// underlying stream reaches EOF (same one-shot design as Deflater).
    private var pendingIn   : [UInt8] = []
    private var compressed  : Bool    = false  // true once compress() was run

    // MARK: - Init

    /// Creates a new stream with a custom Deflater and buffer size.
    public init(_ in_: java.io.InputStream, _ def: java.util.zip.Deflater, _ size: Int) {
      self.def = def
      self.buf = [UInt8](repeating: 0, count: size)
      super.init(in_)
    }

    /// Creates a new stream with a custom Deflater and default buffer size (512).
    public init(_ in_: java.io.InputStream, _ def: java.util.zip.Deflater) {
      self.def = def
      self.buf = [UInt8](repeating: 0, count: 512)
      super.init(in_)
    }

    /// Creates a new stream with a default Deflater and default buffer size.
    public init(_ in_: java.io.InputStream) {
      self.def = java.util.zip.Deflater()
      self.buf = [UInt8](repeating: 0, count: 512)
      super.init(in_)
    }

    // MARK: - Read

    public override func available() throws -> Int {
      return reachEOF ? 0 : 1
    }

    public override func read() throws -> Int {
      var single = [UInt8](repeating: 0, count: 1)
      let n = try read(&single, 0, 1)
      return n == -1 ? -1 : Int(single[0])
    }

    public override func read(_ array: inout [UInt8]) throws -> Int {
      return try read(&array, 0, array.count)
    }

    public override func read(_ array: inout [UInt8], _ offset: Int, _ length: Int) throws -> Int {
      guard !closed else { throw java.io.IOException("Stream closed") }
      guard length > 0 else { return 0 }

      // Drain already-compressed output
      if outOff < outBuf.count {
        let toWrite = Swift.min(length, outBuf.count - outOff)
        array.replaceSubrange(offset..<(offset + toWrite),
                              with: outBuf[outOff..<(outOff + toWrite)])
        outOff += toWrite
        return toWrite
      }

      if reachEOF { return -1 }

      // Not yet compressed: accumulate all underlying input first
      if !compressed {
        while true {
          let n = try super.read(&buf, 0, buf.count)
          if n == -1 { break }  // EOF per Java spec
          pendingIn.append(contentsOf: buf[0..<n])
        }
        // Now compress the complete input in one shot
        def.setInput(pendingIn, 0, pendingIn.count)
        def.finish()
        var tmp = [UInt8](repeating: 0, count: Swift.max(pendingIn.count + 256, 256))
        var allCompressed: [UInt8] = []
        while true {
          let deflateN = def.deflate(&tmp, 0, tmp.count)
          if deflateN > 0 { allCompressed.append(contentsOf: tmp[0..<deflateN]) }
          if def.finished() || deflateN == 0 { break }
        }
        outBuf = allCompressed
        outOff = 0
        compressed = true
        reachEOF = true
      }

      if outOff >= outBuf.count { return -1 }

      let toWrite = Swift.min(length, outBuf.count - outOff)
      array.replaceSubrange(offset..<(offset + toWrite),
                            with: outBuf[outOff..<(outOff + toWrite)])
      outOff += toWrite
      return toWrite
    }

    // MARK: - Close

    public override func close() throws {
      if !closed {
        def.end()
        try super.close()
        closed = true
      }
    }
  }
}
