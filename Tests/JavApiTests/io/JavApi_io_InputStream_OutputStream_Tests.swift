/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
import Foundation
@testable import JavApi

// MARK: - InputStream Abstract Tests

struct JavApi_io_InputStream_Tests {

  @Test("InputStream.available() returns 0 by default")
  func testAvailableDefault() throws {
    let stream = java.io.InputStream()
    #expect(try stream.available() == 0)
  }

  @Test("InputStream.close() does nothing by default (no throw)")
  func testCloseDefault() throws {
    let stream = java.io.InputStream()
    try stream.close()
  }

  @Test("InputStream.read() throws EOFException by default")
  func testReadThrowsDefault() {
    let stream = java.io.InputStream()
    #expect(throws: java.io.EOFException.self) {
      try stream.read()
    }
  }

  @Test("InputStream.read(buffer) delegates to read(buffer, offset, length)")
  func testReadBufferDelegates() throws {
    let stream = ByteArrayInputStreamStub([1, 2, 3] as [UInt8])
    var buf = [UInt8](repeating: 0, count: 3)
    let read = try stream.read(&buf)
    #expect(read == 3)
    #expect(buf == [1, 2, 3])
  }

  @Test("InputStream.read(buffer, offset, length) throws by default")
  func testReadBufferWithOffsetThrowsDefault() {
    let stream = java.io.InputStream()
    var buf = [UInt8](repeating: 0, count: 10)
    #expect(throws: java.io.EOFException.self) {
      try stream.read(&buf, 0, 10)
    }
  }

  @Test("InputStream.skip(n) reads n bytes and returns count read")
  func testSkip() throws {
    let stream = ByteArrayInputStreamStub([1, 2, 3, 4, 5] as [UInt8])
    let skipped = try stream.skip(3)
    #expect(skipped == 3)
    // Nach skip(3) sollte read() 4 zurückgeben (4. Byte)
    #expect(try stream.read() == 4)
  }

  @Test("InputStream.skip(0) skips no bytes")
  func testSkipZero() throws {
    let stream = ByteArrayInputStreamStub([1, 2, 3] as [UInt8])
    let skipped = try stream.skip(0)
    #expect(skipped == 0)
    #expect(try stream.read() == 1)
  }

  @Test("InputStream.nullInputStream() returns empty stream")
  func testNullInputStream() throws {
    let stream = java.io.InputStream.nullInputStream()
    let read = try stream.read()
    #expect(read == -1) // EOF
  }
}

// MARK: - OutputStream Abstract Tests

struct JavApi_io_OutputStream_Tests {

  @Test("OutputStream.close() does nothing by default (no throw)")
  func testCloseDefault() throws {
    let stream = java.io.OutputStream()
    try stream.close()
  }

  @Test("OutputStream.flush() does nothing by default (no throw)")
  func testFlushDefault() throws {
    let stream = java.io.OutputStream()
    try stream.flush()
  }

  @Test("OutputStream.write(Int) throws by default")
  func testWriteIntThrowsDefault() {
    let stream = java.io.OutputStream()
    #expect(throws: Error.self) {
      try stream.write(42)
    }
  }

  @Test("OutputStream.write(UInt8) throws by default")
  func testWriteUInt8ThrowsDefault() {
    let stream = java.io.OutputStream()
    #expect(throws: Error.self) {
      try stream.write(UInt8(42))
    }
  }

  @Test("OutputStream.write(buffer) throws by default")
  func testWriteBufferThrowsDefault() {
    let stream = java.io.OutputStream()
    let buf = [UInt8]([1, 2, 3])
    #expect(throws: Error.self) {
      try stream.write(buf)
    }
  }

  @Test("OutputStream.write(buffer, offset, length) throws by default")
  func testWriteBufferWithOffsetThrowsDefault() {
    let stream = java.io.OutputStream()
    let buf = [UInt8]([1, 2, 3, 4, 5])
    #expect(throws: Error.self) {
      try stream.write(buf, 1, 3)
    }
  }

  @Test("OutputStream.nullOutputStream() returns working stream")
  func testNullOutputStream() throws {
    let stream = java.io.OutputStream.nullOutputStream()
    try stream.close()
    try stream.flush()
  }
}

// MARK: - Integration Tests: ByteArrayInputStream as Concrete Implementation

struct JavApi_io_ByteArrayInputStream_Concrete_Tests {

  @Test("ByteArrayInputStream.read() returns -1 at EOF")
  func testReadEOF() throws {
    let stream = java.io.ByteArrayInputStream([1, 2])
    _ = try stream.read() // 1
    _ = try stream.read() // 2
    let eof = try stream.read()
    #expect(eof == -1)
  }

  @Test("ByteArrayInputStream.available() decreases as bytes are read")
  func testAvailableDecreases() throws {
    let stream = java.io.ByteArrayInputStream([1, 2, 3, 4, 5])
    #expect(try stream.available() == 5)
    _ = try stream.read()
    #expect(try stream.available() == 4)
    _ = try stream.read()
    #expect(try stream.available() == 3)
  }

  @Test("ByteArrayInputStream.skip() skips bytes correctly")
  func testSkipCorrectly() throws {
    let stream = java.io.ByteArrayInputStream([10, 20, 30, 40, 50])
    let skipped = try stream.skip(2)
    #expect(skipped == 2)
    #expect(try stream.read() == 30)
  }

  @Test("ByteArrayInputStream.skip() beyond available returns available count")
  func testSkipBeyondAvailable() throws {
    let stream = java.io.ByteArrayInputStream([1, 2, 3] as [UInt8])
    let skipped = try stream.skip(10)
    #expect(skipped == 3)
    #expect(try stream.read() == -1) // EOF
  }

  @Test("ByteArrayInputStream.mark() and reset() restore position")
  func testMarkAndReset() throws {
    let stream = java.io.ByteArrayInputStream([1, 2, 3, 4, 5])
    _ = try stream.read() // pos=1
    _ = try stream.read() // pos=2
    stream.mark(100)
    _ = try stream.read() // pos=3
    _ = try stream.read() // pos=4
    stream.reset()
    #expect(try stream.read() == 3) // pos should be back to 2, next read is 3
  }

  @Test("ByteArrayInputStream.read(buffer, offset, length) writes to correct position")
  func testReadIntoBuffer() throws {
    let stream = java.io.ByteArrayInputStream([10, 20, 30, 40, 50])
    var buf = [UInt8](repeating: 0, count: 10)
    let read = try stream.read(&buf, 2, 3)
    #expect(read == 3)
    #expect(buf[2] == 10)
    #expect(buf[3] == 20)
    #expect(buf[4] == 30)
  }

  @Test("ByteArrayInputStream with offset constructor reads from offset")
  func testInitWithOffset() throws {
    let data: [UInt8] = [1, 2, 3, 4, 5]
    let stream = java.io.ByteArrayInputStream(data, 2, 3)
    #expect(try stream.available() == 3)
    #expect(try stream.read() == 3) // pos 2 → data[2]
    #expect(try stream.read() == 4) // pos 3 → data[3]
  }

  @Test("ByteArrayInputStream.close() does nothing (no error)")
  func testCloseDoesNothing() throws {
    let stream = java.io.ByteArrayInputStream([1, 2, 3] as [UInt8])
    try stream.close()
    // Stream should still be readable
    #expect(try stream.read() == 1)
  }
}

// MARK: - Integration Tests: ByteArrayOutputStream

struct JavApi_io_ByteArrayOutputStream_Concrete_Tests {

  @Test("ByteArrayOutputStream.write(Int) stores single byte")
  func testWriteInt() throws {
    let stream = java.io.ByteArrayOutputStream()
    try stream.write(72)   // 'H'
    try stream.write(105)  // 'i'
    #expect(stream.toString() == "Hi")
  }

  @Test("ByteArrayOutputStream.write(Int) uses only lowest 8 bits")
  func testWriteIntMasks() throws {
    let stream = java.io.ByteArrayOutputStream()
    try stream.write(0x1FF)  // 511 → only 0xFF used
    try stream.write(0x100)  // 256 → only 0x00 used
    let bytes = stream.toByteArray()
    #expect(bytes.count == 2)
    #expect(bytes[0] == 0xFF)
    #expect(bytes[1] == 0x00)
  }

  @Test("ByteArrayOutputStream.write(buffer) stores all bytes")
  func testWriteBuffer() throws {
    let stream = java.io.ByteArrayOutputStream()
    try stream.write([72, 101, 108, 108, 111])  // "Hello"
    #expect(stream.toString() == "Hello")
  }

  @Test("ByteArrayOutputStream.write(buffer, offset, length) stores partial bytes")
  func testWriteBufferPartial() throws {
    let stream = java.io.ByteArrayOutputStream()
    let data: [UInt8] = [72, 101, 108, 108, 111]  // "Hello"
    try stream.write(data, 1, 3)  // "ell"
    #expect(stream.toString() == "ell")
  }

  @Test("ByteArrayOutputStream buffer grows automatically")
  func testBufferGrows() throws {
    let stream = java.io.ByteArrayOutputStream(2)  // Start with 2 bytes
    for i in 0..<100 {
      try stream.write(i % 256)
    }
    #expect(stream.toByteArray().count == 100)
  }

  @Test("ByteArrayOutputStream.toByteArray() returns copy of internal buffer")
  func testToByteArray() throws {
    let stream = java.io.ByteArrayOutputStream()
    try stream.write([1, 2, 3])
    let bytes = stream.toByteArray()
    #expect(bytes == [1, 2, 3])
  }

  @Test("ByteArrayOutputStream.toString() converts bytes to UTF-8 string")
  func testToString() throws {
    let stream = java.io.ByteArrayOutputStream()
    let helloBytes: [UInt8] = [72, 101, 108, 108, 111]  // "Hello"
    try stream.write(helloBytes)
    #expect(stream.toString() == "Hello")
  }

  @Test("ByteArrayOutputStream.size() returns byte count")
  func testSize() throws {
    let stream = java.io.ByteArrayOutputStream()
    #expect(stream.size() == 0)
    try stream.write(1)
    #expect(stream.size() == 1)
    try stream.write([2, 3, 4] as [UInt8])
    #expect(stream.size() == 4)
  }

  @Test("ByteArrayOutputStream.flush() does nothing (no throw)")
  func testFlush() throws {
    let stream = java.io.ByteArrayOutputStream()
    try stream.write([1, 2, 3])
    try stream.flush()  // Should not throw
    #expect(stream.toByteArray() == [1, 2, 3])
  }

  @Test("ByteArrayOutputStream.close() does nothing (no throw)")
  func testClose() throws {
    let stream = java.io.ByteArrayOutputStream()
    try stream.write([1, 2, 3])
    try stream.close()
    // After close, should still be usable in Java semantics
    #expect(stream.toByteArray() == [1, 2, 3])
  }
}

// MARK: - Helper Stub for Testing

private class ByteArrayInputStreamStub: java.io.InputStream {
  let stream: java.io.ByteArrayInputStream

  init(_ data: [UInt8]) {
    stream = java.io.ByteArrayInputStream(data)
    super.init()
  }

  override func available() throws -> Int {
    return try stream.available()
  }

  override func read() throws -> Int {
    return try stream.read()
  }

  override func read(_ array: inout [UInt8], _ offset: Int, _ length: Int) throws -> Int {
    return try stream.read(&array, offset, length)
  }

  override func skip(_ n: Int) throws -> Int {
    return Int(try stream.skip(Int64(n)))
  }
}
