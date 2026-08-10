/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - DoublePredicate

extension java.util.function {
  /// Represents a predicate (boolean-valued function) of one `Double` argument.
  ///
  /// Primitive specialisation of ``Predicate`` for `Double` (Java's `double`).
  /// Equivalent to `AnyPredicate<Double>`.
  ///
  /// - Since: Java 8
  public typealias DoublePredicate = AnyPredicate<Double>
}
