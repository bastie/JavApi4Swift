/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - ToIntBiFunction<T, U>

extension java.util.function {
  /// Represents a function that accepts two arguments and produces an `Int`-valued result.
  ///
  /// Primitive specialisation of ``BiFunction`` for an `Int` (Java's `int`) result.
  /// Equivalent to `AnyBiFunction<T, U, Int>`.
  ///
  /// - Since: Java 8
  public typealias ToIntBiFunction<T, U> = AnyBiFunction<T, U, Int>
}
