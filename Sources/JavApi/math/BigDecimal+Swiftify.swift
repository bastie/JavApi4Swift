/*
 * SPDX-FileCopyrightText: 2023 - 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

// MARK: - Swiftify: Decimal ↔ BigDecimal conversions

extension java.math.BigDecimal {

  /// Creates a `BigDecimal` from a `Foundation.Decimal`.
  /// Scale is inferred from the Decimal's internal exponent (trailing zeros are NOT preserved).
  /// Use `init(_ val: String)` when trailing-zero scale matters.
  public init(decimal: Decimal) {
    self = java.math.BigDecimal(decimal)
  }

  /// Returns the underlying `Foundation.Decimal` value.
  /// Useful when interoperating with Foundation APIs that expect `Decimal`.
  public func toDecimal() -> Decimal {
    return _value
  }
}

// MARK: - Swiftify: ExpressibleBy literals
// Allows BigDecimal to be initialised from integer and float literals in Swift code,
// e.g.  `let x: java.math.BigDecimal = 42`  or  `let y: java.math.BigDecimal = 3.14`

extension java.math.BigDecimal: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: Int) {
    self = java.math.BigDecimal(value)
  }
}

extension java.math.BigDecimal: ExpressibleByFloatLiteral {
  public init(floatLiteral value: Double) {
    self = java.math.BigDecimal(value)
  }
}

// MARK: - Swiftify: Foundation.Decimal → BigDecimal

extension Decimal {
  /// Wraps this `Decimal` in a `java.math.BigDecimal`.
  /// Scale is inferred; use `java.math.BigDecimal(string:)` when exact scale matters.
  public func toBigDecimal() -> java.math.BigDecimal {
    return java.math.BigDecimal(self)
  }
  public init(_ val: java.math.BigDecimal) {
    self = val.toDecimal()
  }
}

// MARK: - Swift arithmetic operators (delegate to Decimal)

extension java.math.BigDecimal {
  
  public static func + (lhs: java.math.BigDecimal, rhs: java.math.BigDecimal) -> java.math.BigDecimal {
    let result = lhs._value + rhs._value
    return java.math.BigDecimal(result, scale: Swift.max(lhs._scale, rhs._scale))
  }
  
  public static func - (lhs: java.math.BigDecimal, rhs: java.math.BigDecimal) -> java.math.BigDecimal {
    let result = lhs._value - rhs._value
    return java.math.BigDecimal(result, scale: Swift.max(lhs._scale, rhs._scale))
  }
  
  public static func * (lhs: java.math.BigDecimal, rhs: java.math.BigDecimal) -> java.math.BigDecimal {
    let result = lhs._value * rhs._value
    return java.math.BigDecimal(result, scale: lhs._scale + rhs._scale)
  }
  
  public static func / (lhs: java.math.BigDecimal, rhs: java.math.BigDecimal) -> java.math.BigDecimal {
    guard rhs._value != Decimal.zero else { return .ZERO }
    let result = lhs._value / rhs._value
    return java.math.BigDecimal(result)
  }
  
  public static func += (lhs: inout java.math.BigDecimal, rhs: java.math.BigDecimal) {
    lhs = lhs + rhs
  }
  
  public static func -= (lhs: inout java.math.BigDecimal, rhs: java.math.BigDecimal) {
    lhs = lhs - rhs
  }
  
  public static func *= (lhs: inout java.math.BigDecimal, rhs: java.math.BigDecimal) {
    lhs = lhs * rhs
  }
}
