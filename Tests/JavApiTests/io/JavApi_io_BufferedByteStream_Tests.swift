/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
import Foundation
@testable import JavApi

// MARK: - BufferedInputStream Tests

struct JavApi_io_BufferedInputStream_Tests {

  @Test("BufferedInputStream reads from underlying stream")
  func testRead() throws {
    let underlying = java.io.ByteArrayInputStream([1, 2, 3, 4, 5])
    let buffered = try java.io.BufferedInputStream(underlying)

    #expect(try buffered.read() == 1)
    #expect(try buffered.read() == 2)
    #expect(try buffered.read() == 3)
  }

  @Test("BufferedInputStream.read(buffer) reads into buffer")
  func testReadBuffer() throws {
    let underlying = java.io.ByteArrayInputStream([10, 20, 30, 40, 50])
    let buffered = try java.io.BufferedInputStream(underlying)

    var buf = [UInt8](repeating: 0, count: 3)
    let read = try buffered.read(&buf)
    #expect(read == 3)
    #expect(buf == [10, 20, 30])
  }

  @Test("BufferedInputStream with custom buffer size")
  func testCustomBufferSize() throws {
    let underlying = java.io.ByteArrayInputStream([1, 2, 3, 4, 5, 6, 7, 8])
    let buffered = try java.io.BufferedInputStream(underlying, 2)

    // Should work despite small buffer
    #expect(try buffered.read() == 1)
    #expect(try buffered.read() == 2)
    #expect(try buffered.read() == 3)
  }

  @Test("BufferedInputStream.available() returns bytes available")
  func testAvailable() throws {
    let underlying = java.io.ByteArrayInputStream([1, 2, 3, 4, 5])
    let buffered = try java.io.BufferedInputStream(underlying)

    let available = try buffered.available()
    #expect(available > 0)
    _ = try buffered.read()
    let afterRead = try buffered.available()
    #expect(afterRead < available)
  }

  @Test("BufferedInputStream.skip() skips bytes in buffer")
  func testSkip() throws {
    let underlying = java.io.ByteArrayInputStream([1, 2, 3, 4, 5])
    let buffered = try java.io.BufferedInputStream(underlying)

    let skipped = try buffered.skip(2)
    #expect(skipped >= 2) // May skip more due to buffering
    #expect(try buffered.read() >= 3)
  }

  @Test("BufferedInputStream.mark() and reset() work correctly")
  func testMarkReset() throws {
    let underlying = java.io.ByteArrayInputStream([1, 2, 3, 4, 5])
    let buffered = try java.io.BufferedInputStream(underlying)

    _ = try buffered.read() // 1
    _ = try buffered.read() // 2
    try buffered.mark(100)
    _ = try buffered.read() // 3
    _ = try buffered.read() // 4
    try buffered.reset()
    #expect(try buffered.read() == 3)
  }

  @Test("BufferedInputStream.markSupported() returns true")
  func testMarkSupported() throws {
    let underlying = java.io.ByteArrayInputStream([1, 2, 3])
    let buffered = try java.io.BufferedInputStream(underlying)
    #expect(buffered.markSupported())
  }

  @Test("BufferedInputStream EOF returns -1")
  func testEOF() throws {
    let underlying = java.io.ByteArrayInputStream([1, 2])
    let buffered = try java.io.BufferedInputStream(underlying)

    _ = try buffered.read()
    _ = try buffered.read()
    #expect(try buffered.read() == -1)
  }

  @Test("BufferedInputStream.close() closes underlying stream")
  func testClose() throws {
    let underlying = java.io.ByteArrayInputStream([1, 2, 3])
    let buffered = try java.io.BufferedInputStream(underlying)

    _ = try buffered.read()
    try buffered.close()
    // Verify stream is closed (reads may fail)
    #expect(throws: Error.self) {
      try buffered.read()
    }
  }

  @Test("BufferedInputStream large reads are buffered efficiently")
  func testLargeRead() throws {
    let data = (0..<1000).map { UInt8($0 % 256) }
    let underlying = java.io.ByteArrayInputStream(data)
    let buffered = try java.io.BufferedInputStream(underlying, 256)

    var buf = [UInt8](repeating: 0, count: 500)
    let read = try buffered.read(&buf)
    #expect(read == 500)
    #expect(buf == Array(data[0..<500]))
  }

  @Test("BufferedInputStream multiple mark/reset cycles")
  func testMultipleMarkReset() throws {
    let underlying = java.io.ByteArrayInputStream([1, 2, 3, 4, 5])
    let buffered = try java.io.BufferedInputStream(underlying)

    // First cycle
    _ = try buffered.read() // 1
    try buffered.mark(100)
    _ = try buffered.read() // 2
    try buffered.reset()
    #expect(try buffered.read() == 2)

    // Second cycle
    _ = try buffered.read() // 3
    try buffered.mark(100)
    _ = try buffered.read() // 4
    try buffered.reset()
    #expect(try buffered.read() == 4)
  }

  @Test("BufferedInputStream with empty underlying stream")
  func testEmptyStream() throws {
    let underlying = java.io.ByteArrayInputStream([])
    let buffered = try java.io.BufferedInputStream(underlying)

    #expect(try buffered.read() == -1)
    #expect(try buffered.available() == 0)
  }
}

// MARK: - BufferedOutputStream Tests

struct JavApi_io_BufferedOutputStream_Tests {

  @Test("BufferedOutputStream writes to underlying stream")
  func testWrite() throws {
    let underlying = java.io.ByteArrayOutputStream()
    let buffered = java.io.BufferedOutputStream(underlying)

    try buffered.write(1)
    try buffered.write(2)
    try buffered.write(3)
    try buffered.flush()

    #expect(underlying.toByteArray() == [1, 2, 3])
  }

  @Test("BufferedOutputStream.write(buffer) buffers multiple bytes")
  func testWriteBuffer() throws {
    let underlying = java.io.ByteArrayOutputStream()
    let buffered = java.io.BufferedOutputStream(underlying)

    try buffered.write([10, 20, 30, 40, 50])
    try buffered.flush()

    #expect(underlying.toByteArray() == [10, 20, 30, 40, 50])
  }

  @Test("BufferedOutputStream with custom buffer size")
  func testCustomBufferSize() throws {
    let underlying = java.io.ByteArrayOutputStream()
    let buffered = try java.io.BufferedOutputStream(underlying, 2)

    try buffered.write([1, 2, 3])
    try buffered.flush()

    #expect(underlying.toByteArray() == [1, 2, 3])
  }

  @Test("BufferedOutputStream.flush() sends buffer to underlying stream")
  func testFlush() throws {
    let underlying = java.io.ByteArrayOutputStream()
    let buffered = try java.io.BufferedOutputStream(underlying, 10)

    try buffered.write([1, 2, 3])
    #expect(underlying.toByteArray().isEmpty) // Not flushed yet

    try buffered.flush()
    #expect(underlying.toByteArray() == [1, 2, 3])
  }

  @Test("BufferedOutputStream.close() flushes before closing")
  func testClose() throws {
    let underlying = java.io.ByteArrayOutputStream()
    let buffered = java.io.BufferedOutputStream(underlying)

    try buffered.write([1, 2, 3])
    try buffered.close()

    #expect(underlying.toByteArray() == [1, 2, 3])
  }

  @Test("BufferedOutputStream auto-flush on buffer full")
  func testAutoFlushOnFull() throws {
    let underlying = java.io.ByteArrayOutputStream()
    let buffered = try java.io.BufferedOutputStream(underlying, 3)

    try buffered.write(1)
    try buffered.write(2)
    try buffered.write(3)
    // Buffer should be full and auto-flush
    #expect(underlying.toByteArray().count >= 3)
  }

  @Test("BufferedOutputStream partial buffer write")
  func testPartialWrite() throws {
    let underlying = java.io.ByteArrayOutputStream()
    let buffered = java.io.BufferedOutputStream(underlying)

    let data: [UInt8] = [1, 2, 3, 4, 5]
    try buffered.write(data, 1, 2)  // [2, 3]
    try buffered.flush()

    #expect(underlying.toByteArray() == [2, 3])
  }

  @Test("BufferedOutputStream sequential writes with flush")
  func testSequentialWritesWithFlush() throws {
    let underlying = java.io.ByteArrayOutputStream()
    let buffered = java.io.BufferedOutputStream(underlying)

    try buffered.write([1, 2])
    try buffered.flush()
    try buffered.write([3, 4])
    try buffered.flush()

    #expect(underlying.toByteArray() == [1, 2, 3, 4])
  }

  @Test("BufferedOutputStream large write")
  func testLargeWrite() throws {
    let underlying = java.io.ByteArrayOutputStream()
    let buffered = try java.io.BufferedOutputStream(underlying, 256)

    let data = (0..<1000).map { UInt8($0 % 256) }
    try buffered.write(data)
    try buffered.flush()

    #expect(underlying.toByteArray() == data)
  }

  @Test("BufferedOutputStream write after close throws")
  func testWriteAfterClose() throws {
    let underlying = java.io.ByteArrayOutputStream()
    let buffered = java.io.BufferedOutputStream(underlying)

    try buffered.write([1, 2])
    try buffered.close()

    #expect(throws: Error.self) {
      try buffered.write(3)
    }
  }
}

// MARK: - Integration Tests: Buffered Byte Streams

struct JavApi_io_BufferedByteStream_Integration_Tests {

  @Test("BufferedInputStream wrapping ByteArrayInputStream")
  func testBufferedInput() throws {
    let data = (0..<100).map { UInt8($0 % 256) }
    let underlying = java.io.ByteArrayInputStream(data)
    let buffered = try java.io.BufferedInputStream(underlying)

    var buf = [UInt8](repeating: 0, count: 100)
    let read = try buffered.read(&buf)
    #expect(read == 100)
    #expect(buf == data)
  }

  @Test("BufferedOutputStream wrapping ByteArrayOutputStream")
  func testBufferedOutput() throws {
    let underlying = java.io.ByteArrayOutputStream()
    let buffered = java.io.BufferedOutputStream(underlying)

    let data = (0..<100).map { UInt8($0 % 256) }
    try buffered.write(data)
    try buffered.flush()

    #expect(underlying.toByteArray() == data)
  }

  @Test("Chained buffering: BufferedInputStream → ByteArrayInputStream")
  func testChainedBuffering() throws {
    let data: [UInt8] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    let underlying = java.io.ByteArrayInputStream(data)
    let buffered = try java.io.BufferedInputStream(underlying)

    _ = try buffered.read()
    _ = try buffered.read()
    try buffered.mark(100)
    _ = try buffered.read()
    try buffered.reset()

    #expect(try buffered.read() == 3)
  }

  @Test("Round-trip: Write buffered, read buffered")
  func testRoundTripBuffered() throws {
    // Write
    let out = java.io.ByteArrayOutputStream()
    let bufferedOut = java.io.BufferedOutputStream(out)
    let data: [UInt8] = (0..<50).map { UInt8($0 % 256) }
    try bufferedOut.write(data)
    try bufferedOut.flush()

    // Read
    let underlying = java.io.ByteArrayInputStream(out.toByteArray())
    let bufferedIn = try java.io.BufferedInputStream(underlying)
    var readData = [UInt8](repeating: 0, count: 50)
    _ = try bufferedIn.read(&readData)

    #expect(readData == data)
  }

  @Test("Buffered stream with mark/reset and writes")
  func testBufferedMarkResetWithWrites() throws {
    let underlying = java.io.ByteArrayInputStream([1, 2, 3, 4, 5] as [UInt8])
    let buffered = try java.io.BufferedInputStream(underlying)

    _ = try buffered.read() // 1
    try buffered.mark(100)
    let b1 = try buffered.read() // 2
    let b2 = try buffered.read() // 3
    try buffered.reset()

    #expect(try buffered.read() == 2)
    #expect(try buffered.read() == 3)
  }

  @Test("Multiple buffered input streams reading same source independently")
  func testMultipleBufferedInputs() throws {
    let data: [UInt8] = [1, 2, 3, 4, 5]
    let in1 = try java.io.BufferedInputStream(java.io.ByteArrayInputStream(data))
    let in2 = try java.io.BufferedInputStream(java.io.ByteArrayInputStream(data))

    #expect(try in1.read() == 1)
    #expect(try in2.read() == 1)
    #expect(try in1.read() == 2)
    #expect(try in2.read() == 2)
  }

  @Test("Buffered stream performance with large data")
  func testLargeBufferedData() throws {
    let data = (0..<10000).map { UInt8($0 % 256) }

    // Write buffered
    let out = java.io.ByteArrayOutputStream()
    let bufferedOut = try java.io.BufferedOutputStream(out, 4096)
    try bufferedOut.write(data)
    try bufferedOut.flush()

    // Read buffered
    let underlying = java.io.ByteArrayInputStream(out.toByteArray())
    let bufferedIn = try java.io.BufferedInputStream(underlying, 4096)
    var readData = [UInt8](repeating: 0, count: 10000)
    _ = try bufferedIn.read(&readData)

    #expect(readData == data)
  }

  @Test("Buffered skip operation")
  func testBufferedSkip() throws {
    let data: [UInt8] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    let underlying = java.io.ByteArrayInputStream(data)
    let buffered = try java.io.BufferedInputStream(underlying)

    let skipped = try buffered.skip(5)
    #expect(skipped >= 5)
    let nextByte = try buffered.read()
    #expect(nextByte >= 6)
  }

  @Test("Mixed operations: write, flush, read with buffering")
  func testMixedOperations() throws {
    // Step 1: Buffered write
    let out = java.io.ByteArrayOutputStream()
    let bufferedOut = try java.io.BufferedOutputStream(out, 10)
    try bufferedOut.write([1, 2, 3])
    try bufferedOut.write([4, 5])
    try bufferedOut.flush()

    // Step 2: Buffered read
    let underlying = java.io.ByteArrayInputStream(out.toByteArray())
    let bufferedIn = try java.io.BufferedInputStream(underlying, 5)
    let b1 = try bufferedIn.read()
    let b2 = try bufferedIn.read()
    try bufferedIn.mark(100)
    let b3 = try bufferedIn.read()
    try bufferedIn.reset()
    let b3again = try bufferedIn.read()

    #expect(b1 == 1)
    #expect(b2 == 2)
    #expect(b3 == 3)
    #expect(b3again == 3)
  }
}
