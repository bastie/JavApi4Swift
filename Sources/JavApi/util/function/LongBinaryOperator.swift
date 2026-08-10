/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - LongBinaryOperator

extension java.util.function {
  /// Represents an operation upon two `Int64`-valued operands and producing an `Int64` result.
  ///
  /// Primitive specialisation of ``BinaryOperator`` for `Int64` (Java's `long`).
  /// Equivalent to `AnyBinaryOperator<Int64>`.
  ///
  /// - Since: Java 8
  public typealias LongBinaryOperator = AnyBinaryOperator<Int64>
}
