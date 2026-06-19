/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util.zip {

  /// An input stream that reads data in GZIP format (RFC 1952).
  ///
  /// Extends `InflaterInputStream` with GZIP header parsing and trailer
  /// verification (CRC-32 and uncompressed size check).  Pure Swift.
  /// Mirrors `java.util.zip.GZIPInputStream` from Java 1.1.
  ///
  /// ```swift
  /// let src = java.io.ByteArrayInputStream(gzipBytes)
  /// let gz  = try java.util.zip.GZIPInputStream(src)
  /// var buf = [UInt8](repeating: 0, count: 256)
  /// let n   = try gz.read(&buf)
  /// ```
  open class GZIPInputStream : InflaterInputStream, @unchecked Sendable {

    // MARK: - GZIP constants

    /// GZIP magic number (little-endian: 0x1F 0x8B)
    public static let GZIP_MAGIC : Int = 0x8b1f

    // MARK: - State

    private var crc         : java.util.zip.CRC32 = java.util.zip.CRC32()
    private var totalOut    : Int64 = 0
    private var headerRead  : Bool  = false
    /// Remaining bytes from the underlying stream (for trailer parsing)
    private var trailingBuf : [UInt8] = []

    // MARK: - Init

    /// Creates a new GZIP input stream with a custom buffer size.
    public init(_ in_: java.io.InputStream, _ size: Int) throws {
      super.init(in_, java.util.zip.Inflater(true), size)
      try readGZIPHeader()
      headerRead = true
    }

    /// Creates a new GZIP input stream with the default buffer size (512).
    ///
    /// Swift cannot override a non-throwing `init(_ in_:)` from the superclass
    /// with a throwing initializer of the same signature.  Use
    /// `GZIPInputStream(src, 512)` as the equivalent throwing form.
    @available(*, deprecated, renamed: "init(_:_:)",
               message: "Use GZIPInputStream(stream, 512) — Swift requires explicit buffer size to avoid a signature conflict with the non-throwing superclass initializer.")
    public convenience init(gzip in_: java.io.InputStream) throws {
      try self.init(in_, 512)
    }

    // MARK: - Read (override to track CRC / size)

    public override func read(_ array: inout [UInt8], _ offset: Int, _ length: Int) throws -> Int {
      let n = try super.read(&array, offset, length)
      if n > 0 {
        crc.update(array, offset, n)
        totalOut += Int64(n)
      }
      if inf.finished() {
        try readGZIPTrailer()
      }
      return n
    }

    // MARK: - GZIP Header (RFC 1952 §2.3)

    private func readGZIPHeader() throws {
      // ID1 ID2
      let id1 = try readU8()
      let id2 = try readU8()
      guard id1 == 0x1F && id2 == 0x8B else {
        throw java.util.zip.ZipException("Not a GZIP stream")
      }
      // CM
      let cm = try readU8()
      guard cm == 8 else {
        throw java.util.zip.ZipException("Unsupported GZIP compression method: \(cm)")
      }
      // FLG
      let flg = try readU8()
      // MTIME (4) + XFL (1) + OS (1) — skip 6 bytes
      for _ in 0..<6 { _ = try readU8() }

      // Optional extra field (FEXTRA, bit 2)
      if (flg & 0x04) != 0 {
        let xlen = Int(try readU8()) | (Int(try readU8()) << 8)
        for _ in 0..<xlen { _ = try readU8() }
      }
      // Original filename (FNAME, bit 3) — null-terminated
      if (flg & 0x08) != 0 {
        while try readU8() != 0 {}
      }
      // Comment (FCOMMENT, bit 4) — null-terminated
      if (flg & 0x10) != 0 {
        while try readU8() != 0 {}
      }
      // CRC16 header check (FHCRC, bit 1) — skip 2 bytes
      if (flg & 0x02) != 0 {
        _ = try readU8(); _ = try readU8()
      }
    }

    // MARK: - GZIP Trailer (RFC 1952)

    private func readGZIPTrailer() throws {
      // The GZIP trailer is 8 bytes: CRC32 (4 LE) + ISIZE (4 LE).
      // InflaterInputStream pre-reads the underlying stream in chunks and passes
      // everything to inf.setInput(). The raw DEFLATE ends before the trailer,
      // so the trailer bytes end up as "remaining input" inside the Inflater.
      // We must read them from inf.getRemainingInput(), not from self.`in`.
      var trailerBytes = [UInt8](repeating: 0, count: 8)
      var got = 0

      // First drain remaining bytes from the Inflater's input buffer.
      let remaining = inf.getRemainingInput()
      for b in remaining {
        if got >= 8 { break }
        trailerBytes[got] = b
        got += 1
      }
      // If still short (rare: trailer split across read calls), read from stream.
      while got < 8 {
        let b = try self.`in`.read()
        if b == -1 { break }
        trailerBytes[got] = UInt8(b & 0xFF)
        got += 1
      }
      guard got == 8 else { return }  // truncated — skip verification

      let storedCRC = UInt32(trailerBytes[0])
                    | UInt32(trailerBytes[1]) << 8
                    | UInt32(trailerBytes[2]) << 16
                    | UInt32(trailerBytes[3]) << 24

      let storedISize = UInt32(trailerBytes[4])
                      | UInt32(trailerBytes[5]) << 8
                      | UInt32(trailerBytes[6]) << 16
                      | UInt32(trailerBytes[7]) << 24

      let computedCRC   = UInt32(crc.getValue() & 0xFFFF_FFFF)
      let computedISize = UInt32(totalOut & 0xFFFF_FFFF)

      if storedCRC != computedCRC {
        throw java.util.zip.ZipException("GZIP CRC mismatch: expected \(storedCRC), got \(computedCRC)")
      }
      if storedISize != computedISize {
        throw java.util.zip.ZipException("GZIP size mismatch: expected \(storedISize), got \(computedISize)")
      }
    }

    // MARK: - Helper

    /// Read one byte from the underlying InputStream; throws ZipException on EOF.
    private func readU8() throws -> UInt8 {
      let b = try self.`in`.read()
      guard b != -1 else { throw java.util.zip.ZipException("Unexpected EOF in GZIP stream") }
      return UInt8(b & 0xFF)
    }
  }
}
