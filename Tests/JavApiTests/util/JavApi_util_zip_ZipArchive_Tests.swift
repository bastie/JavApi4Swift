/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_util_zip_ZipArchive_Tests {

  // MARK: - Helper

  /// Liest alle Bytes eines ZipInputStream-Entries.
  private func readEntry(_ zis: java.util.zip.ZipInputStream) throws -> [UInt8] {
    var result: [UInt8] = []
    var buf = [UInt8](repeating: 0, count: 256)
    while true {
      let n = try zis.read(&buf, 0, buf.count)
      if n == -1 { break }
      result.append(contentsOf: buf[0..<n])
    }
    return result
  }

  // MARK: - ZipOutputStream → ZipInputStream Roundtrip

  @Test("ZIP roundtrip: einzelner DEFLATED Entry")
  func testZipRoundtripSingleDeflated() throws {
    let input = Array("Hello, ZIP World!".utf8)

    let sink = java.io.ByteArrayOutputStream()
    let zos  = java.util.zip.ZipOutputStream(sink)
    let entry = java.util.zip.ZipEntry("test.txt")
    entry.setMethod(java.util.zip.ZipEntry.DEFLATED)
    try zos.putNextEntry(entry)
    try zos.write(input, 0, input.count)
    try zos.closeEntry()
    try zos.finish()

    let src = java.io.ByteArrayInputStream(sink.toByteArray())
    let zis = java.util.zip.ZipInputStream(src)
    let e = try zis.getNextEntry()
    #expect(e != nil)
    #expect(e!.getName() == "test.txt")
    let data = try readEntry(zis)
    try zis.closeEntry()
    try zis.close()

    #expect(data == input)
  }

  @Test("ZIP roundtrip: einzelner STORED Entry")
  func testZipRoundtripSingleStored() throws {
    let input = Array("Stored content".utf8)

    let sink = java.io.ByteArrayOutputStream()
    let zos  = java.util.zip.ZipOutputStream(sink)
    let entry = java.util.zip.ZipEntry("stored.txt")
    entry.setMethod(java.util.zip.ZipEntry.STORED)
    try zos.putNextEntry(entry)
    try zos.write(input, 0, input.count)
    try zos.closeEntry()
    try zos.finish()

    let src = java.io.ByteArrayInputStream(sink.toByteArray())
    let zis = java.util.zip.ZipInputStream(src)
    let e = try zis.getNextEntry()
    #expect(e != nil)
    #expect(e!.getName() == "stored.txt")
    let data = try readEntry(zis)
    try zis.closeEntry()
    try zis.close()

    #expect(data == input)
  }

  @Test("ZIP roundtrip: mehrere Entries")
  func testZipRoundtripMultipleEntries() throws {
    let entries: [(String, String)] = [
      ("alpha.txt", "Alpha content"),
      ("beta.txt",  "Beta content"),
      ("gamma.txt", "Gamma content"),
    ]

    let sink = java.io.ByteArrayOutputStream()
    let zos  = java.util.zip.ZipOutputStream(sink)
    for (name, content) in entries {
      let e = java.util.zip.ZipEntry(name)
      try zos.putNextEntry(e)
      try zos.write(Array(content.utf8), 0, content.utf8.count)
      try zos.closeEntry()
    }
    try zos.finish()

    let src = java.io.ByteArrayInputStream(sink.toByteArray())
    let zis = java.util.zip.ZipInputStream(src)
    var idx = 0
    while let e = try zis.getNextEntry() {
      let data = try readEntry(zis)
      let expected = entries[idx]
      #expect(e.getName() == expected.0)
      #expect(data == Array(expected.1.utf8))
      try zis.closeEntry()
      idx += 1
    }
    try zis.close()
    #expect(idx == entries.count)
  }

  @Test("ZIP roundtrip: leerer Entry")
  func testZipRoundtripEmptyEntry() throws {
    let sink = java.io.ByteArrayOutputStream()
    let zos  = java.util.zip.ZipOutputStream(sink)
    let entry = java.util.zip.ZipEntry("empty.txt")
    try zos.putNextEntry(entry)
    try zos.closeEntry()
    try zos.finish()

    let src = java.io.ByteArrayInputStream(sink.toByteArray())
    let zis = java.util.zip.ZipInputStream(src)
    let e = try zis.getNextEntry()
    #expect(e != nil)
    #expect(e!.getName() == "empty.txt")
    let data = try readEntry(zis)
    try zis.closeEntry()
    try zis.close()

    #expect(data == [])
  }

  @Test("ZIP roundtrip: repetitive Daten (LZ77)")
  func testZipRoundtripRepetitive() throws {
    let input = [UInt8](repeating: 0xAB, count: 5000)

    let sink = java.io.ByteArrayOutputStream()
    let zos  = java.util.zip.ZipOutputStream(sink)
    let entry = java.util.zip.ZipEntry("rep.bin")
    try zos.putNextEntry(entry)
    try zos.write(input, 0, input.count)
    try zos.closeEntry()
    try zos.finish()

    // Komprimiert muss kleiner sein
    #expect(sink.toByteArray().count < input.count + 100)

    let src = java.io.ByteArrayInputStream(sink.toByteArray())
    let zis = java.util.zip.ZipInputStream(src)
    _ = try zis.getNextEntry()
    let data = try readEntry(zis)
    try zis.closeEntry()
    try zis.close()

    #expect(data == input)
  }

  @Test("ZIP roundtrip: alle 256 Bytewerte")
  func testZipRoundtripAllBytes() throws {
    let input = [UInt8](0...255)

    let sink = java.io.ByteArrayOutputStream()
    let zos  = java.util.zip.ZipOutputStream(sink)
    let entry = java.util.zip.ZipEntry("bytes.bin")
    try zos.putNextEntry(entry)
    try zos.write(input, 0, input.count)
    try zos.closeEntry()
    try zos.finish()

    let src = java.io.ByteArrayInputStream(sink.toByteArray())
    let zis = java.util.zip.ZipInputStream(src)
    _ = try zis.getNextEntry()
    let data = try readEntry(zis)
    try zis.closeEntry()
    try zis.close()

    #expect(data == input)
  }

  // MARK: - ZipInputStream: bekannte Python-ZIP-Bytes dekodieren

  @Test("ZipInputStream: dekodiert bekannten Python-ZIP DEFLATED")
  func testZipInputStreamKnownDeflated() throws {
    // Python: zipfile mit hello.txt = "Hello, ZIP!" und world.txt = "World!"
    let zipBytes: [UInt8] = [
      0x50, 0x4B, 0x03, 0x04, 0x14, 0x00, 0x00, 0x00, 0x08, 0x00, 0x04, 0x9C,
      0xD3, 0x5C, 0xF0, 0x83, 0xA9, 0xEC, 0x0D, 0x00, 0x00, 0x00, 0x0B, 0x00,
      0x00, 0x00, 0x09, 0x00, 0x00, 0x00, 0x68, 0x65, 0x6C, 0x6C, 0x6F, 0x2E,
      0x74, 0x78, 0x74, 0xF3, 0x48, 0xCD, 0xC9, 0xC9, 0xD7, 0x51, 0x88, 0xF2,
      0x0C, 0x50, 0x04, 0x00, 0x50, 0x4B, 0x03, 0x04, 0x14, 0x00, 0x00, 0x00,
      0x08, 0x00, 0x04, 0x9C, 0xD3, 0x5C, 0xDE, 0x9D, 0x28, 0x76, 0x08, 0x00,
      0x00, 0x00, 0x06, 0x00, 0x00, 0x00, 0x09, 0x00, 0x00, 0x00, 0x77, 0x6F,
      0x72, 0x6C, 0x64, 0x2E, 0x74, 0x78, 0x74, 0x0B, 0xCF, 0x2F, 0xCA, 0x49,
      0x51, 0x04, 0x00, 0x50, 0x4B, 0x01, 0x02, 0x14, 0x03, 0x14, 0x00, 0x00,
      0x00, 0x08, 0x00, 0x04, 0x9C, 0xD3, 0x5C, 0xF0, 0x83, 0xA9, 0xEC, 0x0D,
      0x00, 0x00, 0x00, 0x0B, 0x00, 0x00, 0x00, 0x09, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x00, 0x00, 0x00,
      0x00, 0x68, 0x65, 0x6C, 0x6C, 0x6F, 0x2E, 0x74, 0x78, 0x74, 0x50, 0x4B,
      0x01, 0x02, 0x14, 0x03, 0x14, 0x00, 0x00, 0x00, 0x08, 0x00, 0x04, 0x9C,
      0xD3, 0x5C, 0xDE, 0x9D, 0x28, 0x76, 0x08, 0x00, 0x00, 0x00, 0x06, 0x00,
      0x00, 0x00, 0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x80, 0x01, 0x34, 0x00, 0x00, 0x00, 0x77, 0x6F, 0x72, 0x6C,
      0x64, 0x2E, 0x74, 0x78, 0x74, 0x50, 0x4B, 0x05, 0x06, 0x00, 0x00, 0x00,
      0x00, 0x02, 0x00, 0x02, 0x00, 0x6E, 0x00, 0x00, 0x00, 0x63, 0x00, 0x00,
      0x00, 0x00, 0x00
    ]
    let src = java.io.ByteArrayInputStream(zipBytes)
    let zis = java.util.zip.ZipInputStream(src)

    let e1 = try zis.getNextEntry()
    #expect(e1?.getName() == "hello.txt")
    let d1 = try readEntry(zis)
    #expect(d1 == Array("Hello, ZIP!".utf8))
    try zis.closeEntry()

    let e2 = try zis.getNextEntry()
    #expect(e2?.getName() == "world.txt")
    let d2 = try readEntry(zis)
    #expect(d2 == Array("World!".utf8))
    try zis.closeEntry()

    let e3 = try zis.getNextEntry()
    #expect(e3 == nil)
    try zis.close()
  }

  @Test("ZipInputStream: dekodiert bekannten Python-ZIP STORED")
  func testZipInputStreamKnownStored() throws {
    // Python: a.txt = "STORED" mit ZIP_STORED
    let zipBytes: [UInt8] = [
      0x50, 0x4B, 0x03, 0x04, 0x14, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x9C,
      0xD3, 0x5C, 0x8D, 0x3E, 0xBB, 0xA6, 0x06, 0x00, 0x00, 0x00, 0x06, 0x00,
      0x00, 0x00, 0x05, 0x00, 0x00, 0x00, 0x61, 0x2E, 0x74, 0x78, 0x74, 0x53,
      0x54, 0x4F, 0x52, 0x45, 0x44, 0x50, 0x4B, 0x01, 0x02, 0x14, 0x03, 0x14,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x9C, 0xD3, 0x5C, 0x8D, 0x3E, 0xBB,
      0xA6, 0x06, 0x00, 0x00, 0x00, 0x06, 0x00, 0x00, 0x00, 0x05, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x00,
      0x00, 0x00, 0x00, 0x61, 0x2E, 0x74, 0x78, 0x74, 0x50, 0x4B, 0x05, 0x06,
      0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x33, 0x00, 0x00, 0x00,
      0x29, 0x00, 0x00, 0x00, 0x00, 0x00
    ]
    let src = java.io.ByteArrayInputStream(zipBytes)
    let zis = java.util.zip.ZipInputStream(src)

    let e = try zis.getNextEntry()
    #expect(e?.getName() == "a.txt")
    #expect(e?.getMethod() == java.util.zip.ZipEntry.STORED)
    let data = try readEntry(zis)
    #expect(data == Array("STORED".utf8))
    try zis.closeEntry()

    let e2 = try zis.getNextEntry()
    #expect(e2 == nil)
    try zis.close()
  }

  // MARK: - Fehlerszenarien

  @Test("ZipInputStream: ungültige Signatur wirft ZipException")
  func testZipInputStreamBadSignature() {
    let notZip: [UInt8] = [0x00, 0x01, 0x02, 0x03, 0x04, 0x05]
    let src = java.io.ByteArrayInputStream(notZip)
    let zis = java.util.zip.ZipInputStream(src)
    #expect(throws: java.util.zip.ZipException.self) {
      _ = try zis.getNextEntry()
    }
  }

  @Test("ZipOutputStream: Entry-Name wird korrekt gespeichert")
  func testZipEntryName() throws {
    let sink = java.io.ByteArrayOutputStream()
    let zos  = java.util.zip.ZipOutputStream(sink)
    let entry = java.util.zip.ZipEntry("subdir/file.txt")
    try zos.putNextEntry(entry)
    try zos.write(Array("content".utf8), 0, 7)
    try zos.closeEntry()
    try zos.finish()

    let src = java.io.ByteArrayInputStream(sink.toByteArray())
    let zis = java.util.zip.ZipInputStream(src)
    let e = try zis.getNextEntry()
    #expect(e?.getName() == "subdir/file.txt")
    try zis.close()
  }

  @Test("ZipConstants: Signaturen korrekt")
  func testZipSignatureConstants() {
    #expect(java.util.zip.ZipConstants.LOCSIG == 0x04034b50)
    #expect(java.util.zip.ZipConstants.CENSIG == 0x02014b50)
    #expect(java.util.zip.ZipConstants.ENDSIG == 0x06054b50)
    #expect(java.util.zip.ZipConstants.EXTSIG == 0x08074b50)
  }

  // MARK: - Verzeichnis-Entries

  @Test("ZIP roundtrip: Verzeichnis-Entry (Name endet auf /)")
  func testZipRoundtripDirectory() throws {
    let sink = java.io.ByteArrayOutputStream()
    let zos  = java.util.zip.ZipOutputStream(sink)
    let dir  = java.util.zip.ZipEntry("mydir/")
    dir.setMethod(java.util.zip.ZipEntry.STORED)
    try zos.putNextEntry(dir)
    try zos.closeEntry()
    try zos.finish()

    let src = java.io.ByteArrayInputStream(sink.toByteArray())
    let zis = java.util.zip.ZipInputStream(src)
    let e = try zis.getNextEntry()
    #expect(e != nil)
    #expect(e!.getName() == "mydir/")
    #expect(e!.isDirectory() == true)
    let data = try readEntry(zis)
    try zis.closeEntry()
    try zis.close()
    #expect(data == [])
  }

  // MARK: - ZipOutputStream STORED mit manuell gesetztem CRC/Size

  @Test("ZIP STORED: manuell gesetzter CRC und Size werden respektiert")
  func testZipStoredManualCrcAndSize() throws {
    let input: [UInt8] = [0x01, 0x02, 0x03, 0x04, 0x05]
    // CRC-32 von [0x01..0x05] vorab berechnen
    let chk = java.util.zip.CRC32()
    chk.update(input, 0, input.count)
    let expectedCrc = chk.getValue()

    let sink = java.io.ByteArrayOutputStream()
    let zos  = java.util.zip.ZipOutputStream(sink)
    let entry = java.util.zip.ZipEntry("manual.bin")
    entry.setMethod(java.util.zip.ZipEntry.STORED)
    entry.setSize(Int64(input.count))
    entry.setCompressedSize(Int64(input.count))
    entry.setCrc(expectedCrc)
    try zos.putNextEntry(entry)
    try zos.write(input, 0, input.count)
    try zos.closeEntry()
    try zos.finish()

    // Roundtrip: ZipInputStream muss CRC korrekt verifizieren
    let src = java.io.ByteArrayInputStream(sink.toByteArray())
    let zis = java.util.zip.ZipInputStream(src)
    let e = try zis.getNextEntry()
    #expect(e != nil)
    let data = try readEntry(zis)
    try zis.closeEntry()
    try zis.close()
    #expect(data == input)
    #expect(e!.getCrc() == expectedCrc)
  }

  // MARK: - Mehrere Entries gemischt STORED/DEFLATED

  @Test("ZIP roundtrip: gemischte STORED- und DEFLATED-Entries")
  func testZipRoundtripMixed() throws {
    let entries: [(String, [UInt8], Int)] = [
      ("deflated.txt", Array("DEFLATED content".utf8),  java.util.zip.ZipEntry.DEFLATED),
      ("stored.bin",   [0xAA, 0xBB, 0xCC],              java.util.zip.ZipEntry.STORED),
      ("deflated2.txt", Array("Another entry".utf8),    java.util.zip.ZipEntry.DEFLATED),
    ]

    let sink = java.io.ByteArrayOutputStream()
    let zos  = java.util.zip.ZipOutputStream(sink)
    for (name, data, meth) in entries {
      let e = java.util.zip.ZipEntry(name)
      e.setMethod(meth)
      try zos.putNextEntry(e)
      try zos.write(data, 0, data.count)
      try zos.closeEntry()
    }
    try zos.finish()

    let src = java.io.ByteArrayInputStream(sink.toByteArray())
    let zis = java.util.zip.ZipInputStream(src)
    var idx = 0
    while let e = try zis.getNextEntry() {
      let data = try readEntry(zis)
      #expect(e.getName()    == entries[idx].0)
      #expect(data           == entries[idx].1)
      #expect(e.getMethod()  == entries[idx].2)
      try zis.closeEntry()
      idx += 1
    }
    try zis.close()
    #expect(idx == entries.count)
  }

  // MARK: - Große Datenmenge

  @Test("ZIP roundtrip: 100 KB unkomprimierbare Daten (DEFLATED)")
  func testZipRoundtripLargeRandom() throws {
    // Pseudo-zufällige (unkomprimierbare) Daten via LCG
    var seed: UInt64 = 0xDEAD_BEEF_1234_5678
    var input = [UInt8](repeating: 0, count: 100_000)
    for i in input.indices {
      seed = seed &* 6364136223846793005 &+ 1442695040888963407
      input[i] = UInt8(truncatingIfNeeded: seed >> 56)
    }

    let sink = java.io.ByteArrayOutputStream()
    let zos  = java.util.zip.ZipOutputStream(sink)
    let entry = java.util.zip.ZipEntry("random.bin")
    try zos.putNextEntry(entry)
    try zos.write(input, 0, input.count)
    try zos.closeEntry()
    try zos.finish()

    let src = java.io.ByteArrayInputStream(sink.toByteArray())
    let zis = java.util.zip.ZipInputStream(src)
    _ = try zis.getNextEntry()
    let data = try readEntry(zis)
    try zis.closeEntry()
    try zis.close()
    #expect(data == input)
  }

  // MARK: - ZipInputStream: close() ohne read()

  @Test("ZipInputStream: close() ohne read() wirft nicht")
  func testZipInputStreamCloseWithoutRead() throws {
    let sink = java.io.ByteArrayOutputStream()
    let zos  = java.util.zip.ZipOutputStream(sink)
    try zos.putNextEntry(java.util.zip.ZipEntry("x.txt"))
    try zos.write(Array("hello".utf8), 0, 5)
    try zos.closeEntry()
    try zos.finish()

    let src = java.io.ByteArrayInputStream(sink.toByteArray())
    let zis = java.util.zip.ZipInputStream(src)
    // Entry öffnen aber NICHT lesen — direkt schließen
    _ = try zis.getNextEntry()
    try zis.close()  // darf nicht crashen
  }
}
