/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - ToIntFunction<T>

extension java.util.function {
  /// Represents a function that produces an `Int`-valued result.
  ///
  /// Primitive specialisation of ``Function`` for an `Int` (Java's `int`) output.
  /// Equivalent to `AnyFunction<T, Int>`.
  ///
  /// - Since: Java 8
  public typealias ToIntFunction<T> = AnyFunction<T, Int>
}
