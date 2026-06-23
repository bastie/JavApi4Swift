/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

/// Tests for `DecimalFormat` Java 1.5/1.6 additions:
/// `isParseBigDecimal`/`setParseBigDecimal` (1.5) and
/// `getRoundingMode`/`setRoundingMode` (1.6).
///
/// `.serialized` is required because formatting uses `java.util.Locale.getDefault()`
/// internally and `Locale.setDefault()` is not thread-safe.
@Suite("DecimalFormat Java 1.5/1.6 additions", .serialized)
struct JavApi_text_DecimalFormat_Java15_Tests {

  // ---------------------------------------------------------------------------
  // MARK: isParseBigDecimal (Java 1.5)
  // ---------------------------------------------------------------------------

  @Test("isParseBigDecimal default is false")
  func testParseBigDecimalDefault() {
    java.util.Locale.setDefault(java.util.Locale("en", "US"))
    let df = java.text.DecimalFormat("#.##")
    #expect(df.isParseBigDecimal() == false)
  }

  @Test("setParseBigDecimal stores and clears flag")
  func testSetParseBigDecimal() {
    java.util.Locale.setDefault(java.util.Locale("en", "US"))
    let df = java.text.DecimalFormat("#.##")
    df.setParseBigDecimal(true)
    #expect(df.isParseBigDecimal() == true)
    df.setParseBigDecimal(false)
    #expect(df.isParseBigDecimal() == false)
  }

  // ---------------------------------------------------------------------------
  // MARK: getRoundingMode / setRoundingMode (Java 1.6)
  // ---------------------------------------------------------------------------

  @Test("getRoundingMode default is HALF_UP")
  func testRoundingModeDefault() {
    java.util.Locale.setDefault(java.util.Locale("en", "US"))
    let df = java.text.DecimalFormat("#.#")
    #expect(df.getRoundingMode() == java.math.RoundingMode.HALF_UP)
  }

  @Test("setRoundingMode HALF_UP — getter reflects new mode")
  func testRoundingHalfUpGetter() {
    java.util.Locale.setDefault(java.util.Locale("en", "US"))
    let df = java.text.DecimalFormat("#.#")
    df.setRoundingMode(.HALF_UP)
    #expect(df.getRoundingMode() == java.math.RoundingMode.HALF_UP)
  }

  @Test("setRoundingMode FLOOR rounds 2.29 to 2.2")
  func testRoundingFloor() {
    java.util.Locale.setDefault(java.util.Locale("en", "US"))
    let df = java.text.DecimalFormat("#.#")
    df.setRoundingMode(.FLOOR)
    #expect(df.getRoundingMode() == java.math.RoundingMode.FLOOR)
    #expect(df.format(2.29) == "2.2")
  }

  @Test("setRoundingMode CEILING rounds 2.21 to 2.3")
  func testRoundingCeiling() {
    java.util.Locale.setDefault(java.util.Locale("en", "US"))
    let df = java.text.DecimalFormat("#.#")
    df.setRoundingMode(.CEILING)
    #expect(df.getRoundingMode() == java.math.RoundingMode.CEILING)
    #expect(df.format(2.21) == "2.3")
  }

  @Test("setRoundingMode HALF_EVEN (banker's rounding) rounds 2.35 to 2.4")
  func testRoundingHalfEven() {
    java.util.Locale.setDefault(java.util.Locale("en", "US"))
    let df = java.text.DecimalFormat("#.#")
    df.setRoundingMode(.HALF_EVEN)
    #expect(df.getRoundingMode() == java.math.RoundingMode.HALF_EVEN)
    // 2.35 → nearest even → 2.4 (digit 4 is even)
    #expect(df.format(2.35) == "2.4")
  }

  @Test("setRoundingMode DOWN rounds 2.29 to 2.2")
  func testRoundingDown() {
    java.util.Locale.setDefault(java.util.Locale("en", "US"))
    let df = java.text.DecimalFormat("#.#")
    df.setRoundingMode(.DOWN)
    #expect(df.getRoundingMode() == java.math.RoundingMode.DOWN)
    #expect(df.format(2.29) == "2.2")
  }
}
