/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_util_UUID_Tests {

  // MARK: - Existing tests

  @Test("two random UUIDs are not equal")
  func testCreateRandom() {
    let uuid1 = java.util.UUID.randomUUID()
    let uuid2 = java.util.UUID.randomUUID()
    #expect(uuid1 != uuid2)
  }

  @Test("UUID from string parses correctly and compares by value")
  func testCreateFromString() throws {
    let uuid1 = try java.util.UUID.fromString("6339c578-403d-4cb8-9da0-65f096e4f6d1")
    let uuid2 = try java.util.UUID.fromString("6339c578-403d-4cb8-9da0-65f096e4f6d1")
    let uuid3 = try java.util.UUID.fromString("6339c578-403d-4cb8-9da0-65f096e4f6d2")
    #expect(uuid1 == uuid2)
    #expect(uuid1 != uuid3)
  }

  @Test("nameUUIDFromBytes is deterministic and differs for different inputs")
  func testCreateFromName() throws {
    let uuid1 = try java.util.UUID.nameUUIDFromBytes("www.ritter.biz".getBytes("UTF-8"))
    let uuid2 = try java.util.UUID.nameUUIDFromBytes("www.ritter.biz".getBytes("UTF-8"))
    let uuid3 = try java.util.UUID.nameUUIDFromBytes("www.example.com".getBytes("UTF-8"))
    #expect(uuid1 == uuid2)
    #expect(uuid1 != uuid3)
  }

  // MARK: - getMostSignificantBits / getLeastSignificantBits

  /// UUID: 00000000-0000-0000-0000-000000000001
  /// MSB = 0x0000_0000_0000_0000 = 0
  /// LSB = 0x0000_0000_0000_0001 = 1
  @Test("getMostSignificantBits for zero UUID")
  func testMSB_zero() throws {
    let uuid = try java.util.UUID.fromString("00000000-0000-0000-0000-000000000000")
    #expect(uuid.getMostSignificantBits() == 0)
  }

  @Test("getLeastSignificantBits for zero UUID")
  func testLSB_zero() throws {
    let uuid = try java.util.UUID.fromString("00000000-0000-0000-0000-000000000000")
    #expect(uuid.getLeastSignificantBits() == 0)
  }

  /// UUID 00000000-0000-0000-0000-000000000001 → LSB = 1
  @Test("getLeastSignificantBits for UUID with last byte 1")
  func testLSB_one() throws {
    let uuid = try java.util.UUID.fromString("00000000-0000-0000-0000-000000000001")
    #expect(uuid.getLeastSignificantBits() == 1)
  }

  /// UUID: ffffffff-ffff-ffff-ffff-ffffffffffff → MSB = -1 (all bits set)
  @Test("getMostSignificantBits for all-FF UUID")
  func testMSB_allFF() throws {
    let uuid = try java.util.UUID.fromString("ffffffff-ffff-ffff-ffff-ffffffffffff")
    #expect(uuid.getMostSignificantBits() == -1)
    #expect(uuid.getLeastSignificantBits() == -1)
  }

  @Test("MSB and LSB reconstruct a known UUID value")
  func testMSB_LSB_knownValue() throws {
    // UUID: 6ba7b810-9dad-11d1-80b4-00c04fd430c8  (the DNS namespace UUID)
    let uuid = try java.util.UUID.fromString("6ba7b810-9dad-11d1-80b4-00c04fd430c8")
    // MSB bytes: 6b a7 b8 10 9d ad 11 d1
    let expectedMSB = Int64(bitPattern: 0x6ba7b8109dad11d1)
    // LSB bytes: 80 b4 00 c0 4f d4 30 c8
    let expectedLSB = Int64(bitPattern: 0x80b400c04fd430c8)
    #expect(uuid.getMostSignificantBits() == expectedMSB)
    #expect(uuid.getLeastSignificantBits() == expectedLSB)
  }

  // MARK: - version

  @Test("version() returns 4 for random UUIDs")
  func testVersion_random() {
    // randomUUID() creates version-4 UUIDs
    let uuid = java.util.UUID.randomUUID()
    #expect(uuid.version() == 4)
  }

  @Test("version() returns 3 for nameUUIDFromBytes (MD5)")
  func testVersion_name() throws {
    let uuid = try java.util.UUID.nameUUIDFromBytes("test".getBytes("UTF-8"))
    #expect(uuid.version() == 3)
  }

  @Test("version() reads bits 15-12 of MSB correctly")
  func testVersion_knownBits() throws {
    // UUID with version nibble = 1: xxxxxxxx-xxxx-1xxx-...
    let uuid = try java.util.UUID.fromString("6ba7b810-9dad-11d1-80b4-00c04fd430c8")
    #expect(uuid.version() == 1)
  }

  // MARK: - variant

  @Test("variant() returns 2 for standard RFC 4122 UUIDs")
  func testVariant_IETF() throws {
    // bit 63 of LSB = 1, bit 62 = 0 → IETF variant (2)
    // UUID: 6ba7b810-9dad-11d1-80b4-00c04fd430c8 → LSB byte 8 = 0x80 = 10000000 → bits 63-62 = 10
    let uuid = try java.util.UUID.fromString("6ba7b810-9dad-11d1-80b4-00c04fd430c8")
    #expect(uuid.variant() == 2)
  }

  @Test("variant() returns 2 for randomly generated UUIDs")
  func testVariant_random() {
    let uuid = java.util.UUID.randomUUID()
    #expect(uuid.variant() == 2)
  }

  @Test("variant() returns 0 for NCS UUID (bit 63 of LSB = 0)")
  func testVariant_NCS() throws {
    // bit 63 of LSB byte 8 = 0 → NCS
    let uuid = try java.util.UUID.fromString("6ba7b810-9dad-11d1-00b4-00c04fd430c8")  // byte8 = 0x00
    #expect(uuid.variant() == 0)
  }

  // MARK: - compareTo

  @Test("compareTo returns 0 for equal UUIDs")
  func testCompareTo_equal() throws {
    let a = try java.util.UUID.fromString("6339c578-403d-4cb8-9da0-65f096e4f6d1")
    let b = try java.util.UUID.fromString("6339c578-403d-4cb8-9da0-65f096e4f6d1")
    #expect(a.compareTo(b) == 0)
  }

  @Test("compareTo returns negative when self < other (MSB differs)")
  func testCompareTo_lessThan_MSB() throws {
    let a = try java.util.UUID.fromString("00000001-0000-0000-0000-000000000000")
    let b = try java.util.UUID.fromString("00000002-0000-0000-0000-000000000000")
    #expect(a.compareTo(b) < 0)
    #expect(b.compareTo(a) > 0)
  }

  @Test("compareTo returns negative when self < other (LSB differs)")
  func testCompareTo_lessThan_LSB() throws {
    let a = try java.util.UUID.fromString("00000001-0000-0000-0000-000000000001")
    let b = try java.util.UUID.fromString("00000001-0000-0000-0000-000000000002")
    #expect(a.compareTo(b) < 0)
    #expect(b.compareTo(a) > 0)
  }

  @Test("compareTo is consistent with equality")
  func testCompareTo_symmetry() {
    let a = java.util.UUID.randomUUID()
    let b = java.util.UUID.randomUUID()
    let ab = a.compareTo(b)
    let ba = b.compareTo(a)
    if ab == 0 {
      #expect(ba == 0)
    } else {
      #expect(ab == -ba || (ab < 0 && ba > 0) || (ab > 0 && ba < 0))
    }
  }

  // MARK: - Version-1 fields (timestamp / clockSequence / node)

  /// A well-known version-1 UUID: 6ba7b810-9dad-11d1-80b4-00c04fd430c8 (DNS namespace)
  ///
  /// RFC 4122 DNS namespace UUID is actually version-1 in the sense that the
  /// version nibble is 1, but it was not generated dynamically — the timestamp,
  /// clockSeq, and node are fixed.  We just verify the structural extraction
  /// is correct against the known byte values.

  @Test("timestamp() throws for non-version-1 UUID")
  func testTimestamp_throws_forV4() throws {
    let uuid = java.util.UUID.randomUUID()
    #expect(throws: (any Error).self) {
      _ = try uuid.timestamp()
    }
  }

  @Test("clockSequence() throws for non-version-1 UUID")
  func testClockSequence_throws_forV4() {
    let uuid = java.util.UUID.randomUUID()
    #expect(throws: (any Error).self) {
      _ = try uuid.clockSequence()
    }
  }

  @Test("node() throws for non-version-1 UUID")
  func testNode_throws_forV4() {
    let uuid = java.util.UUID.randomUUID()
    #expect(throws: (any Error).self) {
      _ = try uuid.node()
    }
  }

  @Test("timestamp() for known version-1 UUID returns correct value")
  func testTimestamp_knownV1() throws {
    // 6ba7b810-9dad-11d1-80b4-00c04fd430c8 is the well-known DNS namespace UUID (v1)
    let uuid = try java.util.UUID.fromString("6ba7b810-9dad-11d1-80b4-00c04fd430c8")
    #expect(uuid.version() == 1)
    // MSB = 0x6ba7b8109dad11d1
    // time_hi  = msb bits 11..0  = 0x1d1 = 0x0000_0000_0000_01d1 → <<48 = 0x01d1_0000_0000_0000
    // time_mid = msb bits 31..16 = 0x9dad → <<32 = 0x0000_9dad_0000_0000
    // time_low = msb bits 63..32 = 0x6ba7b810
    // result = 0x01d1_9dad_6ba7b810
    let ts = try uuid.timestamp()
    #expect(ts == Int64(bitPattern: 0x01d19dad6ba7b810))
  }

  @Test("clockSequence() for known version-1 UUID returns correct value")
  func testClockSequence_knownV1() throws {
    let uuid = try java.util.UUID.fromString("6ba7b810-9dad-11d1-80b4-00c04fd430c8")
    // LSB = 0x80b400c04fd430c8
    // clockSeq bits = LSB bits 61..48 = (0x80b4... >> 48) & 0x3FFF
    // LSB byte8 = 0x80, byte9 = 0xb4 → top 16 bits = 0x80b4
    // (0x80b4 & 0x3FFF) = 0x00b4 = 180
    let cs = try uuid.clockSequence()
    #expect(cs == 0x00b4)
  }

  @Test("node() for known version-1 UUID returns correct value")
  func testNode_knownV1() throws {
    let uuid = try java.util.UUID.fromString("6ba7b810-9dad-11d1-80b4-00c04fd430c8")
    // LSB = 0x80b400c04fd430c8
    // node = lower 48 bits = 0x00c04fd430c8
    let n = try uuid.node()
    #expect(n == 0x00c04fd430c8)
  }

  // MARK: - hashCode / equals

  @Test("hashCode is consistent for same UUID")
  func testHashCode_consistent() throws {
    let uuid = try java.util.UUID.fromString("6339c578-403d-4cb8-9da0-65f096e4f6d1")
    #expect(uuid.hashCode() == uuid.hashCode())
  }

  @Test("equals returns true for same UUID value")
  func testEquals_sameValue() throws {
    let a = try java.util.UUID.fromString("6339c578-403d-4cb8-9da0-65f096e4f6d1")
    let b = try java.util.UUID.fromString("6339c578-403d-4cb8-9da0-65f096e4f6d1")
    #expect(a.equals(b))
  }

  @Test("equals returns false for different UUIDs")
  func testEquals_differentValue() throws {
    let a = try java.util.UUID.fromString("6339c578-403d-4cb8-9da0-65f096e4f6d1")
    let b = try java.util.UUID.fromString("6339c578-403d-4cb8-9da0-65f096e4f6d2")
    #expect(!a.equals(b))
  }
}
