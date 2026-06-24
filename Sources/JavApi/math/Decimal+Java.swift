/*
 * SPDX-FileCopyrightText: 2023 - 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

/// Extensions on Foundation.Decimal for Java-style usage where Decimal is used directly
/// (not via java.math.BigDecimal).  Java-style BigDecimal methods are on the
/// `java.math.BigDecimal` struct in `BigDecimal+Java.swift`.
extension Decimal {

  // MARK: - Numeric conversions (Java-style method names on raw Decimal)

  public func intValue() -> Int {
    return (self as NSDecimalNumber).intValue
  }

  public func longValue() -> Int64 {
    return (self as NSDecimalNumber).int64Value
  }

  public func doubleValue() -> Double {
    return (self as NSDecimalNumber).doubleValue
  }

  public func floatValue() -> Float {
    return (self as NSDecimalNumber).floatValue
  }

  public func compareTo(_ other: Decimal) -> Int {
    if self < other { return -1 }
    if self > other { return  1 }
    return 0
  }
}
