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
