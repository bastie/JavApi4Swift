/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com> and contributors
 * SPDX-License-Identifier: MIT
 */
import Testing
import Foundation
@testable import JavApi

struct JavApi_time_LocalDateTime_Tests {

  @Test("property setters normalize all fields")
  func testPropertySetter() {
    var min = java.time.LocalDateTime.min
    min.year = 100; min.month = 2; min.day = -12; min.hour = 12; min.minute = 2; min.second = -12; min.nano = -125_221
    #expect(min.year == 100); #expect(min.month == 1); #expect(min.day == 19)
    #expect(min.hour == 12); #expect(min.minute == 1); #expect(min.second == 47); #expect(min.nano == 999_874_779)

    min.date = java.time.LocalDate(year: 100, month: 2, day: -12)
    min.time = java.time.LocalTime(hour: 12, minute: 2, second: -12, nanoOfSecond: -125_221)
    #expect(min.year == 100); #expect(min.month == 1); #expect(min.day == 19)
    #expect(min.hour == 12); #expect(min.minute == 1); #expect(min.second == 47); #expect(min.nano == 999_874_779)
  }

  @Test("min and max static values have correct boundary fields")
  func testMinMaxRange() {
    let min = java.time.LocalDateTime.min; let max = java.time.LocalDateTime.max
    #expect(min.year == -999_999_999); #expect(min.month == 1);  #expect(min.day == 1)
    #expect(min.hour == 0); #expect(min.minute == 0); #expect(min.second == 0); #expect(min.nano == 0)
    #expect(max.year ==  999_999_999); #expect(max.month == 12); #expect(max.day == 31)
    #expect(max.hour == 23); #expect(max.minute == 59); #expect(max.second == 59); #expect(max.nano == 999_999_999)
  }

  @Test("comparable ordering is consistent across all fields")
  func testComparable() {
    let min = java.time.LocalDateTime.min; let max = java.time.LocalDateTime.max
    let old = java.time.LocalDateTime(year: 1627, month: 2, day: 10, hour: 14, minute: 2, second: 18, nanoOfSecond: 1573)
    let n1  = java.time.LocalDateTime(year: 1627, month: 2, day: 10, hour: 14, minute: 2, second: 18, nanoOfSecond: 1574)
    let n2  = java.time.LocalDateTime(year: 1627, month: 2, day: 10, hour: 15, minute: 2, second: 18, nanoOfSecond: 1574)
    let eq  = java.time.LocalDateTime(year: 1627, month: 2, day: 10, hour: 14, minute: 2, second: 18, nanoOfSecond: 1573)
    #expect(min < old); #expect(max > n1); #expect(old <= eq); #expect(old >= eq); #expect(n2 > old); #expect(old == eq); #expect(old < n1)

    let t1 = java.time.LocalDateTime(year: 1500, month: 6, day: 15, hour: 12, minute: 30, second: 30, nanoOfSecond: 500_000_000)
    for t in [
      java.time.LocalDateTime(year: 1499, month: 6, day: 15, hour: 12, minute: 30, second: 30, nanoOfSecond: 500_000_001),
      java.time.LocalDateTime(year: 1499, month: 6, day: 15, hour: 12, minute: 30, second: 31, nanoOfSecond: 500_000_000),
      java.time.LocalDateTime(year: 1499, month: 6, day: 15, hour: 12, minute: 31, second: 30, nanoOfSecond: 500_000_000),
      java.time.LocalDateTime(year: 1499, month: 6, day: 15, hour: 13, minute: 30, second: 30, nanoOfSecond: 500_000_000),
      java.time.LocalDateTime(year: 1499, month: 6, day: 16, hour: 12, minute: 30, second: 30, nanoOfSecond: 500_000_000),
      java.time.LocalDateTime(year: 1499, month: 7, day: 15, hour: 12, minute: 30, second: 30, nanoOfSecond: 500_000_000)
    ] { #expect(t1 > t) }
    for t in [
      java.time.LocalDateTime(year: 1501, month: 6, day: 15, hour: 12, minute: 30, second: 30, nanoOfSecond: 499_999_999),
      java.time.LocalDateTime(year: 1501, month: 6, day: 15, hour: 12, minute: 30, second: 29, nanoOfSecond: 500_000_000),
      java.time.LocalDateTime(year: 1501, month: 6, day: 15, hour: 12, minute: 29, second: 30, nanoOfSecond: 500_000_000),
      java.time.LocalDateTime(year: 1501, month: 6, day: 15, hour: 11, minute: 30, second: 30, nanoOfSecond: 500_000_000),
      java.time.LocalDateTime(year: 1501, month: 6, day: 14, hour: 12, minute: 30, second: 30, nanoOfSecond: 500_000_000),
      java.time.LocalDateTime(year: 1501, month: 5, day: 15, hour: 12, minute: 30, second: 30, nanoOfSecond: 500_000_000)
    ] { #expect(t1 < t) }
  }

  @Test("overflow in all fields is carried forward")
  func testFixOverflow() {
    let d = java.time.LocalDateTime(year: 2000, month: 13, day: 32, hour: 14, minute: 61, second: 18, nanoOfSecond: 1573)
    #expect(d.year == 2001); #expect(d.month == 2); #expect(d.day == 1)
    #expect(d.hour == 15); #expect(d.minute == 1); #expect(d.second == 18); #expect(d.nano == 1573)
  }

  @Test("underflow in all fields is borrowed backward")
  func testFixUnderflow() {
    let d = java.time.LocalDateTime(year: 2000, month: 0, day: -30, hour: 14, minute: -2, second: 18, nanoOfSecond: 1573)
    #expect(d.year == 1999); #expect(d.month == 10); #expect(d.day == 31)
    #expect(d.hour == 13); #expect(d.minute == 58); #expect(d.second == 18); #expect(d.nano == 1573)
  }

  @Test("init from epochDay and nanoOfDay produces correct fields")
  func testFromEpochDayAndNanoOfDay() {
    let d = java.time.LocalDateTime(epochDay: -354_285, nanoOfDay: 13_602_057_328_029)
    #expect(d.year == 1000); #expect(d.month == 1); #expect(d.day == 1)
    #expect(d.hour == 3); #expect(d.minute == 46); #expect(d.second == 42); #expect(d.nano == 57_328_029)
  }

  @Test("init from LocalDate and LocalTime produces correct fields")
  func testFromDateAndTime() {
    let d = java.time.LocalDateTime(
      date: java.time.LocalDate(epochDay: -354_285),
      time: java.time.LocalTime(nanoOfDay: 13_602_057_328_029)
    )
    #expect(d.year == 1000); #expect(d.month == 1); #expect(d.day == 1)
    #expect(d.hour == 3); #expect(d.minute == 46); #expect(d.second == 42); #expect(d.nano == 57_328_029)
  }

  @Test("UTC clock produces fields matching utcCalendar")
  func testOtherTimeZone() {
    var cal = Calendar.current; cal.timeZone = TimeZone(identifier: "UTC")!
    let now = Date()
    let d1 = java.time.LocalDateTime(clock: .UTC)
    let d2 = java.time.LocalDateTime(now, clock: .UTC)
    #expect(d2.year   == cal.component(.year,       from: now))
    #expect(d2.month  == cal.component(.month,      from: now))
    #expect(d2.day    == cal.component(.day,        from: now))
    #expect(d2.hour   == cal.component(.hour,       from: now))
    #expect(d2.minute == cal.component(.minute,     from: now))
    #expect(d2.second == cal.component(.second,     from: now))
    #expect(d2.nano   == cal.component(.nanosecond, from: now))
    #expect(d1 >= d2)
  }

  @Test("format produces correctly formatted string")
  func testFormat() {
    let d = java.time.LocalDateTime(year: 2017, month: 7, day: 24, hour: 3, minute: 46, second: 42, nanoOfSecond: 57_328_029)
    let df = DateFormatter(); df.dateFormat = "yyyy--MM-dd HH::mm:ss.SSS"
    #expect(d.format(df) == "2017--07-24 03::46:42.057")
  }

  @Test("until computes period and component differences correctly")
  func testUntil() {
    let old  = java.time.LocalDateTime(year: 1627, month: 2, day: 10, hour: 14, minute: 2, second: 18, nanoOfSecond: 1573)
    let new1 = java.time.LocalDateTime(year: 1628, month: 3, day: 12, hour: 15, minute: 3, second: 19, nanoOfSecond: 1574)
    let p = old.until(endDateTime: new1)
    #expect(p.year == 1); #expect(p.month == 1); #expect(p.day == 2)
    #expect(p.hour == 1); #expect(p.minute == 1); #expect(p.second == 1); #expect(p.nano == 1)

    #expect(old.until(endDateTime: new1, component: .year)        == 1)
    #expect(old.until(endDateTime: new1, component: .month)       == 13)
    #expect(old.until(endDateTime: new1, component: .weekday)     == 56)
    #expect(old.until(endDateTime: new1, component: .day)         == 397)
    #expect(old.until(endDateTime: new1, component: .hour)        == 9505)
    #expect(old.until(endDateTime: new1, component: .minute)      == 570_301)
    #expect(old.until(endDateTime: new1, component: .second)      == 34_218_061)
    #expect(old.until(endDateTime: new1, component: .nanosecond)  == 34_218_061_000_000_001)

    let new2 = java.time.LocalDateTime(year: 1628, month: 3, day: 11, hour: 14, minute: 3, second: 19, nanoOfSecond: 1574)
    #expect(new1.until(endDateTime: new2, component: .day)  == -2)
    #expect(new1.until(endDateTime: new2, component: .hour) == -25)

    let new3 = java.time.LocalDateTime(year: 1628, month: 3, day: 13, hour: 14, minute: 3, second: 19, nanoOfSecond: 1574)
    #expect(new1.until(endDateTime: new3, component: .day)  == 1)
    #expect(new1.until(endDateTime: new3, component: .hour) == 23)
  }

  @Test("range returns correct upper bounds for all components")
  func testRange() {
    let d = java.time.LocalDateTime(year: 1628, month: 3, day: 12, hour: 15, minute: 3, second: 19, nanoOfSecond: 1574)
    #expect(d.range(.nanosecond).1 == 999_999_999); #expect(d.range(.second).1 == 59)
    #expect(d.range(.minute).1 == 59); #expect(d.range(.hour).1 == 23)
    #expect(d.range(.month).1 == 31); #expect(d.range(.weekday).1 == 5)
    #expect(d.range(.year).1 == 366); #expect(d.range(.weekOfMonth).1 == 5)
    #expect(d.range(.era).1 == 999_999_999)
  }

  @Test("minus subtracts each field independently")
  func testMinus() {
    let d = java.time.LocalDateTime(year: 2000, month: 11, day: 30, hour: 11, minute: 51, second: 18, nanoOfSecond: 1573)
    #expect(d.minus(year: 1)   == java.time.LocalDateTime(year: 1999, month: 11, day: 30, hour: 11, minute: 51, second: 18, nanoOfSecond: 1573))
    #expect(d.minus(month: 1)  == java.time.LocalDateTime(year: 2000, month: 10, day: 30, hour: 11, minute: 51, second: 18, nanoOfSecond: 1573))
    #expect(d.minus(day: 1)    == java.time.LocalDateTime(year: 2000, month: 11, day: 29, hour: 11, minute: 51, second: 18, nanoOfSecond: 1573))
    #expect(d.minus(week: 1)   == java.time.LocalDateTime(year: 2000, month: 11, day: 23, hour: 11, minute: 51, second: 18, nanoOfSecond: 1573))
    #expect(d.minus(hour: 1)   == java.time.LocalDateTime(year: 2000, month: 11, day: 30, hour: 10, minute: 51, second: 18, nanoOfSecond: 1573))
    #expect(d.minus(minute: 1) == java.time.LocalDateTime(year: 2000, month: 11, day: 30, hour: 11, minute: 50, second: 18, nanoOfSecond: 1573))
    #expect(d.minus(second: 1) == java.time.LocalDateTime(year: 2000, month: 11, day: 30, hour: 11, minute: 51, second: 17, nanoOfSecond: 1573))
    #expect(d.minus(nano: 1)   == java.time.LocalDateTime(year: 2000, month: 11, day: 30, hour: 11, minute: 51, second: 18, nanoOfSecond: 1572))
  }

  @Test("plus adds each field independently")
  func testPlus() {
    let d = java.time.LocalDateTime(year: 2000, month: 11, day: 30, hour: 11, minute: 51, second: 18, nanoOfSecond: 1573)
    #expect(d.plus(year: 1)   == java.time.LocalDateTime(year: 2001, month: 11, day: 30, hour: 11, minute: 51, second: 18, nanoOfSecond: 1573))
    #expect(d.plus(month: 1)  == java.time.LocalDateTime(year: 2000, month: 12, day: 30, hour: 11, minute: 51, second: 18, nanoOfSecond: 1573))
    #expect(d.plus(day: 1)    == java.time.LocalDateTime(year: 2000, month: 11, day: 31, hour: 11, minute: 51, second: 18, nanoOfSecond: 1573))
    #expect(d.plus(week: 1)   == java.time.LocalDateTime(year: 2000, month: 12, day: 7,  hour: 11, minute: 51, second: 18, nanoOfSecond: 1573))
    #expect(d.plus(hour: 1)   == java.time.LocalDateTime(year: 2000, month: 11, day: 30, hour: 12, minute: 51, second: 18, nanoOfSecond: 1573))
    #expect(d.plus(minute: 1) == java.time.LocalDateTime(year: 2000, month: 11, day: 30, hour: 11, minute: 52, second: 18, nanoOfSecond: 1573))
    #expect(d.plus(second: 1) == java.time.LocalDateTime(year: 2000, month: 11, day: 30, hour: 11, minute: 51, second: 19, nanoOfSecond: 1573))
    #expect(d.plus(nano: 1)   == java.time.LocalDateTime(year: 2000, month: 11, day: 30, hour: 11, minute: 51, second: 18, nanoOfSecond: 1574))
  }

  @Test("with replaces each field independently")
  func testWith() {
    let d = java.time.LocalDateTime(year: 2000, month: 11, day: 30, hour: 11, minute: 51, second: 18, nanoOfSecond: 1573)
    #expect(d.with(year: 1)   == java.time.LocalDateTime(year: 1,    month: 11, day: 30, hour: 11, minute: 51, second: 18, nanoOfSecond: 1573))
    #expect(d.with(month: 1)  == java.time.LocalDateTime(year: 2000, month: 1,  day: 30, hour: 11, minute: 51, second: 18, nanoOfSecond: 1573))
    #expect(d.with(day: 1)    == java.time.LocalDateTime(year: 2000, month: 11, day: 1,  hour: 11, minute: 51, second: 18, nanoOfSecond: 1573))
    #expect(d.with(hour: 1)   == java.time.LocalDateTime(year: 2000, month: 11, day: 30, hour: 1,  minute: 51, second: 18, nanoOfSecond: 1573))
    #expect(d.with(minute: 1) == java.time.LocalDateTime(year: 2000, month: 11, day: 30, hour: 11, minute: 1,  second: 18, nanoOfSecond: 1573))
    #expect(d.with(second: 1) == java.time.LocalDateTime(year: 2000, month: 11, day: 30, hour: 11, minute: 51, second: 1,  nanoOfSecond: 1573))
    #expect(d.with(nano: 1)   == java.time.LocalDateTime(year: 2000, month: 11, day: 30, hour: 11, minute: 51, second: 18, nanoOfSecond: 1))
  }

  @Test("isLeapYear/lengthOfYear/lengthOfMonth work correctly")
  func testCalendarHelpers() {
    let d1 = java.time.LocalDateTime(year: 2000, month: 11, day: 30, hour: 11, minute: 51, second: 18, nanoOfSecond: 1573)
    #expect(d1.isLeapYear()); #expect(d1.lengthOfYear() == 366)
    let d2 = java.time.LocalDateTime(year: 1628, month: 2, day: 12, hour: 11, minute: 51, second: 18, nanoOfSecond: 1573)
    #expect(d2.lengthOfMonth() == 29)
  }

  @Test("dayOfWeek is pure-math (platform-independent)")
  func testDayOfWeek() {
    #expect(java.time.LocalDateTime(year: 1628, month: 3,  day: 12, hour: 0, minute: 0, second: 0, nanoOfSecond: 0).dayOfWeek == 6)
    #expect(java.time.LocalDateTime(year: 1,    month: 1,  day: 1,  hour: 0, minute: 0, second: 0, nanoOfSecond: 0).dayOfWeek == 0)
    #expect(java.time.LocalDateTime(year: 1970, month: 1,  day: 1,  hour: 0, minute: 0, second: 0, nanoOfSecond: 0).dayOfWeek == 3)
    #expect(java.time.LocalDateTime(year: 1969, month: 12, day: 31, hour: 0, minute: 0, second: 0, nanoOfSecond: 0).dayOfWeek == 2)
    #expect(java.time.LocalDateTime(year: 1517, month: 7,  day: 18, hour: 0, minute: 0, second: 0, nanoOfSecond: 0).dayOfWeek == 2)
    #expect(java.time.LocalDateTime(year: -1,   month: 12, day: 26, hour: 0, minute: 0, second: 0, nanoOfSecond: 0).dayOfWeek == 6)
  }

  @Test("parse with default and custom formatters")
  func testParse() {
    let d1 = java.time.LocalDateTime.parse("2014-11-15T12:44:52.123", clock: .current)!
    #expect(d1.year == 2014); #expect(d1.month == 11); #expect(d1.day == 15)
    #expect(d1.hour == 12); #expect(d1.minute == 44); #expect(d1.second == 52)
    #expect(123_500_000 > d1.nano); #expect(122_500_000 <= d1.nano)

    let df1 = DateFormatter(); df1.dateFormat = "yyyy--MM-dd...HH.mm.ss.SSS"
    #expect(d1 == java.time.LocalDateTime.parse("2014--11-15...12.44.52.123", formatter: df1, clock: .current))

    let df2 = DateFormatter(); df2.dateFormat = "yyyy--asdfasdfsadf"
    #expect(java.time.LocalDateTime.parse("2014--11-15...12.44.52.123", formatter: df2, clock: .current) == nil)
  }

  @Test("+ and += operators add LocalDateTime, date part, and time part")
  func testAddDate() {
    var d   = java.time.LocalDateTime(year: 1000, month: 1, day: 1, hour: 11, minute: 51, second: 18, nanoOfSecond: 1573)
    let add = java.time.LocalDateTime(year: 0,    month: 1, day: 3, hour: 0,  minute: 8,  second: 0,  nanoOfSecond: 0)

    let r1 = d + add
    #expect(r1.year == 1000); #expect(r1.month == 2); #expect(r1.day == 4)
    #expect(r1.hour == 11);   #expect(r1.minute == 59); #expect(r1.nano == 1573)
    d += add; #expect(d == r1)

    let r2 = d + add.date
    #expect(r2.month == 3); #expect(r2.day == 7)
    d += add.date; #expect(d == r2)

    let r3 = d + add.time
    #expect(r3.hour == 12); #expect(r3.minute == 7)
    d += add.time; #expect(d == r3)
  }

  @Test("- and -= operators subtract LocalDateTime, date part, and time part")
  func testSubtractDate() {
    var d   = java.time.LocalDateTime(year: 1000, month: 1, day: 7, hour: 11, minute: 51, second: 18, nanoOfSecond: 1573)
    let sub = java.time.LocalDateTime(year: 0,    month: 1, day: 3, hour: 0,  minute: 8,  second: 0,  nanoOfSecond: 0)

    let r1 = d - sub
    #expect(r1.year == 999); #expect(r1.month == 12); #expect(r1.day == 4); #expect(r1.minute == 43)
    d -= sub; #expect(d == r1)

    let r2 = d - sub.date
    #expect(r2.month == 11); #expect(r2.day == 1)
    d -= sub.date; #expect(d == r2)

    let r3 = d - sub.time
    #expect(r3.minute == 35)
    d -= sub.time; #expect(d == r3)
  }

  @Test("toDate round-trips through UTC calendar")
  func testToDate() {
    var cal = Calendar.current; cal.timeZone = TimeZone(identifier: "UTC")!
    let ldt = java.time.LocalDateTime(year: 1999, month: 10, day: 31, hour: 11, minute: 51, second: 18, nanoOfSecond: 153_000_000)
    let dt  = ldt.toDate(clock: .UTC)
    #expect(cal.component(.year,   from: dt) == 1999); #expect(cal.component(.month,  from: dt) == 10)
    #expect(cal.component(.day,    from: dt) == 31);   #expect(cal.component(.hour,   from: dt) == 11)
    #expect(cal.component(.minute, from: dt) == 51);   #expect(cal.component(.second, from: dt) == 18)
    #expect(153_500_000 >= cal.component(.nanosecond, from: dt))
    #expect(152_500_000 <= cal.component(.nanosecond, from: dt))
  }

  @Test("hashValue matches manually combined hasher")
  func testHashable() {
    let d = java.time.LocalDateTime(year: 1999, month: 10, day: 31, hour: 11, minute: 51, second: 18, nanoOfSecond: 153_000_000)
    var h = Hasher(); h.combine(d.date); h.combine(d.time)
    #expect(d.hashValue == h.finalize())
  }

  @Test("description strings are formatted correctly")
  func testDescription() {
    let d = java.time.LocalDateTime(year: 1999, month: 10, day: 31, hour: 11, minute: 51, second: 18, nanoOfSecond: 153_000_000)
    #expect(d.description == "1999.10.31T11:51:18.153000000")
    #expect(d.debugDescription == "1999.10.31T11:51:18.153000000")
    if let pd = d.playgroundDescription as? String { #expect(pd == "1999.10.31T11:51:18.153000000") }
  }

  @Test("customMirror exposes all seven date-time fields")
  func testMirror() {
    let d = java.time.LocalDateTime(year: 1999, month: 10, day: 31, hour: 11, minute: 51, second: 18, nanoOfSecond: 153_000_000)
    var checkList = ["year": 1999, "month": 10, "day": 31, "hour": 11, "minute": 51, "second": 18, "nano": 153_000_000]
    for child in d.customMirror.children {
      #expect(checkList[child.label!] == (child.value as? Int)!)
      checkList.removeValue(forKey: child.label!)
    }
    #expect(checkList.count == 0)
  }

  @Test("Codable round-trip preserves all fields")
  func testCodable() throws {
    let d1   = java.time.LocalDateTime(year: 1999, month: 10, day: 31, hour: 11, minute: 51, second: 18, nanoOfSecond: 153_000_000)
    let data = try JSONEncoder().encode(d1)
    let d2   = try JSONDecoder().decode(java.time.LocalDateTime.self, from: data)
    #expect(d1 == d2)
  }
}
