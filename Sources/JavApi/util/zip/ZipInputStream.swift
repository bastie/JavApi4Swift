/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util.zip {

  /// Reads ZIP archive entries from an input stream.
  ///
  /// Call `getNextEntry()` to advance to the next entry, then `read()` to
  /// obtain its uncompressed data.  Mirrors `java.util.zip.ZipInputStream`
  /// from Java 1.1. Pure Swift — no system libraries.
  ///
  /// ```swift
  /// let src = java.io.ByteArrayInputStream(zipBytes)
  /// let zis = java.util.zip.ZipInputStream(src)
  /// while let entry = try zis.getNextEntry() {
  ///   var buf = [UInt8](repeating: 0, count: 4096)
  ///   var data: [UInt8] = []
  ///   var n = try zis.read(&buf, 0, buf.count)
  ///   while n != -1 { data.append(contentsOf: buf[0..<n]); n = try zis.read(&buf, 0, buf.count) }
  ///   try zis.closeEntry()
  /// }
  /// try zis.close()
  /// ```
  open class ZipInputStream : java.io.FilterInputStream, @unchecked Sendable {

    // MARK: - State

    /// The entry currently being read, or nil.
    private var currentEntry : java.util.zip.ZipEntry? = nil
    /// Inflater for DEFLATED entries.
    private var inf           : java.util.zip.Inflater = java.util.zip.Inflater(true)
    /// Internal read buffer (for reading from underlying stream).
    private var buf           : [UInt8] = [UInt8](repeating: 0, count: 512)
    /// Remaining *compressed* bytes for the current entry (-1 if unknown / uses Data Descriptor).
    private var remaining     : Int64   = 0
    /// Running CRC-32 for the current entry.
    private var crc           : java.util.zip.CRC32 = java.util.zip.CRC32()
    private var closed        : Bool    = false
    private var entryEOF      : Bool    = false
    /// Decompressed output buffer for DEFLATED entries.
    private var outBuf        : [UInt8] = []
    private var outOff        : Int     = 0
    /// Accumulated compressed bytes for current DEFLATED entry (one-shot inflate).
    private var compressedBuf : [UInt8] = []
    private var inflated      : Bool    = false

    // MARK: - Init

    public init(_ in_: java.io.InputStream) {
      super.init(in_)
    }

    // MARK: - Public API

    /// Reads the Local File Header and returns the next `ZipEntry`, or `nil` at end of archive.
    public func getNextEntry() throws -> java.util.zip.ZipEntry? {
      guard !closed else { throw java.io.IOException("Stream closed") }
      // Close any previous entry
      if currentEntry != nil { try closeEntry() }

      // Read Local File Header signature
      let sig = try readLeInt32()
      // Accept ENDSIG or CENSIG as "no more local entries"
      if sig == Int(java.util.zip.ZipConstants.ENDSIG & 0xFFFF_FFFF) { return nil }
      if sig == Int(java.util.zip.ZipConstants.CENSIG & 0xFFFF_FFFF) { return nil }
      guard sig == Int(java.util.zip.ZipConstants.LOCSIG & 0xFFFF_FFFF) else {
        throw java.util.zip.ZipException("Bad LOC header signature: 0x\(String(sig, radix:16))")
      }

      // version needed (2), flags (2), method (2), mod time (2), mod date (2) = 10 bytes
      let version  = try readLeUInt16()
      let flags    = try readLeUInt16()
      let method   = try readLeUInt16()
      let modTime  = try readLeUInt16()
      let modDate  = try readLeUInt16()
      let crcStored     = try readLeUInt32()
      let compSizeStored = try readLeUInt32()
      let uncompSize    = try readLeUInt32()
      let nameLen  = try readLeUInt16()
      let extraLen = try readLeUInt16()

      // Name
      var nameBytes = [UInt8](repeating: 0, count: nameLen)
      _ = try readFully(&nameBytes)
      let name = String(bytes: nameBytes, encoding: .utf8)
             ?? String(bytes: nameBytes, encoding: .isoLatin1)
             ?? ""

      // Extra field
      var extra: [UInt8]? = nil
      if extraLen > 0 {
        var extraBytes = [UInt8](repeating: 0, count: extraLen)
        _ = try readFully(&extraBytes)
        extra = extraBytes
      }

      // Build entry
      let entry = java.util.zip.ZipEntry(name)
      entry.version = version
      entry.flag    = flags

      // DOS time → ms since epoch
      let dosTime = (Int64(modDate) << 16) | Int64(modTime)
      entry.setTime(dosToJavaTime(dosTime))

      entry.setMethod(method)

      let useDataDescriptor = (flags & 0x08) != 0
      if !useDataDescriptor {
        entry.setCrc(Int64(bitPattern: UInt64(crcStored)))
        entry.setCompressedSize(Int64(bitPattern: UInt64(compSizeStored)))
        entry.setSize(Int64(bitPattern: UInt64(uncompSize)))
      }

      // Reset state
      crc.reset()
      inf.reset()
      outBuf = []
      outOff = 0
      compressedBuf = []
      inflated = false
      entryEOF = false
      ddExtra = []
      ddExtraOff = 0
      remaining = useDataDescriptor ? Int64.max : Int64(bitPattern: UInt64(compSizeStored))

      currentEntry = entry
      return entry
    }

    /// Skips to the end of the current entry without reading its data.
    public func closeEntry() throws {
      guard let _ = currentEntry else { return }
      // Drain remaining data
      var tmp = [UInt8](repeating: 0, count: 512)
      while true {
        let n = try read(&tmp, 0, tmp.count)
        if n == -1 { break }
      }
      currentEntry = nil
    }

    // MARK: - Read

    public override func read() throws -> Int {
      var b = [UInt8](repeating: 0, count: 1)
      let n = try read(&b, 0, 1)
      return n == -1 ? -1 : Int(b[0])
    }

    public override func read(_ array: inout [UInt8]) throws -> Int {
      return try read(&array, 0, array.count)
    }

    public override func read(_ array: inout [UInt8], _ offset: Int, _ length: Int) throws -> Int {
      guard !closed else { throw java.io.IOException("Stream closed") }
      guard currentEntry != nil else { return -1 }
      guard length > 0 else { return 0 }
      if entryEOF { return -1 }

      let method = currentEntry!.getMethod()

      if method == java.util.zip.ZipEntry.STORED {
        return try readStored(&array, offset, length)
      } else {
        return try readDeflated(&array, offset, length)
      }
    }

    public override func available() throws -> Int {
      return entryEOF ? 0 : 1
    }

    public override func close() throws {
      if !closed {
        try super.close()
        closed = true
      }
    }

    // MARK: - STORED read

    private func readStored(_ array: inout [UInt8], _ offset: Int, _ length: Int) throws -> Int {
      if remaining <= 0 {
        entryEOF = true
        return -1
      }
      let toRead = Int(Swift.min(Int64(length), remaining))
      let n = try self.`in`.read(&array, offset, toRead)
      if n == -1 {
        entryEOF = true
        return -1
      }
      crc.update(array, offset, n)
      remaining -= Int64(n)
      if remaining <= 0 {
        try verifyAndFinishEntry()
        entryEOF = true
      }
      return n
    }

    // MARK: - DEFLATED read

    private func readDeflated(_ array: inout [UInt8], _ offset: Int, _ length: Int) throws -> Int {
      // One-shot inflate: accumulate all compressed bytes first, then inflate once.
      if !inflated {
        if remaining == Int64.max {
          // Data Descriptor (flag bit 3): compressed size unknown.
          // Read byte-by-byte until Inflater signals it is done, then verify trailer.
          try readAllCompressedUnknownSize()
        } else {
          // Known compressed size: read exactly that many bytes.
          while remaining > 0 {
            let toFeed = Int(Swift.min(Int64(buf.count), remaining))
            let n = try self.`in`.read(&buf, 0, toFeed)
            if n == -1 { break }
            compressedBuf.append(contentsOf: buf[0..<n])
            remaining -= Int64(n)
          }
        }
        // Inflate all at once.
        // Use known uncompressed size if available, otherwise estimate generously.
        let knownSize = currentEntry?.getSize() ?? -1
        let bufSize   = knownSize > 0 ? Int(knownSize) + 16
                                      : Swift.max(compressedBuf.count * 8 + 256, 65536)
        inf.setInput(compressedBuf)
        var tmp = [UInt8](repeating: 0, count: bufSize)
        let n = try inf.inflate(&tmp, 0, tmp.count)
        outBuf = Array(tmp[0..<n])
        outOff = 0
        inflated = true
      }

      // Drain outBuf
      if outOff >= outBuf.count {
        if !entryEOF {
          try verifyAndFinishEntry()
          entryEOF = true
        }
        return -1
      }

      let toGive = Swift.min(Swift.min(length, array.count - offset), outBuf.count - outOff)
      guard toGive > 0 else { return 0 }
      crc.update(outBuf, outOff, toGive)
      array.replaceSubrange(offset..<(offset + toGive),
                            with: outBuf[outOff..<(outOff + toGive)])
      outOff += toGive
      if outOff >= outBuf.count {
        try verifyAndFinishEntry()
        entryEOF = true
      }
      return toGive
    }

    // MARK: - Data Descriptor: read compressed bytes of unknown length

    /// For entries with flag bit 3 (Data Descriptor), the compressed size is not
    /// known up front. We read the stream byte-by-byte growing `compressedBuf` and
    /// try to inflate after each new chunk, stopping as soon as the Inflater reports
    /// it is finished (all DEFLATE blocks decoded). This is the only correct approach
    /// given our one-shot Inflater design.
    private func readAllCompressedUnknownSize() throws {
      // Read one byte at a time, appending to compressedBuf.
      // After each byte, try to inflate into a scratch buffer to detect stream end.
      // For performance, read in small chunks and retry inflate at each chunk boundary.
      let chunkSize = 64
      var scratch = [UInt8](repeating: 0, count: 65536)
      while true {
        // Read one chunk
        var chunk = [UInt8](repeating: 0, count: chunkSize)
        let n = try self.`in`.read(&chunk, 0, chunkSize)
        if n == -1 { break }
        compressedBuf.append(contentsOf: chunk[0..<n])

        // Try inflating the accumulated buffer
        let testInf = java.util.zip.Inflater(true)
        testInf.setInput(compressedBuf)
        do {
          _ = try testInf.inflate(&scratch, 0, scratch.count)
          if testInf.finished() {
            // Inflater consumed exactly `testInf.getBytesRead()` bytes from compressedBuf.
            // The remaining bytes in compressedBuf belong to the Data Descriptor.
            let consumed = Int(testInf.getBytesRead())
            // Bytes after the compressed data belong to the Data Descriptor.
            // Buffer them so verifyAndFinishEntry() can read them via readU8().
            ddExtra = Array(compressedBuf[consumed...])
            compressedBuf = Array(compressedBuf[0..<consumed])
            return
          }
        } catch {
          // Not yet a valid complete stream — keep reading
        }
      }
    }

    /// Bytes already read past the compressed data (Data Descriptor bytes).
    private var ddExtra: [UInt8] = []
    private var ddExtraOff: Int = 0

    // MARK: - Entry finish / Data Descriptor

    private func verifyAndFinishEntry() throws {
      guard let entry = currentEntry else { return }
      let computedCRC = crc.getValue()

      // Read Data Descriptor if flag bit 3 set
      if (entry.flag & 0x08) != 0 {
        // optional signature 0x08074b50
        let first = try readLeUInt32()
        let crcStored: UInt32
        let compSize: UInt32
        let uncompSize: UInt32
        if first == UInt32(java.util.zip.ZipConstants.EXTSIG & 0xFFFF_FFFF) {
          crcStored  = try readLeUInt32()
          compSize   = try readLeUInt32()
          uncompSize = try readLeUInt32()
        } else {
          crcStored  = first
          compSize   = try readLeUInt32()
          uncompSize = try readLeUInt32()
        }
        entry.setCrc(Int64(bitPattern: UInt64(crcStored)))
        entry.setCompressedSize(Int64(bitPattern: UInt64(compSize)))
        entry.setSize(Int64(bitPattern: UInt64(uncompSize)))
      }

      // CRC check
      let storedCRC = UInt32(entry.getCrc() & 0xFFFF_FFFF)
      let gotCRC    = UInt32(computedCRC & 0xFFFF_FFFF)
      if storedCRC != 0 && storedCRC != gotCRC {
        throw java.util.zip.ZipException(
          "CRC-32 mismatch for \(entry.getName()): expected \(storedCRC), got \(gotCRC)")
      }
    }

    // MARK: - Low-level read helpers

    /// Reads exactly `buf.count` bytes; throws on EOF.
    @discardableResult
    private func readFully(_ bytes: inout [UInt8]) throws -> Int {
      var off = 0
      while off < bytes.count {
        let n = try self.`in`.read(&bytes, off, bytes.count - off)
        if n == -1 { throw java.util.zip.ZipException("Unexpected EOF") }
        off += n
      }
      return off
    }

    /// Reads a little-endian UInt16 (2 bytes).
    private func readLeUInt16() throws -> Int {
      let b0 = try readU8()
      let b1 = try readU8()
      return Int(b0) | (Int(b1) << 8)
    }

    /// Reads a little-endian Int32 (4 bytes) — returns Int for signature comparison.
    private func readLeInt32() throws -> Int {
      let b0 = try readU8()
      let b1 = try readU8()
      let b2 = try readU8()
      let b3 = try readU8()
      return Int(b0) | (Int(b1) << 8) | (Int(b2) << 16) | (Int(b3) << 24)
    }

    /// Reads a little-endian UInt32 (4 bytes).
    private func readLeUInt32() throws -> UInt32 {
      let b0 = try readU8()
      let b1 = try readU8()
      let b2 = try readU8()
      let b3 = try readU8()
      return UInt32(b0) | (UInt32(b1) << 8) | (UInt32(b2) << 16) | (UInt32(b3) << 24)
    }

    private func readU8() throws -> UInt8 {
      // For Data Descriptor entries, bytes past the compressed data are buffered in ddExtra.
      if ddExtraOff < ddExtra.count {
        let b = ddExtra[ddExtraOff]
        ddExtraOff += 1
        return b
      }
      let b = try self.`in`.read()
      guard b != -1 else { throw java.util.zip.ZipException("Unexpected EOF") }
      return UInt8(b & 0xFF)
    }

    // MARK: - DOS time conversion

    /// Converts a DOS date/time (packed Int64) to milliseconds since Java epoch.
    private func dosToJavaTime(_ dosTime: Int64) -> Int64 {
      let sec   = Int( dosTime        & 0x1F) * 2
      let min_  = Int((dosTime >>  5) & 0x3F)
      let hour  = Int((dosTime >> 11) & 0x1F)
      let day   = Int((dosTime >> 16) & 0x1F)
      let month = Int((dosTime >> 21) & 0x0F)   // 1-based
      let year  = Int((dosTime >> 25) & 0x7F) + 1980

      // Rough ms-since-epoch (no DST, UTC)
      let days  = Int64(daysFromEpoch(year: year, month: month, day: day))
      let ms    = Int64(hour * 3600 + min_ * 60 + sec) * 1000
      return days * 86400_000 + ms
    }

    private func daysFromEpoch(year: Int, month: Int, day: Int) -> Int {
      // Days since 1970-01-01, Gregorian (Zeller-like)
      var y = year
      var m = month
      if m < 3 { y -= 1; m += 12 }
      let a = y / 100
      let b = 2 - a + a / 4
      return Int(365.25 * Double(y + 4716)) + Int(30.6001 * Double(m + 1)) + day + b - 1524 - 719163
    }
  }
}
