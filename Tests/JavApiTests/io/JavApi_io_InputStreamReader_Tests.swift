/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
import Foundation
@testable import JavApi

struct JavApi_io_InputStreamReader_Tests {

  // MARK: - Initialisierung / Encoding

  @Test("Default encoding ist UTF-8")
  func defaultEncodingIsUTF8() throws {
    let bis = java.io.ByteArrayInputStream([])
    let isr = java.io.InputStreamReader(bis)
    #expect(isr.getEncoding() == "UTF-8")
  }

  @Test("Bekannte Charset-Namen werden akzeptiert")
  func knownCharsetNames() throws {
    let charsets = ["UTF-8", "UTF-16", "UTF-16BE", "UTF-16LE", "ISO-8859-1", "US-ASCII"]
    for name in charsets {
      let bis = java.io.ByteArrayInputStream([])
      let isr = try java.io.InputStreamReader(bis, name)
      #expect(isr.getEncoding() == name)
    }
  }

  @Test("Alias-Charset-Namen werden normalisiert")
  func aliasCharsetNames() throws {
    let bis1 = java.io.ByteArrayInputStream([])
    let isr1 = try java.io.InputStreamReader(bis1, "UTF8")
    #expect(isr1.getEncoding() == "UTF-8")

    let bis2 = java.io.ByteArrayInputStream([])
    let isr2 = try java.io.InputStreamReader(bis2, "LATIN-1")
    #expect(isr2.getEncoding() == "ISO-8859-1")

    let bis3 = java.io.ByteArrayInputStream([])
    let isr3 = try java.io.InputStreamReader(bis3, "ASCII")
    #expect(isr3.getEncoding() == "US-ASCII")
  }

  @Test("Unbekannter Charset-Name wirft UnsupportedEncodingException")
  func unknownCharsetThrows() throws {
    let bis = java.io.ByteArrayInputStream([])
    #expect(throws: (any Error).self) {
      _ = try java.io.InputStreamReader(bis, "KLINGON-8")
    }
  }

  // MARK: - read()

  @Test("read() liest ASCII-Zeichen korrekt")
  func readAsciiChars() throws {
    let bytes: [UInt8] = Array("Hello".utf8)
    let bis = java.io.ByteArrayInputStream(bytes)
    let isr = java.io.InputStreamReader(bis)

    #expect(try isr.read() == Int(Character("H").unicodeScalars.first!.value))
    #expect(try isr.read() == Int(Character("e").unicodeScalars.first!.value))
    #expect(try isr.read() == Int(Character("l").unicodeScalars.first!.value))
    #expect(try isr.read() == Int(Character("l").unicodeScalars.first!.value))
    #expect(try isr.read() == Int(Character("o").unicodeScalars.first!.value))
  }

  @Test("read() gibt -1 bei leerem Stream zurück")
  func readReturnsMinusOneOnEOF() throws {
    let bis = java.io.ByteArrayInputStream([])
    let isr = java.io.InputStreamReader(bis)
    #expect(try isr.read() == -1)
  }

  @Test("read() dekodiert UTF-8 Multi-Byte-Zeichen korrekt")
  func readMultiByteUTF8() throws {
    let str = "Héllo"
    let bytes = Array(str.utf8)
    let bis = java.io.ByteArrayInputStream(bytes)
    let isr = java.io.InputStreamReader(bis)

    var result = ""
    var ch = try isr.read()
    while ch != -1 {
      if let scalar = Unicode.Scalar(ch) {
        result.append(Character(scalar))
      }
      ch = try isr.read()
    }
    #expect(result == str)
  }

  // MARK: - read(buf, offset, count)

  @Test("read(buf, offset, count) befüllt den Puffer korrekt")
  func readIntoBuffer() throws {
    let bytes: [UInt8] = Array("ABCDE".utf8)
    let bis = java.io.ByteArrayInputStream(bytes)
    let isr = java.io.InputStreamReader(bis)

    var buf = [Character](repeating: "\0", count: 5)
    let n = try isr.read(&buf, 0, 5)
    #expect(n == 5)
    #expect(buf[0] == "A")
    #expect(buf[4] == "E")
  }

  @Test("read(buf, offset, count) mit offset")
  func readIntoBufferWithOffset() throws {
    let bytes: [UInt8] = Array("AB".utf8)
    let bis = java.io.ByteArrayInputStream(bytes)
    let isr = java.io.InputStreamReader(bis)

    var buf = [Character](repeating: "X", count: 4)
    let n = try isr.read(&buf, 2, 2)
    #expect(n == 2)
    #expect(buf[0] == "X")  // unberührt
    #expect(buf[2] == "A")
    #expect(buf[3] == "B")
  }

  @Test("read(buf, offset, count) gibt -1 bei EOF zurück")
  func readIntoBufferEOF() throws {
    let bis = java.io.ByteArrayInputStream([])
    let isr = java.io.InputStreamReader(bis)
    var buf = [Character](repeating: "\0", count: 4)
    #expect(try isr.read(&buf, 0, 4) == -1)
  }

  // MARK: - ready()

  @Test("ready() gibt true zurück wenn Bytes verfügbar")
  func readyWithData() throws {
    let bytes: [UInt8] = Array("X".utf8)
    let bis = java.io.ByteArrayInputStream(bytes)
    let isr = java.io.InputStreamReader(bis)
    #expect(try isr.ready() == true)
  }

  @Test("ready() gibt false zurück bei leerem Stream")
  func readyOnEmptyStream() throws {
    let bis = java.io.ByteArrayInputStream([])
    let isr = java.io.InputStreamReader(bis)
    #expect(try isr.ready() == false)
  }

  // MARK: - close()

  @Test("Nach close() wirft read() IOException")
  func readAfterCloseThrows() throws {
    let bis = java.io.ByteArrayInputStream(Array("hi".utf8))
    let isr = java.io.InputStreamReader(bis)
    try isr.close()
    #expect(throws: (any Error).self) {
      _ = try isr.read()
    }
  }

  @Test("close() ist idempotent")
  func closeIsIdempotent() throws {
    let bis = java.io.ByteArrayInputStream([])
    let isr = java.io.InputStreamReader(bis)
    try isr.close()
    try isr.close()  // kein Fehler
  }
}

struct JavApi_io_OutputStreamWriter_Tests {

  // MARK: - Initialisierung / Encoding

  @Test("Default encoding ist UTF-8")
  func defaultEncodingIsUTF8() throws {
    let bos = java.io.ByteArrayOutputStream()
    let osw = java.io.OutputStreamWriter(bos)
    #expect(osw.getEncoding() == "UTF-8")
  }

  @Test("Bekannte Charset-Namen werden akzeptiert")
  func knownCharsetNames() throws {
    let charsets = ["UTF-8", "UTF-16", "UTF-16BE", "UTF-16LE", "ISO-8859-1", "US-ASCII"]
    for name in charsets {
      let bos = java.io.ByteArrayOutputStream()
      let osw = try java.io.OutputStreamWriter(bos, name)
      #expect(osw.getEncoding() == name)
    }
  }

  @Test("Unbekannter Charset-Name wirft UnsupportedEncodingException")
  func unknownCharsetThrows() throws {
    let bos = java.io.ByteArrayOutputStream()
    #expect(throws: (any Error).self) {
      _ = try java.io.OutputStreamWriter(bos, "KLINGON-8")
    }
  }

  // MARK: - write(String)

  @Test("write(String) schreibt UTF-8 Bytes korrekt")
  func writeStringUTF8() throws {
    let bos = java.io.ByteArrayOutputStream()
    let osw = java.io.OutputStreamWriter(bos)
    try osw.write("Hello")
    try osw.flush()
    let bytes = bos.toByteArray()
    #expect(bytes == Array("Hello".utf8))
  }

  @Test("write(String) kodiert Multi-Byte UTF-8 Zeichen korrekt")
  func writeMultiByteUTF8() throws {
    let str = "Héllo"
    let bos = java.io.ByteArrayOutputStream()
    let osw = java.io.OutputStreamWriter(bos)
    try osw.write(str)
    try osw.flush()
    let bytes = bos.toByteArray()
    #expect(bytes == Array(str.utf8))
  }

  // MARK: - write(String, offset, len)

  @Test("write(String, offset, len) schreibt Teilstring")
  func writeStringWithOffsetAndLen() throws {
    let bos = java.io.ByteArrayOutputStream()
    let osw = java.io.OutputStreamWriter(bos)
    try osw.write("Hello World", 6, 5)
    try osw.flush()
    let bytes = bos.toByteArray()
    #expect(bytes == Array("World".utf8))
  }

  // MARK: - write([Character], offset, len)

  @Test("write([Character], offset, len) schreibt Zeichen-Array")
  func writeCharArray() throws {
    let bos = java.io.ByteArrayOutputStream()
    let osw = java.io.OutputStreamWriter(bos)
    let chars: [Character] = ["A", "B", "C", "D", "E"]
    try osw.write(chars, 1, 3)
    try osw.flush()
    let bytes = bos.toByteArray()
    #expect(bytes == Array("BCD".utf8))
  }

  // MARK: - write(Character)

  @Test("write(Character) schreibt einzelnes Zeichen")
  func writeSingleChar() throws {
    let bos = java.io.ByteArrayOutputStream()
    let osw = java.io.OutputStreamWriter(bos)
    try osw.write("Z" as Character)
    try osw.flush()
    let bytes = bos.toByteArray()
    #expect(bytes == Array("Z".utf8))
  }

  // MARK: - Roundtrip mit InputStreamReader

  @Test("OutputStreamWriter → InputStreamReader Roundtrip")
  func roundtrip() throws {
    let original = "Grüße aus Swift"
    let bos = java.io.ByteArrayOutputStream()
    let osw = java.io.OutputStreamWriter(bos)
    try osw.write(original)
    try osw.flush()

    let bytes = bos.toByteArray()
    let bis = java.io.ByteArrayInputStream(bytes)
    let isr = java.io.InputStreamReader(bis)

    var result = ""
    var ch = try isr.read()
    while ch != -1 {
      if let scalar = Unicode.Scalar(ch) {
        result.append(Character(scalar))
      }
      ch = try isr.read()
    }
    #expect(result == original)
  }

  // MARK: - close()

  @Test("Nach close() wirft write() IOException")
  func writeAfterCloseThrows() throws {
    let bos = java.io.ByteArrayOutputStream()
    let osw = java.io.OutputStreamWriter(bos)
    try osw.close()
    #expect(throws: (any Error).self) {
      try osw.write("x")
    }
  }

  @Test("close() ist idempotent")
  func closeIsIdempotent() throws {
    let bos = java.io.ByteArrayOutputStream()
    let osw = java.io.OutputStreamWriter(bos)
    try osw.close()
    try osw.close()  // kein Fehler
  }
}
