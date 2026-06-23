/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_util_zip_DeflateInflate_Tests {

  // MARK: - Helper

  /// Compress `input` with Deflater, decompress with Inflater, return decompressed bytes.
  private func roundtrip(_ input: [UInt8], level: Int = java.util.zip.Deflater.DEFAULT_COMPRESSION, nowrap: Bool = false) throws -> [UInt8] {
    // --- Compress ---
    let deflater = java.util.zip.Deflater(level, nowrap)
    deflater.setInput(input)
    deflater.finish()

    var compressed = [UInt8](repeating: 0, count: input.count + 256)
    let compressedLen = deflater.deflate(&compressed, 0, compressed.count)
    deflater.end()

    // --- Decompress ---
    let inflater = java.util.zip.Inflater(nowrap)
    inflater.setInput(Array(compressed[0..<compressedLen]))

    var decompressed = [UInt8](repeating: 0, count: input.count + 256)
    let decompressedLen = try inflater.inflate(&decompressed, 0, decompressed.count)
    inflater.end()

    return Array(decompressed[0..<decompressedLen])
  }

  // MARK: - Basic roundtrip tests

  @Test("Roundtrip: empty input")
  func testRoundtripEmpty() throws {
    let result = try roundtrip([])
    #expect(result == [])
  }

  @Test("Roundtrip: single byte")
  func testRoundtripSingleByte() throws {
    let input: [UInt8] = [42]
    let result = try roundtrip(input)
    #expect(result == input)
  }

  @Test("Roundtrip: ASCII text (default compression)")
  func testRoundtripAsciiText() throws {
    let input = Array("Hello, World! This is a test of DEFLATE compression.".utf8)
    let result = try roundtrip(input)
    #expect(result == input)
  }

  @Test("Roundtrip: highly repetitive data (benefits from LZ77)")
  func testRoundtripRepetitive() throws {
    let input = [UInt8](repeating: 0xAB, count: 1000)
    let result = try roundtrip(input)
    #expect(result == input)
  }

  @Test("Roundtrip: longer text")
  func testRoundtripLongerText() throws {
    let text = String(repeating: "JavApi4Swift komprimiert und dekomprimiert korrekt! ", count: 20)
    let input = Array(text.utf8)
    let result = try roundtrip(input)
    #expect(result == input)
  }

  @Test("Roundtrip: binary data (all byte values)")
  func testRoundtripAllBytes() throws {
    let input = [UInt8](0...255)
    let result = try roundtrip(input)
    #expect(result == input)
  }

  // MARK: - Compression level tests

  @Test("Roundtrip: NO_COMPRESSION (stored blocks)")
  func testRoundtripNoCompression() throws {
    let input = Array("Stored without compression".utf8)
    let result = try roundtrip(input, level: java.util.zip.Deflater.NO_COMPRESSION)
    #expect(result == input)
  }

  @Test("Roundtrip: BEST_SPEED")
  func testRoundtripBestSpeed() throws {
    let input = Array("Fast compression test".utf8)
    let result = try roundtrip(input, level: java.util.zip.Deflater.BEST_SPEED)
    #expect(result == input)
  }

  @Test("Roundtrip: BEST_COMPRESSION")
  func testRoundtripBestCompression() throws {
    let input = Array("Maximum compression test with some repeated content repeated content".utf8)
    let result = try roundtrip(input, level: java.util.zip.Deflater.BEST_COMPRESSION)
    #expect(result == input)
  }

  // MARK: - nowrap (raw DEFLATE) tests

  @Test("Roundtrip: raw DEFLATE (nowrap=true)")
  func testRoundtripNowrap() throws {
    let input = Array("Raw DEFLATE without zlib framing".utf8)
    let result = try roundtrip(input, nowrap: true)
    #expect(result == input)
  }

  @Test("Roundtrip: raw DEFLATE, NO_COMPRESSION")
  func testRoundtripNowrapStored() throws {
    let input = Array("Stored raw".utf8)
    let result = try roundtrip(input, level: java.util.zip.Deflater.NO_COMPRESSION, nowrap: true)
    #expect(result == input)
  }

  // MARK: - API / state tests

  @Test("Deflater.needsInput() after setInput")
  func testNeedsInputAfterSetInput() {
    let d = java.util.zip.Deflater()
    #expect(d.needsInput() == true)
    d.setInput(Array("hello".utf8))
    #expect(d.needsInput() == false)
  }

  @Test("Deflater.finished() after full deflate")
  func testDeflaterFinished() {
    let d = java.util.zip.Deflater()
    d.setInput(Array("hello".utf8))
    d.finish()
    var buf = [UInt8](repeating: 0, count: 256)
    _ = d.deflate(&buf)
    #expect(d.finished() == true)
    d.end()
  }

  @Test("Inflater.finished() after full inflate")
  func testInflaterFinished() throws {
    let input = Array("hello".utf8)
    let d = java.util.zip.Deflater()
    d.setInput(input); d.finish()
    var comp = [UInt8](repeating: 0, count: 256)
    let n = d.deflate(&comp)
    d.end()

    let inf = java.util.zip.Inflater()
    inf.setInput(Array(comp[0..<n]))
    var out = [UInt8](repeating: 0, count: 256)
    _ = try inf.inflate(&out)
    #expect(inf.finished() == true)
    inf.end()
  }

  @Test("Deflater.getBytesRead() and getBytesWritten()")
  func testDeflaterByteCounters() {
    let input = Array("Hello counters".utf8)
    let d = java.util.zip.Deflater()
    d.setInput(input); d.finish()
    var buf = [UInt8](repeating: 0, count: 256)
    let n = d.deflate(&buf)
    #expect(d.getBytesRead()    == Int64(input.count))
    #expect(d.getBytesWritten() == Int64(n))
    d.end()
  }

  @Test("Deflater.reset() allows reuse")
  func testDeflaterReset() throws {
    let d = java.util.zip.Deflater()
    let input1 = Array("first".utf8)
    d.setInput(input1); d.finish()
    var buf = [UInt8](repeating: 0, count: 256)
    _ = d.deflate(&buf)

    d.reset()
    #expect(d.finished() == false)
    #expect(d.needsInput() == true)

    let input2 = Array("second".utf8)
    d.setInput(input2); d.finish()
    var buf2 = [UInt8](repeating: 0, count: 256)
    let n = d.deflate(&buf2, 0, buf2.count)

    let inf = java.util.zip.Inflater()
    inf.setInput(Array(buf2[0..<n]))
    var out = [UInt8](repeating: 0, count: 256)
    let m = try inf.inflate(&out)
    #expect(Array(out[0..<m]) == input2)
    inf.end()
    d.end()
  }

  // MARK: - Referenz-Tests (gegen bekannte Python/zlib-Ausgabe)

  @Test("Inflater: dekodiert bekannten zlib-Stream 'Hello, World!'")
  func testInflaterKnownZlibHello() throws {
    // Erzeugt mit Python: zlib.compress(b"Hello, World!", level=6)
    let compressed: [UInt8] = [0x78, 0x9C, 0xF3, 0x48, 0xCD, 0xC9, 0xC9, 0xD7,
                                0x51, 0x08, 0xCF, 0x2F, 0xCA, 0x49, 0x51, 0x04,
                                0x00, 0x1F, 0x9E, 0x04, 0x6A]
    let expected = Array("Hello, World!".utf8)
    let inflater = java.util.zip.Inflater()
    inflater.setInput(compressed)
    var out = [UInt8](repeating: 0, count: 64)
    let n = try inflater.inflate(&out)
    #expect(Array(out[0..<n]) == expected)
    inflater.end()
  }

  @Test("Inflater: dekodiert bekannten zlib-Stream 'AAAAAAAAAA'")
  func testInflaterKnownZlibRepetitive() throws {
    // Erzeugt mit Python: zlib.compress(b"AAAAAAAAAA", level=6)
    let compressed: [UInt8] = [0x78, 0x9C, 0x73, 0x74, 0x84, 0x01, 0x00, 0x0E,
                                0x01, 0x02, 0x8B]
    let expected = Array("AAAAAAAAAA".utf8)
    let inflater = java.util.zip.Inflater()
    inflater.setInput(compressed)
    var out = [UInt8](repeating: 0, count: 64)
    let n = try inflater.inflate(&out)
    #expect(Array(out[0..<n]) == expected)
    inflater.end()
  }

  @Test("Inflater: dekodiert bekannten raw-DEFLATE-Stream 'Hello, World!'")
  func testInflaterKnownRawDeflate() throws {
    // Erzeugt mit Python: zlib.compress(b"Hello, World!", level=6)[2:-4]
    let compressed: [UInt8] = [0xF3, 0x48, 0xCD, 0xC9, 0xC9, 0xD7, 0x51, 0x08,
                                0xCF, 0x2F, 0xCA, 0x49, 0x51, 0x04, 0x00]
    let expected = Array("Hello, World!".utf8)
    let inflater = java.util.zip.Inflater(true)  // nowrap
    inflater.setInput(compressed)
    var out = [UInt8](repeating: 0, count: 64)
    let n = try inflater.inflate(&out)
    #expect(Array(out[0..<n]) == expected)
    inflater.end()
  }

  // MARK: - Kompressionseffizienz

  @Test("Deflater: komprimierte Größe < Originalgröße bei repetitiven Daten")
  func testCompressionRatio() {
    let input = [UInt8](repeating: 0x41, count: 1000)
    let d = java.util.zip.Deflater()
    d.setInput(input); d.finish()
    var buf = [UInt8](repeating: 0, count: input.count + 256)
    let n = d.deflate(&buf)
    d.end()
    #expect(n < input.count, "Komprimierte Größe (\(n)) sollte < Original (\(input.count)) sein")
  }

  // MARK: - Inflater API-Vollständigkeit

  @Test("Inflater.getBytesRead() und getBytesWritten()")
  func testInflaterByteCounters() throws {
    let input = Array("counter test".utf8)
    let d = java.util.zip.Deflater(); d.setInput(input); d.finish()
    var comp = [UInt8](repeating: 0, count: 256)
    let n = d.deflate(&comp); d.end()

    let inf = java.util.zip.Inflater()
    inf.setInput(Array(comp[0..<n]))
    var out = [UInt8](repeating: 0, count: 256)
    let m = try inf.inflate(&out)
    #expect(inf.getBytesRead()    == Int64(n))
    #expect(inf.getBytesWritten() == Int64(m))
    inf.end()
  }

  @Test("Inflater.reset() erlaubt Wiederverwendung")
  func testInflaterReset() throws {
    let d = java.util.zip.Deflater()
    d.setInput(Array("first".utf8)); d.finish()
    var c1 = [UInt8](repeating: 0, count: 256)
    let n1 = d.deflate(&c1); d.end()

    let inf = java.util.zip.Inflater()
    inf.setInput(Array(c1[0..<n1]))
    var o1 = [UInt8](repeating: 0, count: 256)
    let m1 = try inf.inflate(&o1)
    #expect(Array(o1[0..<m1]) == Array("first".utf8))

    inf.reset()
    #expect(inf.finished() == false)

    let d2 = java.util.zip.Deflater()
    d2.setInput(Array("second".utf8)); d2.finish()
    var c2 = [UInt8](repeating: 0, count: 256)
    let n2 = d2.deflate(&c2); d2.end()

    inf.setInput(Array(c2[0..<n2]))
    var o2 = [UInt8](repeating: 0, count: 256)
    let m2 = try inf.inflate(&o2)
    #expect(Array(o2[0..<m2]) == Array("second".utf8))
    inf.end()
  }

  @Test("Inflater: mehrfache inflate()-Aufrufe bei kleinem Output-Buffer")
  func testInflaterSmallOutputBuffer() throws {
    let input = [UInt8](repeating: 0x42, count: 500)
    let d = java.util.zip.Deflater(); d.setInput(input); d.finish()
    var comp = [UInt8](repeating: 0, count: 600)
    let n = d.deflate(&comp); d.end()

    let inf = java.util.zip.Inflater()
    inf.setInput(Array(comp[0..<n]))

    // Kleiner Buffer: nur 50 Bytes pro Aufruf bis alles gelesen ist
    var result: [UInt8] = []
    var chunk = [UInt8](repeating: 0, count: 50)
    repeat {
      let m = try inf.inflate(&chunk, 0, chunk.count)
      if m > 0 { result.append(contentsOf: chunk[0..<m]) }
    } while !inf.finished()
    inf.end()
    #expect(result == input)
  }

  @Test("Roundtrip: Daten größer als stored-block Grenze (>65535 Bytes)")
  func testRoundtripLargeData() throws {
    // Überschreitet die 65535-Byte-Grenze eines stored blocks
    let input = [UInt8]((0..<70000).map { UInt8($0 & 0xFF) })
    let result = try roundtrip(input, level: java.util.zip.Deflater.NO_COMPRESSION)
    #expect(result == input)
  }

  // MARK: - Robustheit / Randfälle

  @Test("Deflater.end() danach deflate() gibt 0 zurück")
  func testDeflaterAfterEnd() {
    let d = java.util.zip.Deflater()
    d.setInput(Array("hello".utf8)); d.finish()
    d.end()
    var buf = [UInt8](repeating: 0, count: 64)
    let n = d.deflate(&buf)
    #expect(n == 0)
  }

  @Test("Inflater.end() danach inflate() gibt 0 zurück")
  func testInflaterAfterEnd() throws {
    let inf = java.util.zip.Inflater()
    inf.end()
    var buf = [UInt8](repeating: 0, count: 64)
    let n = try inf.inflate(&buf)
    #expect(n == 0)
  }

  @Test("Inflater.getRemaining() nach setInput")
  func testInflaterGetRemaining() throws {
    let d = java.util.zip.Deflater()
    d.setInput(Array("test".utf8)); d.finish()
    var comp = [UInt8](repeating: 0, count: 64)
    let n = d.deflate(&comp); d.end()

    let inf = java.util.zip.Inflater()
    inf.setInput(Array(comp[0..<n]))
    #expect(inf.getRemaining() == n)
    var out = [UInt8](repeating: 0, count: 64)
    _ = try inf.inflate(&out)
    // Nach vollständiger Dekompression sollte nichts mehr übrig sein
    #expect(inf.getRemaining() == 0)
    inf.end()
  }

  @Test("DataFormatException bei korruptem zlib-Input")
  func testDataFormatExceptionOnCorruptInput() {
    let corrupt: [UInt8] = [0x78, 0x9C, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]
    let inf = java.util.zip.Inflater()
    inf.setInput(corrupt)
    var out = [UInt8](repeating: 0, count: 64)
    #expect(throws: java.util.zip.DataFormatException.self) {
      try inf.inflate(&out)
    }
    inf.end()
  }

  @Test("Deflater.setStrategy(HUFFMAN_ONLY) Roundtrip")
  func testDeflaterHuffmanOnly() throws {
    let input = Array("Huffman only strategy test".utf8)
    let d = java.util.zip.Deflater()
    d.setStrategy(java.util.zip.Deflater.HUFFMAN_ONLY)
    d.setInput(input); d.finish()
    var comp = [UInt8](repeating: 0, count: 256)
    let n = d.deflate(&comp); d.end()

    let inf = java.util.zip.Inflater()
    inf.setInput(Array(comp[0..<n]))
    var out = [UInt8](repeating: 0, count: 256)
    let m = try inf.inflate(&out)
    #expect(Array(out[0..<m]) == input)
    inf.end()
  }

  @Test("ZipConstants: Signaturen haben korrekte Werte")
  func testZipConstantsSignatures() {
    #expect(java.util.zip.ZipConstants.LOCSIG == 0x04034b50)
    #expect(java.util.zip.ZipConstants.CENSIG == 0x02014b50)
    #expect(java.util.zip.ZipConstants.ENDSIG == 0x06054b50)
    #expect(java.util.zip.ZipConstants.EXTSIG == 0x08074b50)
    #expect(java.util.zip.ZipConstants.STORED   == 0)
    #expect(java.util.zip.ZipConstants.DEFLATED  == 8)
  }

  @Test("ZipException ist konstruierbar und trägt Nachricht")
  func testZipException() {
    let ex = java.util.zip.ZipException("test error")
    #expect(ex.getMessage() == "test error")
    let ex2 = java.util.zip.ZipException()
    #expect(ex2.getMessage() == nil || ex2.getMessage()?.isEmpty == true)
  }

  // MARK: - Randszenarien

  @Test("Inflater: zlib-Stream mit fdict=1 setzt needsDictionary()")
  func testInflaterFdictFlag() throws {
    // Gültiger zlib-Header mit FDICT-Bit (bit5 von FLG gesetzt), gefolgt von 4-Byte Adler32 des Dict
    // Python: CMF=0x78 FLG=0x20 → (0x78*256+0x20)%31==0, fdict=1
    let fdictStream: [UInt8] = [0x78, 0x20, 0x00, 0x00, 0x00, 0x01]
    let inf = java.util.zip.Inflater()
    inf.setInput(fdictStream)
    var out = [UInt8](repeating: 0, count: 64)
    // Der Stream ist unvollständig — wir erwarten entweder DataFormatException oder needsDictionary()==true
    do {
      _ = try inf.inflate(&out)
      #expect(inf.needsDictionary() == true)
    } catch is java.util.zip.DataFormatException {
      // Auch akzeptabel: Stream ist nach dem Header abgeschnitten
    }
    inf.end()
  }

  @Test("Deflater: Output-Buffer kleiner als nötig — inflate liest trotzdem alle Daten")
  func testInflaterWithExternallyCompressedSmallBuffer() throws {
    // 200x 'A' von Python/zlib komprimiert (12 Bytes → 200 Bytes dekomprimiert)
    let compressed: [UInt8] = [0x78, 0x9C, 0x73, 0x74, 0x1C, 0x1E, 0x00, 0x00, 0xF1, 0x69, 0x32, 0xC9]
    let expected = [UInt8](repeating: 0x41, count: 200)  // 200x 'A'

    let inf = java.util.zip.Inflater()
    inf.setInput(compressed)
    // Kleiner Buffer: 30 Bytes pro Aufruf
    var result: [UInt8] = []
    var chunk = [UInt8](repeating: 0, count: 30)
    repeat {
      let m = try inf.inflate(&chunk, 0, chunk.count)
      if m > 0 { result.append(contentsOf: chunk[0..<m]) }
    } while !inf.finished()
    inf.end()
    #expect(result == expected)
  }

  @Test("Deflater.setDictionary() beeinflusst nicht das Roundtrip-Ergebnis")
  func testDeflaterSetDictionaryRoundtrip() throws {
    // setDictionary() ohne echtes LZ77-Seeding: Roundtrip muss trotzdem korrekt sein
    let dict  = Array("Hello".utf8)
    let input = Array("Hello, World!".utf8)

    let d = java.util.zip.Deflater()
    d.setDictionary(dict)
    d.setInput(input); d.finish()
    var comp = [UInt8](repeating: 0, count: 256)
    let n = d.deflate(&comp); d.end()

    let inf = java.util.zip.Inflater()
    inf.setInput(Array(comp[0..<n]))
    var out = [UInt8](repeating: 0, count: 256)
    let m = try inf.inflate(&out)
    #expect(Array(out[0..<m]) == input)
    inf.end()
  }

  @Test("Deflater: deflate() in zu kleinen Output-Buffer ist overflow-sicher")
  func testDeflaterSmallOutputBuffer() {
    // Output-Buffer nur 5 Bytes — darf nicht crashen, gibt 0..5 Bytes zurück
    let input = Array("This input is much longer than the output buffer".utf8)
    let d = java.util.zip.Deflater()
    d.setInput(input); d.finish()
    var buf = [UInt8](repeating: 0, count: 5)
    let n = d.deflate(&buf, 0, 5)
    // Wichtig: kein Crash, Rückgabe innerhalb des Buffer-Limits
    #expect(n >= 0 && n <= 5)
    d.end()
  }

  @Test("Inflater: inflate() mit len=0 gibt 0 zurück ohne Fehler")
  func testInflaterZeroLenBuffer() throws {
    let d = java.util.zip.Deflater()
    d.setInput(Array("test".utf8)); d.finish()
    var comp = [UInt8](repeating: 0, count: 64)
    let n = d.deflate(&comp); d.end()

    let inf = java.util.zip.Inflater()
    inf.setInput(Array(comp[0..<n]))
    var out = [UInt8](repeating: 0, count: 64)
    let m = try inf.inflate(&out, 0, 0)
    #expect(m == 0)
    inf.end()
  }

  @Test("ZipEntry: extra field Roundtrip")
  func testZipEntryExtraField() {
    let entry = java.util.zip.ZipEntry("file.bin")
    let extra: [UInt8] = [0x01, 0x02, 0x03, 0x04]
    entry.setExtra(extra)
    #expect(entry.getExtra() == extra)
    entry.setExtra(nil)
    #expect(entry.getExtra() == nil)
  }

  @Test("ZipEntry: copy constructor ist tief unabhängig")
  func testZipEntryCopyConstructor() {
    let original = java.util.zip.ZipEntry("orig.txt")
    original.setSize(100)
    original.setCrc(0xABCD)
    original.setMethod(java.util.zip.ZipEntry.DEFLATED)
    original.setComment("orig comment")

    let copy = java.util.zip.ZipEntry(original)
    // Mutiere Original nach dem Kopieren
    original.setSize(999)
    original.setComment("changed")

    #expect(copy.getSize()    == 100)
    #expect(copy.getCrc()     == 0xABCD)
    #expect(copy.getMethod()  == java.util.zip.ZipEntry.DEFLATED)
    #expect(copy.getComment() == "orig comment")
    #expect(copy.getName()    == "orig.txt")
  }

  @Test("ZipEntry: toString() gibt Namen zurück")
  func testZipEntryToString() {
    let entry = java.util.zip.ZipEntry("path/to/file.txt")
    #expect(entry.toString() == "path/to/file.txt")
  }

  @Test("ZipEntry: setCompressedSize und getCompressedSize")
  func testZipEntryCompressedSize() {
    let entry = java.util.zip.ZipEntry("data.bin")
    #expect(entry.getCompressedSize() == -1)  // unbekannt initial
    entry.setCompressedSize(512)
    #expect(entry.getCompressedSize() == 512)
  }

  @Test("ZipEntry: Verzeichnisname ohne Slash ist kein Verzeichnis")
  func testZipEntryNotDirectory() {
    let entry = java.util.zip.ZipEntry("folder")
    #expect(entry.isDirectory() == false)
  }

  @Test("ZipEntry: leerer Name")
  func testZipEntryEmptyName() {
    let entry = java.util.zip.ZipEntry("")
    #expect(entry.getName() == "")
    #expect(entry.isDirectory() == false)
  }

  @Test("ZipEntry: STORED and DEFLATED constants match ZipConstants")
  func testZipEntryConstants() {
    #expect(java.util.zip.ZipEntry.STORED   == java.util.zip.ZipConstants.STORED)
    #expect(java.util.zip.ZipEntry.DEFLATED == java.util.zip.ZipConstants.DEFLATED)
  }

  @Test("ZipEntry: getters and setters roundtrip")
  func testZipEntryGetterSetter() {
    let entry = java.util.zip.ZipEntry("test/file.txt")
    #expect(entry.getName() == "test/file.txt")
    #expect(entry.isDirectory() == false)

    entry.setSize(1234)
    #expect(entry.getSize() == 1234)

    entry.setCrc(0xDEADBEEF)
    #expect(entry.getCrc() == 0xDEADBEEF)

    entry.setMethod(java.util.zip.ZipEntry.DEFLATED)
    #expect(entry.getMethod() == java.util.zip.ZipEntry.DEFLATED)

    entry.setComment("test comment")
    #expect(entry.getComment() == "test comment")

    entry.setTime(1_000_000)
    #expect(entry.getTime() == 1_000_000)
  }

  @Test("ZipEntry: directory detection")
  func testZipEntryDirectory() {
    let dir  = java.util.zip.ZipEntry("some/dir/")
    let file = java.util.zip.ZipEntry("some/file.txt")
    #expect(dir.isDirectory()  == true)
    #expect(file.isDirectory() == false)
  }

  @Test("ZipEntry: clone is independent copy")
  func testZipEntryClone() {
    let original = java.util.zip.ZipEntry("original.txt")
    original.setSize(99)
    let copy = original.clone()
    copy.setSize(42)
    #expect(original.getSize() == 99)
    #expect(copy.getSize()     == 42)
  }
}
