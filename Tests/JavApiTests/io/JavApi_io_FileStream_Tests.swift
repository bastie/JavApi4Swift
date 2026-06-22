/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
import Foundation
@testable import JavApi

// MARK: - FileInputStream Tests

struct JavApi_io_FileInputStream_Tests {

  private func tempFile(content: [UInt8]? = nil) throws -> String {
    let tempDir = NSTemporaryDirectory()
    let fileName = "test_\(UUID().uuidString).bin"
    let path = tempDir + fileName

    if let data = content {
      try Data(data).write(to: URL(fileURLWithPath: path))
    } else {
      FileManager.default.createFile(atPath: path, contents: nil)
    }
    return path
  }

  private func cleanupFile(_ path: String) {
    try? FileManager.default.removeItem(atPath: path)
  }

  @Test("FileInputStream reads file content sequentially")
  func testReadSequential() throws {
    let path = try tempFile(content: [1, 2, 3, 4, 5])
    defer { cleanupFile(path) }

    let stream = try java.io.FileInputStream(path)
    defer { try? stream.close() }

    #expect(try stream.read() == 1)
    #expect(try stream.read() == 2)
    #expect(try stream.read() == 3)
    #expect(try stream.read() == 4)
    #expect(try stream.read() == 5)
    #expect(try stream.read() == -1)
  }

  @Test("FileInputStream.read(buffer) reads multiple bytes")
  func testReadBuffer() throws {
    let path = try tempFile(content: [10, 20, 30, 40, 50])
    defer { cleanupFile(path) }

    let stream = try java.io.FileInputStream(path)
    defer { try? stream.close() }

    var buf = [UInt8](repeating: 0, count: 3)
    let read = try stream.read(&buf)
    #expect(read == 3)
    #expect(buf == [10, 20, 30])
  }

  @Test("FileInputStream.available() returns remaining bytes")
  func testAvailable() throws {
    let path = try tempFile(content: [1, 2, 3, 4, 5])
    defer { cleanupFile(path) }

    let stream = try java.io.FileInputStream(path)
    defer { try? stream.close() }

    _ = try stream.read()
    let available = try stream.available()
    #expect(available > 0) // At least some bytes remain (exact value is implementation-dependent)
  }

  @Test("FileInputStream.skip() advances position")
  func testSkip() throws {
    let path = try tempFile(content: [1, 2, 3, 4, 5])
    defer { cleanupFile(path) }

    let stream = try java.io.FileInputStream(path)
    defer { try? stream.close() }

    let skipped = try stream.skip(2)
    #expect(skipped == 2)
    #expect(try stream.read() == 3)
  }

  @Test("FileInputStream.close() closes the stream")
  func testClose() throws {
    let path = try tempFile(content: [1, 2, 3])
    defer { cleanupFile(path) }

    let stream = try java.io.FileInputStream(path)
    try stream.close()
    // Reading from closed stream may throw IOException
    #expect(throws: Error.self) {
      try stream.read()
    }
  }

  @Test("FileInputStream with non-existent file throws FileNotFoundException")
  func testFileNotFound() {
    let path = "/nonexistent/path/\(UUID().uuidString).bin"
    #expect(throws: java.io.FileNotFoundException.self) {
      try java.io.FileInputStream(path)
    }
  }

  @Test("FileInputStream reads entire file into buffer")
  func testReadEntireFile() throws {
    let originalData: [UInt8] = Array(0..<256).map { UInt8($0 % 256) }
    let path = try tempFile(content: originalData)
    defer { cleanupFile(path) }

    let stream = try java.io.FileInputStream(path)
    defer { try? stream.close() }

    var buffer = [UInt8](repeating: 0, count: 256)
    let read = try stream.read(&buffer)
    #expect(read == 256)
    #expect(buffer == originalData)
  }

  @Test("FileInputStream with offset read")
  func testReadWithOffset() throws {
    let path = try tempFile(content: [10, 20, 30, 40, 50])
    defer { cleanupFile(path) }

    let stream = try java.io.FileInputStream(path)
    defer { try? stream.close() }

    var buf = [UInt8](repeating: 0, count: 10)
    let read = try stream.read(&buf, 3, 2)
    #expect(read == 2)
    #expect(buf[3] == 10)
    #expect(buf[4] == 20)
  }

  @Test("FileInputStream on empty file returns -1 immediately")
  func testEmptyFile() throws {
    let path = try tempFile(content: [])
    defer { cleanupFile(path) }

    let stream = try java.io.FileInputStream(path)
    defer { try? stream.close() }

    #expect(try stream.read() == -1)
  }
}

// MARK: - FileOutputStream Tests

struct JavApi_io_FileOutputStream_Tests {

  private func tempDir() -> String {
    NSTemporaryDirectory()
  }

  private func newTempPath() -> String {
    let tempDir = NSTemporaryDirectory()
    let fileName = "test_\(UUID().uuidString).bin"
    return tempDir + fileName
  }

  private func readFileContent(_ path: String) throws -> [UInt8] {
    try [UInt8](Data(contentsOf: URL(fileURLWithPath: path)))
  }

  private func cleanupFile(_ path: String) {
    try? FileManager.default.removeItem(atPath: path)
  }

  @Test("FileOutputStream writes single bytes to new file")
  func testWriteSingleBytes() throws {
    let path = newTempPath()
    defer { cleanupFile(path) }

    let stream = try java.io.FileOutputStream(path)
    defer { try? stream.close() }

    try stream.write(65)  // 'A'
    try stream.write(66)  // 'B'
    try stream.write(67)  // 'C'
    try stream.flush()

    let content = try readFileContent(path)
    #expect(content == [65, 66, 67])
  }

  @Test("FileOutputStream overwrites existing file by default")
  func testOverwriteFile() throws {
    let path = newTempPath()
    defer { cleanupFile(path) }

    // Write initial content
    try Data([1, 2, 3, 4, 5]).write(to: URL(fileURLWithPath: path))

    // Open without append flag (false) - should overwrite
    let stream = try java.io.FileOutputStream(path, false)
    defer { try? stream.close() }
    try stream.write([10, 20] as [UInt8])
    try stream.flush()

    let content = try readFileContent(path)
    #expect(content == [10, 20]) // Old content overwritten
  }

  @Test("FileOutputStream with append flag preserves existing content")
  func testAppendMode() throws {
    let path = newTempPath()
    defer { cleanupFile(path) }

    // Write initial content
    try Data([1, 2, 3]).write(to: URL(fileURLWithPath: path))

    // Open with append flag (true) - preserves existing content
    let stream = try java.io.FileOutputStream(path, true)
    defer { try? stream.close() }
    try stream.write([4, 5] as [UInt8])
    try stream.flush()

    let content = try readFileContent(path)
    #expect(content == [1, 2, 3, 4, 5])
  }

  @Test("FileOutputStream.write(buffer) writes entire array")
  func testWriteBuffer() throws {
    let path = newTempPath()
    defer { cleanupFile(path) }

    let stream = try java.io.FileOutputStream(path)
    defer { try? stream.close() }

    try stream.write([10, 20, 30, 40, 50])
    try stream.flush()

    let content = try readFileContent(path)
    #expect(content == [10, 20, 30, 40, 50])
  }

  @Test("FileOutputStream.write(buffer, offset, length) writes partial data")
  func testWritePartial() throws {
    let path = newTempPath()
    defer { cleanupFile(path) }

    let stream = try java.io.FileOutputStream(path)
    defer { try? stream.close() }

    let data: [UInt8] = [1, 2, 3, 4, 5]
    try stream.write(data, 1, 3)  // [2, 3, 4]
    try stream.flush()

    let content = try readFileContent(path)
    #expect(content == [2, 3, 4])
  }

  @Test("FileOutputStream.flush() persists data")
  func testFlush() throws {
    let path = newTempPath()
    defer { cleanupFile(path) }

    let stream = try java.io.FileOutputStream(path)
    try stream.write([1, 2, 3])
    try stream.flush()

    // Should be readable immediately after flush
    let content = try readFileContent(path)
    #expect(content == [1, 2, 3])
  }

  @Test("FileOutputStream.close() finalizes write")
  func testClose() throws {
    let path = newTempPath()
    defer { cleanupFile(path) }

    let stream = try java.io.FileOutputStream(path)
    try stream.write([10, 20, 30])
    try stream.close()

    let content = try readFileContent(path)
    #expect(content == [10, 20, 30])
  }

  @Test("FileOutputStream multiple writes sequentially")
  func testSequentialWrites() throws {
    let path = newTempPath()
    defer { cleanupFile(path) }

    let stream = try java.io.FileOutputStream(path)
    defer { try? stream.close() }

    try stream.write(1)
    try stream.write([2, 3])
    try stream.write([4, 5, 6], 1, 2)  // [5, 6]
    try stream.flush()

    let content = try readFileContent(path)
    #expect(content == [1, 2, 3, 5, 6])
  }

  @Test("FileOutputStream with invalid path throws IOException")
  func testInvalidPath() {
    let invalidPath = "/root/cannot/write/here/\(UUID().uuidString).bin"
    #expect(throws: Error.self) {
      try java.io.FileOutputStream(invalidPath)
    }
  }

  @Test("FileOutputStream write after close throws IOException")
  func testWriteAfterClose() throws {
    let path = newTempPath()
    defer { cleanupFile(path) }

    let stream = try java.io.FileOutputStream(path)
    try stream.close()

    #expect(throws: Error.self) {
      try stream.write(1)
    }
  }
}

// MARK: - FileInputStream/FileOutputStream Integration Tests

struct JavApi_io_FileStream_Integration_Tests {

  private func newTempPath() -> String {
    let tempDir = NSTemporaryDirectory()
    let fileName = "test_\(UUID().uuidString).bin"
    return tempDir + fileName
  }

  private func cleanupFile(_ path: String) {
    try? FileManager.default.removeItem(atPath: path)
  }

  @Test("Round-trip: write file then read it back")
  func testRoundTrip() throws {
    let path = newTempPath()
    defer { cleanupFile(path) }

    let originalData: [UInt8] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

    // Write
    let out = try java.io.FileOutputStream(path)
    defer { try? out.close() }
    try out.write(originalData)

    // Read
    let `in` = try java.io.FileInputStream(path)
    defer { try? `in`.close() }
    var readData = [UInt8](repeating: 0, count: 10)
    _ = try `in`.read(&readData)

    #expect(readData == originalData)
  }

  @Test("Write file, close, reopen and append")
  func testWriteCloseAppend() throws {
    let path = newTempPath()
    defer { cleanupFile(path) }

    // First write
    let out1 = try java.io.FileOutputStream(path)
    try out1.write([1, 2, 3] as [UInt8])
    try out1.close()

    // Reopen with append flag (true)
    let out2 = try java.io.FileOutputStream(path, true)
    try out2.write([4, 5] as [UInt8])
    try out2.close()

    // Verify - both writes present
    let `in` = try java.io.FileInputStream(path)
    defer { try? `in`.close() }
    var buffer = [UInt8](repeating: 0, count: 5)
    _ = try `in`.read(&buffer)
    #expect(buffer == [1, 2, 3, 4, 5])
  }

  @Test("Multiple sequential reads after write")
  func testMultipleReads() throws {
    let path = newTempPath()
    defer { cleanupFile(path) }

    // Write
    let out = try java.io.FileOutputStream(path)
    try out.write([10, 20, 30, 40, 50])
    try out.close()

    // Read sequentially
    let `in` = try java.io.FileInputStream(path)
    defer { try? `in`.close() }

    var buf1 = [UInt8](repeating: 0, count: 2)
    let read1 = try `in`.read(&buf1)
    #expect(read1 == 2)
    #expect(buf1 == [10, 20])

    var buf2 = [UInt8](repeating: 0, count: 3)
    let read2 = try `in`.read(&buf2)
    #expect(read2 == 3)
    #expect(buf2 == [30, 40, 50])

    var buf3 = [UInt8](repeating: 0, count: 5)
    let read3 = try `in`.read(&buf3)
    #expect(read3 == -1) // EOF
  }

  @Test("Large file write and read")
  func testLargeFile() throws {
    let path = newTempPath()
    defer { cleanupFile(path) }

    let largeData = (0..<10000).map { UInt8($0 % 256) }

    // Write
    let out = try java.io.FileOutputStream(path)
    try out.write(largeData)
    try out.close()

    // Read
    let `in` = try java.io.FileInputStream(path)
    defer { try? `in`.close() }
    var readData = [UInt8](repeating: 0, count: 10000)
    _ = try `in`.read(&readData)

    #expect(readData == largeData)
  }

  @Test("Write UTF-8 string to file and read back")
  func testStringRoundTrip() throws {
    let path = newTempPath()
    defer { cleanupFile(path) }

    let message = "Hello, FileStreams! 🚀"
    let utf8Data = [UInt8](message.utf8)

    // Write
    let out = try java.io.FileOutputStream(path)
    try out.write(utf8Data)
    try out.close()

    // Read
    let `in` = try java.io.FileInputStream(path)
    defer { try? `in`.close() }
    var buffer = [UInt8](repeating: 0, count: utf8Data.count)
    _ = try `in`.read(&buffer)

    let result = String(bytes: buffer, encoding: .utf8)
    #expect(result == message)
  }

  @Test("skip() and read() combined in same stream")
  func testSkipAndRead() throws {
    let path = newTempPath()
    defer { cleanupFile(path) }

    // Write
    let out = try java.io.FileOutputStream(path)
    try out.write([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    try out.close()

    // Read with skip
    let `in` = try java.io.FileInputStream(path)
    defer { try? `in`.close() }

    _ = try `in`.skip(3)  // Skip first 3 bytes
    #expect(try `in`.read() == 4)
    _ = try `in`.skip(2)  // Skip 2 more
    #expect(try `in`.read() == 7)
  }
}
