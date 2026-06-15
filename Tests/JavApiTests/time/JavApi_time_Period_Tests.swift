/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com> and contributors
 * SPDX-License-Identifier: MIT
 */
import Testing
import Foundation
@testable import JavApi

struct JavApi_time_Period_Tests {

  @Test("property setters normalize overflow and underflow across all fields")
  func testPropertySetter() {
    var zero = java.time.Period()
    zero.year   = 100
    zero.month  = 2
    zero.day    = -12
    zero.hour   = -12
    zero.minute = 2
    zero.second = -12
    zero.nano   = -125_221
    #expect(zero.year   == 100)
    #expect(zero.month  == 1)
    #expect(zero.day    == 15)
    #expect(zero.hour   == 12)
    #expect(zero.minute == 1)
    #expect(zero.second == 47)
    #expect(zero.nano   == 999_874_779)
  }

  @Test("comparable ordering across all field variations")
  func testComparable() {
    let min = java.time.Period()
    let max = java.time.Period(year: 1000)
    let old = java.time.Period(month: 2)
    let eq  = java.time.Period(year: 0, month: 2)

    #expect(min < old)
    #expect(max > java.time.Period(year: 1, month: 2))
    #expect(old <= eq)
    #expect(old >= eq)
    #expect(old == eq)

    for np in [
      java.time.Period(year: 1, month: 2),
      java.time.Period(month: 3),
      java.time.Period(month: 2, day: 1),
      java.time.Period(month: 2, hour: 1),
      java.time.Period(month: 2, minute: 1),
      java.time.Period(month: 2, second: 1),
      java.time.Period(month: 2, nano: 1)
    ] {
      #expect(np > old)
      #expect(old < np)
      #expect(np != old)
    }

    // #15 TestCode — year-dominant comparisons
    let t1 = java.time.Period(year: 1500, month: 6, day: 15, hour: 12, minute: 30, second: 30, nano: 500_000_000)
    for t in [
      java.time.Period(year: 1499, month: 6, day: 15, hour: 12, minute: 30, second: 30, nano: 500_000_001),
      java.time.Period(year: 1499, month: 6, day: 15, hour: 12, minute: 30, second: 31, nano: 500_000_000),
      java.time.Period(year: 1499, month: 6, day: 15, hour: 12, minute: 31, second: 30, nano: 500_000_000),
      java.time.Period(year: 1499, month: 6, day: 15, hour: 13, minute: 30, second: 30, nano: 500_000_000),
      java.time.Period(year: 1499, month: 6, day: 16, hour: 12, minute: 30, second: 30, nano: 500_000_000),
      java.time.Period(year: 1499, month: 7, day: 15, hour: 12, minute: 30, second: 30, nano: 500_000_000)
    ] { #expect(t1 > t) }

    for t in [
      java.time.Period(year: 1501, month: 6, day: 15, hour: 12, minute: 30, second: 30, nano: 499_999_999),
      java.time.Period(year: 1501, month: 6, day: 15, hour: 12, minute: 30, second: 29, nano: 500_000_000),
      java.time.Period(year: 1501, month: 6, day: 15, hour: 12, minute: 29, second: 30, nano: 500_000_000),
      java.time.Period(year: 1501, month: 6, day: 15, hour: 11, minute: 30, second: 30, nano: 500_000_000),
      java.time.Period(year: 1501, month: 6, day: 14, hour: 12, minute: 30, second: 30, nano: 500_000_000),
      java.time.Period(year: 1501, month: 5, day: 15, hour: 12, minute: 30, second: 30, nano: 500_000_000)
    ] { #expect(t1 < t) }
  }

  @Test("normalize carries 1_000_000_000 nano into a full year")
  func testNormalize() {
    let p = java.time.Period(year: 0, month: 11, day: 30, hour: 23, minute: 59, second: 59, nano: 1_000_000_000)
    #expect(p.year   == 1)
    #expect(p.month  == 0)
    #expect(p.day    == 0)
    #expect(p.hour   == 0)
    #expect(p.minute == 0)
    #expect(p.second == 0)
    #expect(p.nano   == 0)
  }

  @Test("+ operator on LocalDateTime/ZonedDateTime and Period += mutate in place")
  func testAddOperator() {
    var localDate = java.time.LocalDateTime( year: 1000, month: 1, day: 1, hour: 11, minute: 51, second: 18, nanoOfSecond: 1573)
    var zonedDate = java.time.ZonedDateTime(year: 1000, month: 1, day: 1, hour: 11, minute: 51, second: 18, nanoOfSecond: 1573)
    let add = java.time.Period(year: 0, month: 1, day: 3, hour: 0, minute: 8, second: 0, nano: 0)

    // LocalDateTime and ZonedDateTime have no common protocol, so check separately
    let ldResult = localDate + add
    #expect(ldResult.year == 1000); #expect(ldResult.month == 2); #expect(ldResult.day == 4)
    #expect(ldResult.hour == 11); #expect(ldResult.minute == 59); #expect(ldResult.second == 18); #expect(ldResult.nano == 1573)

    let zdResult = zonedDate + add
    #expect(zdResult.year == 1000); #expect(zdResult.month == 2); #expect(zdResult.day == 4)
    #expect(zdResult.hour == 11); #expect(zdResult.minute == 59); #expect(zdResult.second == 18); #expect(zdResult.nano == 1573)

    localDate += add; zonedDate += add
    #expect(localDate.month == 2); #expect(zonedDate.month == 2)

    var p1 = 1.year
    let p2 = 2.month
    #expect(p1 + p2 == java.time.Period(year: 1, month: 2))
    p1 += p2
    #expect(p1 == java.time.Period(year: 1, month: 2))
  }

  @Test("- operator on LocalDateTime/ZonedDateTime and Period -= mutate in place")
  func testSubtractOperator() {
    var localDate = java.time.LocalDateTime( year: 1000, month: 1, day: 7, hour: 11, minute: 51, second: 18, nanoOfSecond: 1573)
    var zonedDate = java.time.ZonedDateTime(year: 1000, month: 1, day: 7, hour: 11, minute: 51, second: 18, nanoOfSecond: 1573)
    let sub = java.time.Period(year: 0, month: 1, day: 3, hour: 0, minute: 8, second: 0, nano: 0)

    let ldResult = localDate - sub
    #expect(ldResult.year == 999); #expect(ldResult.month == 12); #expect(ldResult.day == 4)
    #expect(ldResult.hour == 11); #expect(ldResult.minute == 43); #expect(ldResult.second == 18); #expect(ldResult.nano == 1573)

    let zdResult = zonedDate - sub
    #expect(zdResult.year == 999); #expect(zdResult.month == 12); #expect(zdResult.day == 4)
    #expect(zdResult.hour == 11); #expect(zdResult.minute == 43); #expect(zdResult.second == 18); #expect(zdResult.nano == 1573)

    localDate -= sub; zonedDate -= sub
    #expect(localDate.month == 12); #expect(zonedDate.month == 12)

    var p1 = 1.year
    let p2 = 2.month
    #expect(p1 - p2 == java.time.Period(month: 10))
    p1 -= p2
    #expect(p1 == java.time.Period(month: 10))
  }

  @Test("hashValue matches manually combined hasher")
  func testHashable() {
    let p = java.time.Period(year: 1, month: 1, day: 3, hour: 1, minute: 8, second: 1, nano: 10)
    var hasher = Hasher()
    hasher.combine(1); hasher.combine(1); hasher.combine(3)
    hasher.combine(1); hasher.combine(8); hasher.combine(1); hasher.combine(10)
    #expect(p.hashValue == hasher.finalize())
  }

  @Test("description strings are formatted correctly, empty period gives empty string")
  func testDescription() {
    let p1 = java.time.Period(year: 1, month: 1, day: 3, hour: 1, minute: 8, second: 1, nano: 10)
    let p2 = java.time.Period()
    #expect(p1.description      == "0001Year 01Mon 03Day 01Hour 08Min 01.000000010Sec")
    #expect(p1.debugDescription == "0001Year 01Mon 03Day 01Hour 08Min 01.000000010Sec")
    if let pd = p1.playgroundDescription as? String {
      #expect(pd == "0001Year 01Mon 03Day 01Hour 08Min 01.000000010Sec")
    }
    #expect(p2.description == "")
    #expect(p2.debugDescription == "")
    if let pd = p2.playgroundDescription as? String { #expect(pd == "") }
  }

  @Test("customMirror exposes all seven fields")
  func testMirror() {
    let p = java.time.Period(year: 1, month: 1, day: 3, hour: 1, minute: 8, second: 1, nano: 10)
    var checkList = ["year": 1, "month": 1, "day": 3, "hour": 1, "minute": 8, "second": 1, "nano": 10]
    for child in p.customMirror.children {
      #expect(checkList[child.label!] == (child.value as? Int)!)
      checkList.removeValue(forKey: child.label!)
    }
    #expect(checkList.count == 0)
  }

  @Test("Codable round-trip preserves all fields")
  func testCodable() throws {
    let p1   = java.time.Period(year: 1, month: 1, day: 3, hour: 1, minute: 8, second: 1, nano: 10)
    let data = try JSONEncoder().encode(p1)
    let p2   = try JSONDecoder().decode(java.time.Period.self, from: data)
    #expect(p1 == p2)
  }
}
