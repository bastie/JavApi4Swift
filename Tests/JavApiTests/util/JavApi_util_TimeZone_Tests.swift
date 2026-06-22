/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com> and contributors
 * SPDX-License-Identifier: Apache-2.0
 */
import Testing
@testable import JavApi

// Regression tests for TimeZone.getDefault() and getTimeZone(String),
// which were missing (commented out) before June 2026.

struct JavApi_util_TimeZone_Tests {

  @available(*, deprecated)
  @Test("SimpleTimeZone.getAvailableIDs returns a non-empty list")
  func testGetAvailableIDsIsNotEmpty() {
    #expect(SimpleTimeZone.getAvailableIDs().count > 0)
  }

  // MARK: - getDefault() — was missing before fix

  @available(*, deprecated)
  @Test("TimeZone.getDefault() returns a TimeZone with a valid ID")
  func testGetDefaultReturnsValidID() {
    // getDefault() returns a non-optional — we verify it is usable by checking the ID.
    let tz = SimpleTimeZone.getDefault()
    #expect(tz.getID().isEmpty == false)
  }

  @available(*, deprecated)
  @Test("TimeZone.getDefault() returns a TimeZone with a non-empty ID")
  func testGetDefaultHasID() {
    let tz = SimpleTimeZone.getDefault()
    #expect(tz.getID().isEmpty == false)
  }

  @available(*, deprecated)
  @Test("TimeZone.getDefault() getRawOffset is a multiple of 60000 ms")
  func testGetDefaultRawOffsetMultipleOfMinute() {
    let tz = SimpleTimeZone.getDefault()
    // All real-world UTC offsets are multiples of 15 minutes (= 900000 ms);
    // at a minimum every valid offset is a multiple of 60000 ms.
    #expect(tz.getRawOffset() % 60_000 == 0)
  }

  // MARK: - getTimeZone(String) — was missing before fix

  @available(*, deprecated)
  @Test("TimeZone.getTimeZone(known IANA id) returns correct zone")
  func testGetTimeZoneKnownID() {
    let tz = SimpleTimeZone.getTimeZone("Europe/Berlin")
    #expect(tz.getID() == "Europe/Berlin")
  }

  @available(*, deprecated)
  @Test("TimeZone.getTimeZone(UTC) preserves the ID string (Java contract)")
  func testGetTimeZoneUTCPreservesID() {
    // Java contract: getTimeZone("UTC").getID() must equal "UTC", not "GMT",
    // even though Foundation maps the UTC abbreviation to identifier "GMT" internally.
    let tz = SimpleTimeZone.getTimeZone("UTC")
    #expect(tz.getID() == "UTC")
    #expect(tz.getRawOffset() == 0)
  }

  @available(*, deprecated)
  @Test("TimeZone.getTimeZone(unknown id) falls back without crashing")
  func testGetTimeZoneUnknownFallback() {
    // Unknown zone must not crash; falls back to GMT (offset 0)
    let tz = SimpleTimeZone.getTimeZone("Invalid/Zone")
    #expect(tz.getRawOffset() == 0)
  }

  @available(*, deprecated)
  @Test("TimeZone.getAvailableIDs(rawOffset) filters by offset")
  func testGetAvailableIDsForOffset() {
    // UTC offset 0 should include at least "GMT" or "UTC"
    let ids = SimpleTimeZone.getAvailableIDs(0)
    #expect(ids.count > 0)
    // Every returned ID must resolve to offset 0
    for id in ids {
      let tz = SimpleTimeZone.getTimeZone(id)
      #expect(tz.getRawOffset() == 0)
    }
  }
}
