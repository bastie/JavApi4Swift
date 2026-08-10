/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - DoubleFunction<R>

extension java.util.function {
  /// Represents a function that accepts a `Double` argument and produces a result.
  ///
  /// Primitive specialisation of ``Function`` for a `Double` (Java's `double`) input.
  /// Equivalent to `AnyFunction<Double, R>`.
  ///
  /// - Since: Java 8
  public typealias DoubleFunction<R> = AnyFunction<Double, R>
}
