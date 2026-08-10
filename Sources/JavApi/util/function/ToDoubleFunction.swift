/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - ToDoubleFunction<T>

extension java.util.function {
  /// Represents a function that produces a `Double`-valued result.
  ///
  /// Primitive specialisation of ``Function`` for a `Double` (Java's `double`) output.
  /// Equivalent to `AnyFunction<T, Double>`.
  ///
  /// - Since: Java 8
  public typealias ToDoubleFunction<T> = AnyFunction<T, Double>
}
