/*
 * SPDX-FileCopyrightText: 2023 - 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

// MARK: - Swiftify: Foundation.Decimal → BigInteger

extension Decimal {
  /// Converts this `Decimal` to a `java.math.BigInteger`, truncating towards zero.
  public func toBigInteger() -> java.math.BigInteger {
    return self.toBigDecimal().toBigInteger()
  }
}
