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

  @Test("Checksum.update(Int) einzelnes Byte — alle drei Algorithmen")
  func testChecksumUpdateSingleByte() {
    // update(Int) muss äquivalent zu update([byte],0,1) sein
    let input: [UInt8] = [0x48, 0x45, 0x4C, 0x4C, 0x4F]  // "HELLO"

    // CRC32
    let crc1 = java.util.zip.CRC32(); crc1.update(input, 0, 5)
    let crc2 = java.util.zip.CRC32(); for b in input { crc2.update(Int(b)) }
    #expect(crc1.getValue() == crc2.getValue())

    // CRC32C
    let c1 = java.util.zip.CRC32C(); c1.update(input, 0, 5)
    let c2 = java.util.zip.CRC32C(); for b in input { c2.update(Int(b)) }
    #expect(c1.getValue() == c2.getValue())

    // Adler32
    let a1 = java.util.zip.Adler32(); a1.update(input, 0, 5)
    let a2 = java.util.zip.Adler32(); for b in input { a2.update(Int(b)) }
    #expect(a1.getValue() == a2.getValue())
  }

  @Test("Adler32.reset(vv) setzt Startzustand korrekt")
  func testAdler32ResetWithValue() {
    // Adler32("HEL") berechnen, Wert merken, dann reset(vv) und "LO" anhängen
    // Ergebnis muss gleich sein wie Adler32("HELLO") in einem Zug
    let input = Array("HELLO".utf8)

    let chk1 = java.util.zip.Adler32()
    chk1.update(input, 0, 5)
    let expected = chk1.getValue()

    let chk2 = java.util.zip.Adler32()
    chk2.update(input, 0, 3)          // "HEL"
    let intermediate = chk2.getValue()
    chk2.reset(intermediate)          // Zustand einfrieren
    chk2.update(input, 3, 2)          // "LO" anhängen
    #expect(chk2.getValue() == expected)
  }

  @Test("Adler32: update mit offset > 0 korrekt")
  func testAdler32WithOffset() {
    let chk1: any Checksum = java.util.zip.Adler32()
    chk1.update(Array("HELLO".utf8), 0, 5)
    let chk2: any Checksum = java.util.zip.Adler32()
    chk2.update(Array("xxHELLO".utf8), 2, 5)
    #expect(chk1.getValue() == chk2.getValue())
  }

  @Test("Adler32: inkrementelles Update entspricht Einmal-Update")
  func testAdler32Incremental() {
    let chk1: any Checksum = java.util.zip.Adler32()
    let input = Array("HELLO".utf8)
    chk1.update(input, 0, 3)
    chk1.update(input, 3, 2)
    let chk2: any Checksum = java.util.zip.Adler32()
    chk2.update(input, 0, 5)
    #expect(chk1.getValue() == chk2.getValue())
  }

  @Test("CRC32C: update mit offset > 0 korrekt")
  func testCRC32CWithOffset() {
    let chk1: any Checksum = java.util.zip.CRC32C()
    chk1.update(Array("HELLO".utf8), 0, 5)
    let chk2: any Checksum = java.util.zip.CRC32C()
    chk2.update(Array("xxHELLO".utf8), 2, 5)
    #expect(chk1.getValue() == chk2.getValue())
  }

  @Test("CRC32C: inkrementelles Update entspricht Einmal-Update")
  func testCRC32CIncremental() {
    let chk1: any Checksum = java.util.zip.CRC32C()
    let input = Array("HELLO".utf8)
    chk1.update(input, 0, 3)
    chk1.update(input, 3, 2)
    let chk2: any Checksum = java.util.zip.CRC32C()
    chk2.update(input, 0, 5)
    #expect(chk1.getValue() == chk2.getValue())
  }

  @Test("ZIP roundtrip: leeres Archiv (0 Entries)")
  func testZipEmptyArchive() throws {
    let sink = java.io.ByteArrayOutputStream()
    let zos  = java.util.zip.ZipOutputStream(sink)
    try zos.finish()
    // Muss mindestens EOCD enthalten (22 Bytes)
    #expect(sink.toByteArray().count >= 22)
    let src = java.io.ByteArrayInputStream(sink.toByteArray())
    let zis = java.util.zip.ZipInputStream(src)
    let e = try zis.getNextEntry()
    #expect(e == nil)
    try zis.close()
  }

  @Test("ZIP roundtrip: Unicode CJK-Dateiname")
  func testZipRoundtripCJKName() throws {
    let name  = "日本語/テスト.txt"
    let input = Array("内容".utf8)
    let sink  = java.io.ByteArrayOutputStream()
    let zos   = java.util.zip.ZipOutputStream(sink)
    let e     = java.util.zip.ZipEntry(name)
    try zos.putNextEntry(e)
    try zos.write(input, 0, input.count)
    try zos.closeEntry()
    try zos.finish()
    let src   = java.io.ByteArrayInputStream(sink.toByteArray())
    let zis   = java.util.zip.ZipInputStream(src)
    let entry = try zis.getNextEntry()
    #expect(entry?.getName() == name)
    var result: [UInt8] = []
    var buf = [UInt8](repeating: 0, count: 64)
    while true { let n = try zis.read(&buf, 0, buf.count); if n == -1 { break }; result.append(contentsOf: buf[0..<n]) }
    try zis.close()
    #expect(result == input)
  }

#if canImport(CryptoKit)
  @Test("Insecure.Adler32 can be instantiated on CryptoKit platforms")
  func testSwiftlyAdler32() {
    _ = Insecure.Adler32()
  }
#endif
}
