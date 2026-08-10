/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - DoubleBinaryOperator

extension java.util.function {
  /// Represents an operation upon two `Double`-valued operands and producing a `Double` result.
  ///
  /// Primitive specialisation of ``BinaryOperator`` for `Double` (Java's `double`).
  /// Equivalent to `AnyBinaryOperator<Double>`.
  ///
  /// - Since: Java 8
  public typealias DoubleBinaryOperator = AnyBinaryOperator<Double>
}
