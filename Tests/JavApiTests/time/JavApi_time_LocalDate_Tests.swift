/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com> and contributors
 * SPDX-License-Identifier: MIT
 */
import Testing
import Foundation
@testable import JavApi

struct JavApi_time_LocalDate_Tests {

  @Test("property setters normalize overflow/underflow")
  func testPropertySetter() {
    var min = java.time.LocalDate.min
    min.year = 100; min.month = 2; min.day = -12
    #expect(min.year == 100); #expect(min.month == 1); #expect(min.day == 19)
  }

  @Test("min and max static values have correct boundary fields")
  func testMinMaxRange() {
    let min = java.time.LocalDate.min; let max = java.time.LocalDate.max
    #expect(min.year == -999_999_999); #expect(min.month == 1); #expect(min.day == 1)
    #expect(max.year ==  999_999_999); #expect(max.month == 12); #expect(max.day == 31)
  }

  @Test("comparable ordering is consistent")
  func testComparable() {
    let min = java.time.LocalDate.min; let max = java.time.LocalDate.max
    let old  = java.time.LocalDate(year: 1627, month: 2, day: 10)
    let n1   = java.time.LocalDate(year: 1627, month: 2, day: 11)
    let n2   = java.time.LocalDate(year: 1627, month: 3, day: 11)
    let n3   = java.time.LocalDate(year: 1628, month: 2, day: 11)
    let eq   = java.time.LocalDate(year: 1627, month: 2, day: 10)
    #expect(min < old); #expect(max > n1)
    #expect(old <= eq); #expect(old >= eq); #expect(old == eq)
    #expect(old < n1); #expect(old < n2); #expect(n3 > old); #expect(n2 > old); #expect(n1 > old)
    #expect(old != n1); #expect(old != n2); #expect(old != n3)

    let t1 = java.time.LocalDate(year: 1500, month: 6, day: 15)
    #expect(t1 > java.time.LocalDate(year: 1499, month: 6, day: 16))
    #expect(t1 > java.time.LocalDate(year: 1499, month: 7, day: 15))
    #expect(t1 < java.time.LocalDate(year: 1501, month: 6, day: 14))
    #expect(t1 < java.time.LocalDate(year: 1501, month: 5, day: 15))
  }

  @Test("overflow month/day is carried forward")
  func testFixOverflow() {
    let d = java.time.LocalDate(year: 2000, month: 13, day: 32)
    #expect(d.year == 2001); #expect(d.month == 2); #expect(d.day == 1)
  }

  @Test("underflow month/day is borrowed backward")
  func testFixUnderflow() {
    let d = java.time.LocalDate(year: 2000, month: 0, day: -30)
    #expect(d.year == 1999); #expect(d.month == 10); #expect(d.day == 31)
  }

  @Test("init from epochDay produces correct year/month/day")
  func testFromEpochDay() {
    let d1 = java.time.LocalDate(epochDay: -354_285)
    #expect(d1.year == 1000); #expect(d1.month == 1); #expect(d1.day == 1)
    let d2 = java.time.LocalDate(epochDay: -719_528)
    #expect(d2.year == 0);    #expect(d2.month == 1); #expect(d2.day == 1)
    let d3 = java.time.LocalDate(epochDay: 11_016)
    #expect(d3.year == 2000); #expect(d3.month == 2); #expect(d3.day == 29)
  }

  @Test("epochDay round-trips for year 1000-01-01")
  func testToEpochDay() {
    #expect(java.time.LocalDate(year: 1000, month: 1, day: 1).epochDay == -354_285)
  }

  @Test("init from dayOfYear resolves to 1970-01-01")
  func testFromDayOfYear() {
    let d = java.time.LocalDate(year: 1, dayOfYear: 719_163)
    #expect(d.year == 1970); #expect(d.month == 1); #expect(d.day == 1)
  }

  @Test("UTC clock produces fields matching utcCalendar")
  func testOtherTimeZone() {
    var cal = Calendar.current; cal.timeZone = TimeZone(identifier: "UTC")!
    let now = Date()
    let d1  = java.time.LocalDate(clock: .UTC)
    let d2  = java.time.LocalDate(now, clock: .UTC)
    #expect(d1.year  == cal.component(.year,  from: now))
    #expect(d1.month == cal.component(.month, from: now))
    #expect(d1.day   == cal.component(.day,   from: now))
    #expect(d1 >= d2)
  }

  @Test("format produces correctly formatted string")
  func testFormat() {
    let df = DateFormatter(); df.dateFormat = "yyyy--MM-dd"
    #expect(java.time.LocalDate(year: 2017, month: 7, day: 24).format(df) == "2017--07-24")
  }

  @Test("until computes component differences and full Period")
  func testUntil() {
    let old  = java.time.LocalDate(year: 1627, month: 2, day: 10)
    let new1 = java.time.LocalDate(year: 1628, month: 3, day: 12)
    #expect(old.until(endDate: new1, component: .year)    == 1)
    #expect(old.until(endDate: new1, component: .month)   == 13)
    #expect(old.until(endDate: new1, component: .weekday) == 56)
    #expect(old.until(endDate: new1, component: .day)     == 396)

    let new2 = java.time.LocalDate(year: 1628, month: 4, day: 11)
    #expect(new1.until(endDate: new2).year == 0); #expect(new1.until(endDate: new2).month == 0); #expect(new1.until(endDate: new2).day == 30)

    let new3 = java.time.LocalDate(year: 1628, month: 2, day: 13)
    #expect(new1.until(endDate: new3).year == -1); #expect(new1.until(endDate: new3).month == 11); #expect(new1.until(endDate: new3).day == 3)

    let p = old.until(endDate: new1)
    #expect(p.year == 1); #expect(p.month == 1); #expect(p.day == 2)
    #expect(p.hour == 0); #expect(p.minute == 0); #expect(p.second == 0); #expect(p.nano == 0)
  }

  @Test("range returns correct upper bounds for all components")
  func testRange() {
    let d1 = java.time.LocalDate(year: 1628, month: 3, day: 12)
    let d2 = java.time.LocalDate(year: 1629, month: 2, day: 12)
    let d3 = java.time.LocalDate(year: -1, month: 1, day: 1)
    #expect(d1.range(.month).1      == 31)
    #expect(d1.range(.weekday).1    == 5)
    #expect(d1.range(.year).1       == 366)
    #expect(d1.range(.weekOfMonth).1 == 5)
    #expect(d2.range(.weekOfMonth).1 == 4)
    #expect(d1.range(.era).1        == 999_999_999)
    #expect(d3.range(.era).1        == 1_000_000_000)
  }

  @Test("minus subtracts year/month/day/week independently")
  func testMinus() {
    let d = java.time.LocalDate(year: 1628, month: 3, day: 12)
    #expect(d.minus(year: 1)  == java.time.LocalDate(year: 1627, month: 3, day: 12))
    #expect(d.minus(month: 1) == java.time.LocalDate(year: 1628, month: 2, day: 12))
    #expect(d.minus(day: 1)   == java.time.LocalDate(year: 1628, month: 3, day: 11))
    #expect(d.minus(week: 1)  == java.time.LocalDate(year: 1628, month: 3, day: 5))
  }

  @Test("plus adds year/month/day/week independently")
  func testPlus() {
    let d = java.time.LocalDate(year: 1628, month: 3, day: 12)
    #expect(d.plus(year: 1)  == java.time.LocalDate(year: 1629, month: 3, day: 12))
    #expect(d.plus(month: 1) == java.time.LocalDate(year: 1628, month: 4, day: 12))
    #expect(d.plus(day: 1)   == java.time.LocalDate(year: 1628, month: 3, day: 13))
    #expect(d.plus(week: 1)  == java.time.LocalDate(year: 1628, month: 3, day: 19))
  }

  @Test("with replaces year/month/dayOfMonth/dayOfYear independently")
  func testWith() {
    let d = java.time.LocalDate(year: 1628, month: 3, day: 12)
    #expect(d.with(year: 1920)      == java.time.LocalDate(year: 1920, month: 3, day: 12))
    #expect(d.with(month: 12)       == java.time.LocalDate(year: 1628, month: 12, day: 12))
    #expect(d.with(dayOfMonth: 31)  == java.time.LocalDate(year: 1628, month: 3, day: 31))
    #expect(d.with(dayOfYear: 122)  == java.time.LocalDate(year: 1628, month: 5, day: 1))
  }

  @Test("toDate round-trips through current calendar")
  func testToDate() {
    let cal = Calendar.current
    let d   = java.time.LocalDate(year: 1999, month: 10, day: 31)
    let dt  = d.toDate(clock: .current)
    #expect(cal.component(.year,  from: dt) == 1999)
    #expect(cal.component(.month, from: dt) == 10)
    #expect(cal.component(.day,   from: dt) == 31)
  }

  @Test("isLeapYear returns true for 1628")
  func testIsLeapYear() {
    #expect(java.time.LocalDate(year: 1628, month: 3, day: 12).isLeapYear())
  }

  @Test("lengthOfYear returns 366 for leap and 365 for non-leap")
  func testLengthOfYear() {
    #expect(java.time.LocalDate(year: 1628, month: 2, day: 12).lengthOfYear() == 366)
    #expect(java.time.LocalDate(year: 1629, month: 2, day: 12).lengthOfYear() == 365)
  }

  @Test("lengthOfMonth returns 29 for Feb 1628 (leap)")
  func testLengthOfMonth() {
    #expect(java.time.LocalDate(year: 1628, month: 2, day: 12).lengthOfMonth() == 29)
  }

  @Test("dayOfWeek is pure-math (platform-independent)")
  func testDayOfWeek() {
    #expect(java.time.LocalDate(year: 1628, month: 3,  day: 12).dayOfWeek == 6)
    #expect(java.time.LocalDate(year: 1,    month: 1,  day: 1 ).dayOfWeek == 0)
    #expect(java.time.LocalDate(year: 1970, month: 1,  day: 1 ).dayOfWeek == 3)
    #expect(java.time.LocalDate(year: 1969, month: 12, day: 31).dayOfWeek == 2)
    #expect(java.time.LocalDate(year: 1517, month: 7,  day: 18).dayOfWeek == 2)
    #expect(java.time.LocalDate(year: -1,   month: 12, day: 26).dayOfWeek == 6)
  }

  @Test("parse with default and custom formatters")
  func testParse() {
    let d1 = java.time.LocalDate.parse("2014-11-15", clock: .current)!
    #expect(d1.year == 2014); #expect(d1.month == 11); #expect(d1.day == 15)

    let df1 = DateFormatter(); df1.dateFormat = "yyyy--MM-dd"
    #expect(d1 == java.time.LocalDate.parse("2014--11-15", formatter: df1, clock: .current))

    let df2 = DateFormatter(); df2.dateFormat = "yyyy-asdf"
    #expect(java.time.LocalDate.parse("2014--11-15", formatter: df2, clock: .current) == nil)
  }

  @Test("+ operator adds dates and += mutates in place")
  func testAddDate() {
    var old = java.time.LocalDate(year: 1000, month: 1, day: 1)
    let add = java.time.LocalDate(month: 1, day: 3)
    let new_ = old + add
    #expect(new_.year == 1000); #expect(new_.month == 2); #expect(new_.day == 4)
    old += add; #expect(old == new_)
  }

  @Test("- operator subtracts dates and -= mutates in place")
  func testSubtractDate() {
    var old = java.time.LocalDate(year: 1000, month: 1, day: 1)
    let sub = java.time.LocalDate(month: 1, day: 3)
    let new_ = old - sub
    #expect(new_.year == 999); #expect(new_.month == 11); #expect(new_.day == 28)
    old -= sub; #expect(old == new_)
  }

  @Test("hashValue matches manually combined hasher")
  func testHashable() {
    let d = java.time.LocalDate(year: 1969, month: 12, day: 31)
    var h = Hasher(); h.combine(1969); h.combine(12); h.combine(31)
    #expect(d.hashValue == h.finalize())
  }

  @Test("description strings are formatted correctly")
  func testDescription() {
    let d = java.time.LocalDate(year: 1969, month: 12, day: 31)
    #expect(d.description == "1969.12.31"); #expect(d.debugDescription == "1969.12.31")
    if let pd = d.playgroundDescription as? String { #expect(pd == "1969.12.31") }
  }

  @Test("customMirror exposes year/month/day")
  func testMirror() {
    let d = java.time.LocalDate(year: 1969, month: 12, day: 31)
    var checkList = ["year": 1969, "month": 12, "day": 31]
    for child in d.customMirror.children {
      #expect(checkList[child.label!] == (child.value as? Int)!)
      checkList.removeValue(forKey: child.label!)
    }
    #expect(checkList.count == 0)
  }

  @Test("Codable round-trip preserves year/month/day")
  func testCodable() throws {
    let d1   = java.time.LocalDate(year: 1969, month: 12, day: 31)
    let data = try JSONEncoder().encode(d1)
    let d2   = try JSONDecoder().decode(java.time.LocalDate.self, from: data)
    #expect(d1 == d2)
  }
}
