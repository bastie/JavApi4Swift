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

  @Test("cos(0) == 1, cos(PI/2) ≈ 0, cos(PI) == -1")
  func testCos() {
    #expect(Math.cos(0.0) == 1.0)
    #expect(abs(Math.cos(Math.PI / 2))        < epsilon)
    #expect(abs(Math.cos(Math.PI) - (-1.0))   < epsilon)
  }

  @Test("tan(0) == 0, tan(PI/4) ≈ 1")
  func testTan() {
    #expect(Math.tan(0.0) == 0.0)
    #expect(abs(Math.tan(Math.PI / 4) - 1.0) < epsilon)
  }

  @Test("asin(0) == 0, asin(1) == PI/2")
  func testAsin() {
    #expect(Math.asin(0.0) == 0.0)
    #expect(abs(Math.asin(1.0) - Math.PI / 2) < epsilon)
  }

  @Test("acos(1) == 0, acos(0) == PI/2")
  func testAcos() {
    #expect(Math.acos(1.0) == 0.0)
    #expect(abs(Math.acos(0.0) - Math.PI / 2) < epsilon)
  }

  @Test("atan(0) == 0, atan(1) == PI/4")
  func testAtan() {
    #expect(Math.atan(0.0) == 0.0)
    #expect(abs(Math.atan(1.0) - Math.PI / 4) < epsilon)
  }

  @Test("atan2(0,1)==0, atan2(1,0)==PI/2, atan2(1,1)==PI/4")
  func testAtan2() {
    #expect(Math.atan2(0.0, 1.0) == 0.0)
    #expect(abs(Math.atan2(1.0, 0.0) - Math.PI / 2) < epsilon)
    #expect(abs(Math.atan2(1.0, 1.0) - Math.PI / 4) < epsilon)
  }
}

// MARK: - Exponential / Logarithmic

struct JavApi_lang_Math_explog_Tests {

  @Test("exp(0) == 1, exp(1) == E")
  func testExp() {
    #expect(Math.exp(0.0) == 1.0)
    #expect(abs(Math.exp(1.0) - Math.E) < epsilon)
  }

  @Test("log(1) == 0, log(E) == 1")
  func testLog() {
    #expect(Math.log(1.0) == 0.0)
    #expect(abs(Math.log(Math.E) - 1.0) < epsilon)
  }

  @Test("sqrt(0)==0, sqrt(1)==1, sqrt(4)==2, sqrt(negative).isNaN")
  func testSqrt() {
    #expect(Math.sqrt(0.0) == 0.0)
    #expect(Math.sqrt(1.0) == 1.0)
    #expect(Math.sqrt(4.0) == 2.0)
    #expect(Math.sqrt(-1.0).isNaN)
  }

  @Test("pow(2,10)==1024, pow(0,0)==1, pow(x,0)==1, pow(1,x)==1")
  func testPow() {
    #expect(Math.pow(2.0, 10.0) == 1024.0)
    #expect(Math.pow(0.0, 0.0)  == 1.0)
    #expect(Math.pow(5.0, 0.0)  == 1.0)
    #expect(Math.pow(1.0, 99.0) == 1.0)
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

  @Test("floor: positive fraction → toward zero, negative fraction → next lower int")
  func testFloor() {
    #expect(Math.floor(1.9)  == 1.0)
    #expect(Math.floor(1.0)  == 1.0)
    #expect(Math.floor(-1.1) == -2.0)
  }

  @Test("rint: round half-to-even (banker's rounding)")
  func testRint() {
    #expect(Math.rint(0.5)  == 0.0)   // round to even
    #expect(Math.rint(1.5)  == 2.0)   // round to even
    #expect(Math.rint(2.5)  == 2.0)   // round to even
    #expect(Math.rint(1.4)  == 1.0)
    #expect(Math.rint(-1.5) == -2.0)
  }

  @Test("round(Double) → Int64: half-up rounding")
  func testRoundDouble() {
    #expect(Math.round(0.5)  == Int64(1))
    #expect(Math.round(-0.5) == Int64(0))   // Java: half-up, so -0.5 → 0
    #expect(Math.round(1.4)  == Int64(1))
    #expect(Math.round(1.5)  == Int64(2))
  }

  @Test("round(Float) → Int: half-up rounding")
  func testRoundFloat() {
    #expect(Math.round(Float(0.5))  == 1)
    #expect(Math.round(Float(1.4))  == 1)
    #expect(Math.round(Float(1.5))  == 2)
    #expect(Math.round(Float(-0.5)) == 0)
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
