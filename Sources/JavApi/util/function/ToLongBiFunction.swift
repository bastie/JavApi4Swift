/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - ToLongBiFunction<T, U>

extension java.util.function {
  /// Represents a function that accepts two arguments and produces an `Int64`-valued result.
  ///
  /// Primitive specialisation of ``BiFunction`` for an `Int64` (Java's `long`) result.
  /// Equivalent to `AnyBiFunction<T, U, Int64>`.
  ///
  /// - Since: Java 8
  public typealias ToLongBiFunction<T, U> = AnyBiFunction<T, U, Int64>
}
