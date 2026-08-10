/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// Regression note: The DAY_OF_MONTH constant was wrongly 8 (should be 5) and
// Calendar.getInstance() / set() were missing entirely — both fixed June 2026.
// GregorianCalendar-specific regressions and constructor tests live in
// JavApi_util_GregorianCalendar_Tests.swift.

@Suite("java.util.Calendar")
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

  @Test("AM/PM constants have correct values")
  func testAmPmConstants() {
    #expect(java.util.Calendar.AM == 0)
    #expect(java.util.Calendar.PM == 1)
  }

  // MARK: - getInstance

  @Test("Calendar.getInstance() returns a non-nil Calendar")
  func testGetInstance() {
    // Test sinnlos, aber er ist nunmal da...
    _ = java.util.Calendar.getInstance()
    #expect(Bool(true))
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

  // MARK: - before / after / compareTo (Java 1.1 / Java 5)

  @Test("before() returns true when this calendar is earlier")
  func testBefore() {
    let earlier = java.util.GregorianCalendar(2000, java.util.Calendar.JANUARY, 1)
    let later   = java.util.GregorianCalendar(2010, java.util.Calendar.JANUARY, 1)
    #expect(earlier.before(later)  == true)
    #expect(later.before(earlier)  == false)
    #expect(earlier.before(earlier) == false)
  }

  @Test("after() returns true when this calendar is later")
  func testAfter() {
    let earlier = java.util.GregorianCalendar(2000, java.util.Calendar.JUNE, 15)
    let later   = java.util.GregorianCalendar(2025, java.util.Calendar.JUNE, 15)
    #expect(later.after(earlier)  == true)
    #expect(earlier.after(later)  == false)
    #expect(later.after(later)    == false)
  }

  @Test("before() and after() return false for non-Calendar argument")
  func testBeforeAfterNonCalendar() {
    let cal = java.util.GregorianCalendar(2026, 0, 1)
    #expect(cal.before("not a calendar") == false)
    #expect(cal.after(42)               == false)
    #expect(cal.before(nil)             == false)
  }

  @Test("compareTo() returns negative, zero, positive")
  func testCompareTo() {
    let a = java.util.GregorianCalendar(2020, 0, 1)
    let b = java.util.GregorianCalendar(2025, 0, 1)
    let c = java.util.GregorianCalendar(2020, 0, 1)
    #expect(a.compareTo(b) < 0)
    #expect(b.compareTo(a) > 0)
    #expect(a.compareTo(c) == 0)
  }

  // MARK: - clone (Java 1.1)

  @Test("clone() returns a calendar with identical field values")
  func testClone() throws {
    let original = java.util.GregorianCalendar(2026, java.util.Calendar.MARCH, 15, 10, 30, 0)
    let copy = original.clone()
    #expect(try copy.get(java.util.Calendar.YEAR)         == 2026)
    #expect(try copy.get(java.util.Calendar.MONTH)        == java.util.Calendar.MARCH)
    #expect(try copy.get(java.util.Calendar.DAY_OF_MONTH) == 15)
    #expect(try copy.get(java.util.Calendar.HOUR_OF_DAY)  == 10)
    #expect(try copy.get(java.util.Calendar.MINUTE)       == 30)
  }

  @Test("clone() produces an independent copy (mutation does not affect original)")
  func testCloneIndependence() throws {
    let original = java.util.GregorianCalendar(2026, 0, 1)
    let copy = original.clone()
    copy.set(java.util.Calendar.YEAR, 1999)
    #expect(try original.get(java.util.Calendar.YEAR) == 2026)
    #expect(try copy.get(java.util.Calendar.YEAR)     == 1999)
  }

  // MARK: - isSet / clear (Java 1.1)

  @Test("isSet() returns true for all fields after construction")
  func testIsSetAfterInit() {
    let cal = java.util.GregorianCalendar(2026, 0, 1)
    #expect(cal.isSet(java.util.Calendar.YEAR)         == true)
    #expect(cal.isSet(java.util.Calendar.MONTH)        == true)
    #expect(cal.isSet(java.util.Calendar.DAY_OF_MONTH) == true)
    #expect(cal.isSet(java.util.Calendar.HOUR_OF_DAY)  == true)
  }

  @Test("isSet() returns false for invalid field index")
  func testIsSetInvalidField() {
    let cal = java.util.GregorianCalendar()
    #expect(cal.isSet(999) == false)
    #expect(cal.isSet(-1)  == false)
  }

  @Test("clear(field) marks field as unset, set() marks it set again")
  func testClearSingleField() {
    let cal = java.util.GregorianCalendar(2026, 0, 1)
    cal.clear(java.util.Calendar.HOUR_OF_DAY)
    #expect(cal.isSet(java.util.Calendar.HOUR_OF_DAY)  == false)
    #expect(cal.isSet(java.util.Calendar.YEAR)         == true)  // unaffected
    cal.set(java.util.Calendar.HOUR_OF_DAY, 12)
    #expect(cal.isSet(java.util.Calendar.HOUR_OF_DAY)  == true)
  }

  @Test("clear() resets all fields and calendar to epoch")
  func testClearAll() throws {
    let cal = java.util.GregorianCalendar(2026, java.util.Calendar.AUGUST, 10)
    cal.clear()
    #expect(cal.isSet(java.util.Calendar.YEAR)         == false)
    #expect(cal.isSet(java.util.Calendar.MONTH)        == false)
    #expect(cal.isSet(java.util.Calendar.DAY_OF_MONTH) == false)
    // After clear(), dateComponents are reset to epoch (1970-01-01)
    #expect(try cal.get(java.util.Calendar.YEAR)         == 1970)
    #expect(try cal.get(java.util.Calendar.MONTH)        == java.util.Calendar.JANUARY)
    #expect(try cal.get(java.util.Calendar.DAY_OF_MONTH) == 1)
  }

  // MARK: - add (Java 1.1)

  @Test("add(YEAR, 1) increments the year")
  func testAddYear() throws {
    let cal = java.util.GregorianCalendar(2020, java.util.Calendar.JUNE, 15)
    cal.add(java.util.Calendar.YEAR, 5)
    #expect(try cal.get(java.util.Calendar.YEAR)  == 2025)
    #expect(try cal.get(java.util.Calendar.MONTH) == java.util.Calendar.JUNE)  // month unchanged
  }

  @Test("add(MONTH, 1) on December wraps to January of next year")
  func testAddMonthOverflow() throws {
    let cal = java.util.GregorianCalendar(2023, java.util.Calendar.DECEMBER, 15)
    cal.add(java.util.Calendar.MONTH, 1)
    #expect(try cal.get(java.util.Calendar.YEAR)  == 2024)
    #expect(try cal.get(java.util.Calendar.MONTH) == java.util.Calendar.JANUARY)
  }

  @Test("add(MONTH, -1) on January wraps to December of previous year")
  func testAddMonthUnderflow() throws {
    let cal = java.util.GregorianCalendar(2024, java.util.Calendar.JANUARY, 10)
    cal.add(java.util.Calendar.MONTH, -1)
    #expect(try cal.get(java.util.Calendar.YEAR)  == 2023)
    #expect(try cal.get(java.util.Calendar.MONTH) == java.util.Calendar.DECEMBER)
  }

  @Test("add(DAY_OF_MONTH, 1) on last day of month wraps to first of next month")
  func testAddDayMonthBoundary() throws {
    let cal = java.util.GregorianCalendar(2023, java.util.Calendar.JANUARY, 31)
    cal.add(java.util.Calendar.DAY_OF_MONTH, 1)
    #expect(try cal.get(java.util.Calendar.MONTH)        == java.util.Calendar.FEBRUARY)
    #expect(try cal.get(java.util.Calendar.DAY_OF_MONTH) == 1)
  }

  @Test("add(HOUR_OF_DAY, 25) carries over to the next day")
  func testAddHourCarry() throws {
    let cal = java.util.GregorianCalendar(2026, java.util.Calendar.MARCH, 10, 10, 0, 0)
    cal.add(java.util.Calendar.HOUR_OF_DAY, 25)
    #expect(try cal.get(java.util.Calendar.DAY_OF_MONTH) == 11)
    #expect(try cal.get(java.util.Calendar.HOUR_OF_DAY)  == 11)
  }

  @Test("add(SECOND, 90) carries over to minutes")
  func testAddSecondCarry() throws {
    let cal = java.util.GregorianCalendar(2026, 0, 1, 0, 0, 30)
    cal.add(java.util.Calendar.SECOND, 90)
    #expect(try cal.get(java.util.Calendar.MINUTE) == 2)
    #expect(try cal.get(java.util.Calendar.SECOND) == 0)
  }

  @Test("add(field, 0) is a no-op")
  func testAddZero() throws {
    let cal = java.util.GregorianCalendar(2026, java.util.Calendar.AUGUST, 10)
    cal.add(java.util.Calendar.DAY_OF_MONTH, 0)
    #expect(try cal.get(java.util.Calendar.DAY_OF_MONTH) == 10)
  }

  // MARK: - roll (Java 1.1)

  @Test("roll(MONTH, true) on December wraps to January without changing year")
  func testRollMonthWrap() throws {
    let cal = java.util.GregorianCalendar(2023, java.util.Calendar.DECEMBER, 15)
    cal.roll(java.util.Calendar.MONTH, true)
    #expect(try cal.get(java.util.Calendar.YEAR)  == 2023)   // year must NOT change
    #expect(try cal.get(java.util.Calendar.MONTH) == java.util.Calendar.JANUARY)
  }

  @Test("roll(MONTH, false) on January wraps to December without changing year")
  func testRollMonthWrapBack() throws {
    let cal = java.util.GregorianCalendar(2024, java.util.Calendar.JANUARY, 10)
    cal.roll(java.util.Calendar.MONTH, false)
    #expect(try cal.get(java.util.Calendar.YEAR)  == 2024)
    #expect(try cal.get(java.util.Calendar.MONTH) == java.util.Calendar.DECEMBER)
  }

  @Test("roll(HOUR_OF_DAY, 3) does not change day")
  func testRollHourNoCarry() throws {
    let cal = java.util.GregorianCalendar(2026, 0, 1, 22, 0, 0)
    cal.roll(java.util.Calendar.HOUR_OF_DAY, 3)
    #expect(try cal.get(java.util.Calendar.DAY_OF_MONTH) == 1)   // day unchanged
    #expect(try cal.get(java.util.Calendar.HOUR_OF_DAY)  == 1)   // 22+3 mod 24
  }

  @Test("roll(SECOND, amount) wraps within 0–59 without changing minute")
  func testRollSecondNoCarry() throws {
    let cal = java.util.GregorianCalendar(2026, 0, 1, 10, 30, 50)
    cal.roll(java.util.Calendar.SECOND, 20)
    #expect(try cal.get(java.util.Calendar.MINUTE) == 30)   // minute unchanged
    #expect(try cal.get(java.util.Calendar.SECOND) == 10)   // (50+20) mod 60
  }

  // MARK: - getTimeZone / setTimeZone (Java 1.1)

  @Test("getTimeZone() returns a non-nil TimeZone")
  func testGetTimeZone() {
    let cal = java.util.GregorianCalendar()
    let tz = cal.getTimeZone()
    // The ID should be a valid non-empty string
    #expect(!tz.getID().isEmpty)
  }

  @Test("setTimeZone() changes the timezone; instant is preserved")
  func testSetTimeZone() {
    let cal = java.util.GregorianCalendar(2000, java.util.Calendar.JANUARY, 1, 12, 0, 0)
    let millisBefore = cal.getTimeInMillis()
    let utc = java.util.SimpleTimeZone(0, "UTC")
    cal.setTimeZone(utc)
    // The underlying instant must not change
    #expect(cal.getTimeInMillis() == millisBefore)
    // The timezone must have been updated
    #expect(cal.getTimeZone().getID() == "UTC")
  }

  // MARK: - getActualMinimum / getActualMaximum (Java 1.2)

  @Test("getActualMaximum(DAY_OF_MONTH) is 28 for February in non-leap year")
  func testActualMaxDayFeb() {
    let cal = java.util.GregorianCalendar(2023, java.util.Calendar.FEBRUARY, 1)
    #expect(cal.getActualMaximum(java.util.Calendar.DAY_OF_MONTH) == 28)
  }

  @Test("getActualMaximum(DAY_OF_MONTH) is 29 for February in leap year")
  func testActualMaxDayFebLeap() {
    let cal = java.util.GregorianCalendar(2024, java.util.Calendar.FEBRUARY, 1)
    #expect(cal.getActualMaximum(java.util.Calendar.DAY_OF_MONTH) == 29)
  }

  @Test("getActualMaximum(DAY_OF_MONTH) is 31 for January")
  func testActualMaxDayJan() {
    let cal = java.util.GregorianCalendar(2026, java.util.Calendar.JANUARY, 1)
    #expect(cal.getActualMaximum(java.util.Calendar.DAY_OF_MONTH) == 31)
  }

  @Test("getActualMaximum(DAY_OF_YEAR) is 366 for leap year")
  func testActualMaxDayOfYearLeap() {
    let cal = java.util.GregorianCalendar(2024, 0, 1)
    #expect(cal.getActualMaximum(java.util.Calendar.DAY_OF_YEAR) == 366)
  }

  @Test("getActualMaximum(DAY_OF_YEAR) is 365 for non-leap year")
  func testActualMaxDayOfYearNonLeap() {
    let cal = java.util.GregorianCalendar(2023, 0, 1)
    #expect(cal.getActualMaximum(java.util.Calendar.DAY_OF_YEAR) == 365)
  }

  @Test("getActualMinimum(DAY_OF_MONTH) is always 1")
  func testActualMinDay() {
    let cal = java.util.GregorianCalendar(2026, java.util.Calendar.FEBRUARY, 15)
    #expect(cal.getActualMinimum(java.util.Calendar.DAY_OF_MONTH) == 1)
  }

  @Test("getActualMinimum(HOUR_OF_DAY) is 0")
  func testActualMinHour() {
    let cal = java.util.GregorianCalendar()
    #expect(cal.getActualMinimum(java.util.Calendar.HOUR_OF_DAY) == 0)
  }

  // MARK: - getInstance(TimeZone) (Java 1.1)

  @Test("getInstance(TimeZone) returns a Calendar with the correct timezone")
  func testGetInstanceTimeZone() throws {
    let tz = java.util.SimpleTimeZone(0, "UTC")
    let cal = java.util.Calendar.getInstance(tz)
    let year = try cal.get(java.util.Calendar.YEAR)
    #expect(year >= 2026)
  }

  @Test("getInstance(TimeZone, Locale) returns a Calendar")
  func testGetInstanceTimeZoneLocale() throws {
    let tz = java.util.SimpleTimeZone(0, "UTC")
    let locale = java.util.Locale("de", "DE")
    let cal = java.util.Calendar.getInstance(tz, locale)
    let year = try cal.get(java.util.Calendar.YEAR)
    #expect(year >= 2026)
  }

  @Test("getAvailableLocales() returns a non-empty array")
  func testGetAvailableLocales() {
    let locales = java.util.Calendar.getAvailableLocales()
    #expect(locales.count > 0)
  }

  // MARK: - getTimeInMillis / setTimeInMillis (Java 1.2)

  @Test("getTimeInMillis() matches getTime().getTime()")
  func testGetTimeInMillis() {
    let cal = java.util.GregorianCalendar(2026, java.util.Calendar.JANUARY, 1, 0, 0, 0)
    let millis = cal.getTimeInMillis()
    let expected = cal.getTime().getTime()
    #expect(millis == expected)
  }

  @Test("setTimeInMillis() round-trips with getTimeInMillis()")
  func testSetTimeInMillisRoundTrip() {
    let original = java.util.GregorianCalendar(2000, java.util.Calendar.JUNE, 15)
    let millis = original.getTimeInMillis()
    let restored = java.util.GregorianCalendar()
    restored.setTimeInMillis(millis)
    #expect(restored.getTimeInMillis() == millis)
  }

  @Test("setTimeInMillis(0) sets calendar to epoch (1970-01-01)")
  func testSetTimeInMillisEpoch() throws {
    let cal = java.util.GregorianCalendar()
    cal.setTimeInMillis(0)
    #expect(try cal.get(java.util.Calendar.YEAR)  == 1970)
    #expect(try cal.get(java.util.Calendar.MONTH) == java.util.Calendar.JANUARY)
    #expect(try cal.get(java.util.Calendar.DAY_OF_MONTH) == 1)
  }

  // MARK: - getMinimum / getMaximum / getGreatestMinimum / getLeastMaximum (Java 1.2)

  @Test("getMinimum(MONTH) == 0, getMaximum(MONTH) == 11")
  func testMonthBounds() {
    let cal = java.util.GregorianCalendar()
    #expect(cal.getMinimum(java.util.Calendar.MONTH)        == 0)
    #expect(cal.getMaximum(java.util.Calendar.MONTH)        == 11)
    #expect(cal.getGreatestMinimum(java.util.Calendar.MONTH) == 0)
    #expect(cal.getLeastMaximum(java.util.Calendar.MONTH)    == 11)
  }

  @Test("getMaximum(DAY_OF_MONTH) == 31, getLeastMaximum == 28")
  func testDayOfMonthBounds() {
    let cal = java.util.GregorianCalendar()
    #expect(cal.getMaximum(java.util.Calendar.DAY_OF_MONTH)      == 31)
    #expect(cal.getLeastMaximum(java.util.Calendar.DAY_OF_MONTH) == 28)
  }

  @Test("getMinimum/Maximum(HOUR_OF_DAY) are 0 and 23")
  func testHourOfDayBounds() {
    let cal = java.util.GregorianCalendar()
    #expect(cal.getMinimum(java.util.Calendar.HOUR_OF_DAY) == 0)
    #expect(cal.getMaximum(java.util.Calendar.HOUR_OF_DAY) == 23)
  }

  @Test("getMinimum/Maximum(MINUTE) are 0 and 59")
  func testMinuteBounds() {
    let cal = java.util.GregorianCalendar()
    #expect(cal.getMinimum(java.util.Calendar.MINUTE) == 0)
    #expect(cal.getMaximum(java.util.Calendar.MINUTE) == 59)
  }

  // MARK: - firstDayOfWeek (Java 1.1)

  @Test("getFirstDayOfWeek() default is SUNDAY")
  func testGetFirstDayOfWeekDefault() {
    let cal = java.util.GregorianCalendar()
    #expect(cal.getFirstDayOfWeek() == java.util.Calendar.SUNDAY)
  }

  @Test("setFirstDayOfWeek() / getFirstDayOfWeek() round-trip")
  func testSetGetFirstDayOfWeek() {
    let cal = java.util.GregorianCalendar()
    cal.setFirstDayOfWeek(java.util.Calendar.MONDAY)
    #expect(cal.getFirstDayOfWeek() == java.util.Calendar.MONDAY)
  }

  @Test("clone() copies firstDayOfWeek")
  func testCloneCopiesFirstDayOfWeek() {
    let cal = java.util.GregorianCalendar()
    cal.setFirstDayOfWeek(java.util.Calendar.FRIDAY)
    let copy = cal.clone()
    #expect(copy.getFirstDayOfWeek() == java.util.Calendar.FRIDAY)
  }

  // MARK: - isLenient / setLenient (Java 1.1)

  @Test("isLenient() default is true")
  func testIsLenientDefault() {
    let cal = java.util.GregorianCalendar()
    #expect(cal.isLenient() == true)
  }

  @Test("setLenient(false) / isLenient() round-trip")
  func testSetLenient() {
    let cal = java.util.GregorianCalendar()
    cal.setLenient(false)
    #expect(cal.isLenient() == false)
    cal.setLenient(true)
    #expect(cal.isLenient() == true)
  }

  // MARK: - minimalDaysInFirstWeek (Java 1.1)

  @Test("getMinimalDaysInFirstWeek() default is 1")
  func testGetMinimalDaysDefault() {
    let cal = java.util.GregorianCalendar()
    #expect(cal.getMinimalDaysInFirstWeek() == 1)
  }

  @Test("setMinimalDaysInFirstWeek() / getMinimalDaysInFirstWeek() round-trip")
  func testSetMinimalDays() {
    let cal = java.util.GregorianCalendar()
    cal.setMinimalDaysInFirstWeek(4)  // ISO 8601
    #expect(cal.getMinimalDaysInFirstWeek() == 4)
  }

  @Test("clone() copies lenient and minimalDaysInFirstWeek")
  func testCloneCopiesProperties() {
    let cal = java.util.GregorianCalendar()
    cal.setLenient(false)
    cal.setMinimalDaysInFirstWeek(4)
    let copy = cal.clone()
    #expect(copy.isLenient()                 == false)
    #expect(copy.getMinimalDaysInFirstWeek() == 4)
  }

  // MARK: - toInstant (Java 8)

  @Test("toInstant() epochMilli matches getTimeInMillis()")
  func testToInstantMatchesGetTimeInMillis() {
    let cal = java.util.GregorianCalendar(2026, java.util.Calendar.AUGUST, 10, 12, 0, 0)
    #expect(cal.toInstant().epochMilli == cal.getTimeInMillis())
  }

  @Test("toInstant() returns positive epochMilli for dates after 1970")
  func testToInstantPositiveForModernDate() {
    let cal = java.util.GregorianCalendar(2000, java.util.Calendar.JANUARY, 1)
    #expect(cal.toInstant().epochMilli > 0)
  }

  @Test("toInstant() returns negative epochMilli for dates before 1970")
  func testToInstantNegativeForHistoricalDate() {
    let cal = java.util.GregorianCalendar(1969, java.util.Calendar.DECEMBER, 31)
    #expect(cal.toInstant().epochMilli < 0)
  }

  @Test("toInstant() is consistent with setTimeInMillis")
  func testToInstantConsistentWithSetTimeInMillis() {
    let cal = java.util.GregorianCalendar()
    let knownMillis: Int64 = 1_000_000_000_000  // 2001-09-08T21:46:40Z
    cal.setTimeInMillis(knownMillis)
    #expect(cal.toInstant().epochMilli == knownMillis)
  }

  // MARK: - getMinimum / getMaximum: full 17-field coverage — Harmony CalendarTest

  @Test("getMinimum/getMaximum for all 17 Calendar fields match Java spec")
  func testAllFieldRanges() {
    let cal = java.util.GregorianCalendar()
    // ERA: 0 … 1
    #expect(cal.getMinimum(java.util.Calendar.ERA) == 0)
    #expect(cal.getMaximum(java.util.Calendar.ERA) == 1)
    // YEAR: 1 … 292278994
    #expect(cal.getMinimum(java.util.Calendar.YEAR) == 1)
    #expect(cal.getMaximum(java.util.Calendar.YEAR) == 292_278_994)
    // MONTH: 0 … 11
    #expect(cal.getMinimum(java.util.Calendar.MONTH) == 0)
    #expect(cal.getMaximum(java.util.Calendar.MONTH) == 11)
    // WEEK_OF_YEAR: 1 … 53
    #expect(cal.getMinimum(java.util.Calendar.WEEK_OF_YEAR) == 1)
    #expect(cal.getMaximum(java.util.Calendar.WEEK_OF_YEAR) == 53)
    // WEEK_OF_MONTH: 0 … 6
    #expect(cal.getMinimum(java.util.Calendar.WEEK_OF_MONTH) == 0)
    #expect(cal.getMaximum(java.util.Calendar.WEEK_OF_MONTH) == 6)
    // DAY_OF_MONTH: 1 … 31
    #expect(cal.getMinimum(java.util.Calendar.DAY_OF_MONTH) == 1)
    #expect(cal.getMaximum(java.util.Calendar.DAY_OF_MONTH) == 31)
    // DAY_OF_YEAR: 1 … 366
    #expect(cal.getMinimum(java.util.Calendar.DAY_OF_YEAR) == 1)
    #expect(cal.getMaximum(java.util.Calendar.DAY_OF_YEAR) == 366)
    // DAY_OF_WEEK: 1 … 7
    #expect(cal.getMinimum(java.util.Calendar.DAY_OF_WEEK) == 1)
    #expect(cal.getMaximum(java.util.Calendar.DAY_OF_WEEK) == 7)
    // DAY_OF_WEEK_IN_MONTH: -1 … 5
    #expect(cal.getMinimum(java.util.Calendar.DAY_OF_WEEK_IN_MONTH) == -1)
    #expect(cal.getMaximum(java.util.Calendar.DAY_OF_WEEK_IN_MONTH) == 5)
    // AM_PM: 0 … 1
    #expect(cal.getMinimum(java.util.Calendar.AM_PM) == 0)
    #expect(cal.getMaximum(java.util.Calendar.AM_PM) == 1)
    // HOUR: 0 … 11
    #expect(cal.getMinimum(java.util.Calendar.HOUR) == 0)
    #expect(cal.getMaximum(java.util.Calendar.HOUR) == 11)
    // HOUR_OF_DAY: 0 … 23
    #expect(cal.getMinimum(java.util.Calendar.HOUR_OF_DAY) == 0)
    #expect(cal.getMaximum(java.util.Calendar.HOUR_OF_DAY) == 23)
    // MINUTE: 0 … 59
    #expect(cal.getMinimum(java.util.Calendar.MINUTE) == 0)
    #expect(cal.getMaximum(java.util.Calendar.MINUTE) == 59)
    // SECOND: 0 … 59
    #expect(cal.getMinimum(java.util.Calendar.SECOND) == 0)
    #expect(cal.getMaximum(java.util.Calendar.SECOND) == 59)
    // MILLISECOND: 0 … 999
    #expect(cal.getMinimum(java.util.Calendar.MILLISECOND) == 0)
    #expect(cal.getMaximum(java.util.Calendar.MILLISECOND) == 999)
    // ZONE_OFFSET: -43200000 … 50400000 (−12h … +14h in ms)
    #expect(cal.getMinimum(java.util.Calendar.ZONE_OFFSET) == -12 * 3_600_000)
    #expect(cal.getMaximum(java.util.Calendar.ZONE_OFFSET) == 14 * 3_600_000)
    // DST_OFFSET: 0 … 7200000 (0 … 2h in ms)
    #expect(cal.getMinimum(java.util.Calendar.DST_OFFSET) == 0)
    #expect(cal.getMaximum(java.util.Calendar.DST_OFFSET) == 2 * 3_600_000)
  }

  @Test("getGreatestMinimum() == getMinimum() for all Gregorian Calendar fields")
  func testGreatestMinimumEqualsMinimum() {
    let cal = java.util.GregorianCalendar()
    for field in 0..<java.util.Calendar.FIELD_COUNT {
      #expect(cal.getGreatestMinimum(field) == cal.getMinimum(field))
    }
  }

  @Test("getLeastMaximum(DAY_OF_MONTH) == 28 and getLeastMaximum(DAY_OF_YEAR) == 365")
  func testLeastMaximumDayCounts() {
    let cal = java.util.GregorianCalendar()
    #expect(cal.getLeastMaximum(java.util.Calendar.DAY_OF_MONTH) == 28)
    #expect(cal.getLeastMaximum(java.util.Calendar.DAY_OF_YEAR)  == 365)
    #expect(cal.getLeastMaximum(java.util.Calendar.WEEK_OF_YEAR) == 52)
    #expect(cal.getLeastMaximum(java.util.Calendar.WEEK_OF_MONTH) == 4)
    #expect(cal.getLeastMaximum(java.util.Calendar.DAY_OF_WEEK_IN_MONTH) == 4)
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

}
