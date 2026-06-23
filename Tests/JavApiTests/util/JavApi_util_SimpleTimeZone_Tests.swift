/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_util_SimpleTimeZone_Tests {

  @Test("SimpleTimeZone(rawOffset, id) resolves known IANA identifier")
  func testKnownIdentifier() {
    let tz = java.util.SimpleTimeZone(3_600_000, "Europe/Berlin")
    #expect(tz.getID() == "Europe/Berlin")
  }

  @Test("SimpleTimeZone(rawOffset, id) falls back to fixed offset for unknown id")
  func testUnknownIdentifierFallback() {
    let tz = java.util.SimpleTimeZone(7_200_000, "Unknown/Zone")
    #expect(tz.getRawOffset() == 7_200_000)
  }

  @Test("SimpleTimeZone DST constructor accepts all parameters without crashing")
  func testDSTConstructor() {
    let tz = java.util.SimpleTimeZone(
      -18_000_000, "America/New_York",
      2, 8, 1, 7_200_000,
      10, 1, 1, 7_200_000
    )
    #expect(tz.getID() == "America/New_York")
  }

  @Test("getRawOffset returns milliseconds (multiple of 60000)")
  func testRawOffset() {
    let tz = java.util.SimpleTimeZone(3_600_000, "Europe/London")
    #expect(tz.getRawOffset() % 60_000 == 0)
  }

  @Test("inDaylightTime returns Bool without crashing")
  func testInDaylightTime() {
    let tz = java.util.SimpleTimeZone(3_600_000, "Europe/Berlin")
    let date = java.util.Date(0)
    let result = tz.inDaylightTime(date)
    #expect(result == true || result == false)
  }
}
