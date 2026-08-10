/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - IntBinaryOperator

extension java.util.function {
  /// Represents an operation upon two `Int`-valued operands and producing an `Int` result.
  ///
  /// Primitive specialisation of ``BinaryOperator`` for `Int` (Java's `int`).
  /// Equivalent to `AnyBinaryOperator<Int>`.
  ///
  /// - Since: Java 8
  public typealias IntBinaryOperator = AnyBinaryOperator<Int>
}
