/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - DoubleConsumer

extension java.util.function {
  /// Represents an operation that accepts a single `Double` argument and returns no result.
  ///
  /// Primitive specialisation of ``Consumer`` for `Double` (Java's `double`).
  /// Equivalent to `AnyConsumer<Double>`.
  ///
  /// - Since: Java 8
  public typealias DoubleConsumer = AnyConsumer<Double>
}
