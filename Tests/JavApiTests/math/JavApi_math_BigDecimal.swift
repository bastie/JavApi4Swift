/*
 * SPDX-FileCopyrightText: 2023 - 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi
import Foundation

struct JavApi_math_BigDecimal_Tests {

  // MARK: - Constants

  @Test("ZERO, ONE, TEN constants have correct values")
  func testConstants() {
    #expect(java.math.BigDecimal.ZERO == java.math.BigDecimal(0.0))
    #expect(java.math.BigDecimal.ONE  == java.math.BigDecimal(1.0))
    #expect(java.math.BigDecimal.TEN  == java.math.BigDecimal(10.0))
    #expect(java.math.BigDecimal.ZERO != java.math.BigDecimal.ONE)
  }

  // MARK: - valueOf

  @Test("valueOf(String) returns nil for invalid input")
  func testValueOfStringInvalid() {
    #expect(java.math.BigDecimal.valueOf("not-a-number") == nil)
    #expect(java.math.BigDecimal.valueOf("") == nil)
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

  @Test("valueOf(Int64) produces correct value")
  func testValueOfInt64() {
    let v = java.math.BigDecimal.valueOf(Int64(99))
    #expect(v == java.math.BigDecimal.valueOf("99")!)
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
    #expect(a.divide(java.math.BigDecimal.ONE) == a)
  }

  @Test("divide by zero produces zero when dividend is zero")
  func testDivideZeroByAnything() {
    #expect(java.math.BigDecimal.ZERO.divide(java.math.BigDecimal.valueOf("5.0")!) == java.math.BigDecimal.ZERO)
  }

  @Test("remainder: 17 mod 5 = 2")
  func testRemainder() {
    let a = java.math.BigDecimal.valueOf("17")!
    let b = java.math.BigDecimal.valueOf("5")!
    #expect(a.remainder(b) == java.math.BigDecimal.valueOf("2")!)
  }

  @Test("remainder: negative dividend preserves sign")
  func testRemainderNegative() {
    let a = java.math.BigDecimal.valueOf("-7")!
    let b = java.math.BigDecimal.valueOf("3")!
    // Java: -7 % 3 = -1
    #expect(a.remainder(b) == java.math.BigDecimal.valueOf("-1")!)
  }

  // MARK: - Comparison

  @Test("compareTo: equal values returns 0")
  func testCompareEqual() {
    let a = java.math.BigDecimal.valueOf("2.5")!
    let b = java.math.BigDecimal.valueOf("2.5")!
    #expect(a.compareTo(b) == 0)
    #expect(a == b)
  }

  @Test("compareTo: ordering via < and >")
  func testCompareOrdering() {
    let small = java.math.BigDecimal.valueOf("1.0")!
    let large = java.math.BigDecimal.valueOf("9.0")!
    #expect(small.compareTo(large) < 0)
    #expect(large.compareTo(small) > 0)
    #expect(small < large)
    #expect(large > small)
  }

  // MARK: - abs / negate / plus / min / max

  @Test("abs of negative returns positive")
  func testAbsNegative() {
    let neg = java.math.BigDecimal.valueOf("-3.5")!
    #expect(neg.abs() == java.math.BigDecimal.valueOf("3.5")!)
  }

  @Test("abs of positive returns same value")
  func testAbsPositive() {
    let pos = java.math.BigDecimal.valueOf("3.5")!
    #expect(pos.abs() == pos)
  }

  @Test("abs of zero returns zero")
  func testAbsZero() {
    #expect(java.math.BigDecimal.ZERO.abs() == java.math.BigDecimal.ZERO)
  }

  @Test("negate of positive returns negative")
  func testNegatePositive() {
    let pos = java.math.BigDecimal.valueOf("5.0")!
    #expect(pos.negate() == java.math.BigDecimal.valueOf("-5.0")!)
  }

  @Test("negate of negative returns positive")
  func testNegateNegative() {
    let neg = java.math.BigDecimal.valueOf("-5.0")!
    #expect(neg.negate() == java.math.BigDecimal.valueOf("5.0")!)
  }

  @Test("negate of zero returns zero")
  func testNegateZero() {
    #expect(java.math.BigDecimal.ZERO.negate() == java.math.BigDecimal.ZERO)
  }

  @Test("plus returns self unchanged")
  func testPlus() {
    let v = java.math.BigDecimal.valueOf("7.77")!
    #expect(v.plus() == v)
  }

  @Test("min returns the lesser value")
  func testMin() {
    let a = java.math.BigDecimal.valueOf("3.0")!
    let b = java.math.BigDecimal.valueOf("7.0")!
    #expect(a.min(b) == a)
    #expect(b.min(a) == a)
  }

  @Test("max returns the greater value")
  func testMax() {
    let a = java.math.BigDecimal.valueOf("3.0")!
    let b = java.math.BigDecimal.valueOf("7.0")!
    #expect(a.max(b) == b)
    #expect(b.max(a) == b)
  }

  // MARK: - scale / precision

  @Test("scale() of integer value is 0")
  func testScaleInteger() {
    let v = java.math.BigDecimal.valueOf("42")!
    #expect(v.scale() == 0)
  }

  @Test("scale() counts decimal places")
  func testScaleDecimal() {
    #expect(java.math.BigDecimal.valueOf("3.14")!.scale()   == 2)
    // Java: new BigDecimal("1.000").scale() == 3 — trailing zeros are significant
    #expect(java.math.BigDecimal.valueOf("1.000")!.scale()  == 3)
    #expect(java.math.BigDecimal.valueOf("0.1")!.scale()    == 1)
  }

  @Test("precision() counts significant digits")
  func testPrecision() {
    #expect(java.math.BigDecimal.valueOf("42")!.precision()    == 2)
    #expect(java.math.BigDecimal.valueOf("3.14")!.precision()  == 3)
    // Java: new BigDecimal("0.010").precision() == 2 (significant digits incl. trailing zeros)
    #expect(java.math.BigDecimal.valueOf("0.010")!.precision() == 2)
    #expect(java.math.BigDecimal.valueOf("1000")!.precision()  == 4)
  }

  // MARK: - setScale ROUND_DOWN

  @Test("setScale ROUND_DOWN truncates toward zero on positive")
  func testRoundDownPositive() {
    let v = java.math.BigDecimal.valueOf("1.55")!
    #expect(v.setScale(1, java.math.BigDecimal.ROUND_DOWN) == java.math.BigDecimal.valueOf("1.5")!)
  }

  @Test("setScale ROUND_DOWN truncates toward zero on negative")
  func testRoundDownNegative() {
    let v = java.math.BigDecimal.valueOf("-1.55")!
    // ROUND_DOWN = toward zero → -1.5
    #expect(v.setScale(1, java.math.BigDecimal.ROUND_DOWN) == java.math.BigDecimal.valueOf("-1.5")!)
  }

  @Test("setScale ROUND_DOWN with scale=0")
  func testRoundDownScaleZero() {
    let pi = java.math.BigDecimal.valueOf(Double.pi)
    #expect(pi.setScale(0, java.math.BigDecimal.ROUND_DOWN) == java.math.BigDecimal.valueOf("3")!)
  }

  @Test("setScale ROUND_DOWN with negative scale")
  func testRoundDownNegativeScale() {
    let big = java.math.BigDecimal(1_103_802.8199999998)
    #expect(big.setScale(-1, java.math.BigDecimal.ROUND_DOWN) == java.math.BigDecimal.valueOf("1103800")!)
  }

  @Test("setScale ROUND_DOWN tax-calculator regression")
  func testRoundDownTaxRegression() {
    var VSP1 = java.math.BigDecimal.valueOf("25000")!
    let RVSATZAN = java.math.BigDecimal.valueOf("0.093000")!
    VSP1 = VSP1.multiply(RVSATZAN).setScale(2, java.math.BigDecimal.ROUND_DOWN)
    #expect(VSP1 == java.math.BigDecimal.valueOf("2325.00")!)
  }

  // MARK: - setScale ROUND_UP

  @Test("setScale ROUND_UP rounds away from zero on positive")
  func testRoundUpPositive() {
    let v = java.math.BigDecimal.valueOf("1.01")!
    #expect(v.setScale(1, java.math.BigDecimal.ROUND_UP) == java.math.BigDecimal.valueOf("1.1")!)
  }

  @Test("setScale ROUND_UP at exact boundary does not round")
  func testRoundUpExact() {
    let v = java.math.BigDecimal.valueOf("2.0")!
    #expect(v.setScale(0, java.math.BigDecimal.ROUND_UP) == java.math.BigDecimal.valueOf("2")!)
  }

  @Test("setScale ROUND_UP on pi to 2 places")
  func testRoundUpPi() {
    let pi = java.math.BigDecimal.valueOf(Double.pi)
    #expect(pi.setScale(2, java.math.BigDecimal.ROUND_UP) == java.math.BigDecimal.valueOf("3.15")!)
  }

  // MARK: - setScale ROUND_HALF_UP

  @Test("setScale ROUND_HALF_UP: 2.45 → 2.5 at scale 1")
  func testRoundHalfUp() {
    let v = java.math.BigDecimal.valueOf("2.45")!
    #expect(v.setScale(1, java.math.BigDecimal.ROUND_HALF_UP) == java.math.BigDecimal.valueOf("2.5")!)
  }

  @Test("setScale ROUND_HALF_UP: 2.44 → 2.4 at scale 1")
  func testRoundHalfUpDown() {
    let v = java.math.BigDecimal.valueOf("2.44")!
    #expect(v.setScale(1, java.math.BigDecimal.ROUND_HALF_UP) == java.math.BigDecimal.valueOf("2.4")!)
  }

  // MARK: - setScale ROUND_HALF_EVEN (banker's)

  @Test("setScale ROUND_HALF_EVEN: 2.5 rounds to 2 (even)")
  func testRoundHalfEven25() {
    let v = java.math.BigDecimal.valueOf("2.5")!
    #expect(v.setScale(0, java.math.BigDecimal.ROUND_HALF_EVEN) == java.math.BigDecimal.valueOf("2")!)
  }

  @Test("setScale ROUND_HALF_EVEN: 3.5 rounds to 4 (even)")
  func testRoundHalfEven35() {
    let v = java.math.BigDecimal.valueOf("3.5")!
    #expect(v.setScale(0, java.math.BigDecimal.ROUND_HALF_EVEN) == java.math.BigDecimal.valueOf("4")!)
  }

  // MARK: - setScale via RoundingMode enum

  @Test("setScale(RoundingMode.DOWN) is equivalent to ROUND_DOWN")
  func testSetScaleRoundingModeEnum() {
    let v = java.math.BigDecimal.valueOf("1.99")!
    let a = v.setScale(1, java.math.BigDecimal.ROUND_DOWN)
    let b = v.setScale(1, java.math.RoundingMode.DOWN)
    #expect(a == b)
  }

  @Test("setScale(RoundingMode.HALF_UP) is equivalent to ROUND_HALF_UP")
  func testSetScaleRoundingModeHalfUp() {
    let v = java.math.BigDecimal.valueOf("2.35")!
    let a = v.setScale(1, java.math.BigDecimal.ROUND_HALF_UP)
    let b = v.setScale(1, java.math.RoundingMode.HALF_UP)
    #expect(a == b)
  }

  // MARK: - toPlainString / toString

  @Test("toPlainString produces human-readable decimal string")
  func testToPlainString() {
    #expect(java.math.BigDecimal.valueOf("3.14")!.toPlainString() == "3.14")
    #expect(java.math.BigDecimal.valueOf("42")!.toPlainString()   == "42")
    #expect(java.math.BigDecimal.valueOf("-7.5")!.toPlainString() == "-7.5")
  }

  @Test("toString equals toPlainString")
  func testToString() {
    let v = java.math.BigDecimal.valueOf("123.456")!
    #expect(v.toString() == v.toPlainString())
  }

  // MARK: - CustomStringConvertible / description

  @Test("description equals toString (Swift interpolation consistency)")
  func testDescription() {
    let v = java.math.BigDecimal.valueOf("3.14")!
    #expect("\(v)" == v.toString())
    #expect(v.description == v.toPlainString())
  }

  @Test("description of negative value matches toString")
  func testDescriptionNegative() {
    let v = java.math.BigDecimal.valueOf("-99.5")!
    #expect(v.description == "-99.5")
  }

  // MARK: - stripTrailingZeros

  @Test("stripTrailingZeros removes trailing zeros after decimal point")
  func testStripTrailingZeros() {
    let v = java.math.BigDecimal.valueOf("3.1400")!
    let s = v.stripTrailingZeros()
    #expect(s.toPlainString() == "3.14")
  }

  @Test("stripTrailingZeros on integer-valued decimal removes decimal point")
  func testStripTrailingZerosInteger() {
    let v = java.math.BigDecimal.valueOf("10.00")!
    let s = v.stripTrailingZeros()
    #expect(s.toPlainString() == "10")
  }

  @Test("stripTrailingZeros on integer without decimal point is unchanged")
  func testStripTrailingZerosNoDecimal() {
    let v = java.math.BigDecimal.valueOf("42")!
    #expect(v.stripTrailingZeros().toPlainString() == "42")
  }

  // MARK: - movePointLeft / movePointRight / scaleByPowerOfTen

  @Test("movePointLeft(1) divides by 10")
  func testMovePointLeft() {
    let v = java.math.BigDecimal.valueOf("123.45")!
    #expect(v.movePointLeft(1) == java.math.BigDecimal.valueOf("12.345")!)
  }

  @Test("movePointLeft(0) is identity")
  func testMovePointLeftZero() {
    let v = java.math.BigDecimal.valueOf("5.0")!
    #expect(v.movePointLeft(0) == v)
  }

  @Test("movePointRight(2) multiplies by 100")
  func testMovePointRight() {
    let v = java.math.BigDecimal.valueOf("1.5")!
    #expect(v.movePointRight(2) == java.math.BigDecimal.valueOf("150.0")!)
  }

  @Test("scaleByPowerOfTen(3) multiplies by 1000")
  func testScaleByPowerOfTen() {
    let v = java.math.BigDecimal.valueOf("2.5")!
    #expect(v.scaleByPowerOfTen(3) == java.math.BigDecimal.valueOf("2500.0")!)
  }

  // MARK: - Numeric conversions

  @Test("intValue truncates fractional part")
  func testIntValue() {
    #expect(java.math.BigDecimal.valueOf("7.9")!.intValue() == 7)
    #expect(java.math.BigDecimal.valueOf("-3.1")!.intValue() == -3)
  }

  @Test("longValue returns Int64")
  func testLongValue() {
    #expect(java.math.BigDecimal.valueOf("99")!.longValue() == Int64(99))
    #expect(java.math.BigDecimal.valueOf("-1")!.longValue() == Int64(-1))
  }

  @Test("doubleValue returns approximate Double")
  func testDoubleValue() {
    // 3.14 cannot be represented exactly in IEEE 754 — allow floating-point epsilon
    #expect(Swift.abs(java.math.BigDecimal.valueOf("3.14")!.doubleValue() - 3.14) < 1e-10)
    // -0.5 is exactly representable
    #expect(java.math.BigDecimal.valueOf("-0.5")!.doubleValue() == -0.5)
  }

  @Test("floatValue returns approximate Float")
  func testFloatValue() {
    #expect(java.math.BigDecimal.valueOf("1.5")!.floatValue() == Float(1.5))
  }

  // MARK: - Real-world regression tests

  @Test("divide and add produce correct result for tax-calculator pseudo code")
  func testDivideAdd() {
    // see pseudo code from German Federal Ministry of Finance
    let ZAHL2   = java.math.BigDecimal.valueOf(2)
    let ZAHL100 = java.math.BigDecimal.valueOf(100)
    var KVSATZAN = java.math.BigDecimal.valueOf(0)
    let KVZ      = java.math.BigDecimal()
    let jamesBond = java.math.BigDecimal.valueOf("0.07")!

    KVSATZAN = (KVZ.divide(ZAHL2).divide(ZAHL100)).add(jamesBond)
    #expect(KVSATZAN == java.math.BigDecimal.valueOf("0.07")!)
  }

  @Test("setScale rounds correctly for positive, zero, and negative scales")
  func testScale() {
    let pi = java.math.BigDecimal.valueOf(Double.pi)
    #expect(pi.setScale(2, java.math.BigDecimal.ROUND_UP)   == java.math.BigDecimal.valueOf("3.15")!)
    #expect(pi.setScale(2, java.math.BigDecimal.ROUND_DOWN) == java.math.BigDecimal.valueOf("3.14")!)
    #expect(pi.setScale(0, java.math.BigDecimal.ROUND_DOWN) == java.math.BigDecimal.valueOf("3")!)
    #expect(pi.setScale(0, java.math.BigDecimal.ROUND_UP)   == java.math.BigDecimal.valueOf("4")!)

    let big = java.math.BigDecimal(1_103_802.8199999998)
    #expect(big.setScale( 1, java.math.BigDecimal.ROUND_DOWN) == java.math.BigDecimal.valueOf("1103802.8")!)
    #expect(big.setScale( 0, java.math.BigDecimal.ROUND_DOWN) == java.math.BigDecimal.valueOf("1103802")!)
    #expect(big.setScale(-1, java.math.BigDecimal.ROUND_DOWN) == java.math.BigDecimal.valueOf("1103800")!)

    let onePoint55 = java.math.BigDecimal.valueOf("1.55")!
    #expect(onePoint55.setScale(1, java.math.BigDecimal.ROUND_DOWN) == java.math.BigDecimal.valueOf("1.5")!)
  }

  // MARK: - setScale ROUND_HALF_DOWN

  @Test("setScale ROUND_HALF_DOWN: 2.5 truncates toward zero")
  func testRoundHalfDown25() {
    let v = java.math.BigDecimal.valueOf("2.5")!
    #expect(v.setScale(0, java.math.BigDecimal.ROUND_HALF_DOWN) == java.math.BigDecimal.valueOf("2")!)
  }

  @Test("setScale ROUND_HALF_DOWN: 2.51 rounds up (not a tie)")
  func testRoundHalfDown251() {
    let v = java.math.BigDecimal.valueOf("2.51")!
    #expect(v.setScale(0, java.math.BigDecimal.ROUND_HALF_DOWN) == java.math.BigDecimal.valueOf("3")!)
  }

  @Test("setScale ROUND_HALF_DOWN: negative -2.5 truncates toward zero")
  func testRoundHalfDownNeg() {
    let v = java.math.BigDecimal.valueOf("-2.5")!
    #expect(v.setScale(0, java.math.BigDecimal.ROUND_HALF_DOWN) == java.math.BigDecimal.valueOf("-2")!)
  }

  // MARK: - setScale ROUND_FLOOR / ROUND_CEILING

  @Test("setScale ROUND_FLOOR: positive rounds toward -∞")
  func testRoundFloorPositive() {
    let v = java.math.BigDecimal.valueOf("1.9")!
    #expect(v.setScale(0, java.math.BigDecimal.ROUND_FLOOR) == java.math.BigDecimal.valueOf("1")!)
  }

  @Test("setScale ROUND_FLOOR: negative rounds toward -∞")
  func testRoundFloorNegative() {
    let v = java.math.BigDecimal.valueOf("-1.1")!
    #expect(v.setScale(0, java.math.BigDecimal.ROUND_FLOOR) == java.math.BigDecimal.valueOf("-2")!)
  }

  @Test("setScale ROUND_CEILING: positive rounds toward +∞")
  func testRoundCeilingPositive() {
    let v = java.math.BigDecimal.valueOf("1.1")!
    #expect(v.setScale(0, java.math.BigDecimal.ROUND_CEILING) == java.math.BigDecimal.valueOf("2")!)
  }

  @Test("setScale ROUND_CEILING: negative rounds toward +∞ (toward zero)")
  func testRoundCeilingNegative() {
    let v = java.math.BigDecimal.valueOf("-1.9")!
    // Java: ceiling(-1.9) = -1 (towards +∞)
    #expect(v.setScale(0, java.math.BigDecimal.ROUND_CEILING) == java.math.BigDecimal.valueOf("-1")!)
  }

  @Test("setScale ROUND_CEILING on exact value does not change it")
  func testRoundCeilingExact() {
    let v = java.math.BigDecimal.valueOf("3.0")!
    #expect(v.setScale(0, java.math.BigDecimal.ROUND_CEILING) == java.math.BigDecimal.valueOf("3")!)
  }

  // MARK: - setScale ROUND_UNNECESSARY

  @Test("setScale ROUND_UNNECESSARY on exact value succeeds")
  func testRoundUnnecessaryExact() {
    let v = java.math.BigDecimal.valueOf("3.10")!
    // 3.10 reduced to scale 1 = 3.1, exact — no rounding
    #expect(v.setScale(1, java.math.BigDecimal.ROUND_UNNECESSARY) == java.math.BigDecimal.valueOf("3.1")!)
  }

  // MARK: - setScale(int) exact

  @Test("setScale(int) throws when rounding would be needed")
  func testSetScaleExactThrows() {
    let v = java.math.BigDecimal.valueOf("3.14")!
    #expect(throws: ArithmeticException.self) { try v.setScale(1) }
  }

  @Test("setScale(int) succeeds when exact")
  func testSetScaleExactSucceeds() {
    let v = java.math.BigDecimal.valueOf("3.10")!
    #expect(throws: Never.self) { try v.setScale(1) }
  }

  // MARK: - signum

  @Test("signum() of positive is 1")
  func testSignumPositive() {
    #expect(java.math.BigDecimal.valueOf("42.5")!.signum() == 1)
  }

  @Test("signum() of negative is -1")
  func testSignumNegative() {
    #expect(java.math.BigDecimal.valueOf("-0.001")!.signum() == -1)
  }

  @Test("signum() of zero is 0")
  func testSignumZero() {
    #expect(java.math.BigDecimal.ZERO.signum() == 0)
  }

  // MARK: - pow

  @Test("pow(0) is always 1 with scale 0")
  func testPowZero() throws {
    #expect(try java.math.BigDecimal.valueOf("99.9")!.pow(0) == java.math.BigDecimal.ONE)
  }

  @Test("pow(1) returns self")
  func testPowOne() throws {
    let v = java.math.BigDecimal.valueOf("3.14")!
    #expect(try v.pow(1) == v)
  }

  @Test("pow(2): 3^2 = 9")
  func testPowSquare() throws {
    let v = java.math.BigDecimal.valueOf("3")!
    #expect(try v.pow(2) == java.math.BigDecimal.valueOf("9")!)
  }

  @Test("pow(3): 2.0^3 = 8 with scale 3")
  func testPowCubicScale() throws {
    let v = java.math.BigDecimal.valueOf("2.0")!  // scale 1
    let result = try v.pow(3)
    #expect(result == java.math.BigDecimal.valueOf("8")!)
    #expect(result.scale() == 3)  // scale = 1 * 3
  }

  @Test("pow(negative) throws ArithmeticException")
  func testPowNegativeThrows() {
    let v = java.math.BigDecimal.valueOf("2")!
    #expect(throws: ArithmeticException.self) { try v.pow(-1) }
  }

  // MARK: - unscaledValue

  @Test("unscaledValue of 3.14 is 314")
  func testUnscaledValue() {
    let v = java.math.BigDecimal.valueOf("3.14")!
    #expect(v.unscaledValue() == (try? java.math.BigInteger("314")))
  }

  @Test("unscaledValue of integer is unchanged")
  func testUnscaledValueInteger() {
    let v = java.math.BigDecimal.valueOf("42")!
    #expect(v.unscaledValue() == (try? java.math.BigInteger("42")))
  }

  @Test("unscaledValue of -0.5 is -5")
  func testUnscaledValueNegative() {
    let v = java.math.BigDecimal.valueOf("-0.5")!
    #expect(v.unscaledValue() == (try? java.math.BigInteger("-5")))
  }

  // MARK: - ulp

  @Test("ulp() of scale-2 value is 0.01")
  func testUlpScale2() {
    let v = java.math.BigDecimal.valueOf("3.14")!
    #expect(v.ulp() == java.math.BigDecimal.valueOf("0.01")!)
  }

  @Test("ulp() of integer (scale 0) is 1")
  func testUlpInteger() {
    let v = java.math.BigDecimal.valueOf("42")!
    #expect(v.ulp() == java.math.BigDecimal.ONE)
  }

  // MARK: - divideToIntegralValue / divideAndRemainder

  @Test("divideToIntegralValue: 7 / 2 = 3")
  func testDivideToIntegral() {
    let a = java.math.BigDecimal.valueOf("7")!
    let b = java.math.BigDecimal.valueOf("2")!
    #expect(a.divideToIntegralValue(b) == java.math.BigDecimal.valueOf("3")!)
  }

  @Test("divideToIntegralValue: -7 / 2 = -3 (truncated toward zero)")
  func testDivideToIntegralNegative() {
    let a = java.math.BigDecimal.valueOf("-7")!
    let b = java.math.BigDecimal.valueOf("2")!
    #expect(a.divideToIntegralValue(b) == java.math.BigDecimal.valueOf("-3")!)
  }

  @Test("divideAndRemainder: 17 / 5 = [3, 2]")
  func testDivideAndRemainder() {
    let a = java.math.BigDecimal.valueOf("17")!
    let b = java.math.BigDecimal.valueOf("5")!
    let r = a.divideAndRemainder(b)
    #expect(r.count == 2)
    #expect(r[0] == java.math.BigDecimal.valueOf("3")!)
    #expect(r[1] == java.math.BigDecimal.valueOf("2")!)
  }

  @Test("divideAndRemainder: -17 / 5 = [-3, -2]")
  func testDivideAndRemainderNegative() {
    let a = java.math.BigDecimal.valueOf("-17")!
    let b = java.math.BigDecimal.valueOf("5")!
    let r = a.divideAndRemainder(b)
    #expect(r[0] == java.math.BigDecimal.valueOf("-3")!)
    #expect(r[1] == java.math.BigDecimal.valueOf("-2")!)
  }

  // MARK: - round(MathContext)

  @Test("round to 3 significant digits with HALF_UP")
  func testRoundMathContext() {
    let v = java.math.BigDecimal.valueOf("3.14159")!
    let mc = java.math.MathContext(3, .HALF_UP)
    let r = v.round(mc)
    #expect(r == java.math.BigDecimal.valueOf("3.14")!)
  }

  @Test("round(UNLIMITED) returns self unchanged")
  func testRoundUnlimited() {
    let v = java.math.BigDecimal.valueOf("3.14159")!
    #expect(v.round(java.math.MathContext.UNLIMITED) == v)
  }

  // MARK: - toBigInteger / toBigIntegerExact

  @Test("toBigInteger truncates fractional part")
  func testToBigInteger() {
    let v = java.math.BigDecimal.valueOf("3.99")!
    #expect(v.toBigInteger() == (try? java.math.BigInteger("3")))
  }

  @Test("toBigInteger of negative truncates toward zero")
  func testToBigIntegerNegative() {
    let v = java.math.BigDecimal.valueOf("-3.99")!
    #expect(v.toBigInteger() == (try? java.math.BigInteger("-3")))
  }

  @Test("toBigIntegerExact succeeds when no fractional part")
  func testToBigIntegerExact() throws {
    let v = java.math.BigDecimal.valueOf("42.0")!
    // 42.0 has scale 1, but fractional part is zero
    #expect(throws: Never.self) { try v.toBigIntegerExact() }
    #expect(try v.toBigIntegerExact() == (try java.math.BigInteger("42")))
  }

  @Test("toBigIntegerExact throws when fractional part exists")
  func testToBigIntegerExactThrows() {
    let v = java.math.BigDecimal.valueOf("3.14")!
    #expect(throws: ArithmeticException.self) { try v.toBigIntegerExact() }
  }

  // MARK: - toEngineeringString

  @Test("toEngineeringString for value < 1000 equals toPlainString")
  func testEngineeringStringSmall() {
    let v = java.math.BigDecimal.valueOf("123.45")!
    #expect(v.toEngineeringString() == v.toPlainString())
  }

  @Test("toEngineeringString uses exponent multiple of 3")
  func testEngineeringStringLarge() {
    let v = java.math.BigDecimal.valueOf("1234567")!
    // 1234567 → 1.234567E+6
    #expect(v.toEngineeringString() == "1.234567E+6")
  }

  // MARK: - equals / hashCode (Java semantics)

  @Test("equals() is scale-sensitive: 2.0 != 2.00")
  func testEqualsScaleSensitive() {
    let a = java.math.BigDecimal.valueOf("2.0")!
    let b = java.math.BigDecimal.valueOf("2.00")!
    #expect(a.equals(b) == false)
    #expect(a == b)  // Swift == is numeric only
  }

  @Test("equals() true when value and scale match")
  func testEqualsExact() {
    let a = java.math.BigDecimal.valueOf("3.14")!
    let b = java.math.BigDecimal.valueOf("3.14")!
    #expect(a.equals(b) == true)
  }

  @Test("hashCode() equal for same value and scale")
  func testHashCodeEqual() {
    let a = java.math.BigDecimal.valueOf("1.5")!
    let b = java.math.BigDecimal.valueOf("1.5")!
    #expect(a.hashCode() == b.hashCode())
  }

  @Test("hashCode() differs for different scale")
  func testHashCodeDifferentScale() {
    let a = java.math.BigDecimal.valueOf("1.5")!
    let b = java.math.BigDecimal.valueOf("1.50")!
    #expect(a.hashCode() != b.hashCode())
  }

  // MARK: - scale() after arithmetic

  @Test("scale after add is max of operand scales")
  func testScaleAfterAdd() {
    let a = java.math.BigDecimal.valueOf("1.5")!    // scale 1
    let b = java.math.BigDecimal.valueOf("2.25")!   // scale 2
    #expect(a.add(b).scale() == 2)
  }

  @Test("scale after multiply is sum of operand scales")
  func testScaleAfterMultiply() {
    let a = java.math.BigDecimal.valueOf("1.5")!    // scale 1
    let b = java.math.BigDecimal.valueOf("2.5")!    // scale 1
    #expect(a.multiply(b).scale() == 2)
  }

  @Test("scale after setScale is the requested scale")
  func testScaleAfterSetScale() {
    let v = java.math.BigDecimal.valueOf("3.14159")!
    #expect(v.setScale(2, java.math.BigDecimal.ROUND_DOWN).scale() == 2)
    #expect(v.setScale(4, java.math.BigDecimal.ROUND_DOWN).scale() == 4)
  }

  // MARK: - precision() edge cases

  @Test("precision() of zero is 1")
  func testPrecisionZero() {
    #expect(java.math.BigDecimal.ZERO.precision() == 1)
  }

  @Test("precision() of very large integer")
  func testPrecisionLarge() {
    let v = java.math.BigDecimal.valueOf("123456789")!
    #expect(v.precision() == 9)
  }

  @Test("precision() of negative preserves digit count")
  func testPrecisionNegative() {
    let v = java.math.BigDecimal.valueOf("-9.99")!
    #expect(v.precision() == 3)
  }

  // MARK: - compareTo edge cases

  @Test("compareTo: -0 == 0")
  func testCompareNegativeZero() {
    let neg = java.math.BigDecimal.valueOf("-0")!
    #expect(neg.compareTo(java.math.BigDecimal.ZERO) == 0)
  }

  @Test("compareTo: very large vs very small")
  func testCompareExtreme() {
    let big   = java.math.BigDecimal.valueOf("999999999")!
    let small = java.math.BigDecimal.valueOf("0.000001")!
    #expect(big.compareTo(small) > 0)
    #expect(small.compareTo(big) < 0)
  }

  @Test("compareTo: same value different scale")
  func testCompareSameValueDifferentScale() {
    let a = java.math.BigDecimal.valueOf("1.0")!
    let b = java.math.BigDecimal.valueOf("1.000")!
    // compareTo ignores scale — numerically equal
    #expect(a.compareTo(b) == 0)
  }

  // MARK: - Swiftify: Decimal ↔ BigDecimal conversions

  @Test("init(decimal:) wraps Decimal correctly")
  func testInitDecimal() {
    let d = Decimal(string: "3.14", locale: Locale(identifier: "en_US_POSIX"))!
    let bd = java.math.BigDecimal(decimal: d)
    #expect(bd == java.math.BigDecimal.valueOf("3.14")!)
  }

  @Test("toDecimal() returns underlying Decimal")
  func testToDecimal() {
    let bd = java.math.BigDecimal.valueOf("2.5")!
    let d  = bd.toDecimal()
    #expect(d == Decimal(string: "2.5", locale: Locale(identifier: "en_US_POSIX"))!)
  }

  @Test("toBigDecimal() on Decimal produces correct BigDecimal")
  func testToBigDecimal() {
    let d  = Decimal(string: "7.77", locale: Locale(identifier: "en_US_POSIX"))!
    let bd = d.toBigDecimal()
    #expect(bd == java.math.BigDecimal.valueOf("7.77")!)
  }

  @Test("ExpressibleByIntegerLiteral: let x: BigDecimal = 42")
  func testIntegerLiteral() {
    let x: java.math.BigDecimal = 42
    #expect(x == java.math.BigDecimal.valueOf(42))
  }

  @Test("ExpressibleByFloatLiteral: let x: BigDecimal = 3.14")
  func testFloatLiteral() {
    let x: java.math.BigDecimal = 3.14
    // Float literal loses precision — compare numerically with epsilon
    #expect(Swift.abs(x.doubleValue() - 3.14) < 1e-10)
  }

  @Test("BigDecimal → Decimal → BigDecimal round-trip preserves numeric value")
  func testBigDecimalDecimalRoundTrip() {
    let original = java.math.BigDecimal.valueOf("3.14")!
    let asDecimal = original.toDecimal()
    let restored  = asDecimal.toBigDecimal()
    // Numeric value must survive the round-trip
    #expect(restored == original)
  }

  @Test("BigDecimal → Decimal → BigDecimal round-trip for negative value")
  func testBigDecimalDecimalRoundTripNegative() {
    let original  = java.math.BigDecimal.valueOf("-99.50")!
    let restored  = original.toDecimal().toBigDecimal()
    #expect(restored == original)
  }

  @Test("BigDecimal → Decimal → BigDecimal round-trip for zero")
  func testBigDecimalDecimalRoundTripZero() {
    let original = java.math.BigDecimal.ZERO
    let restored = original.toDecimal().toBigDecimal()
    #expect(restored == original)
  }

  // MARK: - String round-trip (preserves scale)

  @Test("String round-trip preserves value and scale for 1.000")
  func testStringRoundTripTrailingZeros() throws {
    let original = try java.math.BigDecimal("1.000")
    let restored = try java.math.BigDecimal(original.toPlainString())
    #expect(restored == original)
    #expect(restored.scale() == original.scale())   // scale 3 survives
  }

  @Test("String round-trip preserves value and scale for -99.50")
  func testStringRoundTripNegative() throws {
    let original = try java.math.BigDecimal("-99.50")
    let restored = try java.math.BigDecimal(original.toPlainString())
    #expect(restored == original)
    #expect(restored.scale() == original.scale())   // scale 2 survives
  }

  @Test("String round-trip for integer value has scale 0")
  func testStringRoundTripInteger() throws {
    let original = try java.math.BigDecimal("42")
    let restored = try java.math.BigDecimal(original.toPlainString())
    #expect(restored == original)
    #expect(restored.scale() == 0)
  }

  @Test("Decimal round-trip does NOT preserve trailing-zero scale (documented limitation)")
  func testDecimalRoundTripDropsTrailingZeroScale() throws {
    // Foundation.Decimal normalises "1.000" → 1 (exponent 0), so scale is lost.
    // This test documents the known limitation; the String round-trip must be used
    // when scale preservation is required.
    let original = try java.math.BigDecimal("1.000")   // scale 3
    let viaDecimal = original.toDecimal().toBigDecimal()
    #expect(viaDecimal == original)          // numeric value survives
    #expect(viaDecimal.scale() != original.scale())  // scale is NOT preserved
  }
}
