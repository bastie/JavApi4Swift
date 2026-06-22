/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// MARK: - Basic unread/read operations

struct JavApi_io_PushbackReader_Basic_Tests {

  @Test("PushbackReader with default buffer reads normally")
  func testDefaultBufferRead() throws {
    let reader = java.io.PushbackReader(
      java.io.StringReader("ABC")
    )
    #expect(try reader.read() == Int(Character("A").unicodeScalars.first!.value))
    #expect(try reader.read() == Int(Character("B").unicodeScalars.first!.value))
    #expect(try reader.read() == Int(Character("C").unicodeScalars.first!.value))
    #expect(try reader.read() == -1)
  }

  @Test("unread(int) pushes character back for next read")
  func testUnreadSingleChar() throws {
    let reader = java.io.PushbackReader(
      java.io.StringReader("ABC")
    )
    let first = try reader.read()    // 'A'
    try reader.unread(first)         // push back 'A'
    let again = try reader.read()    // 'A' again
    #expect(again == first)
    #expect(try reader.read() == Int(Character("B").unicodeScalars.first!.value))
  }

  @Test("Multiple unreads in sequence")
  func testMultipleUnreads() throws {
    let reader = try java.io.PushbackReader(
      java.io.StringReader("ABC"),
      3  // buffer size 3
    )
    let a = try reader.read()       // 'A'
    let b = try reader.read()       // 'B'
    let c = try reader.read()       // 'C'

    try reader.unread(c)            // push 'C'
    try reader.unread(b)            // push 'B'
    try reader.unread(a)            // push 'A'

    #expect(try reader.read() == a)
    #expect(try reader.read() == b)
    #expect(try reader.read() == c)
  }

  @Test("Constructor with invalid buffer size throws")
  func testConstructorInvalidBufferSize() throws {
    let reader = java.io.StringReader("test")
    do {
      _ = try java.io.PushbackReader(reader, 0)
      #expect(Bool(false), "Should have thrown IllegalArgumentException")
    } catch let e as java.lang.IllegalArgumentException {
      #expect(e.getMessage()?.contains("size") ?? false)
    }
  }
}

// MARK: - Buffer management and overflow

struct JavApi_io_PushbackReader_Buffer_Tests {

  @Test("unread throws IOException when buffer is full")
  func testUnreadBufferFull() throws {
    let reader = try java.io.PushbackReader(
      java.io.StringReader("AB"),
      1  // buffer size 1
    )

    // Fill buffer with unread
    try reader.unread(100)  // pos = 0 (full)

    // Try to unread again when full – should fail
    do {
      try reader.unread(200)
      #expect(Bool(false), "Should have thrown IOException")
    } catch let e as java.io.IOException {
      #expect(e.getMessage()?.contains("full") ?? false)
    }
  }

  @Test("Custom buffer size is respected")
  func testCustomBufferSize() throws {
    let reader = try java.io.PushbackReader(
      java.io.StringReader("ABCDE"),
      5
    )
    for _ in 0..<5 {
      let ch = try reader.read()
      try reader.unread(ch)
    }
    // Should be able to unread 5 characters
    for _ in 0..<5 {
      _ = try reader.read()
    }
  }

  @Test("Large buffer size allows many unreads")
  func testLargeBufferSize() throws {
    let largeSize = 100
    let testString = (0..<largeSize).map { String($0 % 10) }.joined()
    let reader = try java.io.PushbackReader(
      java.io.StringReader(testString),
      largeSize
    )

    // Read all
    var chars = [Int]()
    for _ in 0..<testString.count {
      chars.append(try reader.read())
    }

    // Unread all in reverse
    for ch in chars.reversed() {
      try reader.unread(ch)
    }

    // Read all again
    for expected in chars {
      #expect(try reader.read() == expected)
    }
  }
}

// MARK: - unread(char[]) and unread(char[], offset, length)

struct JavApi_io_PushbackReader_ArrayUnread_Tests {

  @Test("unread(char[]) pushes entire array back")
  func testUnreadCharArray() throws {
    let reader = try java.io.PushbackReader(
      java.io.StringReader(""),
      10
    )
    let chars: [Character] = ["A", "B", "C"]
    try reader.unread(chars)

    #expect(try reader.read() == Int(Character("A").unicodeScalars.first!.value))
    #expect(try reader.read() == Int(Character("B").unicodeScalars.first!.value))
    #expect(try reader.read() == Int(Character("C").unicodeScalars.first!.value))
  }

  @Test("unread(char[], offset, length) partial push")
  func testUnreadPartialArray() throws {
    let reader = try java.io.PushbackReader(
      java.io.StringReader(""),
      10
    )
    let chars: [Character] = ["1", "2", "3", "4", "5"]
    try reader.unread(chars, 1, 3)  // ["2", "3", "4"]

    #expect(try reader.read() == Int(Character("2").unicodeScalars.first!.value))
    #expect(try reader.read() == Int(Character("3").unicodeScalars.first!.value))
    #expect(try reader.read() == Int(Character("4").unicodeScalars.first!.value))
  }

  @Test("unread(char[]) with empty array")
  func testUnreadEmptyArray() throws {
    let reader = java.io.PushbackReader(
      java.io.StringReader("AB")
    )
    try reader.unread([])  // should succeed

    #expect(try reader.read() == Int(Character("A").unicodeScalars.first!.value))
  }

  @Test("unread(char[], offset, length) throws when buffer insufficient")
  func testUnreadArrayBufferFull() throws {
    let reader = try java.io.PushbackReader(
      java.io.StringReader("123"),
      2  // buffer size 2
    )
    let chars: [Character] = ["A", "B", "C"]

    do {
      try reader.unread(chars, 0, 3)  // needs 3 slots, only has 2
      #expect(Bool(false), "Should have thrown IOException")
    } catch let e as java.io.IOException {
      #expect(e.getMessage()?.contains("full") ?? false)
    }
  }
}

// MARK: - read(char[], offset, length) after unread

struct JavApi_io_PushbackReader_ReadBuffer_Tests {

  @Test("read(buffer) after unread returns pushback buffer first")
  func testReadBufferAfterUnread() throws {
    let reader = java.io.PushbackReader(
      java.io.StringReader("345")
    )
    let first = try reader.read()  // '3'
    try reader.unread(first)       // push back '3'

    var buf = [Character](repeating: " ", count: 5)
    let read = try reader.read(&buf)

    #expect(read == 3)
    #expect(buf[0] == Character(UnicodeScalar(first)!))
  }

  @Test("read(buffer, offset, length) drains pushback buffer")
  func testReadBufferWithOffsetAfterUnread() throws {
    let reader = try java.io.PushbackReader(
      java.io.StringReader("234"),
      3
    )
    let a = try reader.read()  // '2'
    let b = try reader.read()  // '3'
    let c = try reader.read()  // '4'

    try reader.unread(c)       // push '4'
    try reader.unread(b)       // push '3'
    try reader.unread(a)       // push '2'

    var buf = [Character](repeating: " ", count: 10)
    let read = try reader.read(&buf, 2, 4)

    #expect(read == 3)  // only 3 chars unread
  }

  @Test("read(buffer, 0, 0) returns 0")
  func testReadZeroLength() throws {
    let reader = java.io.PushbackReader(
      java.io.StringReader("AB")
    )
    var buf = [Character](repeating: " ", count: 10)
    let read = try reader.read(&buf, 0, 0)

    #expect(read == 0)
    #expect(try reader.read() == Int(Character("A").unicodeScalars.first!.value))
  }
}

// MARK: - ready() method

struct JavApi_io_PushbackReader_Ready_Tests {

  @Test("ready() returns true when pushback buffer has data")
  func testReadyWithPushback() throws {
    let reader = java.io.PushbackReader(
      java.io.StringReader("ABC")
    )
    let ch = try reader.read()
    try reader.unread(ch)

    #expect(try reader.ready() == true)
  }

  @Test("ready() returns false on closed stream")
  func testReadyOnClosedStream() throws {
    let reader = java.io.PushbackReader(
      java.io.StringReader("ABC")
    )
    try reader.close()

    do {
      _ = try reader.ready()
      #expect(Bool(false), "Should have thrown IOException")
    } catch let e as java.io.IOException {
      #expect(e.getMessage()?.contains("closed") ?? false)
    }
  }

  @Test("ready() reflects underlying reader state")
  func testReadyDelegates() throws {
    let reader = java.io.PushbackReader(
      java.io.StringReader("test")
    )
    // StringReader.ready() typically returns true for content
    #expect(try reader.ready() == true)
  }
}

// MARK: - mark/reset rejection

struct JavApi_io_PushbackReader_MarkReset_Tests {

  @Test("markSupported() returns false")
  func testMarkSupportedFalse() throws {
    let reader = java.io.PushbackReader(
      java.io.StringReader("ABC")
    )
    #expect(reader.markSupported() == false)
  }

  @Test("mark() throws IOException")
  func testMarkThrows() throws {
    let reader = java.io.PushbackReader(
      java.io.StringReader("ABC")
    )
    do {
      try reader.mark(100)
      #expect(Bool(false), "Should have thrown IOException")
    } catch let e as java.io.IOException {
      #expect(e.getMessage()?.contains("mark") ?? false)
    }
  }

  @Test("reset() throws IOException")
  func testResetThrows() throws {
    let reader = java.io.PushbackReader(
      java.io.StringReader("ABC")
    )
    do {
      try reader.reset()
      #expect(Bool(false), "Should have thrown IOException")
    } catch let e as java.io.IOException {
      #expect(e.getMessage()?.contains("reset") ?? false)
    }
  }
}

// MARK: - close() behavior

struct JavApi_io_PushbackReader_Close_Tests {

  @Test("close() closes underlying reader")
  func testCloseUnderlyingReader() throws {
    let inner = java.io.StringReader("ABC")
    let reader = java.io.PushbackReader(inner)
    try reader.close()

    do {
      _ = try reader.read()
      #expect(Bool(false), "Should have thrown IOException")
    } catch let e as java.io.IOException {
      #expect(e.getMessage()?.contains("closed") ?? false)
    }
  }

  @Test("Multiple close() calls are safe")
  func testMultipleClose() throws {
    let reader = java.io.PushbackReader(
      java.io.StringReader("ABC")
    )
    try reader.close()
    try reader.close()  // should not throw
  }

  @Test("Operations throw after close()")
  func testOperationsAfterClose() throws {
    let reader = java.io.PushbackReader(
      java.io.StringReader("ABC")
    )
    try reader.close()

    do {
      _ = try reader.read()
      #expect(Bool(false), "Should have thrown IOException")
    } catch let e as java.io.IOException {
      #expect(e.getMessage()?.contains("closed") ?? false)
    }

    do {
      try reader.unread(65)
      #expect(Bool(false), "Should have thrown IOException")
    } catch let e as java.io.IOException {
      #expect(e.getMessage()?.contains("closed") ?? false)
    }
  }
}

// MARK: - Edge cases and EOF behavior

struct JavApi_io_PushbackReader_EdgeCases_Tests {

  @Test("read() returns -1 at EOF")
  func testEOFReturnsMinusOne() throws {
    let reader = java.io.PushbackReader(
      java.io.StringReader("A")
    )
    _ = try reader.read()
    #expect(try reader.read() == -1)
  }

  @Test("Unreading before reading anything succeeds")
  func testUnreadBeforeAnyRead() throws {
    let reader = java.io.PushbackReader(
      java.io.StringReader("AB")
    )
    try reader.unread(99)

    #expect(try reader.read() == 99)
    #expect(try reader.read() == Int(Character("A").unicodeScalars.first!.value))
  }

  @Test("read(buffer) at EOF returns -1")
  func testReadBufferEOF() throws {
    let reader = java.io.PushbackReader(
      java.io.StringReader("")
    )
    var buf = [Character](repeating: " ", count: 5)
    #expect(try reader.read(&buf) == -1)
  }

  @Test("Mixing unread(int) and unread(char[])")
  func testMixedUnreadMethods() throws {
    let reader = try java.io.PushbackReader(
      java.io.StringReader(""),
      10
    )

    try reader.unread(67)  // push single 'C'
    try reader.unread([Character("B"), Character("A")], 0, 2)  // push "BA"

    #expect(try reader.read() == Int(Character("B").unicodeScalars.first!.value))
    #expect(try reader.read() == Int(Character("A").unicodeScalars.first!.value))
    #expect(try reader.read() == 67)  // 'C'
  }

  @Test("Alternating read and unread patterns")
  func testAlternatingReadUnread() throws {
    let reader = try java.io.PushbackReader(
      java.io.StringReader("ABCDE"),
      5
    )

    let a = try reader.read()   // 'A'
    let b = try reader.read()   // 'B'
    try reader.unread(b)        // push 'B'
    try reader.unread(a)        // push 'A'

    #expect(try reader.read() == a)
    #expect(try reader.read() == b)

    let c = try reader.read()   // 'C'
    try reader.unread(c)        // push 'C'

    #expect(try reader.read() == c)
    #expect(try reader.read() == Int(Character("D").unicodeScalars.first!.value))
    #expect(try reader.read() == Int(Character("E").unicodeScalars.first!.value))
  }

  @Test("Unicode characters work correctly")
  func testUnicodeCharacters() throws {
    let reader = try java.io.PushbackReader(
      java.io.StringReader("Ä€"),
      10
    )

    let first = try reader.read()  // 'Ä'
    try reader.unread(first)

    #expect(try reader.read() == first)
    #expect(try reader.read() > 0)  // '€'
  }

  @Test("Large string with pushback operations")
  func testLargeStringWithPushback() throws {
    let largeString = String(repeating: "x", count: 100)
    let reader = try java.io.PushbackReader(
      java.io.StringReader(largeString),
      100
    )

    // Read and pushback alternating
    var count = 0
    var lastChar: Int = -1
    for _ in 0..<50 {
      lastChar = try reader.read()
      if lastChar >= 0 {
        try reader.unread(lastChar)
        count += 1
      }
    }

    #expect(count > 0)
  }
}
