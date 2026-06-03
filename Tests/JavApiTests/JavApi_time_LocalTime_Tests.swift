/*
 * SPDX-License-Identifier: MIT
 */
import Testing
import Foundation
@testable import JavApi

struct JavApi_time_LocalTime_Tests {

  @Test("property setters normalize overflow and underflow")
  func testPropertySetter() {
    var min = java.time.LocalTime.min
    min.hour = 100
    min.minute = 2
    min.second = -12
    min.nano = -125_221

    #expect(min.hour == 100)
    #expect(min.minute == 1)
    #expect(min.second == 47)
    #expect(min.nano == 999_874_779)
  }

  @Test("static variables midNight, noon, min, max have correct values")
  func testStaticVariables() {
    let midNight = java.time.LocalTime.midNight
    let noon     = java.time.LocalTime.noon
    let min      = java.time.LocalTime.min
    let max      = java.time.LocalTime.max

    #expect(midNight.hour == 0)
    #expect(midNight.minute == 0)
    #expect(midNight.second == 0)
    #expect(midNight.nano == 0)

    #expect(noon.hour == 12)
    #expect(noon.minute == 0)
    #expect(noon.second == 0)
    #expect(noon.nano == 0)

    #expect(midNight == min)

    #expect(max.hour == 23)
    #expect(max.minute == 59)
    #expect(max.second == 59)
    #expect(max.nano == 999_999_999)
  }

  @Test("static hour factory sets only hour, rest zero")
  func testStaticHour() {
    let time = java.time.LocalTime.hour(5)
    #expect(time.hour == 5)
    #expect(time.minute == 0)
    #expect(time.second == 0)
    #expect(time.nano == 0)
  }

  @Test("comparable ordering is consistent across all fields")
  func testComparable() {
    let min = java.time.LocalTime.min
    let max = java.time.LocalTime.max

    let oldTime   = java.time.LocalTime(hour: 14, minute: 2,  second: 18, nanoOfSecond: 1573)
    let newTime1  = java.time.LocalTime(hour: 14, minute: 2,  second: 18, nanoOfSecond: 1574)
    let newTime2  = java.time.LocalTime(hour: 14, minute: 2,  second: 19, nanoOfSecond: 1574)
    let newTime3  = java.time.LocalTime(hour: 14, minute: 3,  second: 19, nanoOfSecond: 1574)
    let newTime4  = java.time.LocalTime(hour: 15, minute: 3,  second: 19, nanoOfSecond: 1574)
    let equalTime = java.time.LocalTime(hour: 14, minute: 2,  second: 18, nanoOfSecond: 1573)

    #expect(min < oldTime)
    #expect(max > newTime1)
    #expect(oldTime <= equalTime)
    #expect(oldTime >= equalTime)
    #expect(oldTime < newTime2)
    #expect(oldTime < newTime3)
    #expect(oldTime < newTime4)
    #expect(newTime4 > oldTime)
    #expect(newTime3 > oldTime)
    #expect(newTime2 > oldTime)
    #expect(newTime1 > oldTime)
    #expect(oldTime == equalTime)
    #expect(oldTime != newTime1)
    #expect(oldTime != newTime2)
    #expect(oldTime != newTime3)
    #expect(oldTime != newTime4)
    #expect(oldTime < newTime1)

    // #15 TestCode
    let test1 = java.time.LocalTime(hour: 12, minute: 30, second: 30, nanoOfSecond: 500_000_000)
    let test2 = java.time.LocalTime(hour: 11, minute: 30, second: 30, nanoOfSecond: 500_000_001)
    let test3 = java.time.LocalTime(hour: 11, minute: 30, second: 31, nanoOfSecond: 500_000_000)
    let test4 = java.time.LocalTime(hour: 11, minute: 31, second: 30, nanoOfSecond: 500_000_000)
    #expect(test1 > test2)
    #expect(test1 > test3)
    #expect(test1 > test4)

    let test5 = java.time.LocalTime(hour: 13, minute: 30, second: 30, nanoOfSecond: 499_999_999)
    let test6 = java.time.LocalTime(hour: 13, minute: 30, second: 29, nanoOfSecond: 500_000_000)
    let test7 = java.time.LocalTime(hour: 13, minute: 29, second: 30, nanoOfSecond: 500_000_000)
    #expect(test1 < test5)
    #expect(test1 < test6)
    #expect(test1 < test7)
  }

  @Test("overflow in minutes is carried to hours")
  func testFixOverflow() {
    let time = java.time.LocalTime(hour: 14, minute: 61, second: 18, nanoOfSecond: 1573)
    #expect(time.hour == 15)
    #expect(time.minute == 1)
    #expect(time.second == 18)
    #expect(time.nano == 1573)
  }

  @Test("underflow in minutes is borrowed from hours")
  func testFixUnderflow() {
    let time = java.time.LocalTime(hour: 14, minute: -2, second: 18, nanoOfSecond: 1573)
    #expect(time.hour == 13)
    #expect(time.minute == 58)
    #expect(time.second == 18)
    #expect(time.nano == 1573)
  }

  @Test("init from nanoOfDay produces correct fields")
  func testFromNanoOfDay() {
    let time = java.time.LocalTime(nanoOfDay: 13_602_057_328_029)
    #expect(time.hour == 3)
    #expect(time.minute == 46)
    #expect(time.second == 42)
    #expect(time.nano == 57_328_029)
  }

  @Test("nanoOfDay round-trips correctly")
  func testToNanoOfDay() {
    let time = java.time.LocalTime(hour: 3, minute: 46, second: 42, nanoOfSecond: 57_328_029)
    #expect(time.nanoOfDay == 13_602_057_328_029)
  }

  @Test("secondOfDay is calculated correctly")
  func testToSecondOfDay() {
    let time = java.time.LocalTime(hour: 3, minute: 46, second: 42, nanoOfSecond: 57_328_029)
    #expect(time.secondOfDay == 13_602)
  }

  @Test("init from secondOfDay produces correct fields with nano 0")
  func testFromSecondOfDay() {
    let time = java.time.LocalTime(secondOfDay: 13_602)
    #expect(time.hour == 3)
    #expect(time.minute == 46)
    #expect(time.second == 42)
    #expect(time.nano == 0)
  }

  @Test("UTC clock produces expected hour/minute/second/nano")
  func testOtherTimeZone() {
    var utcCalendar = Calendar.current
    utcCalendar.timeZone = TimeZone(identifier: "UTC")!

    let date = Date()

    let localTime1 = java.time.LocalTime(clock: .UTC)
    let localTime2 = java.time.LocalTime(date, clock: .UTC)
    #expect(localTime2.hour   == utcCalendar.component(.hour,       from: date))
    #expect(localTime2.minute == utcCalendar.component(.minute,     from: date))
    #expect(localTime2.second == utcCalendar.component(.second,     from: date))
    #expect(localTime2.nano   == utcCalendar.component(.nanosecond, from: date))
    #expect(localTime1 >= localTime2)

    let localTime3 = java.time.LocalTime(date, clock: java.time.Clock(offsetHour: 9))
    #expect(localTime2.nanoOfDay != localTime3.nanoOfDay)
  }

  @Test("format produces correctly formatted string")
  func testFormat() {
    let time = java.time.LocalTime(hour: 3, minute: 46, second: 42, nanoOfSecond: 57_328_029)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss.SSS"
    #expect(time.format(dateFormatter) == "03:46:42.057")
  }

  @Test("until computes period and component differences correctly")
  func testUntil() {
    let oldTime = java.time.LocalTime(hour: 14, minute: 2,  second: 18, nanoOfSecond: 1573)
    let newTime = java.time.LocalTime(hour: 15, minute: 3,  second: 19, nanoOfSecond: 1574)

    let period = oldTime.until(endTime: newTime)
    #expect(period.year   == 0)
    #expect(period.month  == 0)
    #expect(period.day    == 0)
    #expect(period.hour   == 1)
    #expect(period.minute == 1)
    #expect(period.second == 1)
    #expect(period.nano   == 1)

    #expect(oldTime.until(endTime: newTime, component: .day)        == 0)
    #expect(oldTime.until(endTime: newTime, component: .hour)       == 1)
    #expect(oldTime.until(endTime: newTime, component: .minute)     == 61)
    #expect(oldTime.until(endTime: newTime, component: .second)     == 3661)
    #expect(oldTime.until(endTime: newTime, component: .nanosecond) == 3661_000_000_001)
  }

  @Test("range returns correct upper bounds for all fields")
  func testRange() {
    let time = java.time.LocalTime(hour: 14, minute: 2, second: 18, nanoOfSecond: 1573)
    #expect(time.range(.hour).1       == 23)
    #expect(time.range(.minute).1     == 59)
    #expect(time.range(.second).1     == 59)
    #expect(time.range(.nanosecond).1 == 999_999_999)
  }

  @Test("minus subtracts each field independently")
  func testMinus() {
    let time = java.time.LocalTime(hour: 14, minute: 2, second: 18, nanoOfSecond: 1573)

    #expect(time.minus(hour:   1) == java.time.LocalTime(hour: 13, minute: 2,  second: 18, nanoOfSecond: 1573))
    #expect(time.minus(minute: 1) == java.time.LocalTime(hour: 14, minute: 1,  second: 18, nanoOfSecond: 1573))
    #expect(time.minus(second: 1) == java.time.LocalTime(hour: 14, minute: 2,  second: 17, nanoOfSecond: 1573))
    #expect(time.minus(nano:   1) == java.time.LocalTime(hour: 14, minute: 2,  second: 18, nanoOfSecond: 1572))
  }

  @Test("plus adds each field independently")
  func testPlus() {
    let time = java.time.LocalTime(hour: 14, minute: 2, second: 18, nanoOfSecond: 1573)

    #expect(time.plus(hour:   1) == java.time.LocalTime(hour: 15, minute: 2,  second: 18, nanoOfSecond: 1573))
    #expect(time.plus(minute: 1) == java.time.LocalTime(hour: 14, minute: 3,  second: 18, nanoOfSecond: 1573))
    #expect(time.plus(second: 1) == java.time.LocalTime(hour: 14, minute: 2,  second: 19, nanoOfSecond: 1573))
    #expect(time.plus(nano:   1) == java.time.LocalTime(hour: 14, minute: 2,  second: 18, nanoOfSecond: 1574))
  }

  @Test("with replaces each field independently")
  func testWith() {
    let time = java.time.LocalTime(hour: 14, minute: 2, second: 18, nanoOfSecond: 1573)

    #expect(time.with(hour:   23)          == java.time.LocalTime(hour: 23, minute: 2,  second: 18, nanoOfSecond: 1573))
    #expect(time.with(minute: 9)           == java.time.LocalTime(hour: 14, minute: 9,  second: 18, nanoOfSecond: 1573))
    #expect(time.with(second: 59)          == java.time.LocalTime(hour: 14, minute: 2,  second: 59, nanoOfSecond: 1573))
    #expect(time.with(nano: 123_157_234)   == java.time.LocalTime(hour: 14, minute: 2,  second: 18, nanoOfSecond: 123_157_234))
  }

  @Test("toDate round-trips through UTC calendar")
  func testToDate() {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(identifier: "UTC")!

    let localTime = java.time.LocalTime(hour: 14, minute: 2, second: 18, nanoOfSecond: 153_000_000)
    let date = localTime.toDate(clock: .UTC)

    #expect(calendar.component(.hour,   from: date) == 14)
    #expect(calendar.component(.minute, from: date) == 2)
    #expect(calendar.component(.second, from: date) == 18)
    #expect(153_500_000 >= calendar.component(.nanosecond, from: date))
    #expect(152_500_000 <= calendar.component(.nanosecond, from: date))
  }

  @Test("parse with default and custom formatters")
  func testParse() {
    let time1 = java.time.LocalTime.parse("05:53:12", clock: .current)!
    #expect(time1.hour   == 5)
    #expect(time1.minute == 53)
    #expect(time1.second == 12)

    let dateFormatter1 = DateFormatter()
    dateFormatter1.dateFormat = "HH:::mm:ss"
    let time2 = java.time.LocalTime.parse("05:::53:12", formatter: dateFormatter1, clock: .current)
    #expect(time1 == time2)

    let dateFormatter2 = DateFormatter()
    dateFormatter2.dateFormat = "HH::asdfs"
    let time3 = java.time.LocalTime.parse("05:::53:12", formatter: dateFormatter2, clock: .current)
    #expect(time3 == nil)
  }

  @Test("+ operator adds times and += mutates in place")
  func testAddTime() {
    var oldTime = java.time.LocalTime(hour: 11, minute: 51, second: 18, nanoOfSecond: 1573)
    let addTime = java.time.LocalTime(hour: 0,  minute: 8,  second: 0,  nanoOfSecond: 0)
    let newTime = oldTime + addTime
    #expect(newTime.hour   == 11)
    #expect(newTime.minute == 59)
    #expect(newTime.second == 18)
    #expect(newTime.nano   == 1573)

    oldTime += addTime
    #expect(oldTime == newTime)
  }

  @Test("- operator subtracts times and -= mutates in place")
  func testSubtractTime() {
    var oldTime = java.time.LocalTime(hour: 11, minute: 51, second: 18, nanoOfSecond: 1573)
    let addTime = java.time.LocalTime(hour: 0,  minute: 8,  second: 0,  nanoOfSecond: 0)
    let newTime = oldTime - addTime
    #expect(newTime.hour   == 11)
    #expect(newTime.minute == 43)
    #expect(newTime.second == 18)
    #expect(newTime.nano   == 1573)

    oldTime -= addTime
    #expect(oldTime == newTime)
  }

  @Test("hashValue matches manually combined hasher")
  func testHashable() {
    let time = java.time.LocalTime(hour: 11, minute: 51, second: 18, nanoOfSecond: 1573)

    var hasher = Hasher()
    hasher.combine(11)
    hasher.combine(51)
    hasher.combine(18)
    hasher.combine(1573)
    #expect(time.hashValue == hasher.finalize())
  }

  @Test("playgroundDescription returns formatted string")
  func testDescription() {
    let time = java.time.LocalTime(hour: 11, minute: 51, second: 18, nanoOfSecond: 1573)
    if let description = time.playgroundDescription as? String {
      #expect(description == "11:51:18.000001573")
    }
  }

  @Test("customMirror exposes hour, minute, second, nano")
  func testMirror() {
    let time = java.time.LocalTime(hour: 11, minute: 51, second: 18, nanoOfSecond: 1573)

    var checkList = ["hour": 11, "minute": 51, "second": 18, "nano": 1573]
    for child in time.customMirror.children {
      #expect(checkList[child.label!] == (child.value as? Int)!)
      checkList.removeValue(forKey: child.label!)
    }
    #expect(checkList.count == 0)
  }

  @Test("Codable round-trip preserves all fields")
  func testCodable() throws {
    let time1 = java.time.LocalTime(hour: 11, minute: 51, second: 18, nanoOfSecond: 1573)
    let jsonData = try JSONEncoder().encode(time1)
    let time2   = try JSONDecoder().decode(java.time.LocalTime.self, from: jsonData)
    #expect(time1 == time2)
  }
}
