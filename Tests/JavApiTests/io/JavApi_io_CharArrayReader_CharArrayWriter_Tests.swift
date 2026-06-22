/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_io_CharArrayReader_Tests {

  // MARK: - Initialisierung

  @Test("init(_:) liest gesamtes Array")
  func initFullArray() throws {
    let chars: [Character] = ["A", "B", "C"]
    let reader = java.io.CharArrayReader(chars)
    #expect(try reader.read() == Int(Character("A").unicodeScalars.first!.value))
    #expect(try reader.read() == Int(Character("B").unicodeScalars.first!.value))
    #expect(try reader.read() == Int(Character("C").unicodeScalars.first!.value))
    #expect(try reader.read() == -1)
  }

  @Test("init(_:_:_:) liest nur den angegebenen Teilbereich")
  func initSubrange() throws {
    let chars: [Character] = ["A", "B", "C", "D", "E"]
    let reader = java.io.CharArrayReader(chars, 1, 3)  // B, C, D
    #expect(try reader.read() == Int(Character("B").unicodeScalars.first!.value))
    #expect(try reader.read() == Int(Character("C").unicodeScalars.first!.value))
    #expect(try reader.read() == Int(Character("D").unicodeScalars.first!.value))
    #expect(try reader.read() == -1)
  }

  @Test("init mit leerem Array gibt sofort -1")
  func initEmptyArray() throws {
    let reader = java.io.CharArrayReader([])
    #expect(try reader.read() == -1)
  }

  // MARK: - read()

  @Test("read() gibt -1 bei EOF zurück")
  func readReturnsMinus1AtEOF() throws {
    let reader = java.io.CharArrayReader(["X"])
    _ = try reader.read()
    #expect(try reader.read() == -1)
  }

  // MARK: - read(buf, offset, count)

  @Test("read(buf, offset, count) befüllt Puffer korrekt")
  func readIntoBuffer() throws {
    let chars: [Character] = ["A", "B", "C", "D"]
    let reader = java.io.CharArrayReader(chars)
    var buf = [Character](repeating: "\0", count: 4)
    let n = try reader.read(&buf, 0, 4)
    #expect(n == 4)
    #expect(buf == ["A", "B", "C", "D"])
  }

  @Test("read(buf, offset, count) mit offset")
  func readIntoBufferWithOffset() throws {
    let chars: [Character] = ["X", "Y"]
    let reader = java.io.CharArrayReader(chars)
    var buf = [Character](repeating: "Z", count: 4)
    let n = try reader.read(&buf, 2, 2)
    #expect(n == 2)
    #expect(buf[0] == "Z")
    #expect(buf[2] == "X")
    #expect(buf[3] == "Y")
  }

  @Test("read(buf, offset, count) gibt -1 bei EOF")
  func readIntoBufferEOF() throws {
    let reader = java.io.CharArrayReader([])
    var buf = [Character](repeating: "\0", count: 2)
    #expect(try reader.read(&buf, 0, 2) == -1)
  }

  @Test("read(buf, offset, count) mit ungültigem Offset wirft IndexOutOfBoundsException")
  func readInvalidOffsetThrows() throws {
    let reader = java.io.CharArrayReader(["A"])
    var buf = [Character](repeating: "\0", count: 2)
    #expect(throws: (any Error).self) {
      _ = try reader.read(&buf, -1, 1)
    }
  }

  // MARK: - skip()

  @Test("skip() überspringt Zeichen korrekt")
  func skipChars() throws {
    let chars: [Character] = ["A", "B", "C", "D", "E"]
    let reader = java.io.CharArrayReader(chars)
    let skipped = try reader.skip(3)
    #expect(skipped == 3)
    #expect(try reader.read() == Int(Character("D").unicodeScalars.first!.value))
  }

  @Test("skip() überspringt nicht mehr als verfügbar")
  func skipMoreThanAvailable() throws {
    let chars: [Character] = ["A", "B"]
    let reader = java.io.CharArrayReader(chars)
    let skipped = try reader.skip(100)
    #expect(skipped == 2)
    #expect(try reader.read() == -1)
  }

  @Test("skip() mit 0 gibt 0 zurück")
  func skipZero() throws {
    let chars: [Character] = ["A"]
    let reader = java.io.CharArrayReader(chars)
    #expect(try reader.skip(0) == 0)
  }

  // MARK: - ready()

  @Test("ready() gibt true zurück solange Zeichen verfügbar")
  func readyWithContent() throws {
    let reader = java.io.CharArrayReader(["A"])
    #expect(try reader.ready() == true)
    _ = try reader.read()
    #expect(try reader.ready() == false)
  }

  // MARK: - markSupported / mark / reset

  @Test("markSupported() gibt true zurück")
  func markSupported() {
    #expect(java.io.CharArrayReader(["A"]).markSupported() == true)
  }

  @Test("mark und reset springen zurück zur markierten Position")
  func markAndReset() throws {
    let chars: [Character] = ["A", "B", "C", "D"]
    let reader = java.io.CharArrayReader(chars)
    _ = try reader.read()  // A
    try reader.mark(10)
    _ = try reader.read()  // B
    _ = try reader.read()  // C
    try reader.reset()
    #expect(try reader.read() == Int(Character("B").unicodeScalars.first!.value))
  }

  @Test("Sub-Range: mark/reset bleibt innerhalb des Teilbereichs")
  func markResetInSubrange() throws {
    let chars: [Character] = ["A", "B", "C", "D", "E"]
    let reader = java.io.CharArrayReader(chars, 1, 3)  // B, C, D
    try reader.mark(10)
    _ = try reader.read()  // B
    try reader.reset()
    #expect(try reader.read() == Int(Character("B").unicodeScalars.first!.value))
  }

  // MARK: - close()

  @Test("Nach close() wirft read() IOException")
  func readAfterCloseThrows() throws {
    let reader = java.io.CharArrayReader(["A"])
    try reader.close()
    #expect(throws: (any Error).self) {
      _ = try reader.read()
    }
  }

  @Test("Nach close() wirft ready() IOException")
  func readyAfterCloseThrows() throws {
    let reader = java.io.CharArrayReader(["A"])
    try reader.close()
    #expect(throws: (any Error).self) {
      _ = try reader.ready()
    }
  }
}

struct JavApi_io_CharArrayWriter_Tests {

  // MARK: - Initialisierung

  @Test("Default-Initialisierung hat size 0")
  func defaultInitSize() {
    let writer = java.io.CharArrayWriter()
    #expect(writer.size() == 0)
  }

  @Test("Initialisierung mit initialSize funktioniert")
  func initWithSize() throws {
    let writer = try java.io.CharArrayWriter(64)
    #expect(writer.size() == 0)
  }

  @Test("Initialisierung mit negativer Größe wirft IllegalArgumentException")
  func initWithNegativeSizeThrows() throws {
    #expect(throws: IllegalArgumentException.self) {
      _ = try java.io.CharArrayWriter(-1)
    }
  }

  // MARK: - write(Character)

  @Test("write(Character) erhöht size um 1")
  func writeCharIncreasesSize() {
    let writer = java.io.CharArrayWriter()
    writer.write("A" as Character)
    #expect(writer.size() == 1)
  }

  @Test("Mehrfaches write(Character) akkumuliert korrekt")
  func writeMultipleChars() {
    let writer = java.io.CharArrayWriter()
    writer.write("H" as Character)
    writer.write("i" as Character)
    #expect(writer.toString() == "Hi")
  }

  // MARK: - write([Character], offset, len)

  @Test("write([Character], offset, len) schreibt Teilbereich korrekt")
  func writeCharArrayRange() throws {
    let writer = java.io.CharArrayWriter()
    let chars: [Character] = ["A", "B", "C", "D", "E"]
    try writer.write(chars, 1, 3)
    #expect(writer.toString() == "BCD")
  }

  @Test("write([Character], offset, len) mit ungültigem Bereich wirft Exception")
  func writeCharArrayInvalidRange() throws {
    let writer = java.io.CharArrayWriter()
    let chars: [Character] = ["A", "B"]
    #expect(throws: (any Error).self) {
      try writer.write(chars, 0, 10)
    }
  }

  // MARK: - write(String, offset, len)

  @Test("write(String, offset, len) schreibt Teilstring korrekt")
  func writeStringRange() throws {
    let writer = java.io.CharArrayWriter()
    try writer.write("Hello World", 6, 5)
    #expect(writer.toString() == "World")
  }

  // MARK: - toCharArray()

  @Test("toCharArray() gibt Kopie des geschriebenen Inhalts zurück")
  func toCharArray() {
    let writer = java.io.CharArrayWriter()
    writer.write("A" as Character)
    writer.write("B" as Character)
    let arr = writer.toCharArray()
    #expect(arr.count == 2)
    #expect(arr[0] == "A")
    #expect(arr[1] == "B")
  }

  @Test("toCharArray() gibt korrekten Inhalt zurück nach write([Character])")
  func toCharArrayAfterArrayWrite() throws {
    let writer = java.io.CharArrayWriter()
    let chars: [Character] = ["X", "Y", "Z"]
    try writer.write(chars, 0, 3)
    let arr = writer.toCharArray()
    #expect(arr.count == 3)
    #expect(arr[0] == "X")
    #expect(arr[2] == "Z")
  }

  // MARK: - reset()

  @Test("reset() setzt size auf 0 zurück")
  func resetSize() throws {
    let writer = java.io.CharArrayWriter()
    let chars: [Character] = ["A", "B", "C"]
    try writer.write(chars, 0, 3)
    #expect(writer.size() == 3)
    writer.reset()
    #expect(writer.size() == 0)
    #expect(writer.toString() == "")
  }

  @Test("Nach reset() kann neu geschrieben werden")
  func writeAfterReset() throws {
    let writer = java.io.CharArrayWriter()
    let chars1: [Character] = ["A", "B"]
    try writer.write(chars1, 0, 2)
    writer.reset()
    let chars2: [Character] = ["X", "Y"]
    try writer.write(chars2, 0, 2)
    #expect(writer.toString() == "XY")
  }

  // MARK: - writeTo()

  @Test("writeTo() überträgt Inhalt in anderen Writer")
  func writeTo() throws {
    let src = java.io.CharArrayWriter()
    let chars: [Character] = ["H", "e", "l", "l", "o"]
    try src.write(chars, 0, 5)

    let dest = java.io.StringWriter()
    try src.writeTo(dest)
    #expect(dest.toString() == "Hello")
  }

  // MARK: - append()

  @Test("append(Character) akkumuliert und gibt self zurück")
  func appendChar() throws {
    let writer = java.io.CharArrayWriter()
    let _: java.io.CharArrayWriter = try writer.append("A" as Character)
    let _: java.io.CharArrayWriter = try writer.append("B" as Character)
    #expect(writer.toString() == "AB")
  }

  @Test("append(CharSequence?) mit nil schreibt 'null'")
  func appendNilCharSequence() throws {
    let writer = java.io.CharArrayWriter()
    let _: java.io.CharArrayWriter = try writer.append(nil as (any CharSequence)?)
    #expect(writer.toString() == "null")
  }

  // MARK: - flush / close (No-Op)

  @Test("flush() und close() sind No-Ops")
  func flushAndCloseAreNoOps() throws {
    let writer = java.io.CharArrayWriter()
    let chars: [Character] = ["X"]
    try writer.write(chars, 0, 1)
    writer.flush()   // non-throwing
    writer.close()   // non-throwing
    #expect(writer.toString() == "X")
  }

  // MARK: - Roundtrip mit CharArrayReader

  @Test("CharArrayWriter → CharArrayReader Roundtrip")
  func roundtrip() throws {
    let writer = java.io.CharArrayWriter()
    let original: [Character] = ["J", "a", "v", "a"]
    try writer.write(original, 0, 4)

    let arr = writer.toCharArray()
    let reader = java.io.CharArrayReader(arr)

    var result = ""
    var ch = try reader.read()
    while ch != -1 {
      if let scalar = Unicode.Scalar(ch) {
        result.append(Character(scalar))
      }
      ch = try reader.read()
    }
    #expect(result == "Java")
  }
}
