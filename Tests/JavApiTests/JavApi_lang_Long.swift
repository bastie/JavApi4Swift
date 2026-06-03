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
}
