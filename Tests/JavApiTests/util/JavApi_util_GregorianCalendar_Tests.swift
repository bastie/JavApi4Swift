/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

@Suite("java.util.GregorianCalendar")
struct JavApi_util_GregorianCalendar_Tests {

  // MARK: - Era constants

  @Test("BC and AD era constants have correct values (0 and 1)")
  func testEraConstants() {
    #expect(java.util.GregorianCalendar.BC == 0)
    #expect(java.util.GregorianCalendar.AD == 1)
  }

  // MARK: - Constructors: month 0-based conversion

  @Test("GregorianCalendar(year, month, day) uses 0-based month like Java")
  func testMonthConversion() throws {
    // Java: NOVEMBER = 10, Foundation month 11
    let cal = java.util.GregorianCalendar(2026, java.util.Calendar.NOVEMBER, 15)
    #expect(try cal.get(java.util.Calendar.YEAR)         == 2026)
    #expect(try cal.get(java.util.Calendar.MONTH)        == java.util.Calendar.NOVEMBER)  // 10
    #expect(try cal.get(java.util.Calendar.DAY_OF_MONTH) == 15)
  }

  @Test("GregorianCalendar(year, JANUARY, day) gives month == 0")
  func testJanuaryIsMonth0() throws {
    let cal = java.util.GregorianCalendar(2026, java.util.Calendar.JANUARY, 1)
    #expect(try cal.get(java.util.Calendar.MONTH) == 0)
  }

  @Test("GregorianCalendar(year, DECEMBER, day) gives month == 11")
  func testDecemberIsMonth11() throws {
    let cal = java.util.GregorianCalendar(2026, java.util.Calendar.DECEMBER, 31)
    #expect(try cal.get(java.util.Calendar.MONTH) == 11)
  }

  @Test("GregorianCalendar 5-arg constructor sets hour and minute")
  func testFiveArgConstructor() throws {
    let cal = java.util.GregorianCalendar(2026, java.util.Calendar.MARCH, 15, 14, 30)
    #expect(try cal.get(java.util.Calendar.HOUR_OF_DAY) == 14)
    #expect(try cal.get(java.util.Calendar.MINUTE)      == 30)
    #expect(try cal.get(java.util.Calendar.SECOND)      == 0)
  }

  @Test("GregorianCalendar 6-arg constructor sets second")
  func testSixArgConstructor() throws {
    let cal = java.util.GregorianCalendar(2026, 0, 1, 10, 30, 45)
    #expect(try cal.get(java.util.Calendar.SECOND) == 45)
  }

  // MARK: - Constructors with TimeZone / Locale (Java 1.1)

  @Test("GregorianCalendar(TimeZone) creates calendar in given timezone")
  func testInitTimeZone() throws {
    let tz = java.util.SimpleTimeZone(0, "UTC")
    let cal = java.util.GregorianCalendar(tz)
    let year = try cal.get(java.util.Calendar.YEAR)
    #expect(year >= 2020)
  }

  @Test("GregorianCalendar(Locale) creates calendar in given locale")
  func testInitLocale() throws {
    let cal = java.util.GregorianCalendar(java.util.Locale.GERMAN)
    let year = try cal.get(java.util.Calendar.YEAR)
    #expect(year >= 2020)
  }

  @Test("GregorianCalendar(TimeZone, Locale) creates calendar in given timezone and locale")
  func testInitTimeZoneLocale() throws {
    let tz     = java.util.SimpleTimeZone(0, "UTC")
    let locale = java.util.Locale.US
    let cal    = java.util.GregorianCalendar(tz, locale)
    let year   = try cal.get(java.util.Calendar.YEAR)
    #expect(year >= 2020)
  }

  // MARK: - get() regression: DAY_OF_MONTH must not return month

  @Test("get(DAY_OF_MONTH) returns the day, not the month")
  func testGetDayOfMonth() throws {
    // Regression: previously returned dateComponents.month instead of .day
    let cal = java.util.GregorianCalendar(2026, java.util.Calendar.JUNE, 22)
    #expect(try cal.get(java.util.Calendar.DAY_OF_MONTH) == 22)
    #expect(try cal.get(java.util.Calendar.MONTH)        == java.util.Calendar.JUNE)
  }

  @Test("get(DAY_OF_MONTH) and get(MONTH) are independent")
  func testDayAndMonthIndependent() throws {
    let cal = java.util.GregorianCalendar(2025, java.util.Calendar.MARCH, 7)
    #expect(try cal.get(java.util.Calendar.DAY_OF_MONTH) == 7)
    #expect(try cal.get(java.util.Calendar.MONTH)        == java.util.Calendar.MARCH)
  }

  // MARK: - get() regression: SECOND must not return MINUTE

  @Test("get(SECOND) returns seconds, not minutes")
  func testGetSecondNotMinute() throws {
    // Regression: get(SECOND) returned dateComponents.minute (copy-paste bug)
    let cal = java.util.GregorianCalendar(2026, 0, 1, 10, 30, 45)
    #expect(try cal.get(java.util.Calendar.SECOND) == 45)
    #expect(try cal.get(java.util.Calendar.MINUTE) == 30)
    #expect(try cal.get(java.util.Calendar.SECOND) != cal.get(java.util.Calendar.MINUTE))
  }

  @Test("get(SECOND) == 0 when second argument is zero")
  func testGetSecondZero() throws {
    let cal = java.util.GregorianCalendar(2026, 0, 1, 10, 30, 0)
    #expect(try cal.get(java.util.Calendar.SECOND) == 0)
    #expect(try cal.get(java.util.Calendar.MINUTE) == 30)
  }

  @Test("Swiftify get(what: .SECOND) also returns seconds not minutes")
  func testSwiftifyGetSecond() throws {
    let cal = java.util.GregorianCalendar(2026, 0, 1, 10, 30, 45)
    // Regression: Swiftify extension also had the copy-paste bug
    #expect(cal.get(what: .SECOND) == 45)
    #expect(cal.get(what: .MINUTE) == 30)
    #expect(cal.get(what: .SECOND) != cal.get(what: .MINUTE))
  }

  // MARK: - isLeapYear

  @Test("isLeapYear correctly identifies leap years")
  func testIsLeapYear() {
    let cal = java.util.GregorianCalendar()
    #expect(cal.isLeapYear(2000) == true)   // divisible by 400
    #expect(cal.isLeapYear(1900) == false)  // divisible by 100 but not 400
    #expect(cal.isLeapYear(2024) == true)   // divisible by 4
    #expect(cal.isLeapYear(2023) == false)  // not divisible by 4
    #expect(cal.isLeapYear(2100) == false)  // next century non-leap
  }

  // MARK: - getGregorianChange / setGregorianChange / isGregorianDate (Java 1.1)

  @Test("getGregorianChange() returns October 15 1582 by default")
  func testGetGregorianChangeDefault() {
    let cal = java.util.GregorianCalendar()
    let change = cal.getGregorianChange()
    // October 15, 1582 00:00:00 UTC = -12219292800000 ms
    let expected: Int64 = -12219292800000
    #expect(abs(change.getTime() - expected) <= 1000)  // ±1 s tolerance
  }

  @Test("setGregorianChange() changes the cutover date")
  func testSetGregorianChange() {
    let cal = java.util.GregorianCalendar()
    let newChange = java.util.Date(Int64.min)
    cal.setGregorianChange(newChange)
    #expect(cal.getGregorianChange().getTime() == Int64.min)
  }

  @Test("setGregorianChange to far future produces a pure Julian calendar")
  func testSetGregorianChangePureJulian() {
    let cal = java.util.GregorianCalendar()
    // Use year 9999 as a safely representable "far future" sentinel —
    // avoids Double precision loss that occurs with Int64.max.
    // Milliseconds for 9999-01-01: approximately 253_370_764_800_000
    let farFuture: Int64 = 253_370_764_800_000  // 9999-01-01 00:00:00 UTC
    cal.setGregorianChange(java.util.Date(farFuture))
    // Any date before year 9999 must be treated as Julian
    let today: Int64 = 1_754_784_000_000  // 2026-08-10
    #expect(!cal.isGregorianDate(java.util.Date(today)))
  }

  @Test("isGregorianDate returns true for dates after the cutover")
  func testIsGregorianDate() {
    let cal = java.util.GregorianCalendar()
    let afterCutover  = java.util.Date(0)               // 1970-01-01
    let beforeCutover = java.util.Date(-20000000000000) // well before 1582
    #expect(cal.isGregorianDate(afterCutover)  == true)
    #expect(cal.isGregorianDate(beforeCutover) == false)
  }

  @Test("isGregorianDate reflects a custom setGregorianChange date")
  func testIsGregorianDateCustomCutover() {
    let cal = java.util.GregorianCalendar()
    // Move cutover to 2000-01-01
    let cutover = java.util.GregorianCalendar(2000, java.util.Calendar.JANUARY, 1).getTime()
    cal.setGregorianChange(cutover)
    let before2000 = java.util.GregorianCalendar(1999, 0, 1).getTime()
    let after2000  = java.util.GregorianCalendar(2001, 0, 1).getTime()
    #expect(cal.isGregorianDate(before2000) == false)
    #expect(cal.isGregorianDate(after2000)  == true)
  }
}
