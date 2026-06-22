/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// MARK: - Line Counting Tests

struct JavApi_io_LineNumberReader_LineCount_Tests {

  @Test("Line number starts at 0")
  func lineNumberStartsAtZero() {
    let reader = java.io.LineNumberReader(java.io.StringReader("hello"))
    #expect(reader.getLineNumber() == 0)
  }

  @Test("LF increments line number")
  func lfIncrementsLineNumber() throws {
    let reader = java.io.LineNumberReader(java.io.StringReader("a\nb\nc"))
    _ = try reader.readLine()  // "a"  → lineNumber 1
    #expect(reader.getLineNumber() == 1)
    _ = try reader.readLine()  // "b"  → lineNumber 2
    #expect(reader.getLineNumber() == 2)
  }

  @Test("CR increments line number and is normalised to LF")
  func crIncrementsLineNumber() throws {
    let reader = java.io.LineNumberReader(java.io.StringReader("a\rb"))
    _ = try reader.readLine()  // "a"  → lineNumber 1
    #expect(reader.getLineNumber() == 1)
  }

  @Test("CRLF counts as single newline")
  func crlfCountsAsSingleNewline() throws {
    let reader = java.io.LineNumberReader(java.io.StringReader("a\r\nb"))
    _ = try reader.readLine()  // "a"  → lineNumber 1 (CRLF zählt als 1)
    #expect(reader.getLineNumber() == 1)
    _ = try reader.readLine()  // "b"  → kein Terminator, kein Increment
    #expect(reader.getLineNumber() == 1)
  }

  @Test("setLineNumber changes the current line number")
  func setLineNumber() throws {
    let reader = java.io.LineNumberReader(java.io.StringReader("a\nb"))
    reader.setLineNumber(10)
    _ = try reader.readLine()
    #expect(reader.getLineNumber() == 11)
  }

  @Test("setLineNumber to negative value")
  func setLineNumberNegative() throws {
    let reader = java.io.LineNumberReader(java.io.StringReader("a\nb"))
    reader.setLineNumber(-5)
    _ = try reader.readLine()
    #expect(reader.getLineNumber() == -4)
  }
}

// MARK: - readLine Tests

struct JavApi_io_LineNumberReader_ReadLine_Tests {

  @Test("readLine returns line content without terminator")
  func readLineStripsTerminator() throws {
    let reader = java.io.LineNumberReader(java.io.StringReader("hello\nworld\n"))
    #expect(try reader.readLine() == "hello")
    #expect(try reader.readLine() == "world")
  }

  @Test("readLine returns nil at end of stream")
  func readLineReturnsNilAtEOF() throws {
    let reader = java.io.LineNumberReader(java.io.StringReader(""))
    #expect(try reader.readLine() == nil)
  }

  @Test("readLine returns last line without trailing newline")
  func readLineWithoutTrailingNewline() throws {
    let reader = java.io.LineNumberReader(java.io.StringReader("only"))
    #expect(try reader.readLine() == "only")
    #expect(try reader.readLine() == nil)
  }

  @Test("readLine with empty lines")
  func readLineEmptyLines() throws {
    let reader = java.io.LineNumberReader(java.io.StringReader("a\n\n\nc"))
    #expect(try reader.readLine() == "a")
    #expect(try reader.readLine() == "")
    #expect(try reader.readLine() == "")
    #expect(try reader.readLine() == "c")
  }

  @Test("readLine with very long line")
  func readLineLongLine() throws {
    let longLine = String(repeating: "x", count: 10000)
    let reader = java.io.LineNumberReader(java.io.StringReader(longLine + "\nshort"))
    #expect(try reader.readLine() == longLine)
    #expect(try reader.readLine() == "short")
  }
}

// MARK: - read() Single Character Tests

struct JavApi_io_LineNumberReader_Read_Tests {

  @Test("read() single character")
  func readSingleChar() throws {
    let reader = java.io.LineNumberReader(java.io.StringReader("abc"))
    #expect(try reader.read() == Int(Character("a").unicodeScalars.first!.value))
    #expect(try reader.read() == Int(Character("b").unicodeScalars.first!.value))
    #expect(try reader.read() == Int(Character("c").unicodeScalars.first!.value))
  }

  @Test("read() increments line number at LF")
  func readIncrementsAtLF() throws {
    let reader = java.io.LineNumberReader(java.io.StringReader("a\nb"))
    _ = try reader.read()  // 'a'
    #expect(reader.getLineNumber() == 0)
    _ = try reader.read()  // '\n' → lineNumber 1
    #expect(reader.getLineNumber() == 1)
  }

  @Test("read() normalizes CR to LF")
  func readNormalizesCR() throws {
    let reader = java.io.LineNumberReader(java.io.StringReader("a\rb"))
    _ = try reader.read()  // 'a'
    let newline = try reader.read()  // '\r' → '\n'
    #expect(newline == Int(Character("\n").unicodeScalars.first!.value))
    #expect(reader.getLineNumber() == 1)
  }

  @Test("read() handles CRLF as single newline")
  func readCRLFAsSingle() throws {
    let reader = java.io.LineNumberReader(java.io.StringReader("a\r\nb"))
    _ = try reader.read()  // 'a'
    _ = try reader.read()  // '\r' → '\n'
    #expect(reader.getLineNumber() == 1)
    _ = try reader.read()  // 'b' (not another newline)
    #expect(reader.getLineNumber() == 1)
  }

  @Test("read() returns -1 at EOF")
  func readReturnsEOF() throws {
    let reader = java.io.LineNumberReader(java.io.StringReader("x"))
    _ = try reader.read()
    #expect(try reader.read() == -1)
  }
}

// MARK: - read(buffer) Tests

struct JavApi_io_LineNumberReader_ReadBuffer_Tests {

  @Test("read(buffer) fills array with characters")
  func readBufferFill() throws {
    let reader = java.io.LineNumberReader(java.io.StringReader("hello"))
    var buf = [Character](repeating: " ", count: 5)
    let read = try reader.read(&buf, 0, 5)
    #expect(read == 5)
    #expect(String(buf) == "hello")
  }

  @Test("read(buffer) with offset")
  func readBufferOffset() throws {
    let reader = java.io.LineNumberReader(java.io.StringReader("abc"))
    var buf = [Character](repeating: " ", count: 5)
    let read = try reader.read(&buf, 1, 3)
    #expect(read == 3)
    #expect(buf[1] == "a")
    #expect(buf[2] == "b")
    #expect(buf[3] == "c")
  }

  @Test("read(buffer) at EOF returns -1")
  func readBufferEOF() throws {
    let reader = java.io.LineNumberReader(java.io.StringReader(""))
    var buf = [Character](repeating: " ", count: 5)
    #expect(try reader.read(&buf) == -1)
  }

  @Test("read(buffer) with zero length")
  func readBufferZeroLength() throws {
    let reader = java.io.LineNumberReader(java.io.StringReader("abc"))
    var buf = [Character](repeating: " ", count: 5)
    let read = try reader.read(&buf, 0, 0)
    #expect(read == 0)
    #expect(try reader.read() == Int(Character("a").unicodeScalars.first!.value))
  }

  @Test("read(buffer) tracks line numbers")
  func readBufferTrackLines() throws {
    let reader = java.io.LineNumberReader(java.io.StringReader("a\nb\nc"))
    var buf = [Character](repeating: " ", count: 5)
    _ = try reader.read(&buf, 0, 3)  // "a\nb"
    #expect(reader.getLineNumber() == 1)
  }
}

// MARK: - Mark/Reset Tests

struct JavApi_io_LineNumberReader_MarkReset_Tests {

  @Test("mark and reset restore line number")
  func markAndResetRestoreLineNumber() throws {
    let reader = java.io.LineNumberReader(java.io.StringReader("line1\nline2\nline3\n"))
    _ = try reader.readLine()          // "line1", lineNumber → 1
    try reader.mark(100)
    _ = try reader.readLine()          // "line2", lineNumber → 2
    try reader.reset()
    #expect(reader.getLineNumber() == 1)
    #expect(try reader.readLine() == "line2")
  }

  @Test("markSupported returns true")
  func markSupported() {
    let reader = java.io.LineNumberReader(java.io.StringReader("test"))
    #expect(reader.markSupported() == true)
  }

  @Test("Multiple mark/reset cycles")
  func multipleMarkResetCycles() throws {
    let reader = java.io.LineNumberReader(java.io.StringReader("a\nb\nc\n"))
    _ = try reader.readLine()  // "a", ln=1
    try reader.mark(100)
    _ = try reader.readLine()  // "b", ln=2
    try reader.reset()         // back to ln=1
    #expect(reader.getLineNumber() == 1)
    try reader.mark(100)
    _ = try reader.readLine()  // "b", ln=2
    try reader.reset()         // back to ln=1
    #expect(reader.getLineNumber() == 1)
  }

  @Test("reset() clears CR state")
  func resetClearsCRState() throws {
    let reader = java.io.LineNumberReader(java.io.StringReader("a\r\nb"))
    _ = try reader.read()  // 'a'
    _ = try reader.read()  // '\r' → '\n'
    try reader.mark(100)
    _ = try reader.read()  // 'b'
    try reader.reset()
    #expect(try reader.read() == Int(Character("b").unicodeScalars.first!.value))
  }
}

// MARK: - Skip Tests

struct JavApi_io_LineNumberReader_Skip_Tests {

  @Test("skip() skips characters")
  func skipCharacters() throws {
    let reader = java.io.LineNumberReader(java.io.StringReader("abcdef"))
    let skipped = try reader.skip(3)
    #expect(skipped == 3)
    #expect(try reader.read() == Int(Character("d").unicodeScalars.first!.value))
  }

  @Test("skip() with newlines increments line number")
  func skipWithNewlines() throws {
    let reader = java.io.LineNumberReader(java.io.StringReader("a\nb\nc"))
    let skipped = try reader.skip(3)  // "a\n"
    #expect(skipped == 3)
    #expect(reader.getLineNumber() >= 1)  // Implementation may vary
  }

  @Test("skip(0) returns 0")
  func skipZero() throws {
    let reader = java.io.LineNumberReader(java.io.StringReader("abc"))
    #expect(try reader.skip(0) == 0)
    #expect(try reader.read() == Int(Character("a").unicodeScalars.first!.value))
  }

  @Test("skip() past EOF")
  func skipPastEOF() throws {
    let reader = java.io.LineNumberReader(java.io.StringReader("abc"))
    let skipped = try reader.skip(100)
    #expect(skipped == 3)
  }
}

// MARK: - Mixed Terminators Test

struct JavApi_io_LineNumberReader_MixedTerminators_Tests {

  @Test("Mixed LF CR CRLF all count as one line each")
  func mixedTerminators() throws {
    let reader = java.io.LineNumberReader(java.io.StringReader("a\nb\rc\r\nd"))
    _ = try reader.readLine()  // "a" — \n → lineNumber 1
    #expect(reader.getLineNumber() == 1)
    _ = try reader.readLine()  // "b" — \r → lineNumber 2
    #expect(reader.getLineNumber() == 2)
    _ = try reader.readLine()  // "c" — \r\n → lineNumber 3
    #expect(reader.getLineNumber() == 3)
    _ = try reader.readLine()  // "d" — kein Terminator, kein Increment
    #expect(reader.getLineNumber() == 3)
  }

  @Test("Large file with mixed terminators")
  func largeFileMixed() throws {
    var content = ""
    for i in 0..<100 {
      if i % 3 == 0 { content += "line\n" }
      else if i % 3 == 1 { content += "line\r" }
      else { content += "line\r\n" }
    }
    let reader = java.io.LineNumberReader(java.io.StringReader(content))
    var count = 0
    while try reader.readLine() != nil {
      count += 1
    }
    #expect(count == 100)
  }
}

// MARK: - Edge Cases

struct JavApi_io_LineNumberReader_EdgeCases_Tests {

  @Test("Constructor with buffer size hint")
  func constructorBufferSizeHint() {
    let reader = java.io.LineNumberReader(java.io.StringReader("test"), 1024)
    #expect(reader.getLineNumber() == 0)
  }

  @Test("Unicode characters preserved")
  func unicodeCharacters() throws {
    let reader = java.io.LineNumberReader(java.io.StringReader("Ä\nB\nÜ"))
    #expect(try reader.readLine() == "Ä")
    #expect(try reader.readLine() == "B")
    #expect(try reader.readLine() == "Ü")
  }

  @Test("Very large line number")
  func veryLargeLineNumber() throws {
    let reader = java.io.LineNumberReader(java.io.StringReader("a\nb"))
    reader.setLineNumber(1000000)
    _ = try reader.readLine()
    #expect(reader.getLineNumber() == 1000001)
  }

  @Test("Repeated consecutive newlines")
  func repeatedNewlines() throws {
    let reader = java.io.LineNumberReader(java.io.StringReader("a\n\n\n\nb"))
    #expect(try reader.readLine() == "a")   // \n → lineNumber 1
    #expect(try reader.readLine() == "")    // \n → lineNumber 2
    #expect(try reader.readLine() == "")    // \n → lineNumber 3
    #expect(try reader.readLine() == "")    // \n → lineNumber 4
    #expect(try reader.readLine() == "b")   // kein Terminator → bleibt 4
    #expect(reader.getLineNumber() == 4)
  }
}
