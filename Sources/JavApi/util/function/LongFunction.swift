/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - LongFunction<R>

extension java.util.function {
  /// Represents a function that accepts an `Int64` argument and produces a result.
  ///
  /// Primitive specialisation of ``Function`` for an `Int64` (Java's `long`) input.
  /// Equivalent to `AnyFunction<Int64, R>`.
  ///
  /// - Since: Java 8
  public typealias LongFunction<R> = AnyFunction<Int64, R>
}
