/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util.zip {

  /// An output stream that writes data in GZIP format (RFC 1952).
  ///
  /// Extends `DeflaterOutputStream` with a GZIP header and trailer (CRC-32
  /// and uncompressed size).  Pure Swift — no system libraries required.
  /// Mirrors `java.util.zip.GZIPOutputStream` from Java 1.1.
  ///
  /// ```swift
  /// let sink = java.io.ByteArrayOutputStream()
  /// let gz   = java.util.zip.GZIPOutputStream(sink)
  /// try gz.write(Array("Hello".utf8))
  /// try gz.finish()
  /// let gzipBytes = sink.toByteArray()
  /// ```
  open class GZIPOutputStream : DeflaterOutputStream, @unchecked Sendable {

    // MARK: - GZIP constants (RFC 1952)

    /// GZIP magic number
    public static let GZIP_MAGIC : Int = 0x8b1f

    // MARK: - State

    /// Running CRC-32 over the uncompressed data.
    private var crc   : java.util.zip.CRC32 = java.util.zip.CRC32()
    /// Total uncompressed bytes written (mod 2^32).
    private var isize : Int64 = 0

    // MARK: - Init

    /// Creates a new GZIP output stream with a custom buffer size.
    /// - Parameters:
    ///   - out:  Destination stream
    ///   - size: Internal buffer size in bytes
    public init(_ out: java.io.OutputStream, _ size: Int) throws {
      super.init(out, java.util.zip.Deflater(java.util.zip.Deflater.DEFAULT_COMPRESSION, true), size)
      try writeGZIPHeader()
    }

    /// Creates a new GZIP output stream with the default buffer size (512).
    ///
    /// Swift cannot override a non-throwing `init(_ out:)` from the superclass
    /// with a throwing initializer of the same signature.
    /// Use `GZIPOutputStream(out, 512)` as the equivalent throwing form.
    public convenience init(gzip out: java.io.OutputStream) throws {
      try self.init(out, 512)
    }

    // MARK: - Write (override to track CRC / size)

    public override func write(_ b: [UInt8], _ off: Int, _ len: Int) throws {
      try super.write(b, off, len)
      crc.update(b, off, len)
      isize += Int64(len)
    }

    // MARK: - Finish (append GZIP trailer)

    public override func finish() throws {
      try super.finish()
      try writeGZIPTrailer()
    }

    // MARK: - GZIP Header (RFC 1952 §2.3)

    private func writeGZIPHeader() throws {
      // ID1 ID2 CM FLG  MTIME(4)  XFL OS
      let header: [UInt8] = [
        0x1F, 0x8B,   // magic
        0x08,          // CM = deflate
        0x00,          // FLG = no name, no comment, no extra
        0x00, 0x00, 0x00, 0x00,  // MTIME = 0
        0x00,          // XFL = 0
        0xFF           // OS = unknown
      ]
      try out.write(header, 0, header.count)
    }

    // MARK: - GZIP Trailer (RFC 1952 §2.3.1)

    private func writeGZIPTrailer() throws {
      let crcVal  = UInt32(crc.getValue() & 0xFFFF_FFFF)
      let isizeVal = UInt32(isize & 0xFFFF_FFFF)
      // CRC32 little-endian
      try out.write(Int(crcVal         & 0xFF))
      try out.write(Int((crcVal >>  8) & 0xFF))
      try out.write(Int((crcVal >> 16) & 0xFF))
      try out.write(Int((crcVal >> 24) & 0xFF))
      // ISIZE little-endian
      try out.write(Int(isizeVal         & 0xFF))
      try out.write(Int((isizeVal >>  8) & 0xFF))
      try out.write(Int((isizeVal >> 16) & 0xFF))
      try out.write(Int((isizeVal >> 24) & 0xFF))
    }
  }
}
