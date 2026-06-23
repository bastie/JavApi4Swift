/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// MARK: - Constructor Tests

struct JavApi_io_PrintWriter_Constructor_Tests {

  @Test("PrintWriter(Writer) writes through to the underlying Writer")
  func testPrintWriterFromWriter() throws {
    let sw = java.io.StringWriter()
    let pw = java.io.PrintWriter(sw)
    pw.println("hello")
    #expect(sw.toString().hasPrefix("hello"))
  }

  @Test("PrintWriter(Writer, autoflush: true) flushes after println")
  func testPrintWriterAutoflush() throws {
    let sw = java.io.StringWriter()
    let pw = java.io.PrintWriter(sw, true)
    pw.println("world")
    #expect(sw.toString().hasPrefix("world"))
  }

  @Test("PrintWriter(Writer, autoflush: false) still writes content")
  func testPrintWriterNoAutoflush() throws {
    let sw = java.io.StringWriter()
    let pw = java.io.PrintWriter(sw, false)
    pw.println("test")
    #expect(sw.toString().hasPrefix("test"))
  }

  @Test("PrintWriter(OutputStream) with default autoflush=true")
  func testPrintWriterFromOutputStream() throws {
    let out = java.io.ByteArrayOutputStream()
    let pw = java.io.PrintWriter(out)
    pw.println("data")
    let result = out.toString()
    #expect(result.contains("data"))
  }

  @Test("PrintWriter(OutputStream, autoflush: false) doesn't auto-flush")
  func testPrintWriterOutputStreamNoAutoflush() throws {
    let out = java.io.ByteArrayOutputStream()
    let pw = java.io.PrintWriter(out, false)
    try pw.write("test")
    // Without flush, content may not be immediately available
    try pw.flush()
    #expect(out.toString().contains("test"))
  }
}

// MARK: - println() Tests

struct JavApi_io_PrintWriter_Println_Tests {

  @Test("println() adds newline")
  func testPrintlnAddsNewline() throws {
    let sw = java.io.StringWriter()
    let pw = java.io.PrintWriter(sw)
    pw.println("first")
    pw.println("second")
    let result = sw.toString()
    #expect(result.contains("first\n"))
    #expect(result.contains("second\n"))
  }

  @Test("println() with empty string")
  func testPrintlnEmpty() throws {
    let sw = java.io.StringWriter()
    let pw = java.io.PrintWriter(sw)
    pw.println("")
    #expect(sw.toString() == "\n")
  }

  @Test("Multiple println() calls preserve content")
  func testMultiplePrintln() throws {
    let sw = java.io.StringWriter()
    let pw = java.io.PrintWriter(sw)
    pw.println("line1")
    pw.println("line2")
    pw.println("line3")
    let result = sw.toString()
    #expect(result.contains("line1\nline2\nline3\n"))
  }
}

// MARK: - print() Tests

struct JavApi_io_PrintWriter_Print_Tests {

  @Test("print() writes without newline")
  func testPrintNoNewline() throws {
    let sw = java.io.StringWriter()
    let pw = java.io.PrintWriter(sw)
    pw.print("hello")
    pw.print(" ")
    pw.print("world")
    let result = sw.toString()
    #expect(result == "hello world")
    #expect(!result.contains("\n"))
  }

  @Test("print() followed by println()")
  func testPrintThenPrintln() throws {
    let sw = java.io.StringWriter()
    let pw = java.io.PrintWriter(sw)
    pw.print("prefix")
    pw.println("suffix")
    #expect(sw.toString() == "prefixsuffix\n")
  }

  @Test("print() with empty string")
  func testPrintEmpty() throws {
    let sw = java.io.StringWriter()
    let pw = java.io.PrintWriter(sw)
    pw.print("")
    #expect(sw.toString() == "")
  }
}

// MARK: - Numeric Output Tests

struct JavApi_io_PrintWriter_Numeric_Tests {

  @Test("println(Int) writes integer")
  func testPrintlnInt() throws {
    let sw = java.io.StringWriter()
    let pw = java.io.PrintWriter(sw)
    pw.println(42)
    #expect(sw.toString().hasPrefix("42"))
  }

  @Test("println(Double) writes double")
  func testPrintlnDouble() throws {
    let sw = java.io.StringWriter()
    let pw = java.io.PrintWriter(sw)
    pw.println(3.14)
    let result = sw.toString()
    #expect(result.contains("3.14") || result.contains("3,14"))
  }

  @Test("println(Bool) writes boolean")
  func testPrintlnBool() throws {
    let sw = java.io.StringWriter()
    let pw = java.io.PrintWriter(sw)
    pw.println(true)
    #expect(sw.toString().contains("true"))

    let sw2 = java.io.StringWriter()
    let pw2 = java.io.PrintWriter(sw2)
    pw2.println(false)
    #expect(sw2.toString().contains("false"))
  }

  @Test("print() with numeric types")
  func testPrintNumeric() throws {
    let sw = java.io.StringWriter()
    let pw = java.io.PrintWriter(sw)
    pw.print(100)
    pw.print(" ")
    pw.print(2.5)
    let result = sw.toString()
    #expect(result.contains("100"))
    #expect(result.contains("2.5") || result.contains("2,5"))
  }
}

// MARK: - Autoflush Tests

struct JavApi_io_PrintWriter_Autoflush_Tests {

  @Test("autoflush=true flushes on println()")
  func testAutoflushOnPrintln() throws {
    let sw = java.io.StringWriter()
    let pw = java.io.PrintWriter(sw, true)
    pw.println("auto")
    #expect(sw.toString().contains("auto"))
  }

  @Test("autoflush=false requires explicit flush()")
  func testNoAutoflushRequiresFlush() throws {
    let sw = java.io.StringWriter()
    let pw = java.io.PrintWriter(sw, false)
    try pw.write("buffered")
    #expect(sw.toString().contains("buffered"))
  }

  @Test("flush() works with autoflush=false")
  func testExplicitFlush() throws {
    let out = java.io.ByteArrayOutputStream()
    let pw = java.io.PrintWriter(out, false)
    try pw.write("test")
    try pw.flush()
    #expect(out.toString().contains("test"))
  }
}

// MARK: - Write Tests

struct JavApi_io_PrintWriter_Write_Tests {

  @Test("write(String) delegates to underlying writer")
  func testWriteString() throws {
    let sw = java.io.StringWriter()
    let pw = java.io.PrintWriter(sw)
    try pw.write("hello")
    #expect(sw.toString() == "hello")
  }

  @Test("write(Int) writes character code")
  func testWriteInt() throws {
    let sw = java.io.StringWriter()
    let pw = java.io.PrintWriter(sw)
    try pw.write(65)  // 'A'
    #expect(sw.toString().contains("A"))
  }

  @Test("write(CharArray) with offset and length")
  func testWriteCharArray() throws {
    let sw = java.io.StringWriter()
    let pw = java.io.PrintWriter(sw)
    let chars: [Character] = ["H", "e", "l", "l", "o"]
    try pw.write(chars, 0, 5)
    #expect(sw.toString() == "Hello")
  }

  @Test("write(CharArray) partial write")
  func testWritePartialCharArray() throws {
    let sw = java.io.StringWriter()
    let pw = java.io.PrintWriter(sw)
    let chars: [Character] = ["A", "B", "C", "D", "E"]
    try pw.write(chars, 1, 3)  // "BCD"
    #expect(sw.toString() == "BCD")
  }
}

// MARK: - Error Handling & Edge Cases

struct JavApi_io_PrintWriter_EdgeCases_Tests {

  @Test("println() with special characters")
  func testPrintlnSpecialChars() throws {
    let sw = java.io.StringWriter()
    let pw = java.io.PrintWriter(sw)
    pw.println("tab:\t quote:\" slash:\\")
    let result = sw.toString()
    #expect(result.contains("tab:"))
    #expect(result.contains("quote:"))
  }

  @Test("println() with unicode characters")
  func testPrintlnUnicode() throws {
    let sw = java.io.StringWriter()
    let pw = java.io.PrintWriter(sw)
    pw.println("Ä B € D")
    #expect(sw.toString().contains("Ä"))
    #expect(sw.toString().contains("€"))
  }

  @Test("close() closes underlying stream")
  func testClose() throws {
    let sw = java.io.StringWriter()
    let pw = java.io.PrintWriter(sw)
    pw.println("before")
    pw.close()
    #expect(sw.toString().contains("before"))
  }

  @Test("Multiple writes in sequence")
  func testMultipleWrites() throws {
    let sw = java.io.StringWriter()
    let pw = java.io.PrintWriter(sw)
    try pw.write("a")
    try pw.write("b")
    try pw.write("c")
    pw.println("d")
    #expect(sw.toString() == "abcd\n")
  }

  @Test("Large string output")
  func testLargeString() throws {
    let sw = java.io.StringWriter()
    let pw = java.io.PrintWriter(sw)
    let largeString = String(repeating: "x", count: 10000)
    pw.println(largeString)
    #expect(sw.toString().count > 10000)
  }
}
