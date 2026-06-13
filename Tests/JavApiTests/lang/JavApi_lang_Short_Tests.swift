/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_lang_Short_Tests {

  @Test("MIN_VALUE and MAX_VALUE match Int16 bounds")
  func testConstants() {
    #expect(Short.MIN_VALUE == Int16.min)
    #expect(Short.MAX_VALUE == Int16.max)
    #expect(Short.MIN_VALUE == -32768)
    #expect(Short.MAX_VALUE == 32767)
  }

  @Test("init stores value and shortValue returns it")
  func testShortValue() {
    #expect(Short(0).shortValue() == 0)
    #expect(Short(32767).shortValue() == 32767)
    #expect(Short(-32768).shortValue() == -32768)
    #expect(Short(1000).shortValue() == 1000)
  }

  @Test("parseShort converts valid strings")
  func testParseShort() throws {
    #expect(try Short.parseShort("0") == 0)
    #expect(try Short.parseShort("32767") == 32767)
    #expect(try Short.parseShort("-32768") == -32768)
    #expect(try Short.parseShort("1000") == 1000)
  }

  @Test("parseShort throws for non-numeric or out-of-range input")
  func testParseShortInvalid() {
    #expect(throws: (any Error).self) { try Short.parseShort("abc") }
    #expect(throws: (any Error).self) { try Short.parseShort("") }
    #expect(throws: (any Error).self) { try Short.parseShort("32768") }   // overflow
    #expect(throws: (any Error).self) { try Short.parseShort("-32769") }  // underflow
  }

  @Test("valueOf returns Short wrapping parsed value")
  func testValueOf() throws {
    let s = try Short.valueOf("1234")
    #expect(s.shortValue() == 1234)
  }

  @Test("toString returns decimal string")
  func testToString() {
    #expect(Short(0).toString() == "0")
    #expect(Short(32767).toString() == "32767")
    #expect(Short(-32768).toString() == "-32768")
    #expect(Short(1000).toString() == "1000")
  }

  @Test("equals compares by value")
  func testEquals() {
    #expect(Short(100) == Short(100))
    #expect(Short(-1) == Short(-1))
    #expect(Short(0) != Short(1))
  }
}
