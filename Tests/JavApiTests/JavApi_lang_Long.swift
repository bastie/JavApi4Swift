/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_lang_Long_Tests {

  @Test("numberOfLeadingZeros for boundary values")
  func testNumberOfLeadingZeros() {
    #expect(Long.numberOfLeadingZeros(0)              == 64)
    #expect(Long.numberOfLeadingZeros(1)              == 63)
    #expect(Long.numberOfLeadingZeros(-1)             == 0)
    #expect(Long.numberOfLeadingZeros(Long.MAX_VALUE) == 1)
    #expect(Long.numberOfLeadingZeros(Long.MIN_VALUE) == 0)
  }

  @Test("numberOfTrailingZeros for boundary values")
  func testNumberOfTrailingZeros() {
    #expect(Long.numberOfTrailingZeros(0)              == 64)
    #expect(Long.numberOfTrailingZeros(1)              == 0)
    #expect(Long.numberOfTrailingZeros(-1)             == 0)
    #expect(Long.numberOfTrailingZeros(Long.MAX_VALUE) == 0)
    #expect(Long.numberOfTrailingZeros(Long.MIN_VALUE) == 63)
  }

  @Test("toString(long, radix) converts to correct base string")
  func testToStringRadix() {
    // Decimal (radix 10)
    #expect(Long.toString(42, 10) == "42")
    #expect(Long.toString(-42, 10) == "-42")
    #expect(Long.toString(0, 10) == "0")
    // Binary (radix 2)
    #expect(Long.toString(8, 2) == "1000")
    #expect(Long.toString(-1, 2) == "-1")
    // Octal (radix 8)
    #expect(Long.toString(255, 8) == "377")
    // Hex (radix 16)
    #expect(Long.toString(255, 16) == "ff")
    #expect(Long.toString(-255, 16) == "-ff")
    // Radix 36
    #expect(Long.toString(35, 36) == "z")
    // Boundary values
    #expect(Long.toString(Long.MAX_VALUE, 10) == "9223372036854775807")
    #expect(Long.toString(Long.MIN_VALUE, 10) == "-9223372036854775808")
    // Invalid radix falls back to 10
    #expect(Long.toString(42, 1) == "42")
    #expect(Long.toString(42, 37) == "42")
  }
}
