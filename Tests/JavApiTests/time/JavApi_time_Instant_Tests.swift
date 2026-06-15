/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com> and contributors
 * SPDX-License-Identifier: MIT
 */
import Testing
import Foundation
@testable import JavApi

struct JavApi_time_Instant_Tests {

  @Test("property setters update second and nano independently")
  func testPropertySetter() {
    var zero = java.time.Instant.EPOCH
    zero.second = 100
    zero.nano   = 100
    #expect(zero.second == 100)
    #expect(zero.nano   == 100)
  }

  @Test("comparable ordering is consistent")
  func testComparable() {
    let min  = java.time.Instant.MIN
    let max  = java.time.Instant.MAX
    let old  = java.time.Instant(epochSecond: 100_000, nano: 999_999_000)
    let new_ = java.time.Instant(epochSecond: 100_000, nano: 999_999_001)
    let eq   = java.time.Instant(epochSecond: 100_000, nano: 999_999_000)

    #expect(min  < old)
    #expect(max  > new_)
    #expect(old <= eq)
    #expect(old >= eq)
    #expect(old  < new_)
    #expect(new_ > old)
    #expect(old == eq)

    // #15 TestCode
    let t1 = java.time.Instant(epochSecond: 100_000, nano: 500_000_000)
    let t2 = java.time.Instant(epochSecond:  99_999, nano: 500_000_001)
    let t3 = java.time.Instant(epochSecond: 100_001, nano: 499_999_999)
    #expect(t1 > t2)
    #expect(t1 < t3)
  }

  @Test("negative nano is normalized by borrowing from seconds")
  func testNormalize() {
    let instant = java.time.Instant(epochSecond: -100, nano: -100)
    #expect(instant.second == -101)
    #expect(instant.nano   == 999_999_900)
  }

  @Test("EPOCH is second=0, nano=0")
  func testEpoch() {
    let epoch = java.time.Instant.EPOCH
    #expect(epoch.second == 0)
    #expect(epoch.nano   == 0)
  }

  @Test("MIN has correct boundary values")
  func testMin() {
    let min = java.time.Instant.MIN
    #expect(min.second == -31_557_014_167_219_200)
    #expect(min.nano   == 0)
  }

  @Test("MAX has correct boundary values")
  func testMax() {
    let max = java.time.Instant.MAX
    #expect(max.second == 31_556_889_864_403_199)
    #expect(max.nano   == 999_999_999)
  }

  @Test("epochMilli conversion is bidirectional")
  func testEpochMilli() {
    let i1 = java.time.Instant(epochSecond: 100_000, nano: 999_999_999)
    #expect(i1.epochMilli == 100_000_999)

    let i2 = java.time.Instant(epochMilli: 100_000_999)
    #expect(i2.second == 100_000)
    #expect(i2.nano   == 999_000_000)
  }

  @Test("parse produces correct second and nano from ISO string")
  func testParse() {
    let i1 = java.time.Instant.parse("1970-1-1T0:1:5.123Z")!
    #expect(i1.second == 65)
    #expect(123_500_000 > i1.nano)
    #expect(122_500_000 <= i1.nano)

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'SSS'Z'"
    let i2 = java.time.Instant.parse("1970-1-1T0:1:5.123Z",
                                     formatter: formatter,
                                     clock: java.time.Clock.UTC)
    #expect(i2 == nil)
  }

  @Test("toZone converts epochSecond 65 to 1970-01-01T00:01:05 UTC")
  func testToZone() {
    let instant = java.time.Instant(epochSecond: 65, nano: 123_000_000)
    let zone = instant.toZone()
    #expect(zone.year   == 1970)
    #expect(zone.month  == 1)
    #expect(zone.day    == 1)
    #expect(zone.hour   == 0)
    #expect(zone.minute == 1)
    #expect(zone.second == 5)
    #expect(zone.nano   == 123_000_000)
  }

  @Test("plus methods add to second and nano correctly")
  func testPlus() {
    let instant = java.time.Instant(epochSecond: 100_000, nano: 999_000_000)
    #expect(instant.plusSeconds(1)                               == java.time.Instant(epochSecond: 100_001, nano: 999_000_000))
    #expect(instant.plus(nano:  1)                               == java.time.Instant(epochSecond: 100_000, nano: 999_000_001))
    #expect(instant.plus(milli: 1)                               == java.time.Instant(epochSecond: 100_001, nano: 000_000_000))
    #expect(instant.plus(component: .second,     newValue: 1)    == java.time.Instant(epochSecond: 100_001, nano: 999_000_000))
    #expect(instant.plus(component: .nanosecond, newValue: 1)    == java.time.Instant(epochSecond: 100_000, nano: 999_000_001))
    #expect(instant.plus(second: 1, nano: 1)                     == java.time.Instant(epochSecond: 100_001, nano: 999_000_001))
  }

  @Test("minus methods subtract from second and nano correctly")
  func testMinus() {
    let instant = java.time.Instant(epochSecond: 100_000, nano: 999_000_000)
    #expect(instant.minus(second: 1)                             == java.time.Instant(epochSecond:  99_999, nano: 999_000_000))
    #expect(instant.minus(nano:   1)                             == java.time.Instant(epochSecond: 100_000, nano: 998_999_999))
    #expect(instant.minus(milli:  1)                             == java.time.Instant(epochSecond: 100_000, nano: 998_000_000))
    #expect(instant.minus(component: .second,     newValue: 1)   == java.time.Instant(epochSecond:  99_999, nano: 999_000_000))
    #expect(instant.minus(component: .nanosecond, newValue: 1)   == java.time.Instant(epochSecond: 100_000, nano: 998_999_999))
    #expect(instant.minus(second: 1, nano: 1)                    == java.time.Instant(epochSecond:  99_999, nano: 998_999_999))
  }

  @Test("until computes differences in all supported components")
  func testUntil() {
    let i1   = java.time.Instant(epochSecond: 100_000, nano: 999_000_000)
    let zero = java.time.Instant(epochSecond: 0,       nano: 0)

    #expect(zero.until(endInstant: i1, component: .nanosecond) == 100_000_999_000_000)
    #expect(zero.until(endInstant: i1, component: .second)     == 100_000)
    #expect(zero.until(endInstant: i1, component: .minute)     == 1_666)
    #expect(zero.until(endInstant: i1, component: .hour)       == 27)
    #expect(zero.until(endInstant: i1, component: .day)        == 1)

    let i2 = java.time.Instant(epochSecond: 100_001, nano: 998_000_000)
    #expect(i1.until(endInstant: i2, component: .nanosecond) == 999_000_000)
    #expect(i1.until(endInstant: i2, component: .second)     == 0)

    let i3 = java.time.Instant(epochSecond: 99_999, nano: 999_900_000)
    #expect(i1.until(endInstant: i3, component: .nanosecond) == -999_100_000)
    #expect(i1.until(endInstant: i3, component: .second)     == 0)
  }

  @Test("with replaces second or nano field")
  func testWith() {
    let instant = java.time.Instant(epochSecond: 100_000, nano: 999_000_000)
    #expect(instant.with(component: .second,     newValue: 500) == java.time.Instant(epochSecond: 500, nano: 999_000_000))
    #expect(instant.with(component: .nanosecond, newValue: 500) == java.time.Instant(epochSecond: 100_000, nano: 500))
  }

  @Test("+ operator adds instants and += mutates in place")
  func testAddDate() {
    var old = java.time.Instant(epochSecond: 306, nano: 124_233_521)
    let add = java.time.Instant(epochSecond: 10,  nano: 100)
    let new_ = old + add
    #expect(new_.second == 316)
    #expect(new_.nano   == 124_233_621)
    old += add
    #expect(old == new_)
  }

  @Test("- operator subtracts instants and -= mutates in place")
  func testSubtractDate() {
    var old = java.time.Instant(epochSecond: 306, nano: 124_233_521)
    let sub = java.time.Instant(epochSecond: 10,  nano: 100)
    let new_ = old - sub
    #expect(new_.second == 296)
    #expect(new_.nano   == 124_233_421)
    old -= sub
    #expect(old == new_)
  }

  @Test("hashValue matches manually combined hasher")
  func testHashable() {
    let instant = java.time.Instant(epochSecond: 100_000, nano: 999_000_000)
    var hasher = Hasher()
    hasher.combine(Int64(100_000))
    hasher.combine(999_000_000)
    #expect(instant.hashValue == hasher.finalize())
  }

  @Test("description strings are formatted correctly")
  func testDescription() {
    let instant = java.time.Instant(epochSecond: 100_000, nano: 999_000_000)
    #expect(instant.description      == "100000.999000000")
    #expect(instant.debugDescription == "100000.999000000")
    if let pd = instant.playgroundDescription as? String {
      #expect(pd == "100000.999000000")
    }
  }

  @Test("customMirror exposes second and nano children")
  func testMirror() {
    let instant = java.time.Instant(epochSecond: 100_000, nano: 999_000_000)
    var checkList: [String: Any] = ["second": Int64(100_000), "nano": 999_000_000]
    for child in instant.customMirror.children {
      if child.label! == "second" {
        #expect(checkList[child.label!] as! Int64 == child.value as! Int64)
      } else {
        #expect(checkList[child.label!] as! Int == child.value as! Int)
      }
      checkList.removeValue(forKey: child.label!)
    }
    #expect(checkList.count == 0)
  }

  @Test("Codable round-trip preserves second and nano")
  func testCodable() throws {
    let i1 = java.time.Instant(epochSecond: 100_000, nano: 999_000_000)
    let data = try JSONEncoder().encode(i1)
    let i2   = try JSONDecoder().decode(java.time.Instant.self, from: data)
    #expect(i1 == i2)
  }
}
