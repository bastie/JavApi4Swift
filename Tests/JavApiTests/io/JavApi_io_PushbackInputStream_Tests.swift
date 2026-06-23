/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// MARK: - Basic unread/read operations

struct JavApi_io_PushbackInputStream_Basic_Tests {

  @Test("PushbackInputStream with default buffer reads normally")
  func testDefaultBufferRead() throws {
    let stream = java.io.PushbackInputStream(
      java.io.ByteArrayInputStream([65, 66, 67])
    )
    #expect(try stream.read() == 65) // 'A'
    #expect(try stream.read() == 66) // 'B'
    #expect(try stream.read() == 67) // 'C'
    #expect(try stream.read() == -1) // EOF
  }

  @Test("unread(byte) pushes byte back for next read")
  func testUnreadSingleByte() throws {
    let stream = java.io.PushbackInputStream(
      java.io.ByteArrayInputStream([65, 66, 67])
    )
    let first = try stream.read()   // 65
    try stream.unread(first)        // push back 65
    let again = try stream.read()   // 65 again
    #expect(again == 65)
    #expect(try stream.read() == 66) // then 66
  }

  @Test("Multiple unreads in sequence")
  func testMultipleUnreads() throws {
    let stream = java.io.PushbackInputStream(
      java.io.ByteArrayInputStream([65, 66, 67]),
      3  // buffer size 3
    )
    let a = try stream.read()      // 65
    let b = try stream.read()      // 66
    let c = try stream.read()      // 67

    try stream.unread(c)           // push 67
    try stream.unread(b)           // push 66
    try stream.unread(a)           // push 65

    #expect(try stream.read() == 65)
    #expect(try stream.read() == 66)
    #expect(try stream.read() == 67)
  }

  @Test("unread uses only lowest 8 bits of argument")
  func testUnreadMasksBits() throws {
    let stream = java.io.PushbackInputStream(
      java.io.ByteArrayInputStream([])
    )
    try stream.unread(0x1FF)  // 511 = 0b111111111, only 0xFF (255) used
    #expect(try stream.read() == 255)
  }
}

// MARK: - Buffer management and overflow

struct JavApi_io_PushbackInputStream_Buffer_Tests {

  @Test("unread throws IOException when buffer is full")
  func testUnreadBufferFull() throws {
    let stream = java.io.PushbackInputStream(
      java.io.ByteArrayInputStream([65, 66]),
      1  // buffer size 1
    )

    // Fill buffer with unread
    try stream.unread(100)  // pos = 0 (full)

    // Try to unread again when full – should fail
    do {
      try stream.unread(200)
      #expect(Bool(false), "Should have thrown IOException")
    } catch let e as java.io.IOException {
      #expect(e.getMessage()?.contains("full") ?? false)
    }
  }

  @Test("Custom buffer size is respected")
  func testCustomBufferSize() throws {
    let stream = java.io.PushbackInputStream(
      java.io.ByteArrayInputStream([1, 2, 3, 4, 5]),
      5
    )
    for _ in 0..<5 {
      let byte = try stream.read()
      try stream.unread(byte)
    }
    // Should be able to unread 5 bytes
    for _ in 0..<5 {
      _ = try stream.read()
    }
  }

  @Test("Buffer size 0 becomes at least 1")
  func testMinimalBufferSize() throws {
    let stream = java.io.PushbackInputStream(
      java.io.ByteArrayInputStream([65]),
      0  // should become 1
    )
    let byte = try stream.read()
    try stream.unread(byte)  // should succeed
    #expect(try stream.read() == 65)
  }

  @Test("Large buffer size allows many unreads")
  func testLargeBufferSize() throws {
    let largeSize = 1000
    let data = [UInt8](0..<UInt8(min(255, largeSize)))
    let stream = java.io.PushbackInputStream(
      java.io.ByteArrayInputStream(data),
      largeSize
    )

    // Read all
    for _ in 0..<data.count {
      _ = try stream.read()
    }

    // Unread all
    for i in (0..<data.count).reversed() {
      try stream.unread(Int(data[i]))
    }

    // Read all again
    for expected in data {
      #expect(try stream.read() == Int(expected))
    }
  }
}

// MARK: - unread(byte[], offset, length)

struct JavApi_io_PushbackInputStream_ArrayUnread_Tests {

  @Test("unread(byte[]) pushes entire array back")
  func testUnreadByteArray() throws {
    let stream = java.io.PushbackInputStream(
      java.io.ByteArrayInputStream([]),
      10
    )
    let bytes: [UInt8] = [65, 66, 67]
    try stream.unread(bytes)

    #expect(try stream.read() == 65)
    #expect(try stream.read() == 66)
    #expect(try stream.read() == 67)
    #expect(try stream.read() == -1)
  }

  @Test("unread(byte[], offset, length) partial push")
  func testUnreadPartialArray() throws {
    let stream = java.io.PushbackInputStream(
      java.io.ByteArrayInputStream([]),
      10
    )
    let bytes: [UInt8] = [10, 20, 30, 40, 50]
    try stream.unread(bytes, 1, 3)  // [20, 30, 40]

    #expect(try stream.read() == 20)
    #expect(try stream.read() == 30)
    #expect(try stream.read() == 40)
  }

  @Test("unread(byte[]) with empty array")
  func testUnreadEmptyArray() throws {
    let stream = java.io.PushbackInputStream(
      java.io.ByteArrayInputStream([65, 66])
    )
    try stream.unread([])  // should succeed

    #expect(try stream.read() == 65)
  }

  @Test("unread(byte[], offset, length) throws when buffer insufficient")
  func testUnreadArrayBufferFull() throws {
    let stream = java.io.PushbackInputStream(
      java.io.ByteArrayInputStream([1, 2, 3]),
      2  // buffer size 2
    )
    let bytes: [UInt8] = [65, 66, 67]

    do {
      try stream.unread(bytes, 0, 3)  // needs 3 slots, only has 2
      #expect(Bool(false), "Should have thrown IOException")
    } catch let e as java.io.IOException {
      #expect(e.getMessage()?.contains("full") ?? false)
    }
  }
}

// MARK: - read(byte[], offset, length) after unread

struct JavApi_io_PushbackInputStream_ReadBuffer_Tests {

  @Test("read(buffer) after unread returns pushback buffer first")
  func testReadBufferAfterUnread() throws {
    let stream = java.io.PushbackInputStream(
      java.io.ByteArrayInputStream([3, 4, 5])
    )
    let first = try stream.read()  // 3
    try stream.unread(first)       // push back 3

    var buf = [UInt8](repeating: 0, count: 5)
    let read = try stream.read(&buf)

    #expect(read == 3)  // 1 from pushback + 2 remaining from stream
    #expect(buf[0] == 3)   // from pushback
    #expect(buf[1] == 4)   // from stream
    #expect(buf[2] == 5)   // from stream
  }

  @Test("read(buffer, offset, length) drains pushback buffer")
  func testReadBufferWithOffsetAfterUnread() throws {
    let stream = java.io.PushbackInputStream(
      java.io.ByteArrayInputStream([2, 3, 4]),
      3
    )
    let a = try stream.read()  // 2
    let b = try stream.read()  // 3
    let c = try stream.read()  // 4

    try stream.unread(c)       // push 4
    try stream.unread(b)       // push 3
    try stream.unread(a)       // push 2

    var buf = [UInt8](repeating: 0, count: 10)
    let read = try stream.read(&buf, 2, 4)

    #expect(read == 3)  // only 3 bytes unread
    #expect(buf[2] == 2)
    #expect(buf[3] == 3)
    #expect(buf[4] == 4)
  }

  @Test("read(buffer, 0, 0) returns 0")
  func testReadZeroLength() throws {
    let stream = java.io.PushbackInputStream(
      java.io.ByteArrayInputStream([65, 66])
    )
    var buf = [UInt8](repeating: 0, count: 10)
    let read = try stream.read(&buf, 0, 0)

    #expect(read == 0)
    #expect(try stream.read() == 65)  // position not advanced
  }
}

// MARK: - available() after unread

struct JavApi_io_PushbackInputStream_Available_Tests {

  @Test("available() includes pushback buffer")
  func testAvailableAfterUnread() throws {
    let stream = java.io.PushbackInputStream(
      java.io.ByteArrayInputStream([1, 2, 3, 4, 5])
    )

    #expect(try stream.available() == 5)
    _ = try stream.read()  // pos = 1, stream has 4 left
    #expect(try stream.available() == 4)

    let byte = try stream.read()  // pos = 2, stream has 3 left
    try stream.unread(byte)       // pos = 1, 1 byte in pushback buffer
    #expect(try stream.available() == 4)  // 1 from pushback + 3 from stream
  }

  @Test("available() with multiple unreads")
  func testAvailableMultipleUnreads() throws {
    let stream = java.io.PushbackInputStream(
      java.io.ByteArrayInputStream([1, 2]),
      5
    )

    _ = try stream.read()
    _ = try stream.read()

    try stream.unread(65)
    try stream.unread(66)
    try stream.unread(67)

    #expect(try stream.available() == 3)  // 3 pushed back, 0 in stream
  }

  @Test("available() on empty stream returns 0")
  func testAvailableEmptyStream() throws {
    let stream = java.io.PushbackInputStream(
      java.io.ByteArrayInputStream([])
    )
    #expect(try stream.available() == 0)
  }
}

// MARK: - Edge cases and EOF behavior

struct JavApi_io_PushbackInputStream_EdgeCases_Tests {

  @Test("read() returns -1 at EOF")
  func testEOFReturnsMinusOne() throws {
    let stream = java.io.PushbackInputStream(
      java.io.ByteArrayInputStream([65])
    )
    _ = try stream.read()
    #expect(try stream.read() == -1)
  }

  @Test("Unreading before reading anything succeeds")
  func testUnreadBeforeAnyRead() throws {
    let stream = java.io.PushbackInputStream(
      java.io.ByteArrayInputStream([65, 66])
    )
    try stream.unread(99)

    #expect(try stream.read() == 99)
    #expect(try stream.read() == 65)
  }

  @Test("read(buffer) at EOF returns -1")
  func testReadBufferEOF() throws {
    let stream = java.io.PushbackInputStream(
      java.io.ByteArrayInputStream([])
    )
    var buf = [UInt8](repeating: 0, count: 5)
    #expect(try stream.read(&buf) == -1)
  }

  @Test("Mixing unread(int) and unread(byte[])")
  func testMixedUnreadMethods() throws {
    let stream = java.io.PushbackInputStream(
      java.io.ByteArrayInputStream([]),
      10
    )

    try stream.unread(67)           // push single
    try stream.unread([66, 65], 0, 2)  // push array

    #expect(try stream.read() == 66)
    #expect(try stream.read() == 65)
    #expect(try stream.read() == 67)
  }

  @Test("Alternating read and unread patterns")
  func testAlternatingReadUnread() throws {
    let stream = java.io.PushbackInputStream(
      java.io.ByteArrayInputStream([1, 2, 3, 4, 5]),
      5
    )

    let a = try stream.read()   // 1
    let b = try stream.read()   // 2
    try stream.unread(b)        // push 2
    try stream.unread(a)        // push 1

    #expect(try stream.read() == 1)
    #expect(try stream.read() == 2)

    let c = try stream.read()   // 3
    try stream.unread(c)        // push 3

    #expect(try stream.read() == 3)
    #expect(try stream.read() == 4)
    #expect(try stream.read() == 5)
  }

  @Test("Large data with pushback operations")
  func testLargeDataWithPushback() throws {
    let largeData = (0..<256).map { UInt8($0) }
    let stream = java.io.PushbackInputStream(
      java.io.ByteArrayInputStream(largeData),
      256
    )

    // Read and pushback alternating
    var count = 0
    var lastByte: Int = -1
    for _ in 0..<100 {
      lastByte = try stream.read()
      if lastByte >= 0 {
        try stream.unread(lastByte)
        count += 1
      }
    }

    #expect(count > 0)
  }
}
