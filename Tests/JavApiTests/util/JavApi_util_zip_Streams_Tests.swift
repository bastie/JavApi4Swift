/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_util_zip_Streams_Tests {

  // MARK: - Helper

  /// Compress bytes using DeflaterOutputStream, return compressed bytes.
  private func compressWithStream(_ input: [UInt8]) throws -> [UInt8] {
    let sink = java.io.ByteArrayOutputStream()
    let out  = java.util.zip.DeflaterOutputStream(sink)
    try out.write(input, 0, input.count)
    try out.finish()
    try out.close()
    return sink.toByteArray()
  }

  /// Decompress bytes using InflaterInputStream, return decompressed bytes.
  private func decompressWithStream(_ compressed: [UInt8]) throws -> [UInt8] {
    let src = java.io.ByteArrayInputStream(compressed)
    let in_ = java.util.zip.InflaterInputStream(src)
    var result: [UInt8] = []
    var buf = [UInt8](repeating: 0, count: 128)
    while true {
      let n = try in_.read(&buf, 0, buf.count)
      if n == -1 { break }
      result.append(contentsOf: buf[0..<n])
    }
    try in_.close()
    return result
  }

  // MARK: - DeflaterOutputStream / InflaterInputStream

  @Test("DeflaterOutputStream→InflaterInputStream: ASCII text roundtrip")
  func testStreamRoundtripText() throws {
    let input = Array("Hello from DeflaterOutputStream!".utf8)
    let compressed   = try compressWithStream(input)
    let decompressed = try decompressWithStream(compressed)
    #expect(decompressed == input)
  }

  @Test("DeflaterOutputStream→InflaterInputStream: leere Eingabe")
  func testStreamRoundtripEmpty() throws {
    let compressed   = try compressWithStream([])
    let decompressed = try decompressWithStream(compressed)
    #expect(decompressed == [])
  }

  @Test("DeflaterOutputStream→InflaterInputStream: repetitive Daten")
  func testStreamRoundtripRepetitive() throws {
    let input = [UInt8](repeating: 0xCC, count: 2000)
    let compressed   = try compressWithStream(input)
    let decompressed = try decompressWithStream(compressed)
    #expect(decompressed == input)
    // Komprimiert sollte deutlich kleiner sein
    #expect(compressed.count < input.count)
  }

  @Test("DeflaterOutputStream→InflaterInputStream: alle 256 Bytewerte")
  func testStreamRoundtripAllBytes() throws {
    let input = [UInt8](0...255)
    let compressed   = try compressWithStream(input)
    let decompressed = try decompressWithStream(compressed)
    #expect(decompressed == input)
  }

  @Test("DeflaterOutputStream: einzelne Bytes schreiben")
  func testDeflaterOutputStreamSingleBytes() throws {
    let input: [UInt8] = [0x41, 0x42, 0x43]  // ABC
    let sink = java.io.ByteArrayOutputStream()
    let out  = java.util.zip.DeflaterOutputStream(sink)
    for b in input { try out.write(Int(b)) }
    try out.finish()
    let decompressed = try decompressWithStream(sink.toByteArray())
    #expect(decompressed == input)
  }

  @Test("DeflaterOutputStream: close() ruft finish() auf")
  func testDeflaterOutputStreamClose() throws {
    let input = Array("Close test".utf8)
    let sink = java.io.ByteArrayOutputStream()
    let out  = java.util.zip.DeflaterOutputStream(sink)
    try out.write(input, 0, input.count)
    try out.close()  // sollte implizit finish() aufrufen
    let decompressed = try decompressWithStream(sink.toByteArray())
    #expect(decompressed == input)
  }

  @Test("InflaterInputStream: read() byte-für-byte")
  func testInflaterInputStreamSingleByteRead() throws {
    let input = Array("ABC".utf8)
    let compressed = try compressWithStream(input)
    let src = java.io.ByteArrayInputStream(compressed)
    let in_ = java.util.zip.InflaterInputStream(src)
    var result: [UInt8] = []
    while true {
      let b = try in_.read()
      if b == -1 { break }
      result.append(UInt8(b))
    }
    try in_.close()
    #expect(result == input)
  }

  @Test("InflaterInputStream: Referenz-zlib-Stream dekodieren")
  func testInflaterInputStreamFromKnownZlib() throws {
    // Python: zlib.compress(b"Hello, World!", level=6)
    let compressed: [UInt8] = [0x78, 0x9C, 0xF3, 0x48, 0xCD, 0xC9, 0xC9, 0xD7,
                                0x51, 0x08, 0xCF, 0x2F, 0xCA, 0x49, 0x51, 0x04,
                                0x00, 0x1F, 0x9E, 0x04, 0x6A]
    let expected = Array("Hello, World!".utf8)
    let decompressed = try decompressWithStream(compressed)
    #expect(decompressed == expected)
  }

  // MARK: - InflaterOutputStream / DeflaterInputStream

  @Test("DeflaterInputStream→InflaterOutputStream: ASCII text roundtrip")
  func testDeflaterInputInflaterOutputRoundtrip() throws {
    let input = Array("Stream pipeline test".utf8)

    // Compress via DeflaterInputStream
    let rawSrc   = java.io.ByteArrayInputStream(input)
    let defIn    = java.util.zip.DeflaterInputStream(rawSrc)
    var compressed: [UInt8] = []
    var tmp = [UInt8](repeating: 0, count: 64)
    while true {
      let n = try defIn.read(&tmp, 0, tmp.count)
      if n == -1 { break }
      compressed.append(contentsOf: tmp[0..<n])
    }
    try defIn.close()

    // Decompress via InflaterOutputStream
    let sink   = java.io.ByteArrayOutputStream()
    let infOut = java.util.zip.InflaterOutputStream(sink)
    try infOut.write(compressed, 0, compressed.count)
    try infOut.finish()
    try infOut.close()

    #expect(sink.toByteArray() == input)
  }

  @Test("InflaterOutputStream: komprimierte Bytes einschreiben, unkomprimiert lesen")
  func testInflaterOutputStreamWrite() throws {
    let input = Array("InflaterOutputStream test".utf8)
    let compressed = try compressWithStream(input)

    let sink   = java.io.ByteArrayOutputStream()
    let infOut = java.util.zip.InflaterOutputStream(sink)
    try infOut.write(compressed, 0, compressed.count)
    try infOut.finish()

    #expect(sink.toByteArray() == input)
    try infOut.close()
  }

  // MARK: - GZIPOutputStream / GZIPInputStream

  @Test("GZIP roundtrip: ASCII text")
  func testGZIPRoundtripText() throws {
    let input = Array("Hello, GZIP World!".utf8)

    let sink = java.io.ByteArrayOutputStream()
    let gz   = try java.util.zip.GZIPOutputStream(sink, 512)
    try gz.write(input, 0, input.count)
    try gz.finish()
    try gz.close()

    let gzipBytes = sink.toByteArray()
    let src  = java.io.ByteArrayInputStream(gzipBytes)
    let gunz = try java.util.zip.GZIPInputStream(src, 512)
    var result: [UInt8] = []
    var buf = [UInt8](repeating: 0, count: 256)
    while true {
      let n = try gunz.read(&buf, 0, buf.count)
      if n == -1 { break }
      result.append(contentsOf: buf[0..<n])
    }
    try gunz.close()
    #expect(result == input)
  }

  @Test("GZIP roundtrip: leere Eingabe")
  func testGZIPRoundtripEmpty() throws {
    let sink = java.io.ByteArrayOutputStream()
    let gz   = try java.util.zip.GZIPOutputStream(sink, 512)
    try gz.finish()
    try gz.close()

    let gzipBytes = sink.toByteArray()
    let src  = java.io.ByteArrayInputStream(gzipBytes)
    let gunz = try java.util.zip.GZIPInputStream(src, 512)
    var buf = [UInt8](repeating: 0, count: 64)
    let n = try gunz.read(&buf, 0, buf.count)
    try gunz.close()
    #expect(n == -1 || n == 0)
  }

  @Test("GZIP roundtrip: repetitive Daten (LZ77-Kompression)")
  func testGZIPRoundtripRepetitive() throws {
    let input = [UInt8](repeating: 0xBB, count: 5000)

    let sink = java.io.ByteArrayOutputStream()
    let gz   = try java.util.zip.GZIPOutputStream(sink, 512)
    try gz.write(input, 0, input.count)
    try gz.finish()
    let gzipBytes = sink.toByteArray()

    // GZIP muss kleiner als Original sein
    #expect(gzipBytes.count < input.count)

    let src  = java.io.ByteArrayInputStream(gzipBytes)
    let gunz = try java.util.zip.GZIPInputStream(src, 512)
    var result: [UInt8] = []
    var buf = [UInt8](repeating: 0, count: 256)
    while true {
      let n = try gunz.read(&buf, 0, buf.count)
      if n == -1 { break }
      result.append(contentsOf: buf[0..<n])
    }
    try gunz.close()
    #expect(result == input)
  }

  @Test("GZIPInputStream: dekodiert bekannten Python-GZIP-Stream")
  func testGZIPInputStreamKnownStream() throws {
    // Python: gzip.compress(b"Hello, GZIP!", mtime=0)
    let gzipBytes: [UInt8] = [0x1F, 0x8B, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00,
                               0x02, 0xFF, 0xF3, 0x48, 0xCD, 0xC9, 0xC9, 0xD7,
                               0x51, 0x70, 0x8F, 0xF2, 0x0C, 0x50, 0x04, 0x00,
                               0x46, 0xDF, 0x35, 0xDC, 0x0C, 0x00, 0x00, 0x00]
    let expected = Array("Hello, GZIP!".utf8)

    let src  = java.io.ByteArrayInputStream(gzipBytes)
    let gunz = try java.util.zip.GZIPInputStream(src, 512)
    var result: [UInt8] = []
    var buf = [UInt8](repeating: 0, count: 64)
    while true {
      let n = try gunz.read(&buf, 0, buf.count)
      if n == -1 { break }
      result.append(contentsOf: buf[0..<n])
    }
    try gunz.close()
    #expect(result == expected)
  }

  @Test("GZIPInputStream: ungültiger Magic ergibt ZipException")
  func testGZIPInputStreamBadMagic() {
    let notGzip: [UInt8] = [0x00, 0x01, 0x02, 0x03]
    let src = java.io.ByteArrayInputStream(notGzip)
    #expect(throws: java.util.zip.ZipException.self) {
      _ = try java.util.zip.GZIPInputStream(src, 512)
    }
  }

  @Test("GZIP: GZIP_MAGIC Konstante korrekt")
  func testGZIPMagicConstant() {
    #expect(java.util.zip.GZIPOutputStream.GZIP_MAGIC == 0x8b1f)
    #expect(java.util.zip.GZIPInputStream.GZIP_MAGIC  == 0x8b1f)
  }

  // MARK: - GZIPInputStream: CRC-Mismatch

  @Test("GZIPInputStream: manipulierter CRC-Trailer wirft ZipException")
  func testGZIPInputStreamCRCMismatch() throws {
    // Validen GZIP-Stream erzeugen, dann die letzten 8 Bytes (CRC+ISIZE) verfälschen
    let input = Array("CRC test".utf8)
    let sink = java.io.ByteArrayOutputStream()
    let gz   = try java.util.zip.GZIPOutputStream(sink, 512)
    try gz.write(input, 0, input.count)
    try gz.finish()
    var gzipBytes = sink.toByteArray()

    // GZIP-Trailer: letzte 8 Bytes = CRC32 (4 LE) + ISIZE (4 LE)
    // Wir verfälschen das erste CRC-Byte (Byte last-8)
    let last = gzipBytes.count
    gzipBytes[last - 8] ^= 0xFF  // CRC-32 kaputt machen

    let src  = java.io.ByteArrayInputStream(gzipBytes)
    let gunz = try java.util.zip.GZIPInputStream(src, 512)
    var buf  = [UInt8](repeating: 0, count: 256)
    #expect(throws: java.util.zip.ZipException.self) {
      // Lesen bis zum Ende triggert CRC-Prüfung
      while true {
        let n = try gunz.read(&buf, 0, buf.count)
        if n == -1 { break }
      }
    }
  }

  // MARK: - InflaterInputStream: close() ohne read()

  @Test("InflaterInputStream: close() ohne vorheriges read() wirft nicht")
  func testInflaterInputStreamCloseWithoutRead() throws {
    let input = Array("hello".utf8)
    let compressed = try compressWithStream(input)
    let src = java.io.ByteArrayInputStream(compressed)
    let in_ = java.util.zip.InflaterInputStream(src)
    // Direkt schließen ohne zu lesen
    try in_.close()
  }

  // MARK: - DeflaterOutputStream: kleiner interner Puffer

  @Test("DeflaterOutputStream→InflaterInputStream: Puffergröße 1 Byte")
  func testStreamRoundtripTinyBuffer() throws {
    let input = Array("tiny buffer test".utf8)
    // DeflaterOutputStream mit syncFlush=true und 1-Byte-Puffer wäre ideal,
    // aber wir testen durch chunk-weises Lesen mit 1-Byte-Buffer beim Lesen
    let sink = java.io.ByteArrayOutputStream()
    let out  = java.util.zip.DeflaterOutputStream(sink)
    // Byte-für-Byte schreiben
    for b in input { try out.write(Int(b)) }
    try out.finish()

    let compressed = sink.toByteArray()
    let src = java.io.ByteArrayInputStream(compressed)
    let in_ = java.util.zip.InflaterInputStream(src)
    // Byte-für-Byte lesen
    var result: [UInt8] = []
    while true {
      let b = try in_.read()
      if b == -1 { break }
      result.append(UInt8(b))
    }
    try in_.close()
    #expect(result == input)
  }

  // MARK: - GZIP alle 256 Bytewerte

  @Test("GZIP roundtrip: alle 256 Bytewerte")
  func testGZIPRoundtripAllBytes() throws {
    let input = [UInt8](0...255)

    let sink = java.io.ByteArrayOutputStream()
    let gz   = try java.util.zip.GZIPOutputStream(sink, 512)
    try gz.write(input, 0, input.count)
    try gz.finish()

    let src  = java.io.ByteArrayInputStream(sink.toByteArray())
    let gunz = try java.util.zip.GZIPInputStream(src, 512)
    var result: [UInt8] = []
    var buf = [UInt8](repeating: 0, count: 64)
    while true {
      let n = try gunz.read(&buf, 0, buf.count)
      if n == -1 { break }
      result.append(contentsOf: buf[0..<n])
    }
    try gunz.close()
    #expect(result == input)
  }

  // MARK: - GZIP optionale Header-Felder

  @Test("GZIPInputStream: dekodiert Stream mit FNAME-Feld")
  func testGZIPInputStreamWithFNAME() throws {
    // Python: gzip.GzipFile(filename="test.txt", mtime=0) → "Hello FNAME"
    let gzipBytes: [UInt8] = [
      0x1F, 0x8B, 0x08, 0x08, 0x00, 0x00, 0x00, 0x00, 0x02, 0xFF,
      0x74, 0x65, 0x73, 0x74, 0x2E, 0x74, 0x78, 0x74, 0x00,  // "test.txt\0"
      0xF3, 0x48, 0xCD, 0xC9, 0xC9, 0x57, 0x70, 0xF3, 0x73, 0xF4, 0x75, 0x05, 0x00,
      0x4B, 0x99, 0xC2, 0xE9, 0x0B, 0x00, 0x00, 0x00
    ]
    let src  = java.io.ByteArrayInputStream(gzipBytes)
    let gunz = try java.util.zip.GZIPInputStream(src, 512)
    var result: [UInt8] = []
    var buf = [UInt8](repeating: 0, count: 64)
    while true {
      let n = try gunz.read(&buf, 0, buf.count)
      if n == -1 { break }
      result.append(contentsOf: buf[0..<n])
    }
    try gunz.close()
    #expect(result == Array("Hello FNAME".utf8))
  }

  @Test("GZIPInputStream: dekodiert Stream mit FEXTRA-Feld")
  func testGZIPInputStreamWithFEXTRA() throws {
    // Manuell gebaut: FLG=0x04 (FEXTRA), 4 Extra-Bytes [0x01,0x02,0x03,0x04], Daten "Hello FEXTRA"
    let gzipBytes: [UInt8] = [
      0x1F, 0x8B, 0x08, 0x04, 0x00, 0x00, 0x00, 0x00, 0x02, 0xFF,
      0x04, 0x00, 0x01, 0x02, 0x03, 0x04,  // XLEN=4 + extra
      0xF3, 0x48, 0xCD, 0xC9, 0xC9, 0x57, 0x70, 0x73, 0x8D, 0x08, 0x09, 0x72, 0x04, 0x00,
      0x67, 0xF1, 0x8B, 0x7E, 0x0C, 0x00, 0x00, 0x00
    ]
    let src  = java.io.ByteArrayInputStream(gzipBytes)
    let gunz = try java.util.zip.GZIPInputStream(src, 512)
    var result: [UInt8] = []
    var buf = [UInt8](repeating: 0, count: 64)
    while true {
      let n = try gunz.read(&buf, 0, buf.count)
      if n == -1 { break }
      result.append(contentsOf: buf[0..<n])
    }
    try gunz.close()
    #expect(result == Array("Hello FEXTRA".utf8))
  }

  @Test("GZIPInputStream: dekodiert Stream mit FCOMMENT-Feld")
  func testGZIPInputStreamWithFCOMMENT() throws {
    // FLG=0x10 (FCOMMENT), Kommentar="my comment\0", Daten="Hello FCOMMENT"
    let gzipBytes: [UInt8] = [
      0x1F, 0x8B, 0x08, 0x10, 0x00, 0x00, 0x00, 0x00, 0x02, 0xFF,
      0x6D, 0x79, 0x20, 0x63, 0x6F, 0x6D, 0x6D, 0x65, 0x6E, 0x74, 0x00,  // "my comment\0"
      0xF3, 0x48, 0xCD, 0xC9, 0xC9, 0x57, 0x70, 0x73, 0xF6, 0xF7, 0xF5, 0x75, 0xF5, 0x0B, 0x01, 0x00,
      0x07, 0xB9, 0xA3, 0xBC, 0x0E, 0x00, 0x00, 0x00
    ]
    let src  = java.io.ByteArrayInputStream(gzipBytes)
    let gunz = try java.util.zip.GZIPInputStream(src, 512)
    var result: [UInt8] = []
    var buf = [UInt8](repeating: 0, count: 64)
    while true {
      let n = try gunz.read(&buf, 0, buf.count)
      if n == -1 { break }
      result.append(contentsOf: buf[0..<n])
    }
    try gunz.close()
    #expect(result == Array("Hello FCOMMENT".utf8))
  }

  @Test("GZIPInputStream: dekodiert Stream mit FHCRC-Feld")
  func testGZIPInputStreamWithFHCRC() throws {
    // FLG=0x02 (FHCRC), 2-Byte Header-CRC, Daten="Hello FHCRC"
    let gzipBytes: [UInt8] = [
      0x1F, 0x8B, 0x08, 0x02, 0x00, 0x00, 0x00, 0x00, 0x02, 0xFF,
      0x12, 0xAB,  // CRC16 des Headers
      0xF3, 0x48, 0xCD, 0xC9, 0xC9, 0x57, 0x70, 0xF3, 0x70, 0x0E, 0x72, 0x06, 0x00,
      0x52, 0xB9, 0x14, 0xEB, 0x0B, 0x00, 0x00, 0x00
    ]
    let src  = java.io.ByteArrayInputStream(gzipBytes)
    let gunz = try java.util.zip.GZIPInputStream(src, 512)
    var result: [UInt8] = []
    var buf = [UInt8](repeating: 0, count: 64)
    while true {
      let n = try gunz.read(&buf, 0, buf.count)
      if n == -1 { break }
      result.append(contentsOf: buf[0..<n])
    }
    try gunz.close()
    #expect(result == Array("Hello FHCRC".utf8))
  }

  // MARK: - GZIP Trailer-Fehler

  @Test("GZIPInputStream: manipulierter ISIZE-Trailer wirft ZipException")
  func testGZIPInputStreamISIZEMismatch() throws {
    // Validen GZIP-Stream erzeugen, dann letztes ISIZE-Byte verfälschen
    let input = Array("ISIZE test".utf8)
    let sink = java.io.ByteArrayOutputStream()
    let gz   = try java.util.zip.GZIPOutputStream(sink, 512)
    try gz.write(input, 0, input.count)
    try gz.finish()
    var gzipBytes = sink.toByteArray()
    // Letztes Byte = letztes ISIZE-Byte
    gzipBytes[gzipBytes.count - 1] ^= 0xFF
    let src  = java.io.ByteArrayInputStream(gzipBytes)
    let gunz = try java.util.zip.GZIPInputStream(src, 512)
    var buf  = [UInt8](repeating: 0, count: 256)
    #expect(throws: java.util.zip.ZipException.self) {
      while true {
        let n = try gunz.read(&buf, 0, buf.count)
        if n == -1 { break }
      }
    }
  }

  // MARK: - Streams nach close()

  @Test("Lesen aus geschlossenem InflaterInputStream wirft IOException")
  func testInflaterInputStreamReadAfterClose() throws {
    let input = Array("hello".utf8)
    let compressed = try compressWithStream(input)
    let src = java.io.ByteArrayInputStream(compressed)
    let in_ = java.util.zip.InflaterInputStream(src)
    try in_.close()
    var buf = [UInt8](repeating: 0, count: 16)
    #expect(throws: java.io.IOException.self) {
      _ = try in_.read(&buf, 0, buf.count)
    }
  }

  @Test("Schreiben in geschlossenen DeflaterOutputStream wirft IOException")
  func testDeflaterOutputStreamWriteAfterClose() throws {
    let sink = java.io.ByteArrayOutputStream()
    let out  = java.util.zip.DeflaterOutputStream(sink)
    try out.close()
    #expect(throws: java.io.IOException.self) {
      try out.write([0x41], 0, 1)
    }
  }

  @Test("Schreiben in geschlossenen GZIPOutputStream wirft IOException")
  func testGZIPOutputStreamWriteAfterClose() throws {
    let sink = java.io.ByteArrayOutputStream()
    let gz   = try java.util.zip.GZIPOutputStream(sink, 512)
    try gz.close()
    #expect(throws: java.io.IOException.self) {
      try gz.write([0x41], 0, 1)
    }
  }

  // MARK: - Deflater.setInput mit offset

  @Test("Deflater.setInput(buf, off, len) mit off>0 komprimiert korrekt")
  func testDeflaterSetInputWithOffset() throws {
    // Puffer: "xxHELLO" — setInput mit offset=2, len=5 soll nur "HELLO" komprimieren
    let padded = Array("xxHELLO".utf8)
    let d = java.util.zip.Deflater()
    d.setInput(padded, 2, 5)
    d.finish()
    var comp = [UInt8](repeating: 0, count: 64)
    let n = d.deflate(&comp)
    d.end()

    let inf = java.util.zip.Inflater()
    inf.setInput(Array(comp[0..<n]))
    var out = [UInt8](repeating: 0, count: 64)
    let m = try inf.inflate(&out)
    inf.end()
    #expect(Array(out[0..<m]) == Array("HELLO".utf8))
  }

  @Test("Inflater.setInput(buf, off, len) mit off>0 dekomprimiert korrekt")
  func testInflaterSetInputWithOffset() throws {
    // Komprimierten Stream mit Padding vorne übergeben
    let input = Array("HELLO".utf8)
    let d = java.util.zip.Deflater()
    d.setInput(input); d.finish()
    var comp = [UInt8](repeating: 0, count: 64)
    let n = d.deflate(&comp); d.end()

    // Padding vor komprimierten Daten
    let padded = [UInt8](repeating: 0xAA, count: 3) + Array(comp[0..<n])
    let inf = java.util.zip.Inflater()
    inf.setInput(padded, 3, n)
    var out = [UInt8](repeating: 0, count: 64)
    let m = try inf.inflate(&out)
    inf.end()
    #expect(Array(out[0..<m]) == input)
  }

  // MARK: - GZIPOutputStream.write(int)

  @Test("GZIPOutputStream: write(int) einzelnes Byte")
  func testGZIPOutputStreamWriteSingleByte() throws {
    let input: [UInt8] = [0x42, 0x43, 0x44]  // BCD
    let sink = java.io.ByteArrayOutputStream()
    let gz   = try java.util.zip.GZIPOutputStream(sink, 512)
    for b in input { try gz.write(Int(b)) }
    try gz.finish()

    let src  = java.io.ByteArrayInputStream(sink.toByteArray())
    let gunz = try java.util.zip.GZIPInputStream(src, 512)
    var result: [UInt8] = []
    var buf = [UInt8](repeating: 0, count: 64)
    while true {
      let n = try gunz.read(&buf, 0, buf.count)
      if n == -1 { break }
      result.append(contentsOf: buf[0..<n])
    }
    try gunz.close()
    #expect(result == input)
  }

  // MARK: - Deflater level 3

  @Test("Roundtrip: Deflater level=3 (mittlere Kompression)")
  func testRoundtripLevel3() throws {
    let input = Array("Mittlere Kompression — level 3".utf8)
    let d = java.util.zip.Deflater(3, false)
    d.setInput(input); d.finish()
    var comp = [UInt8](repeating: 0, count: 256)
    let n = d.deflate(&comp); d.end()

    let inf = java.util.zip.Inflater()
    inf.setInput(Array(comp[0..<n]))
    var out = [UInt8](repeating: 0, count: 256)
    let m = try inf.inflate(&out); inf.end()
    #expect(Array(out[0..<m]) == input)
  }

  // MARK: - ZipOutputStream finish() Idempotenz

  @Test("ZipOutputStream.finish() zweimal aufrufen ist idempotent")
  func testZipOutputStreamFinishIdempotent() throws {
    let sink = java.io.ByteArrayOutputStream()
    let zos  = java.util.zip.ZipOutputStream(sink)
    try zos.putNextEntry(java.util.zip.ZipEntry("f.txt"))
    try zos.write(Array("hi".utf8), 0, 2)
    try zos.closeEntry()
    try zos.finish()
    let size1 = sink.toByteArray().count
    try zos.finish()  // zweites finish() darf nichts hinzufügen
    let size2 = sink.toByteArray().count
    #expect(size1 == size2)
  }

  // MARK: - ZipInputStream: Unicode-Namen

  @Test("ZIP roundtrip: Unicode-Dateiname (Umlaute)")
  func testZipRoundtripUnicodeName() throws {
    let name  = "Ärger_mit_Ü.txt"
    let input = Array("Inhalt mit Umlauten: äöü".utf8)

    let sink = java.io.ByteArrayOutputStream()
    let zos  = java.util.zip.ZipOutputStream(sink)
    let e = java.util.zip.ZipEntry(name)
    try zos.putNextEntry(e)
    try zos.write(input, 0, input.count)
    try zos.closeEntry()
    try zos.finish()

    let src = java.io.ByteArrayInputStream(sink.toByteArray())
    let zis = java.util.zip.ZipInputStream(src)
    let entry = try zis.getNextEntry()
    #expect(entry?.getName() == name)
    var result: [UInt8] = []
    var buf = [UInt8](repeating: 0, count: 64)
    while true { let n = try zis.read(&buf, 0, buf.count); if n == -1 { break }; result.append(contentsOf: buf[0..<n]) }
    try zis.close()
    #expect(result == input)
  }

  // MARK: - Adler32/CRC32C offset

  @Test("Adler32: update mit offset > 0 korrekt")
  func testAdler32WithOffset() {
    let chk1 = java.util.zip.Adler32()
    chk1.update(Array("HELLO".utf8), 0, 5)
    let chk2 = java.util.zip.Adler32()
    chk2.update(Array("xxHELLO".utf8), 2, 5)
    #expect(chk1.getValue() == chk2.getValue())
  }

  @Test("CRC32C: update mit offset > 0 korrekt")
  func testCRC32CWithOffset() {
    let chk1 = java.util.zip.CRC32C()
    chk1.update(Array("HELLO".utf8), 0, 5)
    let chk2 = java.util.zip.CRC32C()
    chk2.update(Array("xxHELLO".utf8), 2, 5)
    #expect(chk1.getValue() == chk2.getValue())
  }
}
