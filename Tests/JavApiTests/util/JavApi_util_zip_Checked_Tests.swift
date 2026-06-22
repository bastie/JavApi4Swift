/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_util_zip_Checked_Tests {

  // MARK: - CheckedInputStream

  @Test("CheckedInputStream: CRC32 nach read() entspricht direktem CRC32")
  func testCheckedInputStreamCRC32() throws {
    let data  = Array("Hello, World!".utf8)
    let raw   = java.io.ByteArrayInputStream(data)
    let crc   = java.util.zip.CRC32()
    let cis   = java.util.zip.CheckedInputStream(raw, crc)

    // Alles lesen
    var buf = [UInt8](repeating: 0, count: 64)
    let n   = try cis.read(&buf, 0, buf.count)
    #expect(n == data.count)

    // Referenzwert direkt berechnen
    let ref = java.util.zip.CRC32()
    ref.update(data, 0, data.count)

    #expect(cis.getChecksum().getValue() == ref.getValue())
  }

  @Test("CheckedInputStream: Adler32 nach byte-weisem read()")
  func testCheckedInputStreamAdler32ByteByByte() throws {
    let data = Array("HELLO".utf8)
    let raw  = java.io.ByteArrayInputStream(data)
    let chk  = java.util.zip.Adler32()
    let cis  = java.util.zip.CheckedInputStream(raw, chk)

    // Byte für Byte lesen
    var read = [Int]()
    while true {
      let b = try cis.read()
      if b == -1 { break }
      read.append(b)
    }
    #expect(read.count == data.count)

    let ref = java.util.zip.Adler32()
    ref.update(data, 0, data.count)
    #expect(cis.getChecksum().getValue() == ref.getValue())
  }

  @Test("CheckedInputStream: skip() berücksichtigt übersprungene Bytes im Checksum")
  func testCheckedInputStreamSkip() throws {
    // Daten: "AABBB" — wir lesen "AA", überspringen dann "BB", lesen "B"
    let data = Array("AABBB".utf8)
    let raw  = java.io.ByteArrayInputStream(data)
    let crc  = java.util.zip.CRC32()
    let cis  = java.util.zip.CheckedInputStream(raw, crc)

    // 2 Bytes lesen
    var buf = [UInt8](repeating: 0, count: 2)
    _ = try cis.read(&buf, 0, 2)
    // 2 Bytes überspringen
    let skipped = try cis.skip(2)
    #expect(skipped == 2)
    // Letztes Byte lesen
    _ = try cis.read(&buf, 0, 1)

    // Referenz: alle 5 Bytes in einem Zug
    let ref = java.util.zip.CRC32()
    ref.update(data, 0, data.count)
    #expect(cis.getChecksum().getValue() == ref.getValue())
  }

  @Test("CheckedInputStream: EOF gibt -1 zurück und Checksum bleibt korrekt")
  func testCheckedInputStreamEOF() throws {
    let data = Array("X".utf8)
    let raw  = java.io.ByteArrayInputStream(data)
    let crc  = java.util.zip.CRC32()
    let cis  = java.util.zip.CheckedInputStream(raw, crc)

    var buf = [UInt8](repeating: 0, count: 4)
    _ = try cis.read(&buf, 0, 4)
    let eof = try cis.read(&buf, 0, 4)
    #expect(eof == -1)

    let ref = java.util.zip.CRC32()
    ref.update(data, 0, data.count)
    #expect(cis.getChecksum().getValue() == ref.getValue())
  }

  // MARK: - CheckedOutputStream

  @Test("CheckedOutputStream: CRC32 nach write() entspricht direktem CRC32")
  func testCheckedOutputStreamCRC32() throws {
    let data = Array("Hello, World!".utf8)
    let sink = java.io.ByteArrayOutputStream()
    let crc  = java.util.zip.CRC32()
    let cos  = java.util.zip.CheckedOutputStream(sink, crc)

    try cos.write(data, 0, data.count)

    // Bytes wurden korrekt weitergeleitet
    #expect(sink.toByteArray() == data)

    let ref = java.util.zip.CRC32()
    ref.update(data, 0, data.count)
    #expect(cos.getChecksum().getValue() == ref.getValue())
  }

  @Test("CheckedOutputStream: Adler32 nach byte-weisem write(Int)")
  func testCheckedOutputStreamAdler32ByteByByte() throws {
    let data = Array("HELLO".utf8)
    let sink = java.io.ByteArrayOutputStream()
    let chk  = java.util.zip.Adler32()
    let cos  = java.util.zip.CheckedOutputStream(sink, chk)

    for b in data {
      try cos.write(Int(b))
    }

    let ref = java.util.zip.Adler32()
    ref.update(data, 0, data.count)
    #expect(cos.getChecksum().getValue() == ref.getValue())
  }

  // MARK: - Roundtrip

  @Test("CheckedOutputStream + CheckedInputStream: Roundtrip mit CRC32 stimmt überein")
  func testCheckedRoundtrip() throws {
    let data = Array("Roundtrip test 1234".utf8)

    // Schreiben
    let sink   = java.io.ByteArrayOutputStream()
    let outCRC = java.util.zip.CRC32()
    let cos    = java.util.zip.CheckedOutputStream(sink, outCRC)
    try cos.write(data, 0, data.count)
    let writtenCRC = cos.getChecksum().getValue()

    // Lesen
    let src   = java.io.ByteArrayInputStream(sink.toByteArray())
    let inCRC = java.util.zip.CRC32()
    let cis   = java.util.zip.CheckedInputStream(src, inCRC)
    var buf   = [UInt8](repeating: 0, count: 64)
    _ = try cis.read(&buf, 0, buf.count)
    let readCRC = cis.getChecksum().getValue()

    #expect(writtenCRC == readCRC)
  }
}
