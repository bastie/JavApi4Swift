/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// StrictMath (Java 1.3) uses the same Foundation functions as Math, but
// its constants are fixed Javadoc literals — not Double.pi / M_E — to
// guarantee bit-exact reproducibility across platforms.

private let epsilon = 1e-10

// MARK: - Constants (exact Javadoc values)

struct JavApi_lang_StrictMath_constants_Tests {

  @Test("PI is the exact Javadoc literal 3.141592653589793")
  func testPI() {
    #expect(StrictMath.PI == 3.141592653589793)
  }

  @Test("E is the exact Javadoc literal 2.718281828459045")
  func testE() {
    #expect(StrictMath.E == 2.718281828459045)
  }

  @Test("TAU is the exact Javadoc literal 6.283185307179586")
  func testTAU() {
    #expect(StrictMath.TAU == 6.283185307179586)
  }

  @Test("TAU == 2 * PI")
  func testTAUisTwoPi() {
    #expect(abs(StrictMath.TAU - 2 * StrictMath.PI) < epsilon)
  }
}

// MARK: - abs / absExact

struct JavApi_lang_StrictMath_abs_Tests {

  @Test("abs(Double): negative, positive, zero, NaN, infinity")
  func testAbsDouble() {
    #expect(StrictMath.abs(-10.0) == 10.0)
    #expect(StrictMath.abs(10.0)  == 10.0)
    #expect(StrictMath.abs(0.0)   == 0.0)
    #expect(StrictMath.abs(Double.nan).isNaN)
    #expect(StrictMath.abs(Double.infinity)  == Double.infinity)
    #expect(StrictMath.abs(-Double.infinity) == Double.infinity)
  }

  @Test("abs(Int): negative, positive, zero")
  func testAbsInt() {
    #expect(StrictMath.abs(-10) == 10)
    #expect(StrictMath.abs(10)  == 10)
    #expect(StrictMath.abs(0)   == 0)
  }

  @Test("abs(Int64): negative, positive, zero")
  func testAbsLong() {
    #expect(StrictMath.abs(Int64(-10)) == 10)
    #expect(StrictMath.abs(Int64(10))  == 10)
    #expect(StrictMath.abs(Int64(0))   == 0)
  }

  @Test("absExact(Int): positive value")
  func testAbsExactInt() throws {
    #expect(try StrictMath.absExact(-42) == 42)
    #expect(try StrictMath.absExact(42)  == 42)
    #expect(try StrictMath.absExact(0)   == 0)
  }

  @Test("absExact(Int.min) throws ArithmeticException")
  func testAbsExactIntOverflow() {
    #expect(throws: ArithmeticException.self) {
      try StrictMath.absExact(Int.min)
    }
  }

  @Test("absExact(Int64.min) throws ArithmeticException")
  func testAbsExactLongOverflow() {
    #expect(throws: ArithmeticException.self) {
      try StrictMath.absExact(Int64.min)
    }
  }
}

// MARK: - addExact / subtractExact / multiplyExact / negateExact

struct JavApi_lang_StrictMath_exactArith_Tests {

  @Test("addExact: normal addition")
  func testAddExact() throws {
    #expect(try StrictMath.addExact(3, 4)           == 7)
    #expect(try StrictMath.addExact(-10, 3)         == -7)
    #expect(try StrictMath.addExact(Int64(5), Int64(6)) == 11)
  }

  @Test("addExact overflows throw ArithmeticException")
  func testAddExactOverflow() {
    #expect(throws: ArithmeticException.self) { try StrictMath.addExact(Int.max, 1) }
    #expect(throws: ArithmeticException.self) { try StrictMath.addExact(Int.min, -1) }
  }

  @Test("subtractExact: normal subtraction")
  func testSubtractExact() throws {
    #expect(try StrictMath.subtractExact(10, 3) == 7)
    #expect(try StrictMath.subtractExact(0, 5)  == -5)
  }

  @Test("subtractExact overflows throw ArithmeticException")
  func testSubtractExactOverflow() {
    #expect(throws: ArithmeticException.self) { try StrictMath.subtractExact(Int.min, 1) }
    #expect(throws: ArithmeticException.self) { try StrictMath.subtractExact(Int.max, -1) }
  }

  @Test("multiplyExact: normal multiplication")
  func testMultiplyExact() throws {
    #expect(try StrictMath.multiplyExact(6, 7)               == 42)
    #expect(try StrictMath.multiplyExact(Int64(100), Int64(200)) == 20000)
  }

  @Test("multiplyExact overflow throws ArithmeticException")
  func testMultiplyExactOverflow() {
    #expect(throws: ArithmeticException.self) { try StrictMath.multiplyExact(Int.max, 2) }
  }

  @Test("negateExact: normal negation")
  func testNegateExact() throws {
    #expect(try StrictMath.negateExact(42)   == -42)
    #expect(try StrictMath.negateExact(-42)  == 42)
    #expect(try StrictMath.negateExact(0)    == 0)
  }

  @Test("negateExact(Int.min) throws ArithmeticException")
  func testNegateExactOverflow() {
    #expect(throws: ArithmeticException.self) { try StrictMath.negateExact(Int.min) }
    #expect(throws: ArithmeticException.self) { try StrictMath.negateExact(Int64.min) }
  }

  @Test("incrementExact / decrementExact: normal cases")
  func testIncrementDecrement() throws {
    #expect(try StrictMath.incrementExact(5)   == 6)
    #expect(try StrictMath.decrementExact(5)   == 4)
    #expect(try StrictMath.incrementExact(Int64(-1)) == 0)
    #expect(try StrictMath.decrementExact(Int64(1))  == 0)
  }

  @Test("incrementExact(Int.max) and decrementExact(Int.min) throw")
  func testIncrementDecrementOverflow() {
    #expect(throws: ArithmeticException.self) { try StrictMath.incrementExact(Int.max) }
    #expect(throws: ArithmeticException.self) { try StrictMath.decrementExact(Int.min) }
  }

  @Test("toIntExact: values within Int range")
  func testToIntExact() throws {
    #expect(try StrictMath.toIntExact(Int64(42))       == 42)
    #expect(try StrictMath.toIntExact(Int64(-100))     == -100)
    #expect(try StrictMath.toIntExact(Int64(Int.max))  == Int.max)
    #expect(try StrictMath.toIntExact(Int64(Int.min))  == Int.min)
  }

  @Test("toIntExact: out of Int range throws")
  func testToIntExactOverflow() {
    // On 64-bit platforms Int == Int64 so this is the platform limit itself;
    // still test the guard path via a value just above Int32 max for safety.
    // On all platforms Int64.max > Int.max when Int is 32-bit.
    if Int.max < Int64.max {
      #expect(throws: ArithmeticException.self) {
        try StrictMath.toIntExact(Int64(Int.max) + 1)
      }
    }
  }
}

// MARK: - divideExact

struct JavApi_lang_StrictMath_divideExact_Tests {

  @Test("divideExact: exact division")
  func testDivideExact() throws {
    #expect(try StrictMath.divideExact(10, 2) == 5)
    #expect(try StrictMath.divideExact(-12, 3) == -4)
    #expect(try StrictMath.divideExact(Int64(100), Int64(4)) == 25)
  }

  @Test("divideExact: non-exact division throws")
  func testDivideExactNotExact() {
    #expect(throws: ArithmeticException.self) { try StrictMath.divideExact(10, 3) }
  }

  @Test("divideExact: division by zero throws")
  func testDivideExactByZero() {
    #expect(throws: ArithmeticException.self) { try StrictMath.divideExact(5, 0) }
  }

  @Test("divideExact: Int.min / -1 throws (overflow)")
  func testDivideExactMinOverflow() {
    #expect(throws: ArithmeticException.self) { try StrictMath.divideExact(Int.min, -1) }
  }
}

// MARK: - floorDiv / floorMod / ceilDiv / ceilMod

struct JavApi_lang_StrictMath_divMod_Tests {

  @Test("floorDiv: truncates toward negative infinity")
  func testFloorDiv() throws {
    #expect(try StrictMath.floorDiv(7, 2)   == 3)
    #expect(try StrictMath.floorDiv(-7, 2)  == -4)   // Java spec: floor(-3.5) = -4
    #expect(try StrictMath.floorDiv(7, -2)  == -4)
    #expect(try StrictMath.floorDiv(-7, -2) == 3)
    #expect(try StrictMath.floorDiv(Int64(10), Int64(3)) == 3)
  }

  @Test("floorDiv by zero throws")
  func testFloorDivByZero() {
    #expect(throws: ArithmeticException.self) { try StrictMath.floorDiv(5, 0) }
  }

  @Test("floorMod: result has same sign as divisor")
  func testFloorMod() throws {
    #expect(try StrictMath.floorMod(7, 3)   == 1)
    #expect(try StrictMath.floorMod(-7, 3)  == 2)   // -7 = (-4)*3 + 2
    #expect(try StrictMath.floorMod(7, -3)  == -2)  // 7 = (-3)*(-3) + (-2)
    #expect(try StrictMath.floorMod(-7, -3) == -1)
  }

  @Test("ceilDiv: truncates toward positive infinity")
  func testCeilDiv() throws {
    #expect(try StrictMath.ceilDiv(7, 2)   == 4)    // ceil(3.5) = 4
    #expect(try StrictMath.ceilDiv(-7, 2)  == -3)   // ceil(-3.5) = -3
    #expect(try StrictMath.ceilDiv(6, 2)   == 3)    // exact
    #expect(try StrictMath.ceilDiv(Int64(-7), Int64(2)) == -3)
  }

  @Test("ceilDiv by zero throws")
  func testCeilDivByZero() {
    #expect(throws: ArithmeticException.self) { try StrictMath.ceilDiv(5, 0) }
  }

  @Test("ceilMod: result has opposite sign of divisor")
  func testCeilMod() throws {
    #expect(try StrictMath.ceilMod(7, 3)   == -2)   // 7 = 4*3 + (-2) → ceilDiv(7,3)=3? No: 7/3=2.33→ceil=3, 7-3*3=-2
    #expect(try StrictMath.ceilMod(-7, 3)  == -1)
    #expect(try StrictMath.ceilMod(6, 3)   == 0)    // exact
  }
}

// MARK: - clamp

struct JavApi_lang_StrictMath_clamp_Tests {

  @Test("clamp(Double): within, below, above range")
  func testClampDouble() {
    #expect(StrictMath.clamp(5.0, 1.0, 10.0)  == 5.0)
    #expect(StrictMath.clamp(-5.0, 1.0, 10.0) == 1.0)
    #expect(StrictMath.clamp(15.0, 1.0, 10.0) == 10.0)
  }

  @Test("clamp(Int64): within, below, above range")
  func testClampLong() {
    #expect(StrictMath.clamp(Int64(5), Int64(1), Int64(10))  == 5)
    #expect(StrictMath.clamp(Int64(-5), Int64(1), Int64(10)) == 1)
    #expect(StrictMath.clamp(Int64(15), Int64(1), Int64(10)) == 10)
  }

  @Test("clamp(Int): within, below, above range")
  func testClampInt() {
    #expect(StrictMath.clamp(5, 1, 10)  == 5)
    #expect(StrictMath.clamp(-5, 1, 10) == 1)
    #expect(StrictMath.clamp(15, 1, 10) == 10)
  }
}

// MARK: - copySign

struct JavApi_lang_StrictMath_copySign_Tests {

  @Test("copySign(Double): magnitude with given sign")
  func testCopySignDouble() {
    #expect(StrictMath.copySign(3.0,  1.0) ==  3.0)
    #expect(StrictMath.copySign(3.0, -1.0) == -3.0)
    #expect(StrictMath.copySign(-3.0, 1.0) ==  3.0)
  }

  @Test("copySign(Float): magnitude with given sign")
  func testCopySignFloat() {
    #expect(StrictMath.copySign(Float(3.0),  Float(1.0)) ==  Float(3.0))
    #expect(StrictMath.copySign(Float(3.0), Float(-1.0)) == Float(-3.0))
  }
}

// MARK: - multiplyFull / multiplyHigh

struct JavApi_lang_StrictMath_multiply_Tests {

  @Test("multiplyFull: Int32 × Int32 → Int64 without overflow")
  func testMultiplyFull() {
    #expect(StrictMath.multiplyFull(Int32(100_000), Int32(100_000)) == 10_000_000_000)
    #expect(StrictMath.multiplyFull(Int32.max, Int32.max)           == Int64(Int32.max) * Int64(Int32.max))
    #expect(StrictMath.multiplyFull(Int32(-3), Int32(4))            == -12)
  }

  @Test("multiplyHigh: high 64 bits of Int64 × Int64")
  func testMultiplyHigh() {
    // Small values: high word is 0 (product fits in 64 bits)
    #expect(StrictMath.multiplyHigh(Int64(2), Int64(3)) == 0)
    // Int64.max * Int64.max = 2^126 - 2^64 + 1
    // high 64 bits (signed) = 2^62 - 1 = 4611686018427387903
    #expect(StrictMath.multiplyHigh(Int64.max, Int64.max) == 4611686018427387903)
  }
}

// MARK: - hypot

struct JavApi_lang_StrictMath_hypot_Tests {

  @Test("hypot(3,4) == 5 (Pythagorean triple)")
  func testHypot() {
    #expect(abs(StrictMath.hypot(3.0, 4.0) - 5.0) < epsilon)
    #expect(StrictMath.hypot(0.0, 0.0) == 0.0)
    #expect(StrictMath.hypot(Double.infinity, 0.0) == Double.infinity)
  }
}

// MARK: - fma

struct JavApi_lang_StrictMath_fma_Tests {

  @Test("fma(Double): a*b+c in one operation")
  func testFmaDouble() {
    #expect(abs(StrictMath.fma(2.0, 3.0, 4.0) - 10.0) < epsilon)
    #expect(abs(StrictMath.fma(-1.0, 5.0, 3.0) - (-2.0)) < epsilon)
  }

  @Test("fma(Float): a*b+c in one operation")
  func testFmaFloat() {
    #expect(abs(Double(StrictMath.fma(Float(2.0), Float(3.0), Float(4.0))) - 10.0) < 1e-6)
  }
}

// MARK: - getExponent

struct JavApi_lang_StrictMath_getExponent_Tests {

  @Test("getExponent(Double): known values")
  func testGetExponentDouble() {
    #expect(StrictMath.getExponent(1.0)  == 0)   // 2^0 = 1.0
    #expect(StrictMath.getExponent(2.0)  == 1)   // 2^1 = 2.0
    #expect(StrictMath.getExponent(4.0)  == 2)   // 2^2 = 4.0
    #expect(StrictMath.getExponent(0.5)  == -1)  // 2^-1 = 0.5
  }

  @Test("getExponent(Float): known values")
  func testGetExponentFloat() {
    #expect(StrictMath.getExponent(Float(1.0)) == 0)
    #expect(StrictMath.getExponent(Float(2.0)) == 1)
  }
}

// MARK: - nextAfter / nextUp / nextDown

struct JavApi_lang_StrictMath_nextFloat_Tests {

  @Test("nextUp(Double): positive step from 1.0")
  func testNextUpDouble() {
    let v = StrictMath.nextUp(1.0)
    #expect(v > 1.0)
    #expect(v < 1.0 + 1e-15)  // adjacent — only 1 ULP away
  }

  @Test("nextDown(Double): negative step from 1.0")
  func testNextDownDouble() {
    let v = StrictMath.nextDown(1.0)
    #expect(v < 1.0)
    #expect(v > 1.0 - 1e-15)
  }

  @Test("nextUp(Double) and nextDown(Double) are inverse for non-special values")
  func testNextUpDownInverse() {
    let original = 3.14
    #expect(StrictMath.nextDown(StrictMath.nextUp(original)) == original)
  }

  @Test("nextUp(Double.infinity) == infinity")
  func testNextUpInfinity() {
    #expect(StrictMath.nextUp(Double.infinity) == Double.infinity)
  }

  @Test("nextAfter: moves toward direction")
  func testNextAfter() {
    let up   = StrictMath.nextAfter(1.0, 2.0)
    let down = StrictMath.nextAfter(1.0, 0.0)
    #expect(up > 1.0)
    #expect(down < 1.0)
    // nextAfter(x, x) == x
    #expect(StrictMath.nextAfter(1.0, 1.0) == 1.0)
  }
}

// MARK: - scalb

struct JavApi_lang_StrictMath_scalb_Tests {

  @Test("scalb(Double): x * 2^n")
  func testScalbDouble() {
    #expect(StrictMath.scalb(1.0, 3)  == 8.0)   // 1 * 2^3 = 8
    #expect(StrictMath.scalb(1.0, -1) == 0.5)   // 1 * 2^-1 = 0.5
    #expect(StrictMath.scalb(3.0, 2)  == 12.0)
  }

  @Test("scalb(Float): x * 2^n")
  func testScalbFloat() {
    #expect(StrictMath.scalb(Float(1.0), 3)  == Float(8.0))
    #expect(StrictMath.scalb(Float(1.0), -1) == Float(0.5))
  }
}

// MARK: - signum

struct JavApi_lang_StrictMath_signum_Tests {

  @Test("signum(Double): -1/0/+1 and NaN")
  func testSignumDouble() {
    #expect(StrictMath.signum(-5.0)       == -1.0)
    #expect(StrictMath.signum(0.0)        ==  0.0)
    #expect(StrictMath.signum(5.0)        ==  1.0)
    #expect(StrictMath.signum(Double.nan).isNaN)
  }

  @Test("signum(Float): -1/0/+1 and NaN")
  func testSignumFloat() {
    #expect(StrictMath.signum(Float(-3.0)) == Float(-1.0))
    #expect(StrictMath.signum(Float(0.0))  == Float(0.0))
    #expect(StrictMath.signum(Float(3.0))  == Float(1.0))
    #expect(StrictMath.signum(Float.nan).isNaN)
  }
}

// MARK: - ulp

struct JavApi_lang_StrictMath_ulp_Tests {

  @Test("ulp(Double): 1.0 has ulp == Double.ulpOfOne (2^-52)")
  func testUlpDouble() {
    #expect(StrictMath.ulp(1.0) == Double.ulpOfOne)
    #expect(StrictMath.ulp(2.0) == Double.ulpOfOne * 2)
    #expect(StrictMath.ulp(Double.infinity) == Double.infinity)
  }

  @Test("ulp(Float): 1.0 has ulp == Float.ulpOfOne")
  func testUlpFloat() {
    #expect(StrictMath.ulp(Float(1.0)) == Float.ulpOfOne)
    #expect(StrictMath.ulp(Float(2.0)) == Float.ulpOfOne * 2)
  }
}

// MARK: - Trigonometry

struct JavApi_lang_StrictMath_trig_Tests {

  @Test("sin(0)==0, sin(PI/2)==1, sin(PI)≈0")
  func testSin() {
    #expect(StrictMath.sin(0.0) == 0.0)
    #expect(abs(StrictMath.sin(StrictMath.PI / 2) - 1.0) < epsilon)
    #expect(abs(StrictMath.sin(StrictMath.PI))           < epsilon)
  }

  @Test("cos(0)==1, cos(PI/2)≈0, cos(PI)==-1")
  func testCos() {
    #expect(StrictMath.cos(0.0) == 1.0)
    #expect(abs(StrictMath.cos(StrictMath.PI / 2))        < epsilon)
    #expect(abs(StrictMath.cos(StrictMath.PI) - (-1.0))   < epsilon)
  }

  @Test("tan(0)==0, tan(PI/4)≈1")
  func testTan() {
    #expect(StrictMath.tan(0.0) == 0.0)
    #expect(abs(StrictMath.tan(StrictMath.PI / 4) - 1.0) < epsilon)
  }

  @Test("asin(0)==0, asin(1)==PI/2")
  func testAsin() {
    #expect(StrictMath.asin(0.0) == 0.0)
    #expect(abs(StrictMath.asin(1.0) - StrictMath.PI / 2) < epsilon)
  }

  @Test("acos(1)==0, acos(0)==PI/2")
  func testAcos() {
    #expect(StrictMath.acos(1.0) == 0.0)
    #expect(abs(StrictMath.acos(0.0) - StrictMath.PI / 2) < epsilon)
  }

  @Test("atan(0)==0, atan(1)==PI/4")
  func testAtan() {
    #expect(StrictMath.atan(0.0) == 0.0)
    #expect(abs(StrictMath.atan(1.0) - StrictMath.PI / 4) < epsilon)
  }

  @Test("atan2(0,1)==0, atan2(1,0)==PI/2, atan2(1,1)==PI/4")
  func testAtan2() {
    #expect(StrictMath.atan2(0.0, 1.0) == 0.0)
    #expect(abs(StrictMath.atan2(1.0, 0.0) - StrictMath.PI / 2) < epsilon)
    #expect(abs(StrictMath.atan2(1.0, 1.0) - StrictMath.PI / 4) < epsilon)
  }

  @Test("IEEEremainder: f1 - round(f1/f2)*f2")
  func testIEEEremainder() {
    #expect(abs(StrictMath.IEEEremainder(10.0, 3.0) - 1.0)    < epsilon)
    #expect(abs(StrictMath.IEEEremainder(3.0,  2.0) - (-1.0)) < epsilon)
    #expect(StrictMath.IEEEremainder(0.0, 1.0) == 0.0)
  }
}

// MARK: - Exponential / Logarithmic

struct JavApi_lang_StrictMath_explog_Tests {

  @Test("exp(0)==1, exp(1)==E")
  func testExp() {
    #expect(StrictMath.exp(0.0) == 1.0)
    #expect(abs(StrictMath.exp(1.0) - StrictMath.E) < epsilon)
  }

  @Test("log(1)==0, log(E)==1")
  func testLog() {
    #expect(StrictMath.log(1.0) == 0.0)
    #expect(abs(StrictMath.log(StrictMath.E) - 1.0) < epsilon)
  }

  @Test("sqrt(0)==0, sqrt(4)==2, sqrt(-1).isNaN")
  func testSqrt() {
    #expect(StrictMath.sqrt(0.0) == 0.0)
    #expect(StrictMath.sqrt(4.0) == 2.0)
    #expect(StrictMath.sqrt(-1.0).isNaN)
  }

  @Test("pow(2,10)==1024, pow(0,0)==1")
  func testPow() {
    #expect(StrictMath.pow(2.0, 10.0) == 1024.0)
    #expect(StrictMath.pow(0.0, 0.0)  == 1.0)
  }

  @Test("cbrt(8)==2, cbrt(-8)==-2, cbrt(0)==0")
  func testCbrt() {
    #expect(abs(StrictMath.cbrt(8.0) - 2.0) < epsilon)
    #expect(abs(StrictMath.cbrt(-8.0) - (-2.0)) < epsilon)
    #expect(StrictMath.cbrt(0.0) == 0.0)
  }
}

// MARK: - Rounding

struct JavApi_lang_StrictMath_rounding_Tests {

  @Test("ceil: positive fraction → next int")
  func testCeil() {
    #expect(StrictMath.ceil(1.1)  == 2.0)
    #expect(StrictMath.ceil(-1.1) == -1.0)
  }

  @Test("floor: positive fraction → truncate")
  func testFloor() {
    #expect(StrictMath.floor(1.9)  == 1.0)
    #expect(StrictMath.floor(-1.1) == -2.0)
  }

  @Test("rint: round half-to-even")
  func testRint() {
    #expect(StrictMath.rint(0.5)  == 0.0)
    #expect(StrictMath.rint(1.5)  == 2.0)
    #expect(StrictMath.rint(2.5)  == 2.0)
    #expect(StrictMath.rint(-1.5) == -2.0)
  }

  @Test("round(Double) → Int64: half-up")
  func testRoundDouble() {
    #expect(StrictMath.round(0.5)  == Int64(1))
    #expect(StrictMath.round(-0.5) == Int64(0))
    #expect(StrictMath.round(1.5)  == Int64(2))
  }

  @Test("round(Float) → Int: half-up")
  func testRoundFloat() {
    #expect(StrictMath.round(Float(0.5))  == 1)
    #expect(StrictMath.round(Float(1.5))  == 2)
    #expect(StrictMath.round(Float(-0.5)) == 0)
  }
}

// MARK: - min / max

struct JavApi_lang_StrictMath_minmax_Tests {

  @Test("min / max for Int")
  func testMinMaxInt() {
    #expect(StrictMath.min(3, 5)  == 3)
    #expect(StrictMath.max(3, 5)  == 5)
  }

  @Test("min / max for Double")
  func testMinMaxDouble() {
    #expect(StrictMath.min(1.0, 2.0) == 1.0)
    #expect(StrictMath.max(1.0, 2.0) == 2.0)
  }
}

// MARK: - toRadians / toDegrees

struct JavApi_lang_StrictMath_conversion_Tests {

  @Test("toRadians(180) == PI")
  func testToRadians() {
    #expect(abs(StrictMath.toRadians(180.0) - StrictMath.PI) < epsilon)
  }

  @Test("toDegrees(PI) == 180  — regression: must divide by PI/180, not multiply")
  func testToDegrees() {
    #expect(abs(StrictMath.toDegrees(StrictMath.PI) - 180.0) < epsilon)
  }

  @Test("toRadians and toDegrees are inverse operations")
  func testRoundTrip() {
    let angle = 42.0
    #expect(abs(StrictMath.toDegrees(StrictMath.toRadians(angle)) - angle) < epsilon)
  }
}

// MARK: - random

struct JavApi_lang_StrictMath_random_Tests {

  @Test("random() returns values in [0.0, 1.0)")
  func testRandom() {
    for _ in 0..<100 {
      let r = StrictMath.random()
      #expect(r >= 0.0 && r < 1.0)
    }
  }
}

// MARK: - NaN / Infinity special values (Harmony-parity)

struct JavApi_lang_StrictMath_special_Tests {

  // abs(MIN_VALUE) wraps silently — no exception, unlike absExact
  @Test("abs(Int.min) wraps silently — Java spec, no exception")
  func testAbsIntMin() {
    #expect(StrictMath.abs(Int.min) == Int.min)
  }
  @Test("abs(Int64.min) wraps silently — Java spec, no exception")
  func testAbsLongMin() {
    #expect(StrictMath.abs(Int64.min) == Int64.min)
  }

  // Trig NaN/infinity
  @Test("sin/cos/tan: NaN and ±infinity inputs → NaN")
  func testTrigSpecial() {
    #expect(StrictMath.sin(Double.nan).isNaN)
    #expect(StrictMath.sin(Double.infinity).isNaN)
    #expect(StrictMath.sin(-Double.infinity).isNaN)
    #expect(StrictMath.cos(Double.nan).isNaN)
    #expect(StrictMath.cos(Double.infinity).isNaN)
    #expect(StrictMath.tan(Double.nan).isNaN)
    #expect(StrictMath.tan(Double.infinity).isNaN)
  }

  @Test("asin/acos: domain outside [-1,1] and NaN → NaN")
  func testAsinAcosSpecial() {
    #expect(StrictMath.asin(Double.nan).isNaN)
    #expect(StrictMath.asin(2.0).isNaN)
    #expect(StrictMath.acos(Double.nan).isNaN)
    #expect(StrictMath.acos(2.0).isNaN)
  }

  @Test("atan(NaN)==NaN, atan(±inf)==±PI/2; atan2(NaN,x)==NaN")
  func testAtanSpecial() {
    #expect(StrictMath.atan(Double.nan).isNaN)
    #expect(abs(StrictMath.atan(Double.infinity)  -  StrictMath.PI / 2) < epsilon)
    #expect(abs(StrictMath.atan(-Double.infinity) - -StrictMath.PI / 2) < epsilon)
    #expect(StrictMath.atan2(Double.nan, 1.0).isNaN)
    #expect(StrictMath.atan2(1.0, Double.nan).isNaN)
  }

  // exp/log/sqrt NaN/infinity
  @Test("exp(NaN)==NaN, exp(+inf)==+inf, exp(-inf)==0")
  func testExpSpecial() {
    #expect(StrictMath.exp(Double.nan).isNaN)
    #expect(StrictMath.exp(Double.infinity)  == Double.infinity)
    #expect(StrictMath.exp(-Double.infinity) == 0.0)
  }

  @Test("log(0)==-inf, log(negative)==NaN, log(NaN)==NaN, log(+inf)==+inf")
  func testLogSpecial() {
    #expect(StrictMath.log(0.0) == -Double.infinity)
    #expect(StrictMath.log(-1.0).isNaN)
    #expect(StrictMath.log(Double.nan).isNaN)
    #expect(StrictMath.log(Double.infinity) == Double.infinity)
  }

  @Test("log10(0)==-inf, log10(negative)==NaN, log10(+inf)==+inf")
  func testLog10Special() {
    #expect(StrictMath.log10(0.0) == -Double.infinity)
    #expect(StrictMath.log10(-1.0).isNaN)
    #expect(StrictMath.log10(Double.infinity) == Double.infinity)
  }

  @Test("log1p(-1)==-inf, log1p(below -1)==NaN, log1p(+inf)==+inf")
  func testLog1pSpecial() {
    #expect(StrictMath.log1p(-1.0) == -Double.infinity)
    #expect(StrictMath.log1p(-2.0).isNaN)
    #expect(StrictMath.log1p(Double.infinity) == Double.infinity)
  }

  @Test("expm1(NaN)==NaN, expm1(+inf)==+inf, expm1(-inf)==-1")
  func testExpm1Special() {
    #expect(StrictMath.expm1(Double.nan).isNaN)
    #expect(StrictMath.expm1(Double.infinity)  == Double.infinity)
    #expect(StrictMath.expm1(-Double.infinity) == -1.0)
  }

  @Test("sqrt(NaN)==NaN, sqrt(+inf)==+inf")
  func testSqrtSpecial() {
    #expect(StrictMath.sqrt(Double.nan).isNaN)
    #expect(StrictMath.sqrt(Double.infinity) == Double.infinity)
  }

  @Test("cbrt(NaN)==NaN, cbrt(±inf)==±inf")
  func testCbrtSpecial() {
    #expect(StrictMath.cbrt(Double.nan).isNaN)
    #expect(StrictMath.cbrt(Double.infinity)  == Double.infinity)
    #expect(StrictMath.cbrt(-Double.infinity) == -Double.infinity)
  }

  // pow IEEE 754 special cases
  @Test("pow: NaN rules — pow(NaN,0)==1, pow(1,NaN)==1, pow(NaN,y≠0)==NaN")
  func testPowNaN() {
    #expect(StrictMath.pow(Double.nan, 0.0) == 1.0)
    #expect(StrictMath.pow(1.0, Double.nan) == 1.0)
    #expect(StrictMath.pow(Double.nan, 2.0).isNaN)
    #expect(StrictMath.pow(2.0, Double.nan).isNaN)
  }

  @Test("pow: zero base rules")
  func testPowZeroBase() {
    #expect(StrictMath.pow(0.0,  -1.0) == Double.infinity)
    #expect(StrictMath.pow(0.0,   2.0) == 0.0)
    #expect(StrictMath.pow(-0.0, -3.0) == -Double.infinity)
    #expect(StrictMath.pow(-0.0, -2.0) ==  Double.infinity)
    let negZeroOdd = StrictMath.pow(-0.0, 3.0)
    #expect(negZeroOdd == 0.0 && negZeroOdd.sign == .minus)
    #expect(StrictMath.pow(-0.0, 2.0) == 0.0)
  }

  @Test("pow: negative base non-integer exponent → NaN")
  func testPowNegBaseNonInt() {
    #expect(StrictMath.pow(-2.0, 0.5).isNaN)
  }

  @Test("pow: ±1 with infinity exponent → 1.0")
  func testPowOneInf() {
    #expect(StrictMath.pow(1.0,   Double.infinity) == 1.0)
    #expect(StrictMath.pow(-1.0,  Double.infinity) == 1.0)
    #expect(StrictMath.pow(1.0,  -Double.infinity) == 1.0)
    #expect(StrictMath.pow(-1.0, -Double.infinity) == 1.0)
  }

  @Test("pow: |x|<1 and |x|>1 with ±infinity exponent")
  func testPowInfExp() {
    #expect(StrictMath.pow(0.5,  Double.infinity)  == 0.0)
    #expect(StrictMath.pow(2.0,  Double.infinity)  == Double.infinity)
    #expect(StrictMath.pow(0.5, -Double.infinity)  == Double.infinity)
    #expect(StrictMath.pow(2.0, -Double.infinity)  == 0.0)
  }

  @Test("pow: ±infinity base")
  func testPowInfBase() {
    #expect(StrictMath.pow(Double.infinity,   2.0) == Double.infinity)
    #expect(StrictMath.pow(Double.infinity,  -2.0) == 0.0)
    #expect(StrictMath.pow(-Double.infinity,  3.0) == -Double.infinity)
    #expect(StrictMath.pow(-Double.infinity,  2.0) ==  Double.infinity)
    #expect(StrictMath.pow(-Double.infinity, -2.0) ==  0.0)
  }

  // hypot special
  @Test("hypot(inf,NaN)==inf — Java spec: infinity dominates NaN")
  func testHypotSpecial() {
    #expect(StrictMath.hypot(Double.infinity, Double.nan) == Double.infinity)
    #expect(StrictMath.hypot(Double.nan, Double.infinity) == Double.infinity)
    #expect(StrictMath.hypot(Double.nan, Double.nan).isNaN)
  }

  // ceil/floor with NaN and -0
  @Test("ceil(NaN)==NaN, ceil(±inf)==±inf, ceil(-0.0)==-0.0")
  func testCeilSpecial() {
    #expect(StrictMath.ceil(Double.nan).isNaN)
    #expect(StrictMath.ceil(Double.infinity)  == Double.infinity)
    #expect(StrictMath.ceil(-Double.infinity) == -Double.infinity)
    let negZeroCeil = StrictMath.ceil(-0.0)
    #expect(negZeroCeil == 0.0 && negZeroCeil.sign == .minus)
  }

  @Test("floor(NaN)==NaN, floor(±inf)==±inf, floor(-0.0)==-0.0")
  func testFloorSpecial() {
    #expect(StrictMath.floor(Double.nan).isNaN)
    #expect(StrictMath.floor(Double.infinity)  == Double.infinity)
    #expect(StrictMath.floor(-Double.infinity) == -Double.infinity)
    let negZeroFloor = StrictMath.floor(-0.0)
    #expect(negZeroFloor == 0.0 && negZeroFloor.sign == .minus)
  }

  @Test("rint(NaN)==NaN, rint(±inf)==±inf")
  func testRintSpecial() {
    #expect(StrictMath.rint(Double.nan).isNaN)
    #expect(StrictMath.rint(Double.infinity)  == Double.infinity)
    #expect(StrictMath.rint(-Double.infinity) == -Double.infinity)
  }

  @Test("round(NaN)==0, round(+inf)==Int64.max, round(-inf)==Int64.min")
  func testRoundSpecial() {
    #expect(StrictMath.round(Double.nan)       == Int64(0))
    #expect(StrictMath.round(Double.infinity)  == Int64.max)
    #expect(StrictMath.round(-Double.infinity) == Int64.min)
    #expect(StrictMath.round(Float.nan)        == 0)
  }

  // min/max NaN propagation
  @Test("min(NaN,x)==NaN and min(x,NaN)==NaN — Java spec")
  func testMinNaN() {
    #expect(StrictMath.min(Double.nan, 1.0).isNaN)
    #expect(StrictMath.min(1.0, Double.nan).isNaN)
  }

  @Test("max(NaN,x)==NaN and max(x,NaN)==NaN — Java spec")
  func testMaxNaN() {
    #expect(StrictMath.max(Double.nan, 1.0).isNaN)
    #expect(StrictMath.max(1.0, Double.nan).isNaN)
  }
}
