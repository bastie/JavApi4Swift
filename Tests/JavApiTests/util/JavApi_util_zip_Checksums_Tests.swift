/*
 * SPDX-FileCopyrightText: 2023, 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi
#if canImport(CryptoKit)
import CryptoKit
#endif

struct JavApi_util_zip_Checksum_Tests {

  @Test("Adler32 checksum of 'HELLO' matches known value")
  func testAdler32() {
    let chksum: any Checksum = java.util.zip.Adler32()
    let input = Array("HELLO".utf8)
    chksum.update(input, 0, input.count)
    #expect(chksum.getValue() == Int64(72_089_973))
  }

  @Test("CRC32 checksum of 'HELLO' matches known value")
  func testCRC32() {
    let chksum: any Checksum = java.util.zip.CRC32()
    let input = Array("HELLO".utf8)
    chksum.update(input, 0, input.count)
    #expect(chksum.getValue() == Int64(3_242_484_790))
  }

  @Test("CRC32 update mit offset > 0 korrekt")
  func testCRC32WithOffset() {
    // CRC32 von "HELLO" via offset: Puffer = "xxHELLO", offset=2, len=5
    let chksum1: any Checksum = java.util.zip.CRC32()
    let padded = Array("xxHELLO".utf8)
    chksum1.update(padded, 2, 5)
    #expect(chksum1.getValue() == Int64(3_242_484_790))
  }

  @Test("CRC32 inkrementelles Update entspricht Einmal-Update")
  func testCRC32Incremental() {
    // CRC32("HELLO") = update("HEL") dann update("LO")
    let chksum1: any Checksum = java.util.zip.CRC32()
    let input = Array("HELLO".utf8)
    chksum1.update(input, 0, 3)
    chksum1.update(input, 3, 2)
    #expect(chksum1.getValue() == Int64(3_242_484_790))
  }

  @Test("CRC32C checksum of 'HELLO' matches known value")
  func testCRC32C() {
    let chksum: any Checksum = java.util.zip.CRC32C()
    let input = Array("HELLO".utf8)
    chksum.update(input, 0, input.count)
    #expect(chksum.getValue() == Int64(3_901_656_152))
  }

#if canImport(CryptoKit)
  @Test("Insecure.Adler32 can be instantiated on CryptoKit platforms")
  func testSwiftlyAdler32() {
    _ = Insecure.Adler32()
  }
#endif
}
