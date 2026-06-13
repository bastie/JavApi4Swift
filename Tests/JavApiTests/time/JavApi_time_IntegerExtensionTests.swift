/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com> and contributors
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_time_IntegerExtensionTests {

  @Test("+ operator on LocalDateTime with period built from integer extensions")
  func testAddOperator() {
    let date = java.time.LocalDateTime(
      year: 1000, month: 1, day: 7,
      hour: 11, minute: 51, second: 18, nanoOfSecond: 1573
    )

    let newDate1 = date + (1.year + 1.week + 2.hour)
    #expect(newDate1.year   == 1001)
    #expect(newDate1.month  == 1)
    #expect(newDate1.day    == 14)
    #expect(newDate1.hour   == 13)
    #expect(newDate1.minute == 51)
    #expect(newDate1.second == 18)
    #expect(newDate1.nano   == 1573)

    let newDate2 = newDate1 + (1.month + 2.day + 3.minute + 4.second + 152.nanosecond)
    #expect(newDate2.year   == 1001)
    #expect(newDate2.month  == 2)
    #expect(newDate2.day    == 16)
    #expect(newDate2.hour   == 13)
    #expect(newDate2.minute == 54)
    #expect(newDate2.second == 22)
    #expect(newDate2.nano   == 1725)
  }

  @Test("- operator on LocalDateTime with period built from integer extensions")
  func testSubtractOperator() {
    let date = java.time.LocalDateTime(
      year: 1000, month: 2, day: 14,
      hour: 11, minute: 51, second: 18, nanoOfSecond: 1573
    )

    let newDate1 = date - (1.year + 1.week + 2.hour)
    #expect(newDate1.year   == 999)
    #expect(newDate1.month  == 2)
    #expect(newDate1.day    == 7)
    #expect(newDate1.hour   == 9)
    #expect(newDate1.minute == 51)
    #expect(newDate1.second == 18)
    #expect(newDate1.nano   == 1573)

    let newDate2 = newDate1 - (1.month + 2.day + 3.minute + 4.second + 152.nanosecond)
    #expect(newDate2.year   == 999)
    #expect(newDate2.month  == 1)
    #expect(newDate2.day    == 5)
    #expect(newDate2.hour   == 9)
    #expect(newDate2.minute == 48)
    #expect(newDate2.second == 14)
    #expect(newDate2.nano   == 1421)
  }
}
