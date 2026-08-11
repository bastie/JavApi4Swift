/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation
#if canImport(CryptoKit)
import CryptoKit
#endif

extension java.util {
  typealias UUID = Foundation.UUID
}


extension Foundation.UUID {
  
  /// Create a UUID from standard description
  /// - Parameters:
  /// - Parameter UUID as String in external representation XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
  public static func fromString (_ uuid: String) throws -> UUID {
    if let uuid = UUID(uuidString: uuid) {
      return uuid
    }
    throw IllegalArgumentException("In result of invalid UUID string \(uuid)")
  }
  
  public static func randomUUID () -> UUID {
    return UUID()
  }
  
  public static func nameUUIDFromBytes (_ bytes : [UInt8]) throws -> UUID {
    let md5 = Insecure.MD5.hash(data: Data(bytes))
    var md5Bytes =  md5.map{$0}
    
    // Page 24 of RFC-4122
    md5Bytes[6]  &= 0x0f;  /* version clearing        */
    md5Bytes[6]  |= 0x30;  /* version set to 3     */
    md5Bytes[8]  &= 0x3f;  /* variant clearing       */
    md5Bytes[8]  |= 0x80;  /* set to IETF variant  */

    let c_struct = (
      md5Bytes[0],
      md5Bytes[1],
      md5Bytes[2],
      md5Bytes[3],
      md5Bytes[4],
      md5Bytes[5],
      md5Bytes[6],
      md5Bytes[7],
      md5Bytes[8],
      md5Bytes[9],
      md5Bytes[10],
      md5Bytes[11],
      md5Bytes[12],
      md5Bytes[15],
      md5Bytes[14],
      md5Bytes[15]
    )
    let result = UUID(uuid: c_struct)
    
    return result
  }

  public func toString () -> String {
    return self.description.lowercased() // Swift print it UPPERcase, Java instead lowerCASE
  }

  // MARK: - Bit extraction

  /// Returns the most significant 64 bits of this UUID.
  ///
  /// The first 8 bytes of the UUID are interpreted as a big-endian `Int64`.
  ///
  /// - Since: Java 1.5
  public func getMostSignificantBits() -> Int64 {
    let b = uuid
    let u: UInt64 =
        (UInt64(b.0)  << 56) | (UInt64(b.1)  << 48) |
        (UInt64(b.2)  << 40) | (UInt64(b.3)  << 32) |
        (UInt64(b.4)  << 24) | (UInt64(b.5)  << 16) |
        (UInt64(b.6)  <<  8) |  UInt64(b.7)
    return Int64(bitPattern: u)
  }

  /// Returns the least significant 64 bits of this UUID.
  ///
  /// The last 8 bytes of the UUID are interpreted as a big-endian `Int64`.
  ///
  /// - Since: Java 1.5
  public func getLeastSignificantBits() -> Int64 {
    let b = uuid
    let u: UInt64 =
        (UInt64(b.8)  << 56) | (UInt64(b.9)  << 48) |
        (UInt64(b.10) << 40) | (UInt64(b.11) << 32) |
        (UInt64(b.12) << 24) | (UInt64(b.13) << 16) |
        (UInt64(b.14) <<  8) |  UInt64(b.15)
    return Int64(bitPattern: u)
  }

  // MARK: - version / variant

  /// The version number of this UUID.
  ///
  /// The version number describes how the UUID was generated:
  /// - 1 – Time-based
  /// - 2 – DCE security
  /// - 3 – Name-based (MD5)
  /// - 4 – Randomly generated
  /// - 5 – Name-based (SHA-1)
  ///
  /// - Since: Java 1.5
  public func version() -> Int {
    return Int((getMostSignificantBits() >> 12) & 0x0F)
  }

  /// The variant number of this UUID, describing its layout.
  ///
  /// Returns:
  /// - 0 – NCS backward compatibility (bit 63 of LSB = 0)
  /// - 2 – IETF RFC 4122 (Leach-Salz) — bits 63-62 of LSB = 10
  /// - 6 – Microsoft backward compatibility — bits 63-61 of LSB = 110
  /// - 7 – Reserved for future use — bits 63-61 of LSB = 111
  ///
  /// - Since: Java 1.5
  public func variant() -> Int {
    let lsbU = UInt64(bitPattern: getLeastSignificantBits())
    let top2 = Int(lsbU >> 62)  // bits 63-62 as 0..3
    switch top2 {
    case 0, 1: return 0   // bit 63 = 0 → NCS
    case 2:    return 2   // bits 63-62 = 10 → IETF RFC 4122
    default:              // bits 63-62 = 11
      return Int(lsbU >> 61) & 7  // returns 6 (110) or 7 (111)
    }
  }

  // MARK: - compareTo

  /// Compares this UUID with another using the same natural ordering as Java.
  ///
  /// The comparison first compares most-significant bits; if equal, it
  /// compares least-significant bits.  Both comparisons are signed (as in Java).
  ///
  /// - Returns: -1, 0, or 1
  /// - Since: Java 1.5
  public func compareTo(_ val: Foundation.UUID) -> Int {
    let msb1 = self.getMostSignificantBits()
    let msb2 = val.getMostSignificantBits()
    if msb1 < msb2 { return -1 }
    if msb1 > msb2 { return  1 }
    let lsb1 = self.getLeastSignificantBits()
    let lsb2 = val.getLeastSignificantBits()
    if lsb1 < lsb2 { return -1 }
    if lsb1 > lsb2 { return  1 }
    return 0
  }

  // MARK: - Version-1 fields

  /// Returns the timestamp value associated with this UUID.
  ///
  /// The 60-bit timestamp represents the number of 100-nanosecond intervals
  /// since midnight, 15 October 1582 UTC, as specified in RFC 4122.
  ///
  /// Only meaningful for version-1 UUIDs.
  ///
  /// - Throws: `UnsupportedOperationException` for non-version-1 UUIDs.
  /// - Since: Java 1.5
  public func timestamp() throws -> Int64 {
    guard version() == 1 else {
      throw UnsupportedOperationException("Not a time-based UUID")
    }
    let msbU = UInt64(bitPattern: getMostSignificantBits())
    // RFC 4122 version-1 MSB layout (big-endian):
    //   bits 63..32 = time_low  (bits 31..0  of the 60-bit timestamp)
    //   bits 31..16 = time_mid  (bits 47..32 of the 60-bit timestamp)
    //   bits 15..12 = version   (always 0x1)
    //   bits 11..0  = time_hi   (bits 59..48 of the 60-bit timestamp)
    let result: UInt64 =
        ((msbU & 0x0FFF) << 48)          // time_hi  → bits 59..48
      | (((msbU >> 16) & 0xFFFF) << 32)  // time_mid → bits 47..32
      | (msbU >> 32)                     // time_low → bits 31..0
    return Int64(bitPattern: result)
  }

  /// Returns the clock-sequence value associated with this UUID.
  ///
  /// Only meaningful for version-1 UUIDs.
  ///
  /// - Throws: `UnsupportedOperationException` for non-version-1 UUIDs.
  /// - Since: Java 1.5
  public func clockSequence() throws -> Int {
    guard version() == 1 else {
      throw UnsupportedOperationException("Not a time-based UUID")
    }
    let lsb = getLeastSignificantBits()
    return Int((lsb & 0x3FFF_0000_0000_0000) >> 48)
  }

  /// Returns the node value associated with this UUID.
  ///
  /// Only meaningful for version-1 UUIDs.
  ///
  /// - Throws: `UnsupportedOperationException` for non-version-1 UUIDs.
  /// - Since: Java 1.5
  public func node() throws -> Int64 {
    guard version() == 1 else {
      throw UnsupportedOperationException("Not a time-based UUID")
    }
    return getLeastSignificantBits() & 0x0000_FFFF_FFFF_FFFF
  }

  // MARK: - hashCode / equals

  /// Returns a hash code for this UUID (delegates to Swift's `Hashable`).
  ///
  /// - Since: Java 1.5
  public func hashCode() -> Int {
    return hashValue
  }

  /// Returns `true` if both UUIDs represent the same 128-bit value.
  ///
  /// - Since: Java 1.5
  public func equals(_ other: Foundation.UUID) -> Bool {
    return self == other
  }
}
