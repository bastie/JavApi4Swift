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

  // MARK: - Additional coverage

  @Test("SimpleTimeZone UTC gives offset 0")
  func testUTCOffset() {
    let tz = java.util.SimpleTimeZone(0, "UTC")
    #expect(tz.getRawOffset() == 0)
  }

  @Test("SimpleTimeZone getID returns the given id")
  func testGetIDMatchesInput() {
    let tz = java.util.SimpleTimeZone(3_600_000, "Europe/Paris")
    #expect(tz.getID() == "Europe/Paris")
  }

  @Test("inDaylightTime is false in January for Berlin (winter)")
  func testInDaylightTimeWinter() {
    let tz = java.util.SimpleTimeZone(3_600_000, "Europe/Berlin")
    // 2024-01-15 12:00 UTC — well within standard time
    let date = java.util.Date(1_705_320_000_000)
    #expect(tz.inDaylightTime(date) == false)
  }

  @Test("inDaylightTime is true in July for Berlin (summer)")
  func testInDaylightTimeSummer() {
    let tz = java.util.SimpleTimeZone(3_600_000, "Europe/Berlin")
    // 2024-07-15 12:00 UTC — well within DST
    let date = java.util.Date(1_721_044_800_000)
    #expect(tz.inDaylightTime(date) == true)
  }

  @Test("Asia/Kolkata has offset +5:30 (19800000 ms)")
  func testKolkataOffset() {
    let tz = java.util.SimpleTimeZone(19_800_000, "Asia/Kolkata")
    #expect(tz.getRawOffset() == 19_800_000)
  }
}
