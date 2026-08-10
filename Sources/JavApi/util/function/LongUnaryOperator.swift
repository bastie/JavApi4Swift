/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - LongUnaryOperator

extension java.util.function {
  /// Represents an operation on a single `Int64`-valued operand that produces an `Int64` result.
  ///
  /// Primitive specialisation of ``UnaryOperator`` for `Int64` (Java's `long`).
  /// Equivalent to `AnyUnaryOperator<Int64>`.
  ///
  /// - Since: Java 8
  public typealias LongUnaryOperator = AnyUnaryOperator<Int64>
}
