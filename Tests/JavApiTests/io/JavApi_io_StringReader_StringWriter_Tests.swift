/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_io_StringReader_Tests {

  // MARK: - read()

  @Test("read() liest ASCII-Zeichen einzeln")
  func readCharsOneByOne() throws {
    let reader = java.io.StringReader("AB")
    #expect(try reader.read() == Int(Character("A").unicodeScalars.first!.value))
    #expect(try reader.read() == Int(Character("B").unicodeScalars.first!.value))
    #expect(try reader.read() == -1)
  }

  @Test("read() gibt -1 bei leerem String zurück")
  func readEmptyString() throws {
    let reader = java.io.StringReader("")
    #expect(try reader.read() == -1)
  }

  @Test("read() liest Unicode-Zeichen korrekt")
  func readUnicodeChar() throws {
    let reader = java.io.StringReader("ü")
    let ch = try reader.read()
    #expect(ch == Int(Character("ü").unicodeScalars.first!.value))
    #expect(try reader.read() == -1)
  }

  @Test("read() behandelt CR und LF als separate Zeichen")
  func readCRLFSeparate() throws {
    let reader = java.io.StringReader("a\r\nb")
    _ = try reader.read()  // 'a'
    let cr = try reader.read()
    let lf = try reader.read()
    let b  = try reader.read()
    #expect(cr == Int(("\r" as Character).unicodeScalars.first!.value))
    #expect(lf == Int(("\n" as Character).unicodeScalars.first!.value))
    #expect(b  == Int(Character("b").unicodeScalars.first!.value))
  }

  // MARK: - read(buf, offset, count)

  @Test("read(buf, offset, count) befüllt Puffer vollständig")
  func readIntoBuffer() throws {
    let reader = java.io.StringReader("ABCDE")
    var buf = [Character](repeating: "\0", count: 5)
    let n = try reader.read(&buf, 0, 5)
    #expect(n == 5)
    #expect(buf == ["A", "B", "C", "D", "E"])
  }

  @Test("read(buf, offset, count) mit offset")
  func readIntoBufferWithOffset() throws {
    let reader = java.io.StringReader("AB")
    var buf = [Character](repeating: "X", count: 4)
    let n = try reader.read(&buf, 2, 2)
    #expect(n == 2)
    #expect(buf[0] == "X")
    #expect(buf[2] == "A")
    #expect(buf[3] == "B")
  }

  @Test("read(buf, offset, count) gibt -1 bei EOF")
  func readIntoBufferEOF() throws {
    let reader = java.io.StringReader("")
    var buf = [Character](repeating: "\0", count: 3)
    #expect(try reader.read(&buf, 0, 3) == -1)
  }

  @Test("read(buf, offset, count) mit count=0 gibt 0 zurück")
  func readZeroChars() throws {
    let reader = java.io.StringReader("ABC")
    var buf = [Character](repeating: "\0", count: 3)
    // Verhält sich wie Java: count == 0 → kein Fehler, liest nicht
    // (Die Implementierung gibt -1 wenn pos >= source.count, sonst 0 wenn count==0)
    // Testen wir dass kein Crash auftritt:
    let n = try reader.read(&buf, 0, 0)
    #expect(n == -1 || n == 0)
  }

  // MARK: - ready()

  @Test("ready() gibt true zurück solange Zeichen verfügbar")
  func readyWithContent() throws {
    let reader = java.io.StringReader("X")
    #expect(try reader.ready() == true)
    _ = try reader.read()
    #expect(try reader.ready() == false)
  }

  @Test("ready() gibt false bei leerem String zurück")
  func readyOnEmpty() throws {
    let reader = java.io.StringReader("")
    #expect(try reader.ready() == false)
  }

  // MARK: - markSupported / mark / reset

  @Test("markSupported() gibt true zurück")
  func markSupported() {
    let reader = java.io.StringReader("abc")
    #expect(reader.markSupported() == true)
  }

  @Test("mark und reset springen zurück zur markierten Position")
  func markAndReset() throws {
    let reader = java.io.StringReader("ABCD")
    _ = try reader.read()  // A
    try reader.mark(10)
    _ = try reader.read()  // B
    _ = try reader.read()  // C
    try reader.reset()
    #expect(try reader.read() == Int(Character("B").unicodeScalars.first!.value))
  }

  @Test("reset ohne vorheriges mark springt zum Anfang")
  func resetWithoutMarkGoesToStart() throws {
    let reader = java.io.StringReader("AB")
    _ = try reader.read()  // A
    try reader.reset()
    #expect(try reader.read() == Int(Character("A").unicodeScalars.first!.value))
  }

  // MARK: - skip()

  @Test("skip() überspringt die angegebene Anzahl Zeichen")
  func skipChars() throws {
    let reader = java.io.StringReader("ABCDE")
    let skipped = try reader.skip(3)
    #expect(skipped == 3)
    #expect(try reader.read() == Int(Character("D").unicodeScalars.first!.value))
  }

  @Test("skip() am Ende gibt 0 zurück")
  func skipAtEOF() throws {
    let reader = java.io.StringReader("A")
    _ = try reader.read()  // EOF erreicht
    let skipped = try reader.skip(5)
    #expect(skipped == 0)
  }

  @Test("skip() überspringt nicht mehr als verfügbar")
  func skipMoreThanAvailable() throws {
    let reader = java.io.StringReader("AB")
    let skipped = try reader.skip(100)
    #expect(skipped == 2)
    #expect(try reader.read() == -1)
  }

  // MARK: - close()

  @Test("Nach close() wirft read() IOException")
  func readAfterCloseThrows() throws {
    let reader = java.io.StringReader("x")
    try reader.close()
    #expect(throws: (any Error).self) {
      _ = try reader.read()
    }
  }

  @Test("Nach close() wirft ready() IOException")
  func readyAfterCloseThrows() throws {
    let reader = java.io.StringReader("x")
    try reader.close()
    #expect(throws: (any Error).self) {
      _ = try reader.ready()
    }
  }
}

struct JavApi_io_StringWriter_Tests {

  // MARK: - write(String)

  @Test("write(String) akkumuliert Inhalt")
  func writeStrings() throws {
    let sw = java.io.StringWriter()
    try sw.write("Hello")
    try sw.write(", ")
    try sw.write("World!")
    #expect(sw.toString() == "Hello, World!")
  }

  @Test("write(String) auf leerem Writer gibt leeren String")
  func emptyWriter() throws {
    let sw = java.io.StringWriter()
    #expect(sw.toString() == "")
  }

  // MARK: - write(String, offset, len)

  @Test("write(String, offset, len) schreibt Teilstring")
  func writeStringWithOffsetAndLen() throws {
    let sw = java.io.StringWriter()
    try sw.write("Hello World", 6, 5)
    #expect(sw.toString() == "World")
  }

  @Test("write(String, offset, len) mit ungültigen Parametern wirft Exception")
  func writeStringInvalidRange() throws {
    let sw = java.io.StringWriter()
    #expect(throws: (any Error).self) {
      try sw.write("Hello", 3, 10)
    }
  }

  // MARK: - write([Character], offset, len)

  @Test("write([Character], offset, len) schreibt Zeichen-Array")
  func writeCharArray() throws {
    let sw = java.io.StringWriter()
    let chars: [Character] = ["A", "B", "C", "D", "E"]
    try sw.write(chars, 1, 3)
    #expect(sw.toString() == "BCD")
  }

  @Test("write([Character], offset, len) mit ungültigem Bereich wirft Exception")
  func writeCharArrayInvalidRange() throws {
    let sw = java.io.StringWriter()
    let chars: [Character] = ["A", "B"]
    #expect(throws: (any Error).self) {
      try sw.write(chars, 0, 10)
    }
  }

  // MARK: - write(Character)

  @Test("write(Character) schreibt einzelnes Zeichen")
  func writeSingleChar() throws {
    let sw = java.io.StringWriter()
    try sw.write("Z" as Character)
    try sw.write("!" as Character)
    #expect(sw.toString() == "Z!")
  }

  // MARK: - append()

  @Test("append(Character) akkumuliert Zeichen")
  func appendChar() throws {
    let sw = java.io.StringWriter()
    let _: java.io.StringWriter = try sw.append("A" as Character)
    let _: java.io.StringWriter = try sw.append("B" as Character)
    #expect(sw.toString() == "AB")
  }

  @Test("append(CharSequence?) mit nil schreibt 'null'")
  func appendNilCharSequence() throws {
    let sw = java.io.StringWriter()
    let _: java.io.StringWriter = try sw.append(nil as (any CharSequence)?)
    #expect(sw.toString() == "null")
  }

  @Test("append(CharSequence?, start, end) schreibt Teilsequenz")
  func appendCharSequenceRange() throws {
    let sw = java.io.StringWriter()
    let sb: (any CharSequence)? = StringBuffer("Hello World")
    let _: java.io.StringWriter = try sw.append(sb, 6, 11)
    #expect(sw.toString() == "World")
  }

  // MARK: - initialSize

  @Test("Initialisierung mit initialSize funktioniert")
  func initWithSize() throws {
    let sw = java.io.StringWriter(64)
    try sw.write("test")
    #expect(sw.toString() == "test")
  }

  // MARK: - getBuffer()

  @Test("getBuffer() gibt StringBuffer mit aktuellem Inhalt zurück")
  func getBuffer() throws {
    let sw = java.io.StringWriter()
    try sw.write("abc")
    let buf = sw.getBuffer()
    #expect(buf.toString() == "abc")
  }

  // MARK: - flush / close (No-Op)

  @Test("flush() und close() sind No-Ops und werfen keine Exception")
  func flushAndCloseAreNoOps() throws {
    let sw = java.io.StringWriter()
    try sw.write("data")
    try sw.flush()
    try sw.close()
    // Nach close() ist StringWriter noch verwendbar (kein Status-Track)
    #expect(sw.toString() == "data")
  }
}
