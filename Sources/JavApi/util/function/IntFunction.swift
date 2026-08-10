/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - IntFunction<R>

extension java.util.function {
  /// Represents a function that accepts an `Int` argument and produces a result.
  ///
  /// Primitive specialisation of ``Function`` for an `Int` (Java's `int`) input.
  /// Equivalent to `AnyFunction<Int, R>`.
  ///
  /// - Since: Java 8
  public typealias IntFunction<R> = AnyFunction<Int, R>
}
