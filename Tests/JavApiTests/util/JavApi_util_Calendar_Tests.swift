/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// Regression tests for bugs fixed in June 2026:
//   - DAY_OF_MONTH was wrongly 8 (should be 5)
//   - get(SECOND) returned minute value (copy-paste bug)
//   - GregorianCalendar.get(DAY_OF_MONTH) returned month instead of day
//   - GregorianCalendar constructor did not convert 0-based Java month to 1-based Foundation month
//   - Calendar.getInstance() and set() were missing entirely

struct JavApi_util_Calendar_Tests {

  // MARK: - Field constant values (Java 1.1 spec)

  @Test("Calendar field constants have correct Java 1.1 integer values")
  func testFieldConstants() {
    #expect(java.util.Calendar.ERA                  == 0)
    #expect(java.util.Calendar.YEAR                 == 1)
    #expect(java.util.Calendar.MONTH                == 2)
    #expect(java.util.Calendar.WEEK_OF_YEAR         == 3)
    #expect(java.util.Calendar.WEEK_OF_MONTH        == 4)
    #expect(java.util.Calendar.DATE                 == 5)
    // Regression: DAY_OF_MONTH was wrongly 8 — must be 5
    #expect(java.util.Calendar.DAY_OF_MONTH         == 5)
    #expect(java.util.Calendar.DAY_OF_YEAR          == 6)
    #expect(java.util.Calendar.DAY_OF_WEEK          == 7)
    // 8 belongs to DAY_OF_WEEK_IN_MONTH, not DAY_OF_MONTH
    #expect(java.util.Calendar.DAY_OF_WEEK_IN_MONTH == 8)
    #expect(java.util.Calendar.AM_PM                == 9)
    #expect(java.util.Calendar.HOUR                 == 10)
    #expect(java.util.Calendar.HOUR_OF_DAY          == 11)
    #expect(java.util.Calendar.MINUTE               == 12)
    #expect(java.util.Calendar.SECOND               == 13)
    #expect(java.util.Calendar.MILLISECOND          == 14)
    #expect(java.util.Calendar.ZONE_OFFSET          == 15)
    #expect(java.util.Calendar.DST_OFFSET           == 16)
    #expect(java.util.Calendar.FIELD_COUNT          == 17)
  }

  @Test("DATE and DAY_OF_MONTH are aliases with the same value")
  func testDateAlias() {
    #expect(java.util.Calendar.DATE == java.util.Calendar.DAY_OF_MONTH)
  }

  // MARK: - Month constants (0-based)

  @Test("Month constants are 0-based (JANUARY=0 … DECEMBER=11)")
  func testMonthConstants() {
    #expect(java.util.Calendar.JANUARY   == 0)
    #expect(java.util.Calendar.FEBRUARY  == 1)
    #expect(java.util.Calendar.MARCH     == 2)
    #expect(java.util.Calendar.APRIL     == 3)
    #expect(java.util.Calendar.MAY       == 4)
    #expect(java.util.Calendar.JUNE      == 5)
    #expect(java.util.Calendar.JULY      == 6)
    #expect(java.util.Calendar.AUGUST    == 7)
    #expect(java.util.Calendar.SEPTEMBER == 8)
    #expect(java.util.Calendar.OCTOBER   == 9)
    #expect(java.util.Calendar.NOVEMBER  == 10)
    #expect(java.util.Calendar.DECEMBER  == 11)
    #expect(java.util.Calendar.UNDECIMBER == 12)
  }

  // MARK: - Day-of-week constants

  @Test("Day-of-week constants are 1-based (SUNDAY=1 … SATURDAY=7)")
  func testDayOfWeekConstants() {
    #expect(java.util.Calendar.SUNDAY    == 1)
    #expect(java.util.Calendar.MONDAY    == 2)
    #expect(java.util.Calendar.TUESDAY   == 3)
    #expect(java.util.Calendar.WEDNESDAY == 4)
    #expect(java.util.Calendar.THURSDAY  == 5)
    #expect(java.util.Calendar.FRIDAY    == 6)
    #expect(java.util.Calendar.SATURDAY  == 7)
  }

  // MARK: - AM/PM and era constants

  @Test("AM/PM and era constants have correct values")
  func testAmPmEraConstants() {
    #expect(java.util.Calendar.AM == 0)
    #expect(java.util.Calendar.PM == 1)
    #expect(java.util.Calendar.BC == 0)
    #expect(java.util.Calendar.AD == 1)
  }

  // MARK: - getInstance

  @Test("Calendar.getInstance() returns a non-nil Calendar")
  func testGetInstance() {
    let cal = java.util.Calendar.getInstance()
    #expect(cal != nil)
  }

  @Test("Calendar.getInstance() returns current year")
  func testGetInstanceYear() throws {
    let cal = java.util.Calendar.getInstance()
    let year = try cal.get(java.util.Calendar.YEAR)
    #expect(year >= 2026)
  }

  @Test("Calendar.getInstance(Locale) returns a Calendar")
  func testGetInstanceLocale() throws {
    let locale = java.util.Locale("en", "US")
    let cal = java.util.Calendar.getInstance(locale)
    let year = try cal.get(java.util.Calendar.YEAR)
    #expect(year >= 2026)
  }

  // MARK: - GregorianCalendar constructor — month 0-based conversion

  @Test("GregorianCalendar(year, month, day) uses 0-based month like Java")
  func testGregorianCalendarMonthConversion() throws {
    // Java: NOVEMBER = 10, Foundation month 11
    let cal = java.util.GregorianCalendar(2026, java.util.Calendar.NOVEMBER, 15)
    let month = try cal.get(java.util.Calendar.MONTH)
    let day   = try cal.get(java.util.Calendar.DAY_OF_MONTH)
    let year  = try cal.get(java.util.Calendar.YEAR)
    #expect(year  == 2026)
    #expect(month == java.util.Calendar.NOVEMBER)  // must be 10
    #expect(day   == 15)
  }

  @Test("GregorianCalendar(year, JANUARY, day) gives month == 0")
  func testGregorianCalendarJanuary() throws {
    let cal = java.util.GregorianCalendar(2026, java.util.Calendar.JANUARY, 1)
    #expect(try cal.get(java.util.Calendar.MONTH) == 0)
  }

  // MARK: - GregorianCalendar.get — Regression: DAY_OF_MONTH returned month

  @Test("GregorianCalendar.get(DAY_OF_MONTH) returns the day, not the month")
  func testGregorianGetDayOfMonth() throws {
    // Regression: previously returned dateComponents.month instead of .day
    let cal = java.util.GregorianCalendar(2026, java.util.Calendar.JUNE, 22)
    #expect(try cal.get(java.util.Calendar.DAY_OF_MONTH) == 22)
    // Sanity: month must be JUNE (5), not 22
    #expect(try cal.get(java.util.Calendar.MONTH) == java.util.Calendar.JUNE)
  }

  @Test("GregorianCalendar.get(DAY_OF_MONTH) and get(MONTH) are independent")
  func testGregorianDayAndMonthIndependent() throws {
    let cal = java.util.GregorianCalendar(2025, java.util.Calendar.MARCH, 7)
    #expect(try cal.get(java.util.Calendar.DAY_OF_MONTH) == 7)
    #expect(try cal.get(java.util.Calendar.MONTH)        == java.util.Calendar.MARCH)
  }

  // MARK: - get(SECOND) — Regression: returned minute instead of second

  @Test("GregorianCalendar.get(SECOND) returns seconds, not minutes")
  func testGetSecondNotMinute() throws {
    // Regression: get(SECOND) returned dateComponents.minute (copy-paste bug)
    let cal = java.util.GregorianCalendar(2026, 0, 1, 10, 30, 45)
    #expect(try cal.get(java.util.Calendar.SECOND) == 45)
    #expect(try cal.get(java.util.Calendar.MINUTE) == 30)
    // Crucially: SECOND != MINUTE
    #expect(try cal.get(java.util.Calendar.SECOND) != cal.get(java.util.Calendar.MINUTE))
  }

  @Test("GregorianCalendar.get(SECOND) == 0 when second is zero")
  func testGetSecondZero() throws {
    let cal = java.util.GregorianCalendar(2026, 0, 1, 10, 30, 0)
    #expect(try cal.get(java.util.Calendar.SECOND) == 0)
    #expect(try cal.get(java.util.Calendar.MINUTE) == 30)
  }

  // MARK: - set(field, value)

  @Test("Calendar.set(YEAR, value) changes the year")
  func testSetYear() throws {
    let cal = java.util.GregorianCalendar(2020, 0, 1)
    cal.set(java.util.Calendar.YEAR, 2030)
    #expect(try cal.get(java.util.Calendar.YEAR) == 2030)
  }

  @Test("Calendar.set(MONTH, value) changes the month (0-based)")
  func testSetMonth() throws {
    let cal = java.util.GregorianCalendar(2026, java.util.Calendar.JANUARY, 1)
    cal.set(java.util.Calendar.MONTH, java.util.Calendar.DECEMBER)
    #expect(try cal.get(java.util.Calendar.MONTH) == java.util.Calendar.DECEMBER)
  }

  @Test("Calendar.set(DAY_OF_MONTH, value) changes the day")
  func testSetDayOfMonth() throws {
    let cal = java.util.GregorianCalendar(2026, 0, 1)
    cal.set(java.util.Calendar.DAY_OF_MONTH, 15)
    #expect(try cal.get(java.util.Calendar.DAY_OF_MONTH) == 15)
  }

  @Test("Calendar.set(HOUR_OF_DAY, value) changes the hour")
  func testSetHourOfDay() throws {
    let cal = java.util.GregorianCalendar(2026, 0, 1, 0, 0, 0)
    cal.set(java.util.Calendar.HOUR_OF_DAY, 14)
    #expect(try cal.get(java.util.Calendar.HOUR_OF_DAY) == 14)
  }

  @Test("Calendar.set(MINUTE, value) changes the minute")
  func testSetMinute() throws {
    let cal = java.util.GregorianCalendar(2026, 0, 1, 10, 0, 0)
    cal.set(java.util.Calendar.MINUTE, 45)
    #expect(try cal.get(java.util.Calendar.MINUTE) == 45)
  }

  @Test("Calendar.set(SECOND, value) changes the second")
  func testSetSecond() throws {
    let cal = java.util.GregorianCalendar(2026, 0, 1, 10, 30, 0)
    cal.set(java.util.Calendar.SECOND, 59)
    #expect(try cal.get(java.util.Calendar.SECOND) == 59)
  }

  // MARK: - isLeapYear

  @Test("GregorianCalendar.isLeapYear identifies leap years correctly")
  func testIsLeapYear() {
    let cal = java.util.GregorianCalendar()
    #expect(cal.isLeapYear(2000) == true)   // divisible by 400
    #expect(cal.isLeapYear(1900) == false)  // divisible by 100 but not 400
    #expect(cal.isLeapYear(2024) == true)   // divisible by 4
    #expect(cal.isLeapYear(2023) == false)  // not divisible by 4
  }

  // MARK: - Swiftify DateComponents enum

  @Test("Calendar.DateComponents enum values match Java field constants")
  func testDateComponentsEnum() {
    #expect(java.util.Calendar.DateComponents.YEAR.rawValue         == java.util.Calendar.YEAR)
    #expect(java.util.Calendar.DateComponents.MONTH.rawValue        == java.util.Calendar.MONTH)
    #expect(java.util.Calendar.DateComponents.DAY_OF_MONTH.rawValue == java.util.Calendar.DAY_OF_MONTH)
    #expect(java.util.Calendar.DateComponents.DAY_OF_WEEK.rawValue  == java.util.Calendar.DAY_OF_WEEK)
    #expect(java.util.Calendar.DateComponents.HOUR_OF_DAY.rawValue  == java.util.Calendar.HOUR_OF_DAY)
    #expect(java.util.Calendar.DateComponents.MINUTE.rawValue       == java.util.Calendar.MINUTE)
    #expect(java.util.Calendar.DateComponents.SECOND.rawValue       == java.util.Calendar.SECOND)
  }

  @Test("Calendar.get(DateComponents.SECOND) returns seconds not minutes")
  func testSwiftifyGetSecond() throws {
    let cal = java.util.GregorianCalendar(2026, 0, 1, 10, 30, 45)
    // Regression: Swiftify extension also had the copy-paste bug
    let sec = cal.get(what: .SECOND)
    let min = cal.get(what: .MINUTE)
    #expect(sec == 45)
    #expect(min == 30)
    #expect(sec != min)
  }
}
