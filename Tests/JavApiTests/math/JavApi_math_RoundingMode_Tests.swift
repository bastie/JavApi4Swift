/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_math_RoundingMode_Tests {

  // MARK: - Raw values match Java ordinals

  @Test("RoundingMode raw values match Java ordinals")
  func testRawValues() {
    #expect(java.math.RoundingMode.UP.rawValue          == 0)
    #expect(java.math.RoundingMode.DOWN.rawValue        == 1)
    #expect(java.math.RoundingMode.CEILING.rawValue     == 2)
    #expect(java.math.RoundingMode.FLOOR.rawValue       == 3)
    #expect(java.math.RoundingMode.HALF_UP.rawValue     == 4)
    #expect(java.math.RoundingMode.HALF_DOWN.rawValue   == 5)
    #expect(java.math.RoundingMode.HALF_EVEN.rawValue   == 6)
    #expect(java.math.RoundingMode.UNNECESSARY.rawValue == 7)
  }

  // MARK: - description

  @Test("RoundingMode.description returns Java-style name")
  func testDescription() {
    #expect(java.math.RoundingMode.UP.description          == "UP")
    #expect(java.math.RoundingMode.DOWN.description        == "DOWN")
    #expect(java.math.RoundingMode.CEILING.description     == "CEILING")
    #expect(java.math.RoundingMode.FLOOR.description       == "FLOOR")
    #expect(java.math.RoundingMode.HALF_UP.description     == "HALF_UP")
    #expect(java.math.RoundingMode.HALF_DOWN.description   == "HALF_DOWN")
    #expect(java.math.RoundingMode.HALF_EVEN.description   == "HALF_EVEN")
    #expect(java.math.RoundingMode.UNNECESSARY.description == "UNNECESSARY")
  }

  // MARK: - allCases

  @Test("RoundingMode.allCases contains exactly 8 values")
  func testAllCases() {
    #expect(java.math.RoundingMode.allCases.count == 8)
  }

  @Test("RoundingMode can be recovered from rawValue")
  func testRoundTripRawValue() {
    for mode in java.math.RoundingMode.allCases {
      let recovered = java.math.RoundingMode(rawValue: mode.rawValue)
      #expect(recovered == mode)
    }
  }

  // MARK: - nsRoundingMode (sanity: property exists and returns without crash)

  @Test("nsRoundingMode is defined for all cases")
  func testNsRoundingMode() {
    for mode in java.math.RoundingMode.allCases {
      // Just accessing the property must not crash
      _ = mode.nsRoundingMode
    }
  }
}


struct JavApi_math_MathContext_Tests {

  // MARK: - Predefined contexts

  @Test("UNLIMITED has precision 0 and HALF_UP")
  func testUnlimited() {
    let ctx = java.math.MathContext.UNLIMITED
    #expect(ctx.precision     == 0)
    #expect(ctx.roundingMode  == .HALF_UP)
  }

  @Test("DECIMAL32 has precision 7 and HALF_EVEN")
  func testDecimal32() {
    let ctx = java.math.MathContext.DECIMAL32
    #expect(ctx.precision    == 7)
    #expect(ctx.roundingMode == .HALF_EVEN)
  }

  @Test("DECIMAL64 has precision 16 and HALF_EVEN")
  func testDecimal64() {
    let ctx = java.math.MathContext.DECIMAL64
    #expect(ctx.precision    == 16)
    #expect(ctx.roundingMode == .HALF_EVEN)
  }

  @Test("DECIMAL128 has precision 34 and HALF_EVEN")
  func testDecimal128() {
    let ctx = java.math.MathContext.DECIMAL128
    #expect(ctx.precision    == 34)
    #expect(ctx.roundingMode == .HALF_EVEN)
  }

  // MARK: - init(_ precision)

  @Test("init(precision) defaults to HALF_UP")
  func testInitPrecisionOnly() {
    let ctx = java.math.MathContext(10)
    #expect(ctx.precision    == 10)
    #expect(ctx.roundingMode == .HALF_UP)
  }

  @Test("init(0) is allowed (unlimited)")
  func testInitZeroPrecision() {
    let ctx = java.math.MathContext(0)
    #expect(ctx.precision == 0)
  }

  // MARK: - init(_ precision, _ roundingMode)

  @Test("init(precision, roundingMode) stores both values")
  func testInitPrecisionAndMode() {
    let ctx = java.math.MathContext(5, .FLOOR)
    #expect(ctx.precision    == 5)
    #expect(ctx.roundingMode == .FLOOR)
  }

  // MARK: - init(_ String)

  @Test("init(String) parses valid MathContext string")
  func testInitString() throws {
    let ctx = try java.math.MathContext("precision=7 roundingMode=HALF_EVEN")
    #expect(ctx.precision    == 7)
    #expect(ctx.roundingMode == .HALF_EVEN)
  }

  @Test("init(String) round-trips all rounding modes")
  func testInitStringAllModes() throws {
    for mode in java.math.RoundingMode.allCases {
      let str = "precision=3 roundingMode=\(mode.description)"
      let ctx = try java.math.MathContext(str)
      #expect(ctx.roundingMode == mode)
      #expect(ctx.precision    == 3)
    }
  }

  @Test("init(String) throws on malformed input")
  func testInitStringInvalid() {
    #expect(throws: NumberFormatException.self) {
      try java.math.MathContext("garbage")
    }
    #expect(throws: NumberFormatException.self) {
      try java.math.MathContext("precision=7")          // missing roundingMode
    }
    #expect(throws: NumberFormatException.self) {
      try java.math.MathContext("precision=-1 roundingMode=UP")  // negative precision
    }
    #expect(throws: NumberFormatException.self) {
      try java.math.MathContext("precision=7 roundingMode=BOGUS") // unknown mode
    }
  }

  // MARK: - description / toString

  @Test("description matches Java format")
  func testDescription() {
    let ctx = java.math.MathContext(7, .HALF_EVEN)
    #expect(ctx.description   == "precision=7 roundingMode=HALF_EVEN")
    #expect(ctx.toString()    == "precision=7 roundingMode=HALF_EVEN")
  }

  // MARK: - Equatable / Hashable

  @Test("equal contexts compare as equal")
  func testEquality() {
    let a = java.math.MathContext(10, .CEILING)
    let b = java.math.MathContext(10, .CEILING)
    #expect(a == b)
  }

  @Test("contexts with different precision or mode are not equal")
  func testInequality() {
    let base = java.math.MathContext(10, .HALF_UP)
    #expect(base != java.math.MathContext(9,  .HALF_UP))
    #expect(base != java.math.MathContext(10, .HALF_DOWN))
  }

  @Test("equal contexts have the same hash value")
  func testHashValue() {
    let a = java.math.MathContext(16, .HALF_EVEN)
    let b = java.math.MathContext(16, .HALF_EVEN)
    #expect(a.hashValue == b.hashValue)
  }

  @Test("hashCode() and equals() are consistent with Swift Equatable")
  func testJavaAPIConsistency() {
    let a = java.math.MathContext(5, .DOWN)
    let b = java.math.MathContext(5, .DOWN)
    let c = java.math.MathContext(5, .UP)
    #expect(a.equals(b as AnyObject))
    #expect(!a.equals(c as AnyObject))
    #expect(a.hashCode() == b.hashCode())
  }

  @Test("MathContext can be used as Dictionary key")
  func testUsableAsDictionaryKey() {
    var dict: [java.math.MathContext: String] = [:]
    dict[java.math.MathContext.DECIMAL64] = "64-bit"
    #expect(dict[java.math.MathContext(16, .HALF_EVEN)] == "64-bit")
  }
}
