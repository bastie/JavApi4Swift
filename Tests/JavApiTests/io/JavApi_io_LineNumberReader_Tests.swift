/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

final class JavApi_io_LineNumberReader_Tests {

  // MARK: - Line counting

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
    _ = try reader.readLine()  // "a"  → lineNumber 1
    #expect(reader.getLineNumber() == 1)
    _ = try reader.readLine()  // "b"  → no additional increment
    #expect(reader.getLineNumber() == 1)
  }

  // MARK: - readLine

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

  // MARK: - setLineNumber

  @Test("setLineNumber changes the current line number")
  func setLineNumber() throws {
    let reader = java.io.LineNumberReader(java.io.StringReader("a\nb"))
    reader.setLineNumber(10)
    _ = try reader.readLine()
    #expect(reader.getLineNumber() == 11)
  }

  // MARK: - mark / reset

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

  // MARK: - mixed terminators

  @Test("Mixed LF CR CRLF all count as one line each")
  func mixedTerminators() throws {
    let reader = java.io.LineNumberReader(java.io.StringReader("a\nb\rc\r\nd"))
    _ = try reader.readLine()  // "a"
    _ = try reader.readLine()  // "b"
    _ = try reader.readLine()  // "c"
    _ = try reader.readLine()  // "d"
    #expect(reader.getLineNumber() == 3)
  }
}
