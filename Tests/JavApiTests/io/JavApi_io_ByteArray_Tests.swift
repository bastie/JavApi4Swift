/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
import Foundation
@testable import JavApi

// MARK: - ByteArrayInputStream Advanced Tests

struct JavApi_io_ByteArrayInputStream_Advanced_Tests {

  @Test("ByteArrayInputStream with empty array returns -1 immediately")
  func testEmptyArray() throws {
    let stream = java.io.ByteArrayInputStream([])
    #expect(try stream.read() == -1)
    #expect(try stream.available() == 0)
  }

  @Test("ByteArrayInputStream.read(buffer) with empty array returns -1")
  func testReadEmptyArray() throws {
    let stream = java.io.ByteArrayInputStream([])
    var buf = [UInt8](repeating: 0, count: 10)
    let read = try stream.read(&buf)
    #expect(read == -1)
  }

  @Test("ByteArrayInputStream.markSupported() returns true")
  func testMarkSupported() throws {
    let stream = java.io.ByteArrayInputStream([1, 2, 3])
    #expect(stream.markSupported())
  }

  @Test("ByteArrayInputStream mark(readAheadLimit) parameter is ignored")
  func testMarkIgnoresReadAheadLimit() throws {
    let stream = java.io.ByteArrayInputStream([1, 2, 3, 4, 5])
    _ = try stream.read() // pos=1, read data[0]=1
    stream.mark(2)  // readAheadLimit=2 should be ignored, mark pos=1
    _ = try stream.read() // pos=2, read data[1]=2
    _ = try stream.read() // pos=3, read data[2]=3
    stream.reset()  // pos back to 1
    #expect(try stream.read() == 2) // Should read data[1]=2
  }

  @Test("ByteArrayInputStream multiple mark/reset cycles work")
  func testMultipleMarkResetCycles() throws {
    let stream = java.io.ByteArrayInputStream([1, 2, 3, 4, 5])

    // First cycle
    _ = try stream.read() // pos=1
    stream.mark(100)
    _ = try stream.read() // pos=2
    stream.reset()
    #expect(try stream.read() == 2)

    // Second cycle
    _ = try stream.read() // pos=3
    stream.mark(100)
    _ = try stream.read() // pos=4
    stream.reset()
    #expect(try stream.read() == 4)
  }

  @Test("ByteArrayInputStream.skip(negative) does nothing")
  func testSkipNegative() throws {
    let stream = java.io.ByteArrayInputStream([1, 2, 3])
    let skipped = try stream.skip(-5)
    #expect(skipped == 0)
    #expect(try stream.read() == 1)
  }

  @Test("ByteArrayInputStream.read(buffer, offset, length) with large offset")
  func testReadLargeOffset() throws {
    let stream = java.io.ByteArrayInputStream([1, 2, 3])
    var buf = [UInt8](repeating: 0, count: 10)
    let read = try stream.read(&buf, 7, 3)
    #expect(read == 3)
    #expect(buf[7] == 1)
    #expect(buf[8] == 2)
    #expect(buf[9] == 3)
  }

  @Test("ByteArrayInputStream.read(buffer, offset, length) with zero length")
  func testReadZeroLength() throws {
    let stream = java.io.ByteArrayInputStream([1, 2, 3])
    var buf = [UInt8](repeating: 0, count: 10)
    let read = try stream.read(&buf, 0, 0)
    #expect(read == 0)
    #expect(try stream.read() == 1) // Position not advanced
  }

  @Test("ByteArrayInputStream constructor with offset=0 and length=array.count")
  func testConstructorFullRange() throws {
    let data: [UInt8] = [10, 20, 30, 40, 50]
    let stream = java.io.ByteArrayInputStream(data, 0, data.count)
    #expect(try stream.available() == 5)
    #expect(try stream.read() == 10)
  }

  @Test("ByteArrayInputStream constructor with partial range")
  func testConstructorPartialRange() throws {
    let data: [UInt8] = [10, 20, 30, 40, 50]
    let stream = java.io.ByteArrayInputStream(data, 1, 3)
    #expect(try stream.available() == 3)
    #expect(try stream.read() == 20)
    #expect(try stream.read() == 30)
    #expect(try stream.read() == 40)
    #expect(try stream.read() == -1)
  }

  @Test("ByteArrayInputStream constructor with offset beyond array")
  func testConstructorOffsetBeyond() throws {
    let data: [UInt8] = [1, 2, 3]
    let stream = java.io.ByteArrayInputStream(data, 10, 5)
    // Constructor uses max(offset, 0) for pos, so pos=10
    #expect(try stream.read() == -1) // pos >= data.count
  }

  @Test("ByteArrayInputStream all bytes sequential read")
  func testSequentialRead() throws {
    let data: [UInt8] = [1, 2, 3, 4, 5]
    let stream = java.io.ByteArrayInputStream(data)
    for expected in data {
      #expect(try stream.read() == Int(expected))
    }
    #expect(try stream.read() == -1)
  }

  @Test("ByteArrayInputStream alternating read() and skip()")
  func testAlternatingReadSkip() throws {
    let stream = java.io.ByteArrayInputStream([1, 2, 3, 4, 5, 6, 7, 8])
    #expect(try stream.read() == 1)
    _ = try stream.skip(2)
    #expect(try stream.read() == 4)
    _ = try stream.skip(1)
    #expect(try stream.read() == 6)
  }

  @Test("ByteArrayInputStream.available() equals count minus pos")
  func testAvailableFormula() throws {
    let stream = java.io.ByteArrayInputStream([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    #expect(try stream.available() == 10)
    _ = try stream.read()
    #expect(try stream.available() == 9)
    _ = try stream.skip(3)
    #expect(try stream.available() == 6)
  }

  @Test("ByteArrayInputStream.read(buffer) reads fewer bytes at EOF")
  func testReadBufferPartialAtEOF() throws {
    let stream = java.io.ByteArrayInputStream([1, 2, 3])
    var buf1 = [UInt8](repeating: 0, count: 5)
    let read1 = try stream.read(&buf1) // Only 3 bytes available
    #expect(read1 == 3)
    #expect(buf1[0] == 1)
    #expect(buf1[1] == 2)
    #expect(buf1[2] == 3)

    var buf2 = [UInt8](repeating: 0, count: 5)
    let read2 = try stream.read(&buf2) // EOF
    #expect(read2 == -1)
  }
}

// MARK: - ByteArrayOutputStream Advanced Tests

struct JavApi_io_ByteArrayOutputStream_Advanced_Tests {

  @Test("ByteArrayOutputStream with custom initial size")
  func testCustomInitialSize() throws {
    let stream = java.io.ByteArrayOutputStream(100)
    try stream.write([1, 2, 3])
    #expect(stream.size() == 3)
  }

  @Test("ByteArrayOutputStream with size 1 still grows")
  func testMinimalSize() throws {
    let stream = java.io.ByteArrayOutputStream(1)
    for i in 0..<10 {
      try stream.write(i)
    }
    #expect(stream.size() == 10)
  }

  @Test("ByteArrayOutputStream.write(Int) with negative number masks correctly")
  func testWriteNegativeInt() throws {
    let stream = java.io.ByteArrayOutputStream()
    try stream.write(-1)  // 0xFFFFFFFF → only 0xFF used
    try stream.write(-128) // 0xFFFFFF80 → only 0x80 used
    let bytes = stream.toByteArray()
    #expect(bytes[0] == 0xFF)
    #expect(bytes[1] == 0x80)
  }

  @Test("ByteArrayOutputStream.write(buffer) with empty buffer")
  func testWriteEmptyBuffer() throws {
    let stream = java.io.ByteArrayOutputStream()
    try stream.write([])
    #expect(stream.size() == 0)
  }

  @Test("ByteArrayOutputStream.write(buffer, offset, 0) writes nothing")
  func testWriteZeroLength() throws {
    let stream = java.io.ByteArrayOutputStream()
    try stream.write([1, 2, 3, 4, 5], 2, 0)
    #expect(stream.size() == 0)
  }

  @Test("ByteArrayOutputStream.write(buffer, offset, length) partial write")
  func testWritePartial() throws {
    let stream = java.io.ByteArrayOutputStream()
    let data: [UInt8] = [10, 20, 30, 40, 50]
    try stream.write(data, 1, 2)  // Write [20, 30]
    #expect(stream.toByteArray() == [20, 30])
  }

  @Test("ByteArrayOutputStream sequential writes preserve order")
  func testSequentialWrites() throws {
    let stream = java.io.ByteArrayOutputStream()
    try stream.write(1)
    try stream.write(2)
    try stream.write([3, 4])
    try stream.write([5, 6, 7], 1, 2)  // [6, 7]
    #expect(stream.toByteArray() == [1, 2, 3, 4, 6, 7])
  }

  @Test("ByteArrayOutputStream.write(UInt8) works directly")
  func testWriteUInt8Direct() throws {
    let stream = java.io.ByteArrayOutputStream()
    try stream.write(UInt8(42))
    #expect(stream.toByteArray() == [42])
  }

  @Test("ByteArrayOutputStream.toString() with UTF-8 multi-byte characters")
  func testToStringUTF8() throws {
    let stream = java.io.ByteArrayOutputStream()
    // "Äpfel" in UTF-8: Ä=C3 84, p=70, f=66, e=65, l=6C
    let utf8Bytes: [UInt8] = [0xC3, 0x84, 0x70, 0x66, 0x65, 0x6C]
    try stream.write(utf8Bytes)
    let result = stream.toString()
    #expect(result.hasPrefix("Ä"))
  }

  @Test("ByteArrayOutputStream.reset() clears content")
  func testReset() throws {
    let stream = java.io.ByteArrayOutputStream()
    try stream.write([1, 2, 3])
    #expect(stream.size() == 3)
    stream.reset()
    #expect(stream.size() == 0)
    #expect(stream.toByteArray().isEmpty)
  }

  @Test("ByteArrayOutputStream.reset() allows reuse")
  func testResetReuse() throws {
    let stream = java.io.ByteArrayOutputStream()

    // First use
    try stream.write([1, 2, 3])
    #expect(stream.toByteArray() == [1, 2, 3])

    // Reset and reuse
    stream.reset()
    try stream.write([10, 20])
    #expect(stream.toByteArray() == [10, 20])
  }

  @Test("ByteArrayOutputStream large buffer stress test")
  func testLargeBuffer() throws {
    let stream = java.io.ByteArrayOutputStream()
    let largeData = (0..<10000).map { UInt8($0 % 256) }
    try stream.write(largeData)
    #expect(stream.size() == 10000)
    #expect(stream.toByteArray().count == 10000)
  }

  @Test("ByteArrayOutputStream write after flush still works")
  func testWriteAfterFlush() throws {
    let stream = java.io.ByteArrayOutputStream()
    try stream.write([1, 2])
    try stream.flush()
    try stream.write([3, 4])
    #expect(stream.toByteArray() == [1, 2, 3, 4])
  }

  @Test("ByteArrayOutputStream write after close still works (Java semantics)")
  func testWriteAfterClose() throws {
    let stream = java.io.ByteArrayOutputStream()
    try stream.write([1, 2, 3])
    try stream.close()
    // Java doesn't prevent writes after close
    try stream.write([4, 5])
    #expect(stream.toByteArray() == [1, 2, 3, 4, 5])
  }

  @Test("ByteArrayOutputStream.writeTo() delegates correctly")
  func testWriteTo() throws {
    let source = java.io.ByteArrayOutputStream()
    try source.write([1, 2, 3])

    let dest = java.io.ByteArrayOutputStream()
    try source.writeTo(dest)
    #expect(dest.toByteArray() == [1, 2, 3])
  }

  @Test("ByteArrayOutputStream.toString(charset) uses specified charset")
  func testToStringCharset() throws {
    let stream = java.io.ByteArrayOutputStream()
    try stream.write([72, 101, 108, 108, 111])  // "Hello" in ASCII/UTF-8
    // ASCII: should work fine for this data
    let result = try stream.toString("UTF-8")
    #expect(result == "Hello")
  }

  @Test("ByteArrayOutputStream alternating write and read from external stream")
  func testWriteReadCycle() throws {
    let out = java.io.ByteArrayOutputStream()
    try out.write([10, 20, 30])

    let `in` = java.io.ByteArrayInputStream(out.toByteArray())
    #expect(try `in`.read() == 10)
    #expect(try `in`.read() == 20)
    #expect(try `in`.read() == 30)
  }
}

// MARK: - ByteArrayInputStream/OutputStream Integration Tests

struct JavApi_io_ByteArray_Integration_Tests {

  @Test("Round-trip: write to output, read from input")
  func testRoundTrip() throws {
    let out = java.io.ByteArrayOutputStream()
    let originalData: [UInt8] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    try out.write(originalData)

    let `in` = java.io.ByteArrayInputStream(out.toByteArray())
    var readData = [UInt8](repeating: 0, count: 10)
    _ = try `in`.read(&readData)

    #expect(readData == originalData)
  }

  @Test("InputStream/OutputStream with large data")
  func testLargeDataRoundTrip() throws {
    let out = java.io.ByteArrayOutputStream()
    let largeData = (0..<1000).map { UInt8($0 % 256) }
    try out.write(largeData)

    let `in` = java.io.ByteArrayInputStream(out.toByteArray())
    var readData = [UInt8](repeating: 0, count: 1000)
    _ = try `in`.read(&readData)

    #expect(readData == largeData)
  }

  @Test("String write/read round-trip through ByteArray streams")
  func testStringRoundTrip() throws {
    let message = "Hello, ByteArray Streams!"

    let out = java.io.ByteArrayOutputStream()
    try out.write([UInt8](message.utf8))

    let `in` = java.io.ByteArrayInputStream(out.toByteArray())
    var buffer = [UInt8](repeating: 0, count: out.size())
    _ = try `in`.read(&buffer)

    let result = String(bytes: buffer, encoding: .utf8)
    #expect(result == message)
  }

  @Test("Multiple inputs can read from same output")
  func testMultipleInputs() throws {
    let out = java.io.ByteArrayOutputStream()
    try out.write([1, 2, 3, 4, 5])

    let bytes = out.toByteArray()
    let in1 = java.io.ByteArrayInputStream(bytes)
    let in2 = java.io.ByteArrayInputStream(bytes)

    #expect(try in1.read() == 1)
    #expect(try in2.read() == 1)
    #expect(try in1.read() == 2)
    #expect(try in2.read() == 2)
  }

  @Test("InputStream position independent from OutputStream")
  func testIndependentPositions() throws {
    let out = java.io.ByteArrayOutputStream()
    let `in` = java.io.ByteArrayInputStream([1, 2, 3, 4, 5])

    // Reading from input doesn't affect output position
    _ = try `in`.read()
    _ = try `in`.read()

    try out.write([10, 20])
    #expect(out.size() == 2)
    #expect(try `in`.available() == 3)
  }
}
