/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.util.zip {

  /// Reads entries from a ZIP archive using random access to the central
  /// directory.
  ///
  /// Mirrors `java.util.zip.ZipFile` (Java 1.1). Unlike `ZipInputStream`, which
  /// reads entries sequentially, `ZipFile` parses the *central directory* once
  /// on construction, allowing `getEntry(_:)` lookups and `getInputStream(_:)`
  /// access in any order.
  ///
  /// The whole archive is read into memory on construction; `getInputStream(_:)`
  /// returns a `ByteArrayInputStream` over the (eagerly) decompressed bytes.
  /// Pure Swift — no system ZIP libraries.
  ///
  /// ```swift
  /// let zf = try java.util.zip.ZipFile("archive.zip")
  /// if let entry = zf.getEntry("folder/file.txt") {
  ///   let input = try zf.getInputStream(entry)
  ///   // read from input …
  /// }
  /// try zf.close()
  /// ```
  ///
  /// - TODO: Java 6 — ZIP64 support: recognise the Zip64 EOCD locator/record
  ///   (0x07064b50 / 0x06064b50) and read 64-bit sizes/offsets when the 32-bit
  ///   fields contain 0xFFFFFFFF.
  ///
  /// - Since: JavaApi > 0.20.0 (Java 1.1)
  open class ZipFile : java.io.Closeable, @unchecked Sendable {

    /// Mode flag: open for reading (Java 1.3). Provided for API completeness.
    public static let OPEN_READ   : Int = 0x1
    /// Mode flag: open for reading and delete on close (Java 1.3).
    public static let OPEN_DELETE : Int = 0x4

    // MARK: - State

    /// The path name of the ZIP file, as returned by `getName()`.
    private let name : String
    /// Full archive content held in memory.
    private let data : [UInt8]
    /// Entries in central-directory order.
    private var entryList : [java.util.zip.ZipEntry] = []
    /// Lookup by entry name.
    private var entryByName : [String : java.util.zip.ZipEntry] = [:]
    /// Whether `close()` has been called.
    private var closed : Bool = false

    // MARK: - Init

    /// Opens a ZIP file for reading given the file name.
    public convenience init(_ name: String) throws {
      try self.init(java.io.File(name))
    }

    /// Opens a ZIP file for reading given a `File` object.
    public init(_ file: java.io.File) throws {
      self.name = file.getPath()
      guard let contents = FileManager.default.contents(atPath: file.getPath())
              ?? FileManager.default.contents(atPath: file.getAbsolutePath()) else {
        throw java.io.FileNotFoundException(file.getPath())
      }
      self.data = [UInt8](contents)
      try readCentralDirectory()
    }

    // MARK: - Public API

    /// Returns the path name of the ZIP file.
    open func getName() -> String {
      return name
    }

    /// Returns the number of entries in the ZIP file.
    open func size() -> Int {
      return entryList.count
    }

    /// Returns an enumeration of the ZIP file entries.
    open func entries() -> any java.util.Enumeration<java.util.zip.ZipEntry> {
      return ZipFileEnumeration(entryList)
    }

    /// Returns the ZIP file entry for the specified name, or `nil` if not found.
    open func getEntry(_ name: String) -> java.util.zip.ZipEntry? {
      if let e = entryByName[name] { return e }
      // Java also matches a directory entry stored with a trailing '/'.
      if !name.hasSuffix("/"), let e = entryByName[name + "/"] { return e }
      return nil
    }

    /// Returns an input stream for reading the contents of the specified entry.
    open func getInputStream(_ entry: java.util.zip.ZipEntry) throws -> java.io.InputStream {
      guard !closed else { throw java.io.IOException("ZipFile closed") }
      let off = Int(entry.offset)
      guard off >= 0, off + java.util.zip.ZipConstants.LOCHDR <= data.count else {
        throw java.util.zip.ZipException("Invalid local header offset for \(entry.getName())")
      }
      guard readLe32(off) == Int(java.util.zip.ZipConstants.LOCSIG & 0xFFFF_FFFF) else {
        throw java.util.zip.ZipException("Bad LOC header signature for \(entry.getName())")
      }
      let nameLen  = readLe16(off + java.util.zip.ZipConstants.LOCNAM)
      let extraLen = readLe16(off + java.util.zip.ZipConstants.LOCEXT)
      let dataStart = off + java.util.zip.ZipConstants.LOCHDR + nameLen + extraLen

      var compSize = Int(entry.getCompressedSize())
      if compSize < 0 { compSize = data.count - dataStart }
      guard dataStart >= 0, dataStart + compSize <= data.count else {
        throw java.util.zip.ZipException("Truncated entry data for \(entry.getName())")
      }
      let compressed = Array(data[dataStart ..< dataStart + compSize])

      if entry.getMethod() == java.util.zip.ZipEntry.STORED {
        return java.io.ByteArrayInputStream(compressed)
      }

      // DEFLATED — inflate eagerly with a raw (nowrap) inflater.
      let inflater = java.util.zip.Inflater(true)
      inflater.setInput(compressed)
      var out : [UInt8] = []
      let expected = Int(entry.getSize())
      out.reserveCapacity(expected > 0 ? expected : compSize * 2)
      var buf = [UInt8](repeating: 0, count: 8192)
      while !inflater.finished() {
        let n = try inflater.inflate(&buf, 0, buf.count)
        if n > 0 {
          out.append(contentsOf: buf[0 ..< n])
        } else if inflater.finished() || inflater.needsInput() || inflater.needsDictionary() {
          break
        }
      }
      inflater.end()
      return java.io.ByteArrayInputStream(out)
    }

    /// Closes the ZIP file. Subsequent `getInputStream(_:)` calls throw.
    open func close() throws {
      closed = true
    }

    // MARK: - Central directory parsing

    private func readCentralDirectory() throws {
      guard let eocd = locateEndOfCentralDirectory() else {
        throw java.util.zip.ZipException("End of central directory record not found")
      }
      let total    = readLe16(eocd + java.util.zip.ZipConstants.ENDTOT)
      var p        = readLe32(eocd + java.util.zip.ZipConstants.ENDOFF)

      for _ in 0 ..< total {
        guard p >= 0, p + java.util.zip.ZipConstants.CENHDR <= data.count else {
          throw java.util.zip.ZipException("Corrupt central directory")
        }
        guard readLe32(p) == Int(java.util.zip.ZipConstants.CENSIG & 0xFFFF_FFFF) else {
          throw java.util.zip.ZipException("Bad CEN header signature")
        }
        let method   = readLe16(p + java.util.zip.ZipConstants.CENHOW)
        let modTime  = readLe16(p + java.util.zip.ZipConstants.CENTIM)
        let modDate  = readLe16(p + java.util.zip.ZipConstants.CENTIM + 2)
        let crc      = readLeU32(p + java.util.zip.ZipConstants.CENCRC)
        let compSize = readLe32(p + java.util.zip.ZipConstants.CENSIZ)
        let size     = readLe32(p + java.util.zip.ZipConstants.CENLEN)
        let nameLen  = readLe16(p + java.util.zip.ZipConstants.CENNAM)
        let extraLen = readLe16(p + java.util.zip.ZipConstants.CENEXT)
        let commLen  = readLe16(p + java.util.zip.ZipConstants.CENCOM)
        let lhOffset = readLe32(p + java.util.zip.ZipConstants.CENOFF)

        let nameStart = p + java.util.zip.ZipConstants.CENHDR
        let nameBytes = Array(data[nameStart ..< nameStart + nameLen])
        let entryName = String(bytes: nameBytes, encoding: .utf8)
                    ?? String(bytes: nameBytes, encoding: .isoLatin1)
                    ?? ""

        let entry = java.util.zip.ZipEntry(entryName)
        entry.setMethod(method)
        entry.setCrc(Int64(crc) & 0xFFFF_FFFF)
        entry.setCompressedSize(Int64(compSize))
        entry.setSize(Int64(size))
        entry.setTime(ZipFile.dosToJavaTime((Int64(modDate) << 16) | Int64(modTime)))
        entry.offset = Int64(lhOffset)

        if extraLen > 0 {
          let extraStart = nameStart + nameLen
          entry.setExtra(Array(data[extraStart ..< extraStart + extraLen]))
        }
        if commLen > 0 {
          let commStart = nameStart + nameLen + extraLen
          let commBytes = Array(data[commStart ..< commStart + commLen])
          entry.setComment(String(bytes: commBytes, encoding: .utf8)
                        ?? String(bytes: commBytes, encoding: .isoLatin1))
        }

        entryList.append(entry)
        entryByName[entryName] = entry

        p = nameStart + nameLen + extraLen + commLen
      }
    }

    /// Scans backwards for the End Of Central Directory signature.
    private func locateEndOfCentralDirectory() -> Int? {
      let n = data.count
      let end = java.util.zip.ZipConstants.ENDHDR
      if n < end { return nil }
      let sig = Int(java.util.zip.ZipConstants.ENDSIG & 0xFFFF_FFFF)
      let minStart = Swift.max(0, n - end - 0xFFFF)
      var i = n - end
      while i >= minStart {
        if readLe32(i) == sig { return i }
        i -= 1
      }
      return nil
    }

    // MARK: - Little-endian helpers

    private func readLe16(_ offset: Int) -> Int {
      return Int(data[offset]) | (Int(data[offset + 1]) << 8)
    }

    /// Reads a 32-bit little-endian value as `UInt32` (computed without overflow,
    /// safe on 32-bit targets). Used directly for full-range fields such as CRC.
    private func readLeU32(_ offset: Int) -> UInt32 {
      return  UInt32(data[offset])
           | (UInt32(data[offset + 1]) << 8)
           | (UInt32(data[offset + 2]) << 16)
           | (UInt32(data[offset + 3]) << 24)
    }

    /// Reads a 32-bit little-endian value as `Int` (for offsets, sizes and
    /// signatures, which fit in `Int` for non-ZIP64 archives held in memory).
    private func readLe32(_ offset: Int) -> Int {
      return Int(readLeU32(offset))
    }

    // MARK: - DOS time conversion

    /// Converts a packed DOS date/time value to milliseconds since the epoch
    /// (UTC, no DST). Mirrors the arithmetic used by `ZipInputStream`.
    private static func dosToJavaTime(_ dosTime: Int64) -> Int64 {
      let sec   = Int( dosTime        & 0x1F) * 2
      let minute = Int((dosTime >>  5) & 0x3F)
      let hour  = Int((dosTime >> 11) & 0x1F)
      let day   = Int((dosTime >> 16) & 0x1F)
      let month = Int((dosTime >> 21) & 0x0F)   // 1-based
      let year  = Int((dosTime >> 25) & 0x7F) + 1980
      guard day > 0, month > 0 else { return -1 }
      let days  = Int64(daysFromEpoch(year: year, month: month, day: day))
      let ms    = Int64(hour * 3600 + minute * 60 + sec) * 1000
      return days * 86400_000 + ms
    }

    /// Days since 1970-01-01, proleptic Gregorian.
    private static func daysFromEpoch(year: Int, month: Int, day: Int) -> Int {
      var y = year
      var m = month
      if m < 3 { y -= 1; m += 12 }
      let a = y / 100
      let b = 2 - a + a / 4
      return Int(365.25 * Double(y + 4716)) + Int(30.6001 * Double(m + 1)) + day + b - 1524 - 719163
    }
  }
}

/// Array-backed enumeration over the entries of a `ZipFile`.
internal final class ZipFileEnumeration : java.util.Enumeration {
  public typealias Element = java.util.zip.ZipEntry

  private let items : [java.util.zip.ZipEntry]
  private var index : Int = 0

  init(_ items: [java.util.zip.ZipEntry]) {
    self.items = items
  }

  public func hasMoreElements() -> Bool {
    return index < items.count
  }

  public func nextElement() throws -> java.util.zip.ZipEntry {
    guard index < items.count else { throw java.util.NoSuchElementException() }
    defer { index += 1 }
    return items[index]
  }

  public func next() -> java.util.zip.ZipEntry? {
    guard hasMoreElements() else { return nil }
    return try? nextElement()
  }

  public func makeIterator() -> ZipFileEnumeration {
    return self
  }
}
