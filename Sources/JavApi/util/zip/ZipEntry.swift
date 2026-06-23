/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util.zip {
  /// Represents a ZIP file entry
  open class ZipEntry : Cloneable, @unchecked Sendable {

    /// Compression method: stored (no compression)
    public static let STORED   : Int = ZipConstants.STORED
    /// Compression method: deflated
    public static let DEFLATED : Int = ZipConstants.DEFLATED

    /// Entry name (path within ZIP) — read-only per Java API
    private var name    : String
    /// Last modification time in milliseconds since the epoch, or -1 if not set
    private var time    : Int64  = -1
    /// CRC-32 checksum of uncompressed data, or -1 if not known
    private var crc     : Int64  = -1
    /// Compressed size, or -1 if not known
    private var compressedSize : Int64 = -1
    /// Uncompressed size, or -1 if not known
    private var size    : Int64  = -1
    /// Compression method (STORED or DEFLATED), or -1 if not set
    private var method  : Int    = -1
    /// Extra field data
    private var extra   : [UInt8]? = nil
    /// Entry comment
    private var comment : String? = nil

    /// Internal compression flags (used by streams)
    internal var flag  : Int    = 0
    /// Version needed to extract
    internal var version : Int  = 20
    /// Offset of local header in ZIP file
    internal var offset : Int64 = 0

    /// Creates a new ZIP entry with the given name
    /// - Parameter name: Entry name (path within ZIP)
    public init (_ name: String) {
      guard name.count <= 0xFFFF else {
        // Java throws IllegalArgumentException here; we truncate silently in Swift
        // because we cannot throw from init without making it failable
        self.name = String(name.prefix(0xFFFF))
        return
      }
      self.name = name
    }

    /// Creates a new ZIP entry from an existing entry (copy constructor)
    /// - Parameter entry: Source entry to copy
    public init (_ entry: ZipEntry) {
      self.name           = entry.name
      self.time           = entry.time
      self.crc            = entry.crc
      self.compressedSize = entry.compressedSize
      self.size           = entry.size
      self.method         = entry.method
      self.extra          = entry.extra
      self.comment        = entry.comment
      self.flag           = entry.flag
      self.version        = entry.version
      self.offset         = entry.offset
    }

    /// Returns the name of the entry
    public func getName() -> String {
      return name
    }

    /// Sets the last modification time of the entry
    /// - Parameter time: Modification time in milliseconds since the epoch
    public func setTime(_ time: Int64) {
      self.time = time
    }

    /// Returns the last modification time of the entry in milliseconds since the epoch, or -1
    public func getTime() -> Int64 {
      return time
    }

    /// Sets the uncompressed size of the entry
    /// - Parameter size: Uncompressed size in bytes, or -1 if unknown
    public func setSize(_ size: Int64) {
      self.size = size
    }

    /// Returns the uncompressed size of the entry, or -1 if unknown
    public func getSize() -> Int64 {
      return size
    }

    /// Returns the compressed size of the entry, or -1 if unknown
    public func getCompressedSize() -> Int64 {
      return compressedSize
    }

    /// Sets the compressed size of the entry
    /// - Parameter compressedSize: Compressed size in bytes, or -1 if unknown
    public func setCompressedSize(_ compressedSize: Int64) {
      self.compressedSize = compressedSize
    }

    /// Sets the CRC-32 checksum of the uncompressed data
    /// - Parameter crc: CRC-32 value
    public func setCrc(_ crc: Int64) {
      self.crc = crc
    }

    /// Returns the CRC-32 checksum of the uncompressed data, or -1 if unknown
    public func getCrc() -> Int64 {
      return crc
    }

    /// Sets the compression method of the entry
    /// - Parameter method: STORED or DEFLATED
    public func setMethod(_ method: Int) {
      self.method = method
    }

    /// Returns the compression method of the entry, or -1 if not set
    public func getMethod() -> Int {
      return method
    }

    /// Sets the optional extra field data
    /// - Parameter extra: Extra field bytes, or nil to clear
    public func setExtra(_ extra: [UInt8]?) {
      self.extra = extra
    }

    /// Returns the extra field data, or nil if not set
    public func getExtra() -> [UInt8]? {
      return extra
    }

    /// Sets the optional comment for the entry
    /// - Parameter comment: Comment string, or nil to clear
    public func setComment(_ comment: String?) {
      self.comment = comment
    }

    /// Returns the comment for the entry, or nil if not set
    public func getComment() -> String? {
      return comment
    }

    /// Returns true if this is a directory entry (name ends with '/')
    public func isDirectory() -> Bool {
      return name.hasSuffix("/")
    }

    /// Returns the name of the entry
    public func toString() -> String {
      return name
    }

    /// Creates a copy of this entry
    public func clone() -> ZipEntry {
      return ZipEntry(self)
    }
  }
}
