/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - LongPredicate

extension java.util.function {
  /// Represents a predicate (boolean-valued function) of one `Int64` argument.
  ///
  /// Primitive specialisation of ``Predicate`` for `Int64` (Java's `long`).
  /// Equivalent to `AnyPredicate<Int64>`.
  ///
  /// - Since: Java 8
  public typealias LongPredicate = AnyPredicate<Int64>
}
