/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_lang_Integer_Tests {

  @Test("MAX_VALUE and MIN_VALUE match Int32 bounds")
  func testConstants() {
    #expect(Integer.MAX_VALUE == Int(Int32.max))
    #expect(Integer.MIN_VALUE == Int(Int32.min))
  }

  @Test("parseInt converts valid strings")
  func testParseInt() throws {
    #expect(try Integer.parseInt("42") == 42)
    #expect(try Integer.parseInt("-1") == -1)
    #expect(try Integer.parseInt("0") == 0)
  }

  @Test("parseInt throws for non-numeric input")
  func testParseIntInvalid() {
    #expect(throws: (any Error).self) {
      try Integer.parseInt("abc")
    }
  }

  @Test("toHexString produces lowercase hex")
  func testToHexString() {
    #expect(Integer.toHexString(255) == "ff")
    #expect(Integer.toHexString(0) == "0")
    #expect(Integer.toHexString(16) == "10")
  }

  @Test("reverseBytes swaps byte order like Java int")
  func testReverseBytes() {
    #expect(Integer.reverseBytes(0x00801600) == 0x00168000)
    #expect(Integer.reverseBytes(0) == 0)
  }
}
