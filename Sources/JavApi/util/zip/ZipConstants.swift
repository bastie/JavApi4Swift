/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util.zip {
  /// Constants used in ZIP file format
  ///
  /// These constants correspond to the signatures and field values defined
  /// in the ZIP file format specification (PKWARE APPNOTE.TXT).
  public enum ZipConstants {
    /// Signature of Local File Header
    public static let LOCSIG : Int64 = 0x04034b50
    /// Signature of Extra Data Descriptor
    public static let EXTSIG : Int64 = 0x08074b50
    /// Signature of Central Directory Header
    public static let CENSIG : Int64 = 0x02014b50
    /// Signature of End of Central Directory Record
    public static let ENDSIG : Int64 = 0x06054b50

    /// Size of Local File Header (without filename/extra)
    public static let LOCHDR : Int = 30
    /// Size of Extra Data Descriptor
    public static let EXTHDR : Int = 16
    /// Size of Central Directory Header (without filename/extra/comment)
    public static let CENHDR : Int = 46
    /// Size of End of Central Directory Record (without comment)
    public static let ENDHDR : Int = 22

    // Local File Header field offsets
    /// Version needed to extract
    public static let LOCVER : Int = 4
    /// General purpose bit flag
    public static let LOCFLG : Int = 6
    /// Compression method
    public static let LOCHOW : Int = 8
    /// Last modification time
    public static let LOCTIM : Int = 10
    /// CRC-32 of uncompressed data
    public static let LOCCRC : Int = 14
    /// Compressed size
    public static let LOCSIZ : Int = 18
    /// Uncompressed size
    public static let LOCLEN : Int = 22
    /// Filename length
    public static let LOCNAM : Int = 26
    /// Extra field length
    public static let LOCEXT : Int = 28

    // Extra Data Descriptor field offsets
    /// CRC-32 of uncompressed data
    public static let EXTCRC : Int = 4
    /// Compressed size
    public static let EXTSIZ : Int = 8
    /// Uncompressed size
    public static let EXTLEN : Int = 12

    // Central Directory Header field offsets
    /// Version made by
    public static let CENVEM : Int = 4
    /// Version needed to extract
    public static let CENVER : Int = 6
    /// General purpose bit flag
    public static let CENFLG : Int = 8
    /// Compression method
    public static let CENHOW : Int = 10
    /// Last modification time
    public static let CENTIM : Int = 12
    /// CRC-32 of uncompressed data
    public static let CENCRC : Int = 16
    /// Compressed size
    public static let CENSIZ : Int = 20
    /// Uncompressed size
    public static let CENLEN : Int = 24
    /// Filename length
    public static let CENNAM : Int = 28
    /// Extra field length
    public static let CENEXT : Int = 30
    /// File comment length
    public static let CENCOM : Int = 32
    /// Disk number start
    public static let CENDSK : Int = 34
    /// Internal file attributes
    public static let CENATT : Int = 36
    /// External file attributes
    public static let CENATX : Int = 38
    /// Relative offset of Local Header
    public static let CENOFF : Int = 42

    // End of Central Directory Record field offsets
    /// Disk number
    public static let ENDDSK : Int = 4
    /// Disk with start of Central Directory
    public static let ENDSUB : Int = 8  // corrected: start disk of central dir entries
    /// Number of Central Directory entries on this disk
    public static let ENDTOT : Int = 10
    /// Total number of Central Directory entries
    public static let ENDSIZ : Int = 12 // size of central directory
    /// Offset of start of Central Directory
    public static let ENDOFF : Int = 16
    /// ZIP file comment length
    public static let ENDCOM : Int = 20

    // Compression methods
    /// Stored (no compression)
    public static let STORED    : Int = 0
    /// Deflated
    public static let DEFLATED  : Int = 8
  }
}
