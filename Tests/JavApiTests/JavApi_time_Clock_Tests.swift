/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com> and contributors
 * SPDX-License-Identifier: MIT
 */
import Testing
import Foundation
@testable import JavApi

struct JavApi_time_Clock_Tests {

  @Test("comparable ordering: America/St_Lucia < UTC")
  func testComparable() {
    let old   = java.time.Clock(identifier: .americaStLucia)
    let new_  = java.time.Clock.UTC
    let equal = java.time.Clock(identifier: .americaStLucia)
    #expect(old  < new_)
    #expect(new_ > old)
    #expect(old <= equal)
    #expect(old >= equal)
    #expect(old == equal)
  }

  @Test("UTC clock has offsetSecond == 0")
  func testUTC() {
    #expect(java.time.Clock.UTC.offsetSecond == 0)
  }

  @Test("GMT clock has offsetSecond == 0")
  func testGMT() {
    #expect(java.time.Clock.GMT.offsetSecond == 0)
  }

  @Test("current clock matches system timezone offset")
  func testCurrent() {
    #expect(java.time.Clock.current.offsetSecond == TimeZone.current.secondsFromGMT())
  }

  @Test("autoupdatingCurrent and current both match system timezone offset")
  func testAutoUpdatingCurrent() {
    let tz = TimeZone.current.secondsFromGMT()
    #expect(java.time.Clock.autoupdatingCurrent.offsetSecond == tz)
    #expect(java.time.Clock.current.offsetSecond            == tz)
  }

  @Test("identifier-based constructors produce correct offsets")
  func testIdentifier() {
    let tz = TimeZone.current

    let clock1 = java.time.Clock(identifier: .americaStLucia)
    #expect(clock1.offsetSecond == TimeZone(identifier: "America/St_Lucia")!.secondsFromGMT())

    let clock2 = java.time.Clock(identifier: "Europe/Vilnius")!
    #expect(clock2.offsetSecond == TimeZone(identifier: "Europe/Vilnius")!.secondsFromGMT())

    #expect(java.time.Clock(identifier: "TEST IDENTIFIER") == nil)

    #expect(java.time.Clock(identifier: .current).offsetSecond            == tz.secondsFromGMT())
    #expect(java.time.Clock(identifier: .autoUpdatingCurrent).offsetSecond == tz.secondsFromGMT())
  }

  @Test("offsetSecond constructor stores value directly")
  func testOffsetSecond() {
    #expect(java.time.Clock(offsetSecond: 10_800).offsetSecond == 10_800)
  }

  @Test("offsetMinute constructor converts to seconds")
  func testOffsetMinute() {
    #expect(java.time.Clock(offsetMinute: 180).offsetSecond == 10_800)
  }

  @Test("offsetHour constructor converts to seconds")
  func testOffsetHour() {
    #expect(java.time.Clock(offsetHour: 3).offsetSecond == 10_800)
  }

  @Test("toTime returns correct hour/minute/second/nano for America/St_Lucia (-4h)")
  func testToTime() {
    let time = java.time.Clock(identifier: .americaStLucia).toTime()
    #expect(time.hour   == -4)
    #expect(time.minute == 0)
    #expect(time.second == 0)
    #expect(time.nano   == 0)
  }

  @Test("toTimeZone preserves offset seconds")
  func testToTimeZone() {
    #expect(java.time.Clock(offsetSecond: 10_860).toTimeZone().secondsFromGMT() == 10_860)
  }

  @Test("offset applies duration to base clock")
  func testOffset() {
    let clock = java.time.Clock.offset(baseClock: java.time.Clock(identifier: .americaStLucia), offsetDuration: 100)
    #expect(clock.offsetSecond == -14_300)
  }

  @Test("hashValue matches Int(offsetSecond).hashValue")
  func testHashable() {
    let clock = java.time.Clock(offsetSecond: 10_860)
    #expect(clock.hashValue == Int(10_860).hashValue)
  }

  @Test("description strings are formatted correctly")
  func testDescription() {
    let clock = java.time.Clock(offsetSecond: 10_860)
    #expect(clock.description      == "03:01:00.000000000")
    #expect(clock.debugDescription == "03:01:00.000000000")
    if let pd = clock.playgroundDescription as? String {
      #expect(pd == "03:01:00.000000000")
    }
  }

  @Test("customMirror exposes offsetSecond")
  func testMirror() {
    let clock = java.time.Clock(offsetSecond: 10_860)
    var checkList = ["offsetSecond": 10_860]
    for child in clock.customMirror.children {
      #expect(checkList[child.label!]! == (child.value as? Int)!)
      checkList.removeValue(forKey: child.label!)
    }
    #expect(checkList.count == 0)
  }

  @Test("Codable round-trip preserves offsetSecond")
  func testCodable() throws {
    let clock1 = java.time.Clock(offsetSecond: 10_860)
    let data   = try JSONEncoder().encode(clock1)
    let clock2 = try JSONDecoder().decode(java.time.Clock.self, from: data)
    #expect(clock1 == clock2)
  }
}
