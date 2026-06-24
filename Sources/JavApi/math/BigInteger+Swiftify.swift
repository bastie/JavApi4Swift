/*
 * SPDX-FileCopyrightText: 2023 - 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

// MARK: - Swiftify: Convenience Initialisers

extension java.math.BigInteger {

  /// Creates a `BigInteger` from a Swift `Int`.
  /// Named parameter version for Swift-idiomatic usage.
  public convenience init(int value: Int) {
    self.init(Int128(value))
  }

  /// Creates a `BigInteger` from a Swift `Int64`.
  /// Named parameter version for Swift-idiomatic usage.
  public convenience init(long value: Int64) {
    self.init(Int128(value))
  }

  /// Converts this `BigInteger` to a `java.math.BigDecimal` with scale 0.
  public func toBigDecimal() -> java.math.BigDecimal {
    // toString() always produces valid decimal digits, so try! is safe here
    return (try? java.math.BigDecimal(self.toString())) ?? java.math.BigDecimal.ZERO
  }
}

// MARK: - Swiftify: Foundation.Decimal → BigInteger

extension Decimal {
  /// Converts this `Decimal` to a `java.math.BigInteger`, truncating towards zero.
  public func toBigInteger() -> java.math.BigInteger {
    return self.toBigDecimal().toBigInteger()
  }
}
