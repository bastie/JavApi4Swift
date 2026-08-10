/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - ToDoubleBiFunction<T, U>

extension java.util.function {
  /// Represents a function that accepts two arguments and produces a `Double`-valued result.
  ///
  /// Primitive specialisation of ``BiFunction`` for a `Double` (Java's `double`) result.
  /// Equivalent to `AnyBiFunction<T, U, Double>`.
  ///
  /// - Since: Java 8
  public typealias ToDoubleBiFunction<T, U> = AnyBiFunction<T, U, Double>
}
