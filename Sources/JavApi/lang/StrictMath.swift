/*
 * SPDX-FileCopyrightText: 2026- Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

/// - Since: Java 1.3
public struct StrictMath {

  public static let PI = 3.141592653589793 // value from Javadoc
  public static let E = 2.718281828459045 // value from Javadoc
  public static let TAU = 6.283185307179586 // value from Javadoc

  public static func abs (_ value : Double) -> Double {
    switch value {
    case .nan : return .nan
    case .signalingNaN : return .nan
    case .infinity : return .infinity
    default:
      if value < .zero {
        return -1 * value
      }
      return value
    }
  }
  public static func abs<T: Numeric & Comparable>(_ value: T) -> T {
    if value < .zero {
      return -1 * value
    }
    return value
  }

  /// Returns the absolute value, throwing `ArithmeticException` on `Int.min` (no positive counterpart).
  /// - Since: Java 15
  public static func absExact(_ value: Int) throws(ArithmeticException) -> Int {
    guard value != Int.min else { throw ArithmeticException("integer overflow") }
    return value < 0 ? -value : value
  }

  /// Returns the absolute value, throwing `ArithmeticException` on `Int64.min`.
  /// - Since: Java 15
  public static func absExact(_ value: Int64) throws(ArithmeticException) -> Int64 {
    guard value != Int64.min else { throw ArithmeticException("integer overflow") }
    return value < 0 ? -value : value
  }

  public static func acos (_ value : Double) -> Double {
    return Foundation.acos(value)
  }

  /// Adds two ints, throwing `ArithmeticException` on overflow.
  /// - Since: Java 8
  public static func addExact(_ x: Int, _ y: Int) throws(ArithmeticException) -> Int {
    let (result, overflow) = x.addingReportingOverflow(y)
    guard !overflow else { throw ArithmeticException("integer overflow") }
    return result
  }

  /// Adds two longs, throwing `ArithmeticException` on overflow.
  /// - Since: Java 8
  public static func addExact(_ x: Int64, _ y: Int64) throws(ArithmeticException) -> Int64 {
    let (result, overflow) = x.addingReportingOverflow(y)
    guard !overflow else { throw ArithmeticException("integer overflow") }
    return result
  }

  public static func asin (_ value : Double) -> Double {
    return Foundation.asin(value)
  }
  public static func atan (_ value : Double) -> Double {
    return Foundation.atan(value)
  }

  /// Returns the angle theta from rectangular coordinates (x, y) to polar (r, theta).
  /// - Since: Java 1.3
  public static func atan2(_ y: Double, _ x: Double) -> Double {
    return Foundation.atan2(y, x)
  }

  public static func cbrt (_ value : Double) -> Double {
    return Foundation.cbrt(value)
  }
  public static func ceil (_ value : Double) -> Double {
    return Foundation.ceil(value)
  }

  /// Returns the smallest (closest to negative infinity) int value that is ≥ the algebraic quotient.
  /// Truncates toward positive infinity, unlike `/` which truncates toward zero.
  /// - Since: Java 18
  public static func ceilDiv(_ x: Int, _ y: Int) throws(ArithmeticException) -> Int {
    guard y != 0 else { throw ArithmeticException("/ by zero") }
    let q = x / y
    // round up if signs are same and remainder non-zero
    return (x ^ y >= 0) && (q * y != x) ? q + 1 : q
  }

  /// Returns the smallest int value ≥ the algebraic quotient (long variant).
  /// - Since: Java 18
  public static func ceilDiv(_ x: Int64, _ y: Int64) throws(ArithmeticException) -> Int64 {
    guard y != 0 else { throw ArithmeticException("/ by zero") }
    let q = x / y
    return (x ^ y >= 0) && (q * y != x) ? q + 1 : q
  }

  /// Returns the ceiling modulus: x - ceilDiv(x,y)*y, result has opposite sign of y (or zero).
  /// - Since: Java 18
  public static func ceilMod(_ x: Int, _ y: Int) throws(ArithmeticException) -> Int {
    guard y != 0 else { throw ArithmeticException("/ by zero") }
    let r = x % y  // Swift %: sign follows x (dividend)
    // If remainder is non-zero and has the SAME sign as y, subtract y to flip sign
    return (r != 0 && ((r > 0) == (y > 0))) ? r - y : r
  }

  /// Returns the ceiling modulus (long variant).
  /// - Since: Java 18
  public static func ceilMod(_ x: Int64, _ y: Int64) throws(ArithmeticException) -> Int64 {
    guard y != 0 else { throw ArithmeticException("/ by zero") }
    let r = x % y
    return (r != 0 && ((r > 0) == (y > 0))) ? r - y : r
  }

  /// Clamps a value to [min, max].
  /// - Since: Java 21
  public static func clamp(_ value: Double, _ min: Double, _ max: Double) -> Double {
    return Swift.max(min, Swift.min(max, value))
  }

  /// Clamps a value to [min, max].
  /// - Since: Java 21
  public static func clamp(_ value: Float, _ min: Float, _ max: Float) -> Float {
    return Swift.max(min, Swift.min(max, value))
  }

  /// Clamps a value to [min, max].
  /// - Since: Java 21
  public static func clamp(_ value: Int64, _ min: Int64, _ max: Int64) -> Int64 {
    return Swift.max(min, Swift.min(max, value))
  }

  /// Clamps a value to [min, max].
  /// - Since: Java 21
  public static func clamp(_ value: Int, _ min: Int, _ max: Int) -> Int {
    return Swift.max(min, Swift.min(max, value))
  }

  /// Returns the first floating-point argument with the sign of the second.
  /// - Since: Java 6
  public static func copySign(_ magnitude: Double, _ sign: Double) -> Double {
    return Foundation.copysign(magnitude, sign)
  }

  /// Returns the first floating-point argument with the sign of the second (float variant).
  /// - Since: Java 6
  public static func copySign(_ magnitude: Float, _ sign: Float) -> Float {
    return Foundation.copysignf(magnitude, sign)
  }

  public static func cos (_ value : Double) -> Double {
    return Foundation.cos(value)
  }
  public static func cosh (_ value : Double) -> Double {
    return Foundation.cosh(value)
  }

  /// Decrements the argument, throwing `ArithmeticException` on overflow.
  /// - Since: Java 8
  public static func decrementExact(_ a: Int) throws(ArithmeticException) -> Int {
    guard a != Int.min else { throw ArithmeticException("integer overflow") }
    return a - 1
  }

  /// Decrements the argument, throwing `ArithmeticException` on overflow.
  /// - Since: Java 8
  public static func decrementExact(_ a: Int64) throws(ArithmeticException) -> Int64 {
    guard a != Int64.min else { throw ArithmeticException("integer overflow") }
    return a - 1
  }

  /// Returns the exact quotient, throwing `ArithmeticException` if not exact.
  /// - Since: Java 18
  public static func divideExact(_ x: Int, _ y: Int) throws(ArithmeticException) -> Int {
    guard y != 0 else { throw ArithmeticException("/ by zero") }
    guard !(x == Int.min && y == -1) else { throw ArithmeticException("integer overflow") }
    guard x % y == 0 else { throw ArithmeticException("Not exact: \(x) / \(y)") }
    return x / y
  }

  /// Returns the exact quotient (long variant).
  /// - Since: Java 18
  public static func divideExact(_ x: Int64, _ y: Int64) throws(ArithmeticException) -> Int64 {
    guard y != 0 else { throw ArithmeticException("/ by zero") }
    guard !(x == Int64.min && y == -1) else { throw ArithmeticException("integer overflow") }
    guard x % y == 0 else { throw ArithmeticException("Not exact: \(x) / \(y)") }
    return x / y
  }

  public static func exp (_ value : Double) -> Double {
    return Foundation.exp(value)
  }
  public static func expm1 (_ value : Double) -> Double {
    return Foundation.expm1(value)
  }
  public static func floor (_ value : Double) -> Double {
    return Foundation.floor(value)
  }

  /// Returns the largest int value ≤ the algebraic quotient (floor division).
  /// - Since: Java 8
  public static func floorDiv(_ x: Int, _ y: Int) throws(ArithmeticException) -> Int {
    guard y != 0 else { throw ArithmeticException("/ by zero") }
    let q = x / y
    return (x ^ y < 0) && (q * y != x) ? q - 1 : q
  }

  /// Floor division (long variant).
  /// - Since: Java 8
  public static func floorDiv(_ x: Int64, _ y: Int64) throws(ArithmeticException) -> Int64 {
    guard y != 0 else { throw ArithmeticException("/ by zero") }
    let q = x / y
    return (x ^ y < 0) && (q * y != x) ? q - 1 : q
  }

  /// Returns the floor modulus: x - floorDiv(x,y)*y, same sign as y.
  /// - Since: Java 8
  public static func floorMod(_ x: Int, _ y: Int) throws(ArithmeticException) -> Int {
    guard y != 0 else { throw ArithmeticException("/ by zero") }
    let r = x % y
    return (r != 0 && (r ^ y) < 0) ? r + y : r
  }

  /// Floor modulus (long variant).
  /// - Since: Java 8
  public static func floorMod(_ x: Int64, _ y: Int64) throws(ArithmeticException) -> Int64 {
    guard y != 0 else { throw ArithmeticException("/ by zero") }
    let r = x % y
    return (r != 0 && (r ^ y) < 0) ? r + y : r
  }

  /// Returns a × b + c as if computed with infinite precision, then rounded once.
  /// Uses Swift's built-in FMA.
  /// - Since: Java 9
  public static func fma(_ a: Double, _ b: Double, _ c: Double) -> Double {
    return Foundation.fma(a, b, c)
  }

  /// FMA for Float.
  /// - Since: Java 9
  public static func fma(_ a: Float, _ b: Float, _ c: Float) -> Float {
    return Foundation.fmaf(a, b, c)
  }

  /// Returns the unbiased exponent of the Double (IEEE 754 biased exponent minus 1023).
  /// - Since: Java 6
  public static func getExponent(_ d: Double) -> Int {
    return Int(d.exponentBitPattern) - 1023
  }

  /// Returns the unbiased exponent of the Float.
  /// - Since: Java 6
  public static func getExponent(_ f: Float) -> Int {
    return Int(f.exponentBitPattern) - 127
  }

  /// Returns sqrt(x² + y²) without intermediate overflow.
  /// - Since: Java 5 (1.5)
  public static func hypot(_ x: Double, _ y: Double) -> Double {
    return Foundation.hypot(x, y)
  }

  /// IEEE remainder: f1 - (round(f1/f2) * f2)
  /// - Since: Java 1.3
  public static func IEEEremainder(_ f1: Double, _ f2: Double) -> Double {
    return Foundation.remainder(f1, f2)
  }

  /// Increments the argument, throwing `ArithmeticException` on overflow.
  /// - Since: Java 8
  public static func incrementExact(_ a: Int) throws(ArithmeticException) -> Int {
    guard a != Int.max else { throw ArithmeticException("integer overflow") }
    return a + 1
  }

  /// Increments the argument, throwing `ArithmeticException` on overflow.
  /// - Since: Java 8
  public static func incrementExact(_ a: Int64) throws(ArithmeticException) -> Int64 {
    guard a != Int64.max else { throw ArithmeticException("integer overflow") }
    return a + 1
  }

  public static func log (_ value : Double) -> Double {
    return Foundation.log(value)
  }
  public static func log10 (_ value : Double) -> Double {
    return Foundation.log10(value)
  }
  public static func log1p (_ value : Double) -> Double {
    return Foundation.log1p(value)
  }

  @inlinable
  public static func max<T>(_ x: T, _ y: T) -> T where T : Comparable {
    Swift.max(x, y)
  }

  @inlinable
  public static func min<T>(_ x: T, _ y: T) -> T where T : Comparable {
    Swift.min(x, y)
  }

  /// Multiplies two ints, throwing `ArithmeticException` on overflow.
  /// - Since: Java 8
  public static func multiplyExact(_ x: Int, _ y: Int) throws(ArithmeticException) -> Int {
    let (result, overflow) = x.multipliedReportingOverflow(by: y)
    guard !overflow else { throw ArithmeticException("integer overflow") }
    return result
  }

  /// Multiplies two longs, throwing `ArithmeticException` on overflow.
  /// - Since: Java 8
  public static func multiplyExact(_ x: Int64, _ y: Int64) throws(ArithmeticException) -> Int64 {
    let (result, overflow) = x.multipliedReportingOverflow(by: y)
    guard !overflow else { throw ArithmeticException("integer overflow") }
    return result
  }

  /// Returns the exact product of two ints as an Int64 (cannot overflow).
  /// - Since: Java 9
  public static func multiplyFull(_ x: Int32, _ y: Int32) -> Int64 {
    return Int64(x) * Int64(y)
  }

  /// Returns the high 64 bits of the 128-bit product of two Int64 values.
  /// - Since: Java 9
  public static func multiplyHigh(_ x: Int64, _ y: Int64) -> Int64 {
    let (high, _) = x.multipliedFullWidth(by: y)
    return high
  }

  /// Negates the argument, throwing `ArithmeticException` on overflow (`Int.min`).
  /// - Since: Java 8
  public static func negateExact(_ a: Int) throws(ArithmeticException) -> Int {
    guard a != Int.min else { throw ArithmeticException("integer overflow") }
    return -a
  }

  /// Negates the argument, throwing `ArithmeticException` on overflow (`Int64.min`).
  /// - Since: Java 8
  public static func negateExact(_ a: Int64) throws(ArithmeticException) -> Int64 {
    guard a != Int64.min else { throw ArithmeticException("integer overflow") }
    return -a
  }

  /// Returns the adjacent floating-point value in the direction of second argument.
  /// - Since: Java 6
  public static func nextAfter(_ start: Double, _ direction: Double) -> Double {
    if start.isNaN || direction.isNaN { return Double.nan }
    if start == direction { return direction }
    return direction > start ? nextUp(start) : nextDown(start)
  }

  /// nextAfter for Float.
  /// - Since: Java 6
  public static func nextAfter(_ start: Float, _ direction: Double) -> Float {
    if start.isNaN || direction.isNaN { return Float.nan }
    if Double(start) == direction { return start }
    return direction > Double(start) ? nextUp(start) : nextDown(start)
  }

  /// Returns the adjacent floating-point value toward negative infinity.
  /// - Since: Java 6
  public static func nextDown(_ d: Double) -> Double {
    return -nextUp(-d)
  }

  /// nextDown for Float.
  /// - Since: Java 6
  public static func nextDown(_ f: Float) -> Float {
    return -nextUp(-f)
  }

  /// Returns the adjacent floating-point value toward positive infinity.
  /// - Since: Java 6
  public static func nextUp(_ d: Double) -> Double {
    if d.isNaN || d == Double.infinity { return d }
    if d == 0.0 { return Double.leastNonzeroMagnitude }
    let bits = d.bitPattern
    return Double(bitPattern: d > 0 ? bits + 1 : bits - 1)
  }

  /// nextUp for Float.
  /// - Since: Java 6
  public static func nextUp(_ f: Float) -> Float {
    if f.isNaN || f == Float.infinity { return f }
    if f == 0.0 { return Float.leastNonzeroMagnitude }
    let bits = f.bitPattern
    return Float(bitPattern: f > 0 ? bits + 1 : bits - 1)
  }

  public static func pow (_ value : Double, _ value2 : Double) -> Double {
    return Foundation.pow(value,value2)
  }

  /// Returns a pseudorandom double in [0.0, 1.0).
  /// - Since: Java 1.0
  public static func random() -> Double {
    return Double.random(in: 0.0..<1.0)
  }

  /// Returns the double closest to a that is a mathematical integer, rounding to even
  /// - Since: Java 1.3
  public static func rint(_ a: Double) -> Double {
    return Foundation.rint(a)
  }

  /// Java spec: round(a) = (long) floor(a + 0.5) — half-up rounding (not banker's rounding).
  public static func round (_ d : Double) -> Int64 {
    if d.isNaN { return 0 }
    if d >= Double(Int64.max) { return Int64.max }
    if d < Double(Int64.min) { return Int64.min }
    return Int64(Foundation.floor(d + 0.5))
  }
  /// Java spec: round(a) = (int) floor(a + 0.5f) — half-up rounding.
  public static func round (_ f : Float) -> Int {
    if f.isNaN { return 0 }
    return Int(Foundation.floorf(f + 0.5))
  }

  /// Returns d × 2^scaleFactor, computed as if by a correctly rounded floating-point multiply.
  /// - Since: Java 6
  public static func scalb(_ d: Double, _ scaleFactor: Int) -> Double {
    return Foundation.scalbn(d, Int32(clamping: scaleFactor))
  }

  /// scalb for Float.
  /// - Since: Java 6
  public static func scalb(_ f: Float, _ scaleFactor: Int) -> Float {
    return Foundation.scalbnf(f, Int32(clamping: scaleFactor))
  }

  /// Returns the signum of the argument: -1.0, 0.0, or 1.0.
  /// - Since: Java 6
  public static func signum(_ d: Double) -> Double {
    if d.isNaN { return Double.nan }
    if d == 0.0 { return 0.0 }
    return d < 0 ? -1.0 : 1.0
  }

  /// signum for Float.
  /// - Since: Java 6
  public static func signum(_ f: Float) -> Float {
    if f.isNaN { return Float.nan }
    if f == 0.0 { return 0.0 }
    return f < 0 ? -1.0 : 1.0
  }

  public static func sin (_ value : Double) -> Double {
    return Foundation.sin(value)
  }
  public static func sinh (_ value : Double) -> Double {
    return Foundation.sinh(value)
  }
  public static func sqrt (_ value : Double) -> Double {
    return Foundation.sqrt(value)
  }

  /// Subtracts two ints, throwing `ArithmeticException` on overflow.
  /// - Since: Java 8
  public static func subtractExact(_ x: Int, _ y: Int) throws(ArithmeticException) -> Int {
    let (result, overflow) = x.subtractingReportingOverflow(y)
    guard !overflow else { throw ArithmeticException("integer overflow") }
    return result
  }

  /// Subtracts two longs, throwing `ArithmeticException` on overflow.
  /// - Since: Java 8
  public static func subtractExact(_ x: Int64, _ y: Int64) throws(ArithmeticException) -> Int64 {
    let (result, overflow) = x.subtractingReportingOverflow(y)
    guard !overflow else { throw ArithmeticException("integer overflow") }
    return result
  }

  public static func tan (_ value : Double) -> Double {
    return Foundation.tan(value)
  }
  public static func tanh (_ value : Double) -> Double {
    return Foundation.tanh(value)
  }

  public static func toDegrees (_ value : Double) -> Double {
    return value * 180 / PI
  }

  /// Converts an Int64 to Int, throwing `ArithmeticException` on overflow.
  /// - Since: Java 8
  public static func toIntExact(_ value: Int64) throws(ArithmeticException) -> Int {
    guard value >= Int64(Int.min) && value <= Int64(Int.max) else {
      throw ArithmeticException("integer overflow")
    }
    return Int(value)
  }

  public static func toRadians (_ value : Double) -> Double {
    return value * PI / 180
  }

  /// Returns the size of an ulp of the Double argument.
  /// Java spec: ulp(±infinity) = infinity, ulp(NaN) = NaN.
  /// - Since: Java 6
  public static func ulp(_ d: Double) -> Double {
    if d.isNaN { return Double.nan }
    if d.isInfinite { return Double.infinity }
    return d.ulp
  }

  /// Returns the size of an ulp of the Float argument.
  /// Java spec: ulp(±infinity) = infinity, ulp(NaN) = NaN.
  /// - Since: Java 6
  public static func ulp(_ f: Float) -> Float {
    if f.isNaN { return Float.nan }
    if f.isInfinite { return Float.infinity }
    return f.ulp
  }
}
