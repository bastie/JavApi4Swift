/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - IntPredicate

extension java.util.function {
  /// Represents a predicate (boolean-valued function) of one `Int` argument.
  ///
  /// Primitive specialisation of ``Predicate`` for `Int` (Java's `int`).
  /// Equivalent to `AnyPredicate<Int>`.
  ///
  /// - Since: Java 8
  public typealias IntPredicate = AnyPredicate<Int>
}
