/*
 * SPDX-FileCopyrightText: 2023 - 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.math.BigDecimal {

  // MARK: - Constants

  public static let ZERO = java.math.BigDecimal(Decimal.zero, scale: 0)
  public static let ONE  = java.math.BigDecimal(Decimal(1),   scale: 0)
  public static let TEN  = java.math.BigDecimal(Decimal(10),  scale: 0)

  /// Legacy int constants mirroring java.math.BigDecimal (deprecated in Java 9, still used in practice)
  public static let ROUND_UP          = 0
  public static let ROUND_DOWN        = 1
  public static let ROUND_CEILING     = 2
  public static let ROUND_FLOOR       = 3
  public static let ROUND_HALF_UP     = 4
  public static let ROUND_HALF_DOWN   = 5
  public static let ROUND_HALF_EVEN   = 6
  public static let ROUND_UNNECESSARY = 7

  // MARK: - valueOf factory methods

  /// NOTE: Same as Java, using a Double to initialise a BigDecimal is a bad idea.
  /// Better use `valueOf(_:String)` because the internal scale is set correctly.
  public static func valueOf(_ newValue: Double) -> java.math.BigDecimal {
    return java.math.BigDecimal(newValue)
  }

  /// Parses a decimal string. Returns `nil` on invalid input.
  public static func valueOf(_ newValue: String) -> java.math.BigDecimal? {
    return try? java.math.BigDecimal(newValue)
  }

  public static func valueOf(_ newValue: Int) -> java.math.BigDecimal {
    return java.math.BigDecimal(newValue)
  }

  public static func valueOf(_ newValue: Int64) -> java.math.BigDecimal {
    return java.math.BigDecimal(newValue)
  }

  // MARK: - scale / precision

  /// Returns the scale of this BigDecimal (number of digits to the right of the decimal point).
  /// Preserves trailing zeros: `new BigDecimal("1.000").scale() == 3`.
  public func scale() -> Int {
    return _scale
  }

  /// Returns the number of significant digits (precision).
  ///
  /// Java rule: `new BigDecimal("0.010").precision() == 2` (significant digits only, no leading zeros).
  public func precision() -> Int {
    let str = toPlainStringWithScale()
    let digits = str
      .replacingOccurrences(of: "-", with: "")
      .replacingOccurrences(of: ".", with: "")
    let trimmed = digits.drop(while: { $0 == "0" })
    return trimmed.isEmpty ? 1 : trimmed.count
  }

  // MARK: - Basic arithmetic (Java method names)

  public func add(_ summand: java.math.BigDecimal) -> java.math.BigDecimal {
    return self + summand
  }

  public func subtract(_ other: java.math.BigDecimal) -> java.math.BigDecimal {
    return self - other
  }

  public func multiply(_ other: java.math.BigDecimal) -> java.math.BigDecimal {
    return self * other
  }

  public func divide(_ by: java.math.BigDecimal) -> java.math.BigDecimal {
    return self / by
  }

  /// Three-argument divide with explicit scale and legacy rounding-mode int.
  public func divide(_ bd: java.math.BigDecimal, _ accuracy: Int, _ round: Int) -> java.math.BigDecimal {
    let raw     = java.math.BigDecimal(self._value / bd._value)
    let rounded = _roundedJava(raw, scale: accuracy, mode: round)
    return java.math.BigDecimal(rounded._value, scale: accuracy)
  }

  /// Returns self % divisor (truncated division remainder, same sign as dividend — Java semantics).
  public func remainder(_ divisor: java.math.BigDecimal) -> java.math.BigDecimal {
    let quotient = self.divide(divisor, 0, java.math.BigDecimal.ROUND_DOWN)
    return self - (divisor * quotient)
  }

  // MARK: - Comparison

  public func compareTo(_ other: java.math.BigDecimal) -> Int {
    if self._value < other._value { return -1 }
    if self._value > other._value { return  1 }
    return 0
  }

  // MARK: - abs / negate / plus / min / max

  public func abs() -> java.math.BigDecimal {
    return self._value < Decimal.zero
      ? java.math.BigDecimal(0 - self._value, scale: self._scale)
      : self
  }

  public func negate() -> java.math.BigDecimal {
    return java.math.BigDecimal(0 - self._value, scale: self._scale)
  }

  public func plus() -> java.math.BigDecimal { self }

  public func min(_ val: java.math.BigDecimal) -> java.math.BigDecimal {
    return self._value <= val._value ? self : val
  }

  public func max(_ val: java.math.BigDecimal) -> java.math.BigDecimal {
    return self._value >= val._value ? self : val
  }

  // MARK: - setScale

  /// Sets scale using the modern `RoundingMode` enum.
  public func setScale(_ newScale: Int, _ roundingMode: java.math.RoundingMode) -> java.math.BigDecimal {
    return setScale(newScale, roundingMode.rawValue)
  }

  /// Sets scale using legacy int rounding-mode constants.
  public func setScale(_ newScale: Int, _ roundingMode: Int) -> java.math.BigDecimal {
    if roundingMode == java.math.BigDecimal.ROUND_UNNECESSARY {
      let rounded = _rounded(self, scale: newScale, mode: .plain)
      precondition(rounded._value == self._value, "Rounding necessary but ROUND_UNNECESSARY specified")
      return java.math.BigDecimal(rounded._value, scale: newScale)
    }

    if newScale >= 0 {
      let rounded = _roundedJava(self, scale: newScale, mode: roundingMode)
      return java.math.BigDecimal(rounded._value, scale: newScale)
    } else {
      // Negative scale: round to nearest 10^(-newScale)
      let factor  = _pow10(-newScale)
      let divided = java.math.BigDecimal(self._value / factor._value)
      let rounded = _roundedJava(divided, scale: 0, mode: roundingMode)
      return java.math.BigDecimal(rounded._value * factor._value, scale: 0)
    }
  }

  // MARK: - String representation

  /// Returns a string with exactly `_scale` decimal places (pads trailing zeros).
  internal func toPlainStringWithScale() -> String {
    let base = (self._value as NSDecimalNumber).stringValue
    guard _scale > 0 else {
      // scale == 0: strip any decimal point Foundation may produce
      if let dotIndex = base.firstIndex(of: ".") {
        return String(base[base.startIndex..<dotIndex])
      }
      return base
    }
    let parts    = base.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)
    let intPart  = String(parts[0])
    let fracPart = parts.count > 1 ? String(parts[1]) : ""
    let padded: String
    if fracPart.count < _scale {
      padded = fracPart + String(repeating: "0", count: _scale - fracPart.count)
    } else {
      padded = String(fracPart.prefix(_scale))
    }
    return intPart + "." + padded
  }

  /// Returns the string representation without scientific notation.
  public func toPlainString() -> String {
    return toPlainStringWithScale()
  }

  /// Returns the string representation (same as toPlainString for this implementation).
  public func toString() -> String { toPlainString() }

  // MARK: - Numeric conversions

  public func intValue() -> Int {
    return (self._value as NSDecimalNumber).intValue
  }

  public func longValue() -> Int64 {
    return (self._value as NSDecimalNumber).int64Value
  }

  public func doubleValue() -> Double {
    return (self._value as NSDecimalNumber).doubleValue
  }

  public func floatValue() -> Float {
    return (self._value as NSDecimalNumber).floatValue
  }

  // MARK: - Point shifting

  /// Moves the decimal point n places to the left (divides by 10^n).
  public func movePointLeft(_ n: Int) -> java.math.BigDecimal {
    if n >= 0 {
      return java.math.BigDecimal(self._value / _pow10(n)._value, scale: self._scale + n)
    } else {
      return java.math.BigDecimal(self._value * _pow10(-n)._value, scale: Swift.max(0, self._scale - (-n)))
    }
  }

  /// Moves the decimal point n places to the right (multiplies by 10^n).
  public func movePointRight(_ n: Int) -> java.math.BigDecimal {
    if n >= 0 {
      return java.math.BigDecimal(self._value * _pow10(n)._value, scale: Swift.max(0, self._scale - n))
    } else {
      return java.math.BigDecimal(self._value / _pow10(-n)._value, scale: self._scale + (-n))
    }
  }

  /// Multiplies by 10^n.
  public func scaleByPowerOfTen(_ n: Int) -> java.math.BigDecimal {
    return movePointRight(n)
  }

  // MARK: - stripTrailingZeros

  /// Returns an equivalent BigDecimal with trailing zeros removed.
  public func stripTrailingZeros() -> java.math.BigDecimal {
    let str = (self._value as NSDecimalNumber).stringValue
    guard str.contains(".") else { return java.math.BigDecimal(self._value, scale: 0) }
    var trimmed = str
    while trimmed.hasSuffix("0") { trimmed = String(trimmed.dropLast()) }
    if trimmed.hasSuffix(".") { trimmed = String(trimmed.dropLast()) }
    let newScale = java.math.BigDecimal._parseScale(trimmed)
    guard let d = Decimal(string: trimmed, locale: Locale(identifier: "en_US_POSIX")) else { return self }
    return java.math.BigDecimal(d, scale: newScale)
  }

  // MARK: - Private rounding helpers

  private func _roundedJava(_ value: java.math.BigDecimal, scale: Int, mode: Int) -> java.math.BigDecimal {
    let isNegative = value._value < Decimal.zero
    switch mode {
    case java.math.BigDecimal.ROUND_DOWN:
      // Java ROUND_DOWN = towards zero (truncate).
      // NS .up = ceiling (+∞), NS .down = floor (-∞).
      // Towards zero: positive → floor (NS .down), negative → ceiling (NS .up).
      return _rounded(value, scale: scale, mode: isNegative ? .up : .down)
    case java.math.BigDecimal.ROUND_UP:
      // Java ROUND_UP = away from zero.
      // Positive → ceiling (NS .up), negative → floor (NS .down).
      return _rounded(value, scale: scale, mode: isNegative ? .down : .up)
    case java.math.BigDecimal.ROUND_CEILING:
      // Java CEILING = towards +∞ = NS .up always.
      return _rounded(value, scale: scale, mode: .up)
    case java.math.BigDecimal.ROUND_FLOOR:
      // Java FLOOR = towards -∞ = NS .down always.
      return _rounded(value, scale: scale, mode: .down)
    case java.math.BigDecimal.ROUND_HALF_UP:
      return _rounded(value, scale: scale, mode: .plain)
    case java.math.BigDecimal.ROUND_HALF_DOWN:
      return _roundHalfDown(value, scale: scale)
    case java.math.BigDecimal.ROUND_HALF_EVEN:
      return _rounded(value, scale: scale, mode: .bankers)
    default:
      return _rounded(value, scale: scale, mode: .plain)
    }
  }

  private func _rounded(_ value: java.math.BigDecimal, scale: Int, mode: NSDecimalNumber.RoundingMode) -> java.math.BigDecimal {
    let handler = NSDecimalNumberHandler(
      roundingMode: mode,
      scale: Int16(scale),
      raiseOnExactness: false,
      raiseOnOverflow: false,
      raiseOnUnderflow: false,
      raiseOnDivideByZero: false
    )
    let rounded = (value._value as NSDecimalNumber).rounding(accordingToBehavior: handler)
    return java.math.BigDecimal(rounded as Decimal, scale: scale)
  }

  private func _roundHalfDown(_ value: java.math.BigDecimal, scale: Int) -> java.math.BigDecimal {
    // ROUND_HALF_DOWN: ties go towards zero.
    // Strategy: shift to integer domain, detect exact 0.5 tie, then truncate (towards zero).
    let isNegative = value._value < Decimal.zero
    let factor     = _pow10(scale)
    // Work with absolute value to make fraction detection sign-independent
    let absValue   = isNegative
      ? java.math.BigDecimal(0 - value._value, scale: value._scale)
      : value
    let shifted    = java.math.BigDecimal(absValue._value * factor._value)
    // floor of |shifted| (NS .down on positive = floor)
    let floored    = _rounded(shifted, scale: 0, mode: .down)
    let fraction   = shifted._value - floored._value
    let half       = Decimal(floatLiteral: 0.5)
    if fraction == half {
      // Exact tie: truncate towards zero → use floor of absolute value, then restore sign
      let truncatedAbs = java.math.BigDecimal(floored._value / factor._value, scale: scale)
      return isNegative
        ? java.math.BigDecimal(0 - truncatedAbs._value, scale: scale)
        : truncatedAbs
    }
    // Not a tie: delegate to HALF_UP (standard rounding)
    return _rounded(value, scale: scale, mode: .plain)
  }

  private func _pow10(_ n: Int) -> java.math.BigDecimal {
    var result = Decimal(1)
    let ten    = Decimal(10)
    for _ in 0..<n { result = result * ten }
    return java.math.BigDecimal(result, scale: 0)
  }

  // MARK: - signum / pow / unscaledValue / ulp

  /// Returns -1, 0, or 1 as the value is negative, zero, or positive.
  public func signum() -> Int {
    if _value < Decimal.zero { return -1 }
    if _value > Decimal.zero { return  1 }
    return 0
  }

  /// Returns a BigDecimal whose value is self^n (n must be >= 0).
  /// Scale = self.scale() * n, matching Java's contract.
  public func pow(_ n: Int) throws(ArithmeticException) -> java.math.BigDecimal {
    guard n >= 0 else { throw ArithmeticException("Negative exponent") }
    if n == 0 { return java.math.BigDecimal(Decimal(1), scale: 0) }
    var result = Decimal(1)
    let base   = self._value
    for _ in 0..<n { result = result * base }
    return java.math.BigDecimal(result, scale: self._scale * n)
  }

  /// Returns the unscaled value: self * 10^scale as a BigInteger.
  /// E.g. `new BigDecimal("3.14").unscaledValue()` == `BigInteger("314")`.
  public func unscaledValue() -> java.math.BigInteger {
    // Shift decimal point right by _scale, then truncate
    let shifted = self._value * _pow10(_scale)._value
    let str = (shifted as NSDecimalNumber).stringValue
    // strip any decimal point (should be none after shift, but guard for float noise)
    let intStr = str.split(separator: ".").first.map(String.init) ?? str
    return (try? java.math.BigInteger(intStr)) ?? java.math.BigInteger.ZERO
  }

  /// Returns the unit in the last place (ulp) of this BigDecimal.
  /// ulp = 10^(-scale).
  public func ulp() -> java.math.BigDecimal {
    return java.math.BigDecimal(_pow10(_scale)._value == Decimal.zero
      ? Decimal(1)
      : Decimal(1) / _pow10(_scale)._value,
      scale: _scale)
  }

  // MARK: - divideToIntegralValue / divideAndRemainder

  /// Returns the integer part of self / divisor (truncated towards zero).
  public func divideToIntegralValue(_ divisor: java.math.BigDecimal) -> java.math.BigDecimal {
    return self.divide(divisor, 0, java.math.BigDecimal.ROUND_DOWN)
  }

  /// Returns [quotient, remainder] where quotient = divideToIntegralValue, remainder = self - quotient * divisor.
  public func divideAndRemainder(_ divisor: java.math.BigDecimal) -> [java.math.BigDecimal] {
    let q = divideToIntegralValue(divisor)
    let r = self - (divisor * q)
    return [q, r]
  }

  // MARK: - round(MathContext)

  /// Rounds to the precision specified by `mc`.
  /// If `mc.precision == 0` (UNLIMITED) returns self unchanged.
  public func round(_ mc: java.math.MathContext) -> java.math.BigDecimal {
    guard mc.precision > 0 else { return self }
    // Count current significant digits
    let currentPrecision = self.precision()
    let digitsToRemove   = currentPrecision - mc.precision
    if digitsToRemove <= 0 { return self }  // already within precision
    let newScale = self._scale - digitsToRemove
    return self.setScale(Swift.max(0, newScale), mc.roundingMode)
  }

  // MARK: - setScale(int) — exact only, throws if rounding needed

  /// Changes scale exactly — equivalent to ROUND_UNNECESSARY.
  /// Throws `ArithmeticException` if rounding would be needed.
  public func setScale(_ newScale: Int) throws(ArithmeticException) -> java.math.BigDecimal {
    let rounded = _rounded(self, scale: newScale, mode: .plain)
    if rounded._value != self._value {
      throw ArithmeticException("Rounding necessary")
    }
    return java.math.BigDecimal(rounded._value, scale: newScale)
  }

  // MARK: - toBigInteger / toBigIntegerExact

  /// Converts to BigInteger by truncating any fractional part (towards zero).
  public func toBigInteger() -> java.math.BigInteger {
    // Truncate towards zero: positive → floor (NS .down), negative → ceiling (NS .up)
    let isNeg     = self._value < Decimal.zero
    let truncated = _rounded(self, scale: 0, mode: isNeg ? .up : .down)
    let str       = (truncated._value as NSDecimalNumber).stringValue
    let intStr    = str.split(separator: ".").first.map(String.init) ?? str
    return (try? java.math.BigInteger(intStr)) ?? java.math.BigInteger.ZERO
  }

  /// Converts to BigInteger; throws ArithmeticException if any fractional part exists.
  public func toBigIntegerExact() throws(ArithmeticException) -> java.math.BigInteger {
    if _scale > 0 {
      let isNeg     = self._value < Decimal.zero
      let truncated = _rounded(self, scale: 0, mode: isNeg ? .up : .down)
      if truncated._value != self._value {
        throw ArithmeticException("Fractional part non-zero")
      }
    }
    return toBigInteger()
  }

  // MARK: - toEngineeringString

  /// Returns a string in engineering notation (exponent always a multiple of 3).
  public func toEngineeringString() -> String {
    // For values without fractional part and scale <= 0, use engineering notation.
    // Otherwise fall back to plain string (matches Java behaviour for values that
    // are already representable without an exponent).
    let plain = toPlainString()
    // Find the order of magnitude
    let absVal = _value < Decimal.zero ? java.math.BigDecimal(0 - _value, scale: _scale) : self
    if absVal._value == Decimal.zero { return "0" }
    // Count integer digits
    let intStr = (absVal._value as NSDecimalNumber).stringValue.split(separator: ".").first.map(String.init) ?? "0"
    let intDigits = intStr == "0" ? 0 : intStr.count
    // Engineering exponent: largest multiple of 3 <= (intDigits - 1)
    let exp3 = intDigits > 0 ? ((intDigits - 1) / 3) * 3 : 0
    if exp3 == 0 { return plain }
    // Shift
    let shifted = absVal.movePointLeft(exp3)
    let sign = _value < Decimal.zero ? "-" : ""
    return "\(sign)\(shifted.toPlainString())E+\(exp3)"
  }

  // MARK: - Java-style equals / hashCode

  /// Java-style `equals`: numerically equal AND same scale.
  /// In Java `new BigDecimal("2.0").equals(new BigDecimal("2.00"))` is `false`.
  public func equals(_ other: java.math.BigDecimal) -> Bool {
    return self._value == other._value && self._scale == other._scale
  }

  /// Java-style `hashCode` consistent with `equals`.
  public func hashCode() -> Int {
    var hasher = Hasher()
    hasher.combine(_value)
    hasher.combine(_scale)
    return hasher.finalize()
  }
}
