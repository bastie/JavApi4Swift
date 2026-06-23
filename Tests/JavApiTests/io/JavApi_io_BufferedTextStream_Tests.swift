/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
import Foundation
@testable import JavApi

// MARK: - BufferedReader Tests

@Suite(.serialized)
struct JavApi_io_BufferedReader_Tests {

  @Test("BufferedReader.readLine() reads single line")
  func testReadLineSingle() throws {
    let reader = java.io.BufferedReader(java.io.StringReader("hello"))
    #expect(try reader.readLine() == "hello")
    #expect(try reader.readLine() == nil)
  }

  @Test("BufferedReader.readLine() reads multiple lines with LF")
  func testReadMultipleLinesLF() throws {
    let reader = java.io.BufferedReader(java.io.StringReader("line1\nline2\nline3"))
    #expect(try reader.readLine() == "line1")
    #expect(try reader.readLine() == "line2")
    #expect(try reader.readLine() == "line3")
    #expect(try reader.readLine() == nil)
  }

  @Test("BufferedReader.readLine() strips LF terminator")
  func testReadLineStripsLF() throws {
    let reader = java.io.BufferedReader(java.io.StringReader("hello\n"))
    let line = try reader.readLine()
    #expect(line == "hello")
    #expect(!line!.hasSuffix("\n"))
  }

  @Test("BufferedReader.readLine() handles CR terminator")
  func testReadLineCR() throws {
    let reader = java.io.BufferedReader(java.io.StringReader("hello\rworld"))
    #expect(try reader.readLine() == "hello")
    #expect(try reader.readLine() == "world")
  }

  @Test("BufferedReader.readLine() handles CRLF as single newline")
  func testReadLineCRLF() throws {
    let reader = java.io.BufferedReader(java.io.StringReader("hello\r\nworld"))
    let hello = try reader.readLine()
    #expect(hello == "hello")
    let world = try reader.readLine()
    #expect(world == "world")
  }

  @Test("BufferedReader.readLine() last line without newline")
  func testReadLineLastWithoutNewline() throws {
    let reader = java.io.BufferedReader(java.io.StringReader("line1\nline2"))
    _ = try reader.readLine()
    #expect(try reader.readLine() == "line2")
    #expect(try reader.readLine() == nil)
  }

  @Test("BufferedReader.readLine() on empty string returns nil")
  func testReadLineEmpty() throws {
    let reader = java.io.BufferedReader(java.io.StringReader(""))
    #expect(try reader.readLine() == nil)
  }

  @Test("BufferedReader.readLine() only with newline")
  func testReadLineOnlyNewline() throws {
    let reader = java.io.BufferedReader(java.io.StringReader("\n"))
    #expect(try reader.readLine() == "")
    #expect(try reader.readLine() == nil)
  }

  @Test("BufferedReader.ready() returns true when data available")
  func testReadyTrue() throws {
    let reader = java.io.BufferedReader(java.io.StringReader("hello"))
    #expect(try reader.ready())
  }

  @Test("BufferedReader.ready() after consuming all data")
  func testReadyAfterEOF() throws {
    let reader = java.io.BufferedReader(java.io.StringReader("h"))
    _ = try reader.read()
    // After EOF, ready might be false or true depending on implementation
    let ready = try reader.ready()
    #expect(ready == false)
  }

  @Test("BufferedReader.read() returns character code")
  func testRead() throws {
    let reader = java.io.BufferedReader(java.io.StringReader("abc"))
    #expect(try reader.read() == Int("a".unicodeScalars.first!.value))
    #expect(try reader.read() == Int("b".unicodeScalars.first!.value))
    #expect(try reader.read() == Int("c".unicodeScalars.first!.value))
    #expect(try reader.read() == -1)
  }

  @Test("BufferedReader.read(buffer) reads into character buffer")
  func testReadBuffer() throws {
    let reader = java.io.BufferedReader(java.io.StringReader("hello"))
    var buf = [Character](repeating: " ", count: 5)
    let read = try reader.read(&buf, 0, 5)
    #expect(read == 5)
    #expect(buf == [Character]("hello"))
  }

  @Test("BufferedReader.mark() and reset() restore position")
  func testMarkReset() throws {
    let reader = java.io.BufferedReader(java.io.StringReader("hello\nworld"))
    _ = try reader.readLine()  // "hello"
    try reader.mark(100)
    _ = try reader.readLine()  // "world"
    try reader.reset()
    #expect(try reader.readLine() == "world")
  }

  @Test("BufferedReader.markSupported() returns true")
  func testMarkSupported() throws {
    let reader = java.io.BufferedReader(java.io.StringReader("test"))
    #expect(reader.markSupported())
  }

  @Test("BufferedReader with custom buffer size")
  func testCustomBufferSize() throws {
    let reader = try java.io.BufferedReader(java.io.StringReader("hello\nworld"), 2)
    #expect(try reader.readLine() == "hello")
    #expect(try reader.readLine() == "world")
  }

  @Test("BufferedReader mixed CR LF CRLF terminators")
  func testMixedTerminators() throws {
    let reader = java.io.BufferedReader(java.io.StringReader("a\nb\rc\r\nd"))
    let a = try reader.readLine()
    #expect(a == "a")
    let b = try reader.readLine()
    #expect(b == "b")
    let c = try reader.readLine()
    #expect(c == "c")
    let d = try reader.readLine()
    #expect(d == "d")
  }

  @Test("BufferedReader.skip() skips characters")
  func testSkip() throws {
    let reader = java.io.BufferedReader(java.io.StringReader("hello"))
    let skipped = try reader.skip(2)
    #expect(skipped >= 2)
    let next = try reader.read()
    #expect(next >= 0) // Some character after skip
  }

  @Test("BufferedReader close() prevents further reads")
  func testClose() throws {
    let reader = java.io.BufferedReader(java.io.StringReader("hello"))
    try reader.close()
    #expect(throws: Error.self) {
      try reader.read()
    }
  }

  @Test("BufferedReader large content")
  func testLargeContent() throws {
    let lines = (0..<100).map { "line\($0)" }
    let content = lines.joined(separator: "\n")
    let reader = java.io.BufferedReader(java.io.StringReader(content))

    for (_, expected) in lines.enumerated() {
      let line = try reader.readLine()
      #expect(line == expected)
    }
    #expect(try reader.readLine() == nil)
  }
}

// MARK: - BufferedWriter Tests

@Suite(.serialized)
struct JavApi_io_BufferedWriter_Tests {

  @Test("BufferedWriter.write(Int) writes character")
  func testWriteInt() throws {
    let underlying = java.io.StringWriter()
    let writer = java.io.BufferedWriter(underlying)
    try writer.write(Int("A".unicodeScalars.first!.value))
    try writer.flush()
    #expect(underlying.toString() == "A")
  }

  @Test("BufferedWriter.write(Character) writes single character")
  func testWriteCharacter() throws {
    let underlying = java.io.StringWriter()
    let writer = java.io.BufferedWriter(underlying)
    try writer.write(Character("X"))
    try writer.flush()
    #expect(underlying.toString() == "X")
  }

  @Test("BufferedWriter.write(String) writes full string")
  func testWriteString() throws {
    let underlying = java.io.StringWriter()
    let writer = java.io.BufferedWriter(underlying)
    try writer.write("hello")
    try writer.flush()
    #expect(underlying.toString() == "hello")
  }

  @Test("BufferedWriter.write(buffer) writes character array")
  func testWriteBuffer() throws {
    let underlying = java.io.StringWriter()
    let writer = java.io.BufferedWriter(underlying)
    let chars = [Character]("world")
    try writer.write(chars)
    try writer.flush()
    #expect(underlying.toString() == "world")
  }

  @Test("BufferedWriter.write(buffer, offset, length) writes partial")
  func testWritePartial() throws {
    let underlying = java.io.StringWriter()
    let writer = java.io.BufferedWriter(underlying)
    let chars = [Character]("hello")
    try writer.write(chars, 1, 3)  // "ell"
    try writer.flush()
    #expect(underlying.toString() == "ell")
  }

  @Test("BufferedWriter.newLine() writes platform newline")
  func testNewLine() throws {
    let underlying = java.io.StringWriter()
    let writer = java.io.BufferedWriter(underlying)
    try writer.write("hello")
    try writer.newLine()
    try writer.write("world")
    try writer.flush()
    let result = underlying.toString()
    #expect(result.contains("hello"))
    #expect(result.contains("world"))
    #expect(result.count > "helloworld".count)
  }

  @Test("BufferedWriter.flush() sends to underlying writer")
  func testFlush() throws {
    let underlying = java.io.StringWriter()
    let writer = try java.io.BufferedWriter(underlying, 10)
    try writer.write("test")
    #expect(underlying.toString().isEmpty) // Not flushed

    try writer.flush()
    #expect(underlying.toString() == "test")
  }

  @Test("BufferedWriter.close() flushes before closing")
  func testClose() throws {
    let underlying = java.io.StringWriter()
    let writer = java.io.BufferedWriter(underlying)
    try writer.write("test")
    try writer.close()
    #expect(underlying.toString() == "test")
  }

  @Test("BufferedWriter with custom buffer size")
  func testCustomBufferSize() throws {
    let underlying = java.io.StringWriter()
    let writer = try java.io.BufferedWriter(underlying, 2)
    try writer.write("hello")
    try writer.flush()
    #expect(underlying.toString() == "hello")
  }

  @Test("BufferedWriter auto-flush on full buffer")
  func testAutoFlushOnFull() throws {
    let underlying = java.io.StringWriter()
    let writer = try java.io.BufferedWriter(underlying, 3)
    try writer.write("abc")
    // May auto-flush when full
    try writer.write("d")
    try writer.flush()
    #expect(underlying.toString() == "abcd")
  }

  @Test("BufferedWriter sequential writes")
  func testSequentialWrites() throws {
    let underlying = java.io.StringWriter()
    let writer = java.io.BufferedWriter(underlying)
    try writer.write("hello")
    try writer.write(" ")
    try writer.write("world")
    try writer.flush()
    #expect(underlying.toString() == "hello world")
  }

  @Test("BufferedWriter write after close throws")
  func testWriteAfterClose() throws {
    let underlying = java.io.StringWriter()
    let writer = java.io.BufferedWriter(underlying)
    try writer.close()
    #expect(throws: Error.self) {
      try writer.write("test")
    }
  }

  @Test("BufferedWriter newLine multiple times")
  func testMultipleNewLines() throws {
    let underlying = java.io.StringWriter()
    let writer = java.io.BufferedWriter(underlying)
    try writer.write("line1")
    try writer.newLine()
    try writer.write("line2")
    try writer.newLine()
    try writer.write("line3")
    try writer.flush()
    let result = underlying.toString()
    #expect(result.contains("line1"))
    #expect(result.contains("line2"))
    #expect(result.contains("line3"))
  }
}

// MARK: - BufferedReader/BufferedWriter Integration Tests

@Suite(.serialized)
struct JavApi_io_BufferedTextStream_Integration_Tests {

  @Test("Round-trip: write then read with buffering")
  func testRoundTrip() throws {
    // Write
    let stringWriter = java.io.StringWriter()
    let bufferedWriter = java.io.BufferedWriter(stringWriter)
    try bufferedWriter.write("hello\nworld\ntest")
    try bufferedWriter.flush()

    // Read
    let stringReader = java.io.StringReader(stringWriter.toString())
    let bufferedReader = java.io.BufferedReader(stringReader)
    #expect(try bufferedReader.readLine() == "hello")
    #expect(try bufferedReader.readLine() == "world")
    #expect(try bufferedReader.readLine() == "test")
  }

  @Test("Write lines with newLine() and read back")
  func testWriteReadLines() throws {
    // Write
    let stringWriter = java.io.StringWriter()
    let writer = java.io.BufferedWriter(stringWriter)
    try writer.write("line1")
    try writer.newLine()
    try writer.write("line2")
    try writer.newLine()
    try writer.write("line3")
    try writer.flush()

    // Read
    let reader = java.io.BufferedReader(java.io.StringReader(stringWriter.toString()))
    #expect(try reader.readLine() == "line1")
    #expect(try reader.readLine() == "line2")
    #expect(try reader.readLine() == "line3")
  }

  @Test("Multiple sequential writes and reads")
  func testMultipleSequentialOps() throws {
    let stringWriter = java.io.StringWriter()
    let writer = java.io.BufferedWriter(stringWriter)

    try writer.write("a")
    try writer.write("b")
    try writer.newLine()
    try writer.write("c")
    try writer.flush()

    let reader = java.io.BufferedReader(java.io.StringReader(stringWriter.toString()))
    let line1 = try reader.readLine()
    #expect(line1 == "ab")
    let line2 = try reader.readLine()
    #expect(line2 == "c")
  }

  @Test("Reader mark/reset with writer output")
  func testReaderMarkResetWithWriterOutput() throws {
    // Write
    let stringWriter = java.io.StringWriter()
    let writer = java.io.BufferedWriter(stringWriter)
    try writer.write("line1\nline2\nline3\n")
    try writer.flush()

    // Read with mark/reset
    let reader = java.io.BufferedReader(java.io.StringReader(stringWriter.toString()))
    _ = try reader.readLine()  // "line1"
    try reader.mark(100)
    _ = try reader.readLine()  // "line2"
    try reader.reset()
    #expect(try reader.readLine() == "line2")
  }

  @Test("Large text content buffered read/write")
  func testLargeTextBuffered() throws {
    // Write large content
    let stringWriter = java.io.StringWriter()
    let writer = java.io.BufferedWriter(stringWriter)

    for i in 0..<100 {
      try writer.write("line\(i)")
      try writer.newLine()
    }
    try writer.flush()

    // Read it back
    let reader = java.io.BufferedReader(java.io.StringReader(stringWriter.toString()))
    for i in 0..<100 {
      let line = try reader.readLine()
      #expect(line == "line\(i)")
    }
  }

  @Test("Mixed line terminators in written content")
  func testMixedTerminatorsWrittenRead() throws {
    // Create content with various line endings manually
    let content = "line1\nline2\rline3\r\nline4"
    let reader = java.io.BufferedReader(java.io.StringReader(content))

    let line1 = try reader.readLine()
    #expect(line1 == "line1")
    let line2 = try reader.readLine()
    #expect(line2 == "line2")
    let line3 = try reader.readLine()
    #expect(line3 == "line3")
    let line4 = try reader.readLine()
    #expect(line4 == "line4")
  }

  @Test("BufferedReader character read after line read")
  func testCharReadAfterLineRead() throws {
    let reader = java.io.BufferedReader(java.io.StringReader("hello\nworld"))
    _ = try reader.readLine()  // "hello"

    // Next read should be 'w'
    let charCode = try reader.read()
    #expect(charCode == Int("w".unicodeScalars.first!.value))
  }

  @Test("BufferedWriter and Reader with special characters")
  func testSpecialCharacters() throws {
    let specialChars = "!@#$%^&*()"

    // Write
    let stringWriter = java.io.StringWriter()
    let writer = java.io.BufferedWriter(stringWriter)
    try writer.write(specialChars)
    try writer.flush()

    // Read
    let reader = java.io.BufferedReader(java.io.StringReader(stringWriter.toString()))
    var buf = [Character](repeating: " ", count: specialChars.count)
    _ = try reader.read(&buf, 0, specialChars.count)
    #expect(String(buf) == specialChars)
  }

  @Test("Empty lines with buffered read/write")
  func testEmptyLines() throws {
    // Write
    let stringWriter = java.io.StringWriter()
    let writer = java.io.BufferedWriter(stringWriter)
    try writer.write("line1")
    try writer.newLine()
    try writer.newLine()
    try writer.write("line2")
    try writer.flush()

    // Read
    let reader = java.io.BufferedReader(java.io.StringReader(stringWriter.toString()))
    #expect(try reader.readLine() == "line1")
    #expect(try reader.readLine() == "")
    #expect(try reader.readLine() == "line2")
  }
}
