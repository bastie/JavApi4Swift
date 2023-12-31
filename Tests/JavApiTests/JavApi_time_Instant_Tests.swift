/*
 * SPDX-License-Identifier: MIT
 */
import XCTest
import Foundation
@testable import JavApi

class JavApi_time_Instant_Tests : XCTestCase {
  
  func testPropertySetter() {
    var zero = java.time.Instant.EPOCH
    zero.second = 100
    zero.nano = 100
    
    XCTAssertEqual(zero.second, 100)
    XCTAssertEqual(zero.nano, 100)
  }
  func testComparable() {
    let min = java.time.Instant.MIN
    let max = java.time.Instant.MAX
    
    let oldDate = java.time.Instant(epochSecond: 100_000, nano: 999_999_000)
    let newDate = java.time.Instant(epochSecond: 100_000, nano: 999_999_001)
    let equalDate = java.time.Instant(epochSecond: 100_000, nano: 999_999_000)
    
    XCTAssertLessThan(min, oldDate)
    XCTAssertGreaterThan(max, newDate)
    XCTAssertLessThanOrEqual(oldDate, equalDate)
    XCTAssertGreaterThanOrEqual(oldDate, equalDate)
    XCTAssertLessThan(oldDate, newDate)
    XCTAssertGreaterThan(newDate, oldDate)
    XCTAssertEqual(oldDate, equalDate)
    XCTAssertLessThan(oldDate, newDate)
    
    /// #15 TestCode
    let test1 = java.time.Instant(epochSecond: 100_000, nano: 500_000_000)
    let test2 = java.time.Instant(epochSecond: 99_999, nano: 500_000_001)
    XCTAssertGreaterThan(test1, test2)
    
    let test3 = java.time.Instant(epochSecond: 100_001, nano: 499_999_999)
    XCTAssertLessThan(test1, test3)
  }
  func testNormalize() {
    let instant = java.time.Instant(epochSecond: -100, nano: -100)
    XCTAssertEqual(instant.second, -101)
    XCTAssertEqual(instant.nano, 999_999_900)
  }
  func testEpoch() {
    let instant = java.time.Instant.EPOCH
    XCTAssertEqual(instant.second, 0)
    XCTAssertEqual(instant.nano, 0)
  }
  func testMin() {
    let min = java.time.Instant.MIN
    XCTAssertEqual(min.second, -31_557_014_167_219_200)
    XCTAssertEqual(min.nano, 0)
  }
  func testMax() {
    let max = java.time.Instant.MAX
    XCTAssertEqual(max.second, 31_556_889_864_403_199)
    XCTAssertEqual(max.nano, 999_999_999)
  }
  func testEpochMilli() {
    let instant1 = java.time.Instant(epochSecond: 100_000, nano: 999_999_999)
    XCTAssertEqual(instant1.epochMilli, 100_000_999)
    
    let instant2 = java.time.Instant(epochMilli: 100_000_999)
    XCTAssertEqual(instant2.second, 100_000)
    XCTAssertEqual(instant2.nano, 999_000_000)
  }
  func testParse() {
    let instant1 = java.time.Instant.parse("1970-1-1T0:1:5.123Z")!
    XCTAssertEqual(instant1.second, 65)
    XCTAssertGreaterThan(123_500_000, instant1.nano)
    XCTAssertLessThanOrEqual(122_500_000, instant1.nano)
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'SSS'Z'"
    let instant2 = java.time.Instant.parse("1970-1-1T0:1:5.123Z", formatter: formatter, clock: java.time.Clock.UTC)
    XCTAssertEqual(instant2, nil)
  }
  func testToZone() {
    let instant = java.time.Instant(epochSecond: 65, nano: 123_000_000)
    let zone = instant.toZone()
    
    XCTAssertEqual(zone.year, 1970)
    XCTAssertEqual(zone.month, 1)
    XCTAssertEqual(zone.day, 1)
    XCTAssertEqual(zone.hour, 0)
    XCTAssertEqual(zone.minute, 1)
    XCTAssertEqual(zone.second, 5)
    XCTAssertEqual(zone.nano, 123_000_000)
  }
  func testPlus() {
    let instant = java.time.Instant(epochSecond: 100_000, nano: 999_000_000)
    
    let expected1 = java.time.Instant(epochSecond: 100_001, nano: 999_000_000)
    let expected2 = java.time.Instant(epochSecond: 100_000, nano: 999_000_001)
    let expected3 = java.time.Instant(epochSecond: 100_001, nano: 000_000_000)
    let expected4 = java.time.Instant(epochSecond: 100_001, nano: 999_000_001)
    
    
    let actually = instant.plusSeconds(1)
    XCTAssertEqual(actually, expected1)
    XCTAssertEqual(instant.plus(nano: 1), expected2)
    XCTAssertEqual(instant.plus(milli: 1), expected3)
    XCTAssertEqual(instant.plus(component: .second, newValue: 1), expected1)
    XCTAssertEqual(instant.plus(component: .nanosecond, newValue: 1), expected2)
    XCTAssertEqual(instant.plus(second: 1, nano: 1), expected4)
  }
  func testMinus() {
    let instant = java.time.Instant(epochSecond: 100_000, nano: 999_000_000)
    
    let compare1 = java.time.Instant(epochSecond: 99_999, nano: 999_000_000)
    let compare2 = java.time.Instant(epochSecond: 100_000, nano: 998_999_999)
    let compare3 = java.time.Instant(epochSecond: 100_000, nano: 998_000_000)
    let compare4 = java.time.Instant(epochSecond: 99_999, nano: 998_999_999)
    
    XCTAssertEqual(instant.minus(second: 1), compare1)
    XCTAssertEqual(instant.minus(nano: 1), compare2)
    XCTAssertEqual(instant.minus(milli: 1), compare3)
    XCTAssertEqual(instant.minus(component: .second, newValue: 1), compare1)
    XCTAssertEqual(instant.minus(component: .nanosecond, newValue: 1), compare2)
    XCTAssertEqual(instant.minus(second: 1, nano: 1), compare4)
  }
  func testUntil() {
    let instant1 = java.time.Instant(epochSecond: 100_000, nano: 999_000_000)
    let zero = java.time.Instant(epochSecond: 0, nano: 0)
    
    XCTAssertEqual(zero.until(endInstant: instant1, component: .nanosecond), 100_000_999_000_000)
    XCTAssertEqual(zero.until(endInstant: instant1, component: .second), 100_000)
    XCTAssertEqual(zero.until(endInstant: instant1, component: .minute), 1666)
    XCTAssertEqual(zero.until(endInstant: instant1, component: .hour), 27)
    XCTAssertEqual(zero.until(endInstant: instant1, component: .day), 1)
    
    let instant2 = java.time.Instant(epochSecond: 100_001, nano: 998_000_000)
    XCTAssertEqual(instant1.until(endInstant: instant2, component: .nanosecond), 999_000_000)
    XCTAssertEqual(instant1.until(endInstant: instant2, component: .second), 0)
    XCTAssertEqual(instant1.until(endInstant: instant2, component: .minute), 0)
    XCTAssertEqual(instant1.until(endInstant: instant2, component: .hour), 0)
    XCTAssertEqual(instant1.until(endInstant: instant2, component: .day), 0)
    
    let instant3 = java.time.Instant(epochSecond: 99_999, nano: 999_900_000)
    XCTAssertEqual(instant1.until(endInstant: instant3, component: .nanosecond), -999_100_000)
    XCTAssertEqual(instant1.until(endInstant: instant3, component: .second), 0)
    XCTAssertEqual(instant1.until(endInstant: instant3, component: .minute), 0)
    XCTAssertEqual(instant1.until(endInstant: instant3, component: .hour), 0)
    XCTAssertEqual(instant1.until(endInstant: instant3, component: .day), 0)
  }
  func testWith() {
    let instant = java.time.Instant(epochSecond: 100_000, nano: 999_000_000)
    
    let compare1 = java.time.Instant(epochSecond: 500, nano: 999_000_000)
    let compare2 = java.time.Instant(epochSecond: 100_000, nano: 500)
    
    XCTAssertEqual(instant.with(component: .second, newValue: 500), compare1)
    XCTAssertEqual(instant.with(component: .nanosecond, newValue: 500), compare2)
  }
  func testAddDate() {
    var oldInstant = java.time.Instant(epochSecond: 306, nano: 124_233_521)
    let addInstant = java.time.Instant(epochSecond: 10, nano: 100)
    
    let newInstant = oldInstant + addInstant
    XCTAssertEqual(newInstant.second, 316)
    XCTAssertEqual(newInstant.nano, 124_233_621)
    
    oldInstant += addInstant
    XCTAssertEqual(oldInstant.second, 316)
    XCTAssertEqual(oldInstant.nano, 124_233_621)
  }
  func testSubtractDate() {
    var oldInstant = java.time.Instant(epochSecond: 306, nano: 124_233_521)
    let addInstant = java.time.Instant(epochSecond: 10, nano: 100)
    
    let newInstant = oldInstant - addInstant
    XCTAssertEqual(newInstant.second, 296)
    XCTAssertEqual(newInstant.nano, 124_233_421)
    
    oldInstant -= addInstant
    XCTAssertEqual(oldInstant.second, 296)
    XCTAssertEqual(oldInstant.nano, 124_233_421)
  }
  func testHashable() {
    let instant = java.time.Instant(epochSecond: 100_000, nano: 999_000_000)
    
    var hasher = Hasher()
    hasher.combine(100_000)
    hasher.combine(999_000_000)
    XCTAssertEqual(
      instant.hashValue, hasher.finalize()
    )
  }
  func testDescription() {
    let instant = java.time.Instant(epochSecond: 100_000, nano: 999_000_000)
    XCTAssertEqual(instant.description, "100000.999000000")
    XCTAssertEqual(instant.debugDescription, "100000.999000000")
    if let description = instant.playgroundDescription as? String {
      XCTAssertEqual(description, "100000.999000000")
    }
  }
  func testMirror() {
    let instant = java.time.Instant(epochSecond: 100_000, nano: 999_000_000)
    
    var checkList: [String: Any] = [
      "second": Int64(100_000),
      "nano": 999_000_000
    ]
    for child in instant.customMirror.children {
      if child.label! == "second" {
        XCTAssertEqual(checkList[child.label!] as! Int64, child.value as! Int64)
      } else {
        XCTAssertEqual(checkList[child.label!] as! Int, child.value as! Int)
      }
      checkList.removeValue(forKey: child.label!)
    }
    XCTAssertEqual(checkList.count, 0)
  }
  func testCodable() {
    let instant1 = java.time.Instant(epochSecond: 100_000, nano: 999_000_000)
    let jsonString = String(data: try! JSONEncoder().encode(instant1), encoding: .utf8)!
    
    let jsonData = jsonString.data(using: .utf8)!
    let instant2 = try! JSONDecoder().decode(java.time.Instant.self, from: jsonData)
    
    XCTAssertEqual(instant1, instant2)
  }
}
