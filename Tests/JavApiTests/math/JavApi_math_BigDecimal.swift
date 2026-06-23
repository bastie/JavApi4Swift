/*
 * SPDX-FileCopyrightText: 2023 - 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_math_BigDecimal_Tests {

  @Test("divide and add produce correct result for tax-calculator pseudo code")
  func testDivideAdd() {
    // see pseudo code from German Federal Ministry of Finance
    // https://www.bmf-steuerrechner.de/interface/einganginterface.xhtml
    let ZAHL2   = java.math.BigDecimal.valueOf(2)
    let ZAHL100 = java.math.BigDecimal.valueOf(100)
    var KVSATZAN = java.math.BigDecimal.valueOf(0)
    let KVZ      = java.math.BigDecimal()
    let jamesBond = java.math.BigDecimal.valueOf("0.07")!

    KVSATZAN = (KVZ.divide(ZAHL2).divide(ZAHL100)).add(jamesBond)

    // Compare numerically — avoids NSDecimalNumber.stringValue which is locale-sensitive
    #expect(KVSATZAN == java.math.BigDecimal.valueOf("0.07")!)
  }

  @Test("setScale rounds correctly for positive, zero, and negative scales")
  func testScale() {
    // tax-calculator: 25000 * 0.093 rounded down to 2 decimal places
    var VSP1     = java.math.BigDecimal.valueOf("25000")!
    let RVSATZAN = java.math.BigDecimal.valueOf("0.093000")!
    VSP1 = (VSP1.multiply(RVSATZAN)).setScale(2, java.math.BigDecimal.ROUND_DOWN)
    #expect(VSP1 == java.math.BigDecimal.valueOf("2325.00")!)

    // pi rounded to 2 decimal places
    let pi   = java.math.BigDecimal.valueOf(Double.pi)
    #expect(pi.setScale(2, java.math.BigDecimal.ROUND_UP)   == 3.15)
    #expect(pi.setScale(2, java.math.BigDecimal.ROUND_DOWN) == 3.14)

    // scale 0
    #expect(pi.setScale(0, java.math.BigDecimal.ROUND_DOWN) == 3)
    #expect(pi.setScale(0, java.math.BigDecimal.ROUND_UP)   == 4)

    // scale 0 with large value
    let big = java.math.BigDecimal(1_103_802.8199999998)
    #expect(big.setScale( 1, java.math.BigDecimal.ROUND_DOWN) == java.math.BigDecimal.valueOf("1103802.8")!)
    #expect(big.setScale( 0, java.math.BigDecimal.ROUND_DOWN) == java.math.BigDecimal.valueOf("1103802")!)
    #expect(big.setScale(-1, java.math.BigDecimal.ROUND_DOWN) == java.math.BigDecimal.valueOf("1103800")!)

    // regression: scale > 0 with digit 5 as last
    let onePoint55 = java.math.BigDecimal.valueOf("1.55")!
    #expect(onePoint55.setScale(1, java.math.BigDecimal.ROUND_DOWN) == java.math.BigDecimal.valueOf("1.5")!)
  }

  // MARK: - Constants

  @Test("ZERO and ONE constants have correct values")
  func testConstants() {
    #expect(java.math.BigDecimal.ZERO == java.math.BigDecimal(0.0))
    #expect(java.math.BigDecimal.ONE  == java.math.BigDecimal(1.0))
    #expect(java.math.BigDecimal.ZERO != java.math.BigDecimal.ONE)
  }

  // MARK: - valueOf

  @Test("valueOf(String) returns nil for invalid input")
  func testValueOfStringInvalid() {
    #expect(java.math.BigDecimal.valueOf("not-a-number") == nil)
    #expect(java.math.BigDecimal.valueOf("")             == nil)
  }

  @Test("valueOf(String) parses integers and decimals")
  func testValueOfStringValid() {
    #expect(java.math.BigDecimal.valueOf("0")    != nil)
    #expect(java.math.BigDecimal.valueOf("42")   != nil)
    #expect(java.math.BigDecimal.valueOf("-7")   != nil)
    #expect(java.math.BigDecimal.valueOf("3.14") != nil)
  }

  @Test("valueOf(Int) produces correct value")
  func testValueOfInt() {
    let v = java.math.BigDecimal.valueOf(42)
    #expect(v == java.math.BigDecimal.valueOf("42")!)
  }

  // MARK: - Basic arithmetic

  @Test("add produces correct result")
  func testAdd() {
    let a = java.math.BigDecimal.valueOf("1.5")!
    let b = java.math.BigDecimal.valueOf("2.5")!
    #expect(a.add(b) == java.math.BigDecimal.valueOf("4.0")!)
  }

  @Test("subtract produces correct result")
  func testSubtract() {
    let a = java.math.BigDecimal.valueOf("10.0")!
    let b = java.math.BigDecimal.valueOf("3.5")!
    #expect(a.subtract(b) == java.math.BigDecimal.valueOf("6.5")!)
  }

  @Test("multiply produces correct result")
  func testMultiply() {
    let a = java.math.BigDecimal.valueOf("3.0")!
    let b = java.math.BigDecimal.valueOf("4.0")!
    #expect(a.multiply(b) == java.math.BigDecimal.valueOf("12")!)
  }

  @Test("divide by one returns same value")
  func testDivideByOne() {
    let a = java.math.BigDecimal.valueOf("7.5")!
    let one = java.math.BigDecimal.ONE
    #expect(a.divide(one) == a)
  }

  @Test("divide by zero produces zero when dividend is zero")
  func testDivideZeroByAnything() {
    let zero = java.math.BigDecimal.ZERO
    let nonzero = java.math.BigDecimal.valueOf("5.0")!
    #expect(zero.divide(nonzero) == zero)
  }

  // MARK: - Comparison

  @Test("compareTo: equal values")
  func testCompareEqual() {
    let a = java.math.BigDecimal.valueOf("2.5")!
    let b = java.math.BigDecimal.valueOf("2.5")!
    #expect(a == b)
  }

  @Test("compareTo: ordering via < and >")
  func testCompareOrdering() {
    let small = java.math.BigDecimal.valueOf("1.0")!
    let large = java.math.BigDecimal.valueOf("9.0")!
    #expect(small < large)
    #expect(large > small)
  }

  // MARK: - ROUND_UP edge cases

  @Test("setScale ROUND_UP rounds away from zero on positive")
  func testRoundUpPositive() {
    let v = java.math.BigDecimal.valueOf("1.01")!
    #expect(v.setScale(1, java.math.BigDecimal.ROUND_UP) == java.math.BigDecimal.valueOf("1.1")!)
  }

  @Test("setScale ROUND_UP at .0 boundary does not round up")
  func testRoundUpExact() {
    let v = java.math.BigDecimal.valueOf("2.0")!
    #expect(v.setScale(0, java.math.BigDecimal.ROUND_UP) == java.math.BigDecimal.valueOf("2")!)
  }
}
