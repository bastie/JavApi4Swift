/*
 * SPDX-FileCopyrightText: 2025-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// Tolerance for floating-point comparisons (matches Apache Harmony test suite)
private let epsilon = 1e-10

// MARK: - abs

struct JavApi_lang_Math_abs_Tests {

  @Test("abs(Double): negative, positive, zero, NaN, infinity")
  func testAbsDouble() {
    #expect(Math.abs(-10.0) == 10.0)
    #expect(Math.abs(10.0)  == 10.0)
    #expect(Math.abs(0.0)   == 0.0)
    #expect(Math.abs(Double.nan).isNaN)
    #expect(Math.abs(Double.infinity)  == Double.infinity)
    #expect(Math.abs(-Double.infinity) == Double.infinity)
  }

  @Test("abs(Int): negative, positive, zero")
  func testAbsInt() {
    #expect(Math.abs(-10) == 10)
    #expect(Math.abs(10)  == 10)
    #expect(Math.abs(0)   == 0)
  }

  @Test("abs(Int64): negative, positive, zero")
  func testAbsLong() {
    #expect(Math.abs(Int64(-10)) == 10)
    #expect(Math.abs(Int64(10))  == 10)
    #expect(Math.abs(Int64(0))   == 0)
  }

  // Java spec: abs(Int.min) overflows silently — result is Int.min (negative).
  // No exception is thrown. This differs from StrictMath.absExact which throws.
  @Test("abs(Int.min) wraps silently — Java spec, no exception")
  func testAbsIntMin() {
    // The generic abs uses -1 * value which wraps on Int.min — Java behaviour
    let result = Math.abs(Int.min)
    #expect(result == Int.min)
  }

  @Test("abs(Int64.min) wraps silently — Java spec, no exception")
  func testAbsLongMin() {
    let result = Math.abs(Int64.min)
    #expect(result == Int64.min)
  }
}

// MARK: - Constants

struct JavApi_lang_Math_constants_Tests {

  @Test("PI matches Java specification value")
  func testPI() {
    #expect(Math.PI == 3.141592653589793)
  }

  @Test("E matches Java specification value")
  func testE() {
    #expect(Math.E == 2.718281828459045)
  }
}

// MARK: - Trigonometry

struct JavApi_lang_Math_trig_Tests {

  @Test("sin(0) == 0, sin(PI/2) == 1, sin(PI) ≈ 0")
  func testSin() {
    #expect(Math.sin(0.0) == 0.0)
    #expect(abs(Math.sin(Math.PI / 2) - 1.0) < epsilon)
    #expect(abs(Math.sin(Math.PI))           < epsilon)
  }

  @Test("sin(NaN)==NaN, sin(±infinity)==NaN")
  func testSinSpecial() {
    #expect(Math.sin(Double.nan).isNaN)
    #expect(Math.sin(Double.infinity).isNaN)
    #expect(Math.sin(-Double.infinity).isNaN)
  }

  @Test("cos(0) == 1, cos(PI/2) ≈ 0, cos(PI) == -1")
  func testCos() {
    #expect(Math.cos(0.0) == 1.0)
    #expect(abs(Math.cos(Math.PI / 2))        < epsilon)
    #expect(abs(Math.cos(Math.PI) - (-1.0))   < epsilon)
  }

  @Test("cos(NaN)==NaN, cos(±infinity)==NaN")
  func testCosSpecial() {
    #expect(Math.cos(Double.nan).isNaN)
    #expect(Math.cos(Double.infinity).isNaN)
    #expect(Math.cos(-Double.infinity).isNaN)
  }

  @Test("tan(0) == 0, tan(PI/4) ≈ 1")
  func testTan() {
    #expect(Math.tan(0.0) == 0.0)
    #expect(abs(Math.tan(Math.PI / 4) - 1.0) < epsilon)
  }

  @Test("tan(NaN)==NaN, tan(±infinity)==NaN")
  func testTanSpecial() {
    #expect(Math.tan(Double.nan).isNaN)
    #expect(Math.tan(Double.infinity).isNaN)
    #expect(Math.tan(-Double.infinity).isNaN)
  }

  @Test("asin(0) == 0, asin(1) == PI/2")
  func testAsin() {
    #expect(Math.asin(0.0) == 0.0)
    #expect(abs(Math.asin(1.0) - Math.PI / 2) < epsilon)
  }

  @Test("asin: domain outside [-1,1] → NaN; asin(NaN) → NaN")
  func testAsinSpecial() {
    #expect(Math.asin(Double.nan).isNaN)
    #expect(Math.asin(2.0).isNaN)
    #expect(Math.asin(-2.0).isNaN)
  }

  @Test("acos(1) == 0, acos(0) == PI/2")
  func testAcos() {
    #expect(Math.acos(1.0) == 0.0)
    #expect(abs(Math.acos(0.0) - Math.PI / 2) < epsilon)
  }

  @Test("acos: domain outside [-1,1] → NaN; acos(NaN) → NaN")
  func testAcosSpecial() {
    #expect(Math.acos(Double.nan).isNaN)
    #expect(Math.acos(2.0).isNaN)
    #expect(Math.acos(-2.0).isNaN)
  }

  @Test("atan(0) == 0, atan(1) == PI/4")
  func testAtan() {
    #expect(Math.atan(0.0) == 0.0)
    #expect(abs(Math.atan(1.0) - Math.PI / 4) < epsilon)
  }

  @Test("atan(NaN)==NaN, atan(±infinity)==±PI/2")
  func testAtanSpecial() {
    #expect(Math.atan(Double.nan).isNaN)
    #expect(abs(Math.atan(Double.infinity)  -  Math.PI / 2) < epsilon)
    #expect(abs(Math.atan(-Double.infinity) - -Math.PI / 2) < epsilon)
  }

  @Test("atan2(0,1)==0, atan2(1,0)==PI/2, atan2(1,1)==PI/4")
  func testAtan2() {
    #expect(Math.atan2(0.0, 1.0) == 0.0)
    #expect(abs(Math.atan2(1.0, 0.0) - Math.PI / 2) < epsilon)
    #expect(abs(Math.atan2(1.0, 1.0) - Math.PI / 4) < epsilon)
  }

  @Test("atan2(NaN,x)==NaN; atan2(y,NaN)==NaN; atan2(±inf,±inf)==±PI/4 variants")
  func testAtan2Special() {
    #expect(Math.atan2(Double.nan, 1.0).isNaN)
    #expect(Math.atan2(1.0, Double.nan).isNaN)
    // atan2(+inf, +inf) = PI/4
    #expect(abs(Math.atan2(Double.infinity, Double.infinity) - Math.PI / 4) < epsilon)
    // atan2(+inf, -inf) = 3*PI/4
    #expect(abs(Math.atan2(Double.infinity, -Double.infinity) - 3 * Math.PI / 4) < epsilon)
  }
}

// MARK: - Exponential / Logarithmic

struct JavApi_lang_Math_explog_Tests {

  @Test("exp(0) == 1, exp(1) == E")
  func testExp() {
    #expect(Math.exp(0.0) == 1.0)
    #expect(abs(Math.exp(1.0) - Math.E) < epsilon)
  }

  @Test("exp(NaN)==NaN, exp(+inf)==+inf, exp(-inf)==0")
  func testExpSpecial() {
    #expect(Math.exp(Double.nan).isNaN)
    #expect(Math.exp(Double.infinity) == Double.infinity)
    #expect(Math.exp(-Double.infinity) == 0.0)
  }

  @Test("log(1) == 0, log(E) == 1")
  func testLog() {
    #expect(Math.log(1.0) == 0.0)
    #expect(abs(Math.log(Math.E) - 1.0) < epsilon)
  }

  @Test("log(0)==-inf, log(negative)==NaN, log(NaN)==NaN, log(+inf)==+inf")
  func testLogSpecial() {
    #expect(Math.log(0.0) == -Double.infinity)
    #expect(Math.log(-1.0).isNaN)
    #expect(Math.log(Double.nan).isNaN)
    #expect(Math.log(Double.infinity) == Double.infinity)
  }

  @Test("log10(1)==0, log10(10)==1, log10(100)==2")
  func testLog10() {
    #expect(Math.log10(1.0) == 0.0)
    #expect(abs(Math.log10(10.0) - 1.0) < epsilon)
    #expect(abs(Math.log10(100.0) - 2.0) < epsilon)
  }

  @Test("log10(0)==-inf, log10(negative)==NaN, log10(NaN)==NaN, log10(+inf)==+inf")
  func testLog10Special() {
    #expect(Math.log10(0.0) == -Double.infinity)
    #expect(Math.log10(-1.0).isNaN)
    #expect(Math.log10(Double.nan).isNaN)
    #expect(Math.log10(Double.infinity) == Double.infinity)
  }

  @Test("log1p(0)==0, log1p(E-1)≈1")
  func testLog1p() {
    #expect(Math.log1p(0.0) == 0.0)
    #expect(abs(Math.log1p(Math.E - 1.0) - 1.0) < epsilon)
  }

  @Test("log1p(-1)==-inf, log1p(negative<-1)==NaN, log1p(NaN)==NaN, log1p(+inf)==+inf")
  func testLog1pSpecial() {
    #expect(Math.log1p(-1.0) == -Double.infinity)
    #expect(Math.log1p(-2.0).isNaN)
    #expect(Math.log1p(Double.nan).isNaN)
    #expect(Math.log1p(Double.infinity) == Double.infinity)
  }

  @Test("expm1(0)==0, expm1(1)==E-1")
  func testExpm1() {
    #expect(Math.expm1(0.0) == 0.0)
    #expect(abs(Math.expm1(1.0) - (Math.E - 1.0)) < epsilon)
  }

  @Test("expm1(NaN)==NaN, expm1(+inf)==+inf, expm1(-inf)==-1")
  func testExpm1Special() {
    #expect(Math.expm1(Double.nan).isNaN)
    #expect(Math.expm1(Double.infinity) == Double.infinity)
    #expect(Math.expm1(-Double.infinity) == -1.0)
  }

  @Test("sqrt(0)==0, sqrt(1)==1, sqrt(4)==2, sqrt(negative).isNaN")
  func testSqrt() {
    #expect(Math.sqrt(0.0) == 0.0)
    #expect(Math.sqrt(1.0) == 1.0)
    #expect(Math.sqrt(4.0) == 2.0)
    #expect(Math.sqrt(-1.0).isNaN)
  }

  @Test("sqrt(NaN)==NaN, sqrt(+inf)==+inf")
  func testSqrtSpecial() {
    #expect(Math.sqrt(Double.nan).isNaN)
    #expect(Math.sqrt(Double.infinity) == Double.infinity)
  }

  @Test("cbrt(8)==2, cbrt(-8)==-2, cbrt(0)==0")
  func testCbrt() {
    #expect(abs(Math.cbrt(8.0)  -  2.0) < epsilon)
    #expect(abs(Math.cbrt(-8.0) - -2.0) < epsilon)
    #expect(Math.cbrt(0.0) == 0.0)
  }

  @Test("cbrt(NaN)==NaN, cbrt(±inf)==±inf")
  func testCbrtSpecial() {
    #expect(Math.cbrt(Double.nan).isNaN)
    #expect(Math.cbrt(Double.infinity)  == Double.infinity)
    #expect(Math.cbrt(-Double.infinity) == -Double.infinity)
  }

  @Test("pow(2,10)==1024, pow(0,0)==1, pow(x,0)==1, pow(1,x)==1")
  func testPow() {
    #expect(Math.pow(2.0, 10.0) == 1024.0)
    #expect(Math.pow(0.0, 0.0)  == 1.0)
    #expect(Math.pow(5.0, 0.0)  == 1.0)
    #expect(Math.pow(1.0, 99.0) == 1.0)
    #expect(abs(Math.pow(-2.0, 3.0) - (-8.0)) < epsilon)  // negative base, integer odd
    #expect(abs(Math.pow(-2.5, 2.0) - 6.25) < epsilon)    // negative base, integer even
  }

  // IEEE 754 / Java spec edge cases for pow (Harmony MathTest covers all of these)
  @Test("pow: NaN rules — pow(NaN,0)==1, pow(1,NaN)==1, pow(NaN,y≠0)==NaN, pow(x≠1,NaN)==NaN")
  func testPowNaN() {
    #expect(Math.pow(Double.nan, 0.0) == 1.0)
    #expect(Math.pow(1.0, Double.nan) == 1.0)
    #expect(Math.pow(Double.nan, 2.0).isNaN)
    #expect(Math.pow(2.0, Double.nan).isNaN)
  }

  @Test("pow: zero base rules")
  func testPowZeroBase() {
    // pow(+0, negative) = +infinity
    #expect(Math.pow(0.0, -1.0) == Double.infinity)
    // pow(+0, positive) = 0
    #expect(Math.pow(0.0, 2.0) == 0.0)
    // pow(-0, negative odd) = -infinity
    #expect(Math.pow(-0.0, -3.0) == -Double.infinity)
    // pow(-0, negative even) = +infinity
    #expect(Math.pow(-0.0, -2.0) == Double.infinity)
    // pow(-0, positive odd) = -0
    let negZeroOdd = Math.pow(-0.0, 3.0)
    #expect(negZeroOdd == 0.0 && negZeroOdd.sign == .minus)
    // pow(-0, positive even) = +0
    #expect(Math.pow(-0.0, 2.0) == 0.0)
  }

  @Test("pow: negative base non-integer exponent → NaN")
  func testPowNegBaseNonInt() {
    #expect(Math.pow(-2.0, 0.5).isNaN)
    #expect(Math.pow(-3.0, 1.5).isNaN)
  }

  @Test("pow: ±1 with infinity exponent → 1.0")
  func testPowOneInf() {
    #expect(Math.pow(1.0,  Double.infinity) == 1.0)
    #expect(Math.pow(-1.0, Double.infinity) == 1.0)
    #expect(Math.pow(1.0, -Double.infinity) == 1.0)
    #expect(Math.pow(-1.0,-Double.infinity) == 1.0)
  }

  @Test("pow: |x|<1 and |x|>1 with ±infinity exponent")
  func testPowInfExp() {
    #expect(Math.pow(0.5,  Double.infinity) == 0.0)
    #expect(Math.pow(2.0,  Double.infinity) == Double.infinity)
    #expect(Math.pow(0.5, -Double.infinity) == Double.infinity)
    #expect(Math.pow(2.0, -Double.infinity) == 0.0)
  }

  @Test("pow: ±infinity base")
  func testPowInfBase() {
    #expect(Math.pow(Double.infinity,  2.0) == Double.infinity)
    #expect(Math.pow(Double.infinity, -2.0) == 0.0)
    #expect(Math.pow(-Double.infinity,  3.0) == -Double.infinity)  // odd
    #expect(Math.pow(-Double.infinity,  2.0) ==  Double.infinity)  // even
    #expect(Math.pow(-Double.infinity, -3.0) == -0.0)              // odd negative → -0
    #expect(Math.pow(-Double.infinity, -2.0) ==  0.0)              // even negative → +0
  }
}

// MARK: - hypot

struct JavApi_lang_Math_hypot_Tests {

  @Test("hypot(3,4)==5, hypot(0,0)==0")
  func testHypot() {
    #expect(abs(Math.hypot(3.0, 4.0) - 5.0) < epsilon)
    #expect(Math.hypot(0.0, 0.0) == 0.0)
  }

  @Test("hypot(inf,NaN)==inf — Java spec: infinity dominates NaN")
  func testHypotSpecial() {
    #expect(Math.hypot(Double.infinity, Double.nan) == Double.infinity)
    #expect(Math.hypot(Double.nan, Double.infinity) == Double.infinity)
    #expect(Math.hypot(Double.nan, Double.nan).isNaN)
    #expect(Math.hypot(Double.infinity, 0.0) == Double.infinity)
  }
}

// MARK: - Rounding

struct JavApi_lang_Math_rounding_Tests {

  @Test("ceil: positive fraction → next int, negative fraction → toward zero")
  func testCeil() {
    #expect(Math.ceil(1.1)  == 2.0)
    #expect(Math.ceil(1.0)  == 1.0)
    #expect(Math.ceil(-1.1) == -1.0)
  }

  @Test("ceil(NaN)==NaN, ceil(±inf)==±inf, ceil(-0.0)==-0.0")
  func testCeilSpecial() {
    #expect(Math.ceil(Double.nan).isNaN)
    #expect(Math.ceil(Double.infinity)  == Double.infinity)
    #expect(Math.ceil(-Double.infinity) == -Double.infinity)
    let negZeroCeil = Math.ceil(-0.0)
    #expect(negZeroCeil == 0.0 && negZeroCeil.sign == .minus)
  }

  @Test("floor: positive fraction → toward zero, negative fraction → next lower int")
  func testFloor() {
    #expect(Math.floor(1.9)  == 1.0)
    #expect(Math.floor(1.0)  == 1.0)
    #expect(Math.floor(-1.1) == -2.0)
  }

  @Test("floor(NaN)==NaN, floor(±inf)==±inf, floor(-0.0)==-0.0")
  func testFloorSpecial() {
    #expect(Math.floor(Double.nan).isNaN)
    #expect(Math.floor(Double.infinity)  == Double.infinity)
    #expect(Math.floor(-Double.infinity) == -Double.infinity)
    let negZeroFloor = Math.floor(-0.0)
    #expect(negZeroFloor == 0.0 && negZeroFloor.sign == .minus)
  }

  @Test("rint: round half-to-even (banker's rounding)")
  func testRint() {
    #expect(Math.rint(0.5)  == 0.0)   // round to even
    #expect(Math.rint(1.5)  == 2.0)   // round to even
    #expect(Math.rint(2.5)  == 2.0)   // round to even
    #expect(Math.rint(1.4)  == 1.0)
    #expect(Math.rint(-1.5) == -2.0)
  }

  @Test("rint(NaN)==NaN, rint(±inf)==±inf")
  func testRintSpecial() {
    #expect(Math.rint(Double.nan).isNaN)
    #expect(Math.rint(Double.infinity)  == Double.infinity)
    #expect(Math.rint(-Double.infinity) == -Double.infinity)
  }

  @Test("round(Double) → Int64: half-up rounding")
  func testRoundDouble() {
    #expect(Math.round(0.5)  == Int64(1))
    #expect(Math.round(-0.5) == Int64(0))   // Java: half-up, so -0.5 → 0
    #expect(Math.round(1.4)  == Int64(1))
    #expect(Math.round(1.5)  == Int64(2))
  }

  @Test("round(NaN)==0, round(+inf)==Int64.max, round(-inf)==Int64.min")
  func testRoundDoubleSpecial() {
    #expect(Math.round(Double.nan)         == Int64(0))
    #expect(Math.round(Double.infinity)    == Int64.max)
    #expect(Math.round(-Double.infinity)   == Int64.min)
  }

  @Test("round(Float) → Int: half-up rounding")
  func testRoundFloat() {
    #expect(Math.round(Float(0.5))  == 1)
    #expect(Math.round(Float(1.4))  == 1)
    #expect(Math.round(Float(1.5))  == 2)
    #expect(Math.round(Float(-0.5)) == 0)
  }

  @Test("round(Float NaN)==0")
  func testRoundFloatSpecial() {
    #expect(Math.round(Float.nan) == 0)
  }
}

// MARK: - IEEEremainder

struct JavApi_lang_Math_IEEEremainder_Tests {

  @Test("IEEEremainder: f1 - round(f1/f2)*f2")
  func testIEEEremainder() {
    // 10 / 3 = 3.333… → round = 3 → remainder = 10 - 9 = 1
    #expect(abs(Math.IEEEremainder(10.0, 3.0) - 1.0) < epsilon)
    // 3 / 2 = 1.5 → round-half-to-even = 2 → remainder = 3 - 4 = -1
    #expect(abs(Math.IEEEremainder(3.0, 2.0) - (-1.0)) < epsilon)
    #expect(Math.IEEEremainder(0.0, 1.0) == 0.0)
  }
}

// MARK: - min / max

struct JavApi_lang_Math_minmax_Tests {

  @Test("min / max for Int")
  func testMinMaxInt() {
    #expect(Math.min(3, 5)  == 3)
    #expect(Math.max(3, 5)  == 5)
    #expect(Math.min(-1, 0) == -1)
  }

  @Test("min / max for Double")
  func testMinMaxDouble() {
    #expect(Math.min(1.0, 2.0) == 1.0)
    #expect(Math.max(1.0, 2.0) == 2.0)
  }

  // Java spec: min/max with NaN always return NaN (unlike Swift.min which doesn't propagate NaN)
  @Test("min(NaN,x)==NaN and min(x,NaN)==NaN — Java spec, Swift.min does NOT do this")
  func testMinNaN() {
    #expect(Math.min(Double.nan, 1.0).isNaN)
    #expect(Math.min(1.0, Double.nan).isNaN)
    #expect(Math.min(Double.nan, Double.nan).isNaN)
  }

  @Test("max(NaN,x)==NaN and max(x,NaN)==NaN — Java spec")
  func testMaxNaN() {
    #expect(Math.max(Double.nan, 1.0).isNaN)
    #expect(Math.max(1.0, Double.nan).isNaN)
    #expect(Math.max(Double.nan, Double.nan).isNaN)
  }

  @Test("min/max with ±infinity")
  func testMinMaxInfinity() {
    #expect(Math.min(-Double.infinity, 0.0) == -Double.infinity)
    #expect(Math.max(Double.infinity,  0.0) ==  Double.infinity)
    #expect(Math.min(Double.infinity, -Double.infinity) == -Double.infinity)
    #expect(Math.max(Double.infinity, -Double.infinity) ==  Double.infinity)
  }
}

// MARK: - toRadians / toDegrees

struct JavApi_lang_Math_conversion_Tests {

  @Test("toRadians(180) == PI")
  func testToRadians() {
    #expect(abs(Math.toRadians(180.0) - Math.PI) < epsilon)
  }

  @Test("toDegrees(PI) == 180  — regression: toDegrees must divide by PI/180, not multiply")
  func testToDegrees() {
    #expect(abs(Math.toDegrees(Math.PI) - 180.0) < epsilon)
  }
}
