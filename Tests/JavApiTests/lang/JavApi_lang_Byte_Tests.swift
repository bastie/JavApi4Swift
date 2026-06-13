/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_lang_Byte_Tests {

  // MARK: - Unsigned bounds (Byte.swift)

  @Test("UMIN_VALUE and UMAX_VALUE match UInt8 bounds")
  func testUnsignedConstants() {
    #expect(Byte.UMIN_VALUE == UInt8.min)
    #expect(Byte.UMAX_VALUE == UInt8.max)
    #expect(Byte.UMIN_VALUE == 0)
    #expect(Byte.UMAX_VALUE == 255)
  }

  @Test("MIN_VALUE / MAX_VALUE are aliases for the unsigned variants")
  func testAliasConstants() {
    #expect(Byte.MIN_VALUE == Byte.UMIN_VALUE)
    #expect(Byte.MAX_VALUE == Byte.UMAX_VALUE)
  }

  // MARK: - Signed bounds (Byte+Java.swift)

  @Test("SMIN_VALUE and SMAX_VALUE match Int8 bounds")
  func testSignedConstants() {
    #expect(Byte.SMIN_VALUE == Int8.min)
    #expect(Byte.SMAX_VALUE == Int8.max)
    #expect(Byte.SMIN_VALUE == -128)
    #expect(Byte.SMAX_VALUE == 127)
  }

  // MARK: - Init and byteValue

  @Test("init stores UInt8 value and byteValue returns it")
  func testByteValue() {
    #expect(Byte(0).byteValue() == 0)
    #expect(Byte(255).byteValue() == 255)
    #expect(Byte(128).byteValue() == 128)
    #expect(Byte(42).byteValue() == 42)
  }

  // MARK: - signedByteValue (Byte+Java.swift)

  @Test("signedByteValue reinterprets bit pattern as Int8")
  func testSignedByteValue() {
    #expect(Byte(0).signedByteValue() == 0)
    #expect(Byte(127).signedByteValue() == 127)
    #expect(Byte(128).signedByteValue() == -128)   // bit-exact reinterpretation
    #expect(Byte(255).signedByteValue() == -1)
  }

  // MARK: - parseByte (unsigned)

  @Test("parseByte converts valid unsigned strings")
  func testParseByte() throws {
    #expect(try Byte.parseByte("0") == 0)
    #expect(try Byte.parseByte("255") == 255)
    #expect(try Byte.parseByte("128") == 128)
    #expect(try Byte.parseByte("42") == 42)
  }

  @Test("parseByte throws for out-of-range or invalid input")
  func testParseByteInvalid() {
    #expect(throws: (any Error).self) { try Byte.parseByte("abc") }
    #expect(throws: (any Error).self) { try Byte.parseByte("") }
    #expect(throws: (any Error).self) { try Byte.parseByte("256") }   // overflow
    #expect(throws: (any Error).self) { try Byte.parseByte("-1") }    // negative not valid for UInt8
  }

  // MARK: - parseSignedByte (Byte+Java.swift)

  @Test("parseSignedByte converts valid signed strings")
  func testParseSignedByte() throws {
    #expect(try Byte.parseSignedByte("0") == 0)
    #expect(try Byte.parseSignedByte("127") == 127)
    #expect(try Byte.parseSignedByte("-128") == -128)
    #expect(try Byte.parseSignedByte("42") == 42)
  }

  @Test("parseSignedByte throws for out-of-range or invalid input")
  func testParseSignedByteInvalid() {
    #expect(throws: (any Error).self) { try Byte.parseSignedByte("abc") }
    #expect(throws: (any Error).self) { try Byte.parseSignedByte("128") }   // overflow
    #expect(throws: (any Error).self) { try Byte.parseSignedByte("-129") }  // underflow
  }

  // MARK: - valueOf

  @Test("valueOf returns Byte wrapping parsed unsigned value")
  func testValueOf() throws {
    let b = try Byte.valueOf("200")
    #expect(b.byteValue() == 200)
  }

  // MARK: - toString

  @Test("toString returns decimal string")
  func testToString() {
    #expect(Byte(0).toString() == "0")
    #expect(Byte(255).toString() == "255")
    #expect(Byte(128).toString() == "128")
    #expect(Byte(42).toString() == "42")
  }

  // MARK: - Equatable

  @Test("equals compares by value")
  func testEquals() {
    #expect(Byte(5) == Byte(5))
    #expect(Byte(255) == Byte(255))
    #expect(Byte(0) != Byte(1))
  }
}
