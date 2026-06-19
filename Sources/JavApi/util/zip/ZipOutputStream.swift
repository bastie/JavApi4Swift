/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util.zip {

  /// Writes entries into a ZIP archive.
  ///
  /// Call `putNextEntry(_:)`, write the entry's uncompressed data, then
  /// `closeEntry()`. Call `finish()` or `close()` to flush the Central
  /// Directory and End-of-Central-Directory record.
  /// Mirrors `java.util.zip.ZipOutputStream` from Java 1.1. Pure Swift.
  ///
  /// ```swift
  /// let sink = java.io.ByteArrayOutputStream()
  /// let zos  = java.util.zip.ZipOutputStream(sink)
  /// let entry = java.util.zip.ZipEntry("hello.txt")
  /// try zos.putNextEntry(entry)
  /// try zos.write(Array("Hello!".utf8))
  /// try zos.closeEntry()
  /// try zos.finish()
  /// let zipBytes = sink.toByteArray()
  /// ```
  open class ZipOutputStream : java.io.FilterOutputStream, @unchecked Sendable {

    // MARK: - Constants

    public static let STORED   : Int = java.util.zip.ZipConstants.STORED
    public static let DEFLATED : Int = java.util.zip.ZipConstants.DEFLATED

    // MARK: - State

    /// Default compression method for new entries.
    public var method : Int = java.util.zip.ZipConstants.DEFLATED
    /// Default compression level.
    public var level  : Int = java.util.zip.Deflater.DEFAULT_COMPRESSION

    private var currentEntry    : java.util.zip.ZipEntry? = nil
    private var crc             : java.util.zip.CRC32     = java.util.zip.CRC32()
    private var written         : Int64  = 0   // bytes written to underlying stream
    private var entryDataBuf    : [UInt8] = [] // accumulated uncompressed data for current entry
    private var centralDir      : [UInt8] = [] // central directory records
    private var entriesWritten  : Int     = 0
    private var closed          : Bool    = false
    private var finished        : Bool    = false

    // MARK: - Init

    public override init(_ out: java.io.OutputStream) {
      super.init(out)
    }

    // MARK: - Entry API

    /// Begins a new entry. Closes any currently open entry first.
    public func putNextEntry(_ entry: java.util.zip.ZipEntry) throws {
      guard !closed else { throw java.io.IOException("Stream closed") }
      if currentEntry != nil { try closeEntry() }

      // Apply defaults
      if entry.getMethod() == -1 { entry.setMethod(method) }

      currentEntry = entry
      crc.reset()
      entryDataBuf = []
    }

    /// Writes data for the current entry.
    public override func write(_ b: [UInt8], _ off: Int, _ len: Int) throws {
      guard !closed else { throw java.io.IOException("Stream closed") }
      guard currentEntry != nil else { throw java.io.IOException("No current entry") }
      guard len > 0 else { return }
      entryDataBuf.append(contentsOf: b[off..<(off + len)])
    }

    public override func write(_ b: Int) throws {
      try write([UInt8(b & 0xFF)], 0, 1)
    }

    public override func write(_ b: [UInt8]) throws {
      try write(b, 0, b.count)
    }

    /// Finishes the current entry and writes its data to the archive.
    public func closeEntry() throws {
      guard let entry = currentEntry else { return }

      let rawData    = entryDataBuf
      let uncompSize = Int64(rawData.count)

      crc.reset()
      crc.update(rawData, 0, rawData.count)
      let crcVal = UInt32(crc.getValue() & 0xFFFF_FFFF)

      let compData: [UInt8]
      let compSize: Int64

      if entry.getMethod() == java.util.zip.ZipConstants.STORED {
        compData = rawData
        compSize = uncompSize
        entry.setCrc(Int64(bitPattern: UInt64(crcVal)))
        entry.setSize(uncompSize)
        entry.setCompressedSize(uncompSize)
      } else {
        // DEFLATE (raw, no zlib wrapper)
        let def = java.util.zip.Deflater(level, true)
        def.setInput(rawData, 0, rawData.count)
        def.finish()
        var tmp = [UInt8](repeating: 0, count: rawData.count + 256)
        var deflated: [UInt8] = []
        while true {
          let n = def.deflate(&tmp, 0, tmp.count)
          if n > 0 { deflated.append(contentsOf: tmp[0..<n]) }
          if def.finished() || n == 0 { break }
        }
        compData = deflated
        compSize = Int64(deflated.count)
        entry.setCrc(Int64(bitPattern: UInt64(crcVal)))
        entry.setSize(uncompSize)
        entry.setCompressedSize(compSize)
      }

      // Record offset before writing LOC
      let locOffset = written

      // Write Local File Header
      try writeLOC(entry, compSize: UInt32(compSize), uncompSize: UInt32(uncompSize), crcVal: crcVal)

      // Write compressed (or stored) data
      if !compData.isEmpty {
        try out.write(compData, 0, compData.count)
        written += Int64(compData.count)
      }

      // Append Central Directory record
      centralDir.append(contentsOf: buildCEN(entry,
                                              locOffset: UInt32(locOffset & 0xFFFF_FFFF),
                                              compSize: UInt32(compSize),
                                              uncompSize: UInt32(uncompSize),
                                              crcVal: crcVal))
      entriesWritten += 1
      entry.offset = locOffset
      currentEntry = nil
      entryDataBuf = []
    }

    // MARK: - Finish / Close

    /// Writes the Central Directory and EOCD; does not close the underlying stream.
    open func finish() throws {
      guard !finished else { return }
      if currentEntry != nil { try closeEntry() }

      let cdOffset = written
      // Write Central Directory
      try out.write(centralDir, 0, centralDir.count)
      written += Int64(centralDir.count)

      // Write End of Central Directory record
      try writeEOCD(cdOffset: UInt32(cdOffset & 0xFFFF_FFFF),
                    cdSize:   UInt32(centralDir.count),
                    count:    UInt16(entriesWritten & 0xFFFF))
      finished = true
    }

    public override func close() throws {
      if !closed {
        try finish()
        try out.close()
        closed = true
      }
    }

    // MARK: - LOC builder

    private func writeLOC(_ entry: java.util.zip.ZipEntry,
                          compSize: UInt32, uncompSize: UInt32, crcVal: UInt32) throws {
      let nameBytes = Array(entry.getName().utf8)
      let extraBytes = entry.getExtra() ?? []
      let method = entry.getMethod() == -1 ? java.util.zip.ZipConstants.STORED : entry.getMethod()
      let dosTime = javaToDosTime(entry.getTime())

      var loc = [UInt8]()
      loc.reserveCapacity(java.util.zip.ZipConstants.LOCHDR + nameBytes.count + extraBytes.count)

      appendLeUInt32(&loc, UInt32(java.util.zip.ZipConstants.LOCSIG & 0xFFFF_FFFF))  // signature
      appendLeUInt16(&loc, UInt16(entry.version == 0 ? 20 : entry.version))           // version needed
      appendLeUInt16(&loc, UInt16(entry.flag & 0xFFFF))                               // flags
      appendLeUInt16(&loc, UInt16(method & 0xFFFF))                                   // method
      appendLeUInt32(&loc, UInt32(dosTime & 0xFFFF_FFFF))                             // mod time+date
      appendLeUInt32(&loc, crcVal)                                                    // CRC-32
      appendLeUInt32(&loc, compSize)                                                  // compressed size
      appendLeUInt32(&loc, uncompSize)                                                // uncompressed size
      appendLeUInt16(&loc, UInt16(nameBytes.count & 0xFFFF))                         // name length
      appendLeUInt16(&loc, UInt16(extraBytes.count & 0xFFFF))                        // extra length
      loc.append(contentsOf: nameBytes)
      loc.append(contentsOf: extraBytes)

      try out.write(loc, 0, loc.count)
      written += Int64(loc.count)
    }

    // MARK: - CEN builder

    private func buildCEN(_ entry: java.util.zip.ZipEntry,
                          locOffset: UInt32,
                          compSize: UInt32, uncompSize: UInt32, crcVal: UInt32) -> [UInt8] {
      let nameBytes  = Array(entry.getName().utf8)
      let extraBytes = entry.getExtra() ?? []
      let comment    = Array((entry.getComment() ?? "").utf8)
      let method     = entry.getMethod() == -1 ? java.util.zip.ZipConstants.STORED : entry.getMethod()
      let dosTime    = javaToDosTime(entry.getTime())

      var cen = [UInt8]()
      cen.reserveCapacity(java.util.zip.ZipConstants.CENHDR
                          + nameBytes.count + extraBytes.count + comment.count)

      appendLeUInt32(&cen, UInt32(java.util.zip.ZipConstants.CENSIG & 0xFFFF_FFFF))
      appendLeUInt16(&cen, UInt16(20))                                                  // version made by
      appendLeUInt16(&cen, UInt16(entry.version == 0 ? 20 : entry.version))            // version needed
      appendLeUInt16(&cen, UInt16(entry.flag & 0xFFFF))                                // flags
      appendLeUInt16(&cen, UInt16(method & 0xFFFF))                                    // method
      appendLeUInt32(&cen, UInt32(dosTime & 0xFFFF_FFFF))                              // mod time+date
      appendLeUInt32(&cen, crcVal)                                                     // CRC-32
      appendLeUInt32(&cen, compSize)                                                   // compressed size
      appendLeUInt32(&cen, uncompSize)                                                 // uncompressed size
      appendLeUInt16(&cen, UInt16(nameBytes.count & 0xFFFF))                          // name length
      appendLeUInt16(&cen, UInt16(extraBytes.count & 0xFFFF))                         // extra length
      appendLeUInt16(&cen, UInt16(comment.count & 0xFFFF))                            // comment length
      appendLeUInt16(&cen, 0)                                                          // disk number start
      appendLeUInt16(&cen, 0)                                                          // internal attrs
      appendLeUInt32(&cen, 0)                                                          // external attrs
      appendLeUInt32(&cen, locOffset)                                                  // LOC offset
      cen.append(contentsOf: nameBytes)
      cen.append(contentsOf: extraBytes)
      cen.append(contentsOf: comment)
      return cen
    }

    // MARK: - EOCD builder

    private func writeEOCD(cdOffset: UInt32, cdSize: UInt32, count: UInt16) throws {
      var eocd = [UInt8]()
      eocd.reserveCapacity(java.util.zip.ZipConstants.ENDHDR)
      appendLeUInt32(&eocd, UInt32(java.util.zip.ZipConstants.ENDSIG & 0xFFFF_FFFF))
      appendLeUInt16(&eocd, 0)          // disk number
      appendLeUInt16(&eocd, 0)          // disk with CD start
      appendLeUInt16(&eocd, count)      // entries on this disk
      appendLeUInt16(&eocd, count)      // total entries
      appendLeUInt32(&eocd, cdSize)     // size of central directory
      appendLeUInt32(&eocd, cdOffset)   // offset of CD
      appendLeUInt16(&eocd, 0)          // comment length
      try out.write(eocd, 0, eocd.count)
      written += Int64(eocd.count)
    }

    // MARK: - Little-endian helpers

    private func appendLeUInt16(_ buf: inout [UInt8], _ v: UInt16) {
      buf.append(UInt8(v & 0xFF))
      buf.append(UInt8((v >> 8) & 0xFF))
    }

    private func appendLeUInt32(_ buf: inout [UInt8], _ v: UInt32) {
      buf.append(UInt8(v & 0xFF))
      buf.append(UInt8((v >>  8) & 0xFF))
      buf.append(UInt8((v >> 16) & 0xFF))
      buf.append(UInt8((v >> 24) & 0xFF))
    }

    // MARK: - DOS time conversion

    /// Converts Java epoch ms to a packed DOS date/time Int64.
    private func javaToDosTime(_ javaTime: Int64) -> Int64 {
      guard javaTime >= 0 else { return dosTimeFromComponents(1980, 1, 1, 0, 0, 0) }
      let totalSec = javaTime / 1000
      let sec   = Int(totalSec % 60)
      let min_  = Int((totalSec / 60) % 60)
      let hour  = Int((totalSec / 3600) % 24)
      let days  = Int(totalSec / 86400)   // days since 1970-01-01
      let (y, m, d) = gregorianFromDays(days + 719163)  // + days from 0000-01-01 to 1970-01-01
      let year  = Swift.max(1980, y)
      return dosTimeFromComponents(year, m, d, hour, min_, sec)
    }

    private func dosTimeFromComponents(_ year: Int, _ month: Int, _ day: Int,
                                       _ hour: Int, _ min_: Int, _ sec: Int) -> Int64 {
      let time = Int64(sec / 2) | (Int64(min_) << 5) | (Int64(hour) << 11)
      let date = Int64(day) | (Int64(month) << 5) | (Int64(year - 1980) << 9)
      return (date << 16) | time
    }

    private func gregorianFromDays(_ z: Int) -> (Int, Int, Int) {
      // Algorithm from http://howardhinnant.github.io/date_algorithms.html
      let z2  = z + 719468
      let era = (z2 >= 0 ? z2 : z2 - 146096) / 146097
      let doe = z2 - era * 146097
      let yoe = (doe - doe/1460 + doe/36524 - doe/146096) / 365
      let y   = yoe + era * 400
      let doy = doe - (365*yoe + yoe/4 - yoe/100)
      let mp  = (5*doy + 2) / 153
      let d   = doy - (153*mp + 2)/5 + 1
      let m   = mp < 10 ? mp + 3 : mp - 9
      return (m <= 2 ? y + 1 : y, m, d)
    }
  }
}
