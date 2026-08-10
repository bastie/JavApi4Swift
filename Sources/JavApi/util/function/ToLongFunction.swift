/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - ToLongFunction<T>

extension java.util.function {
  /// Represents a function that produces an `Int64`-valued result.
  ///
  /// Primitive specialisation of ``Function`` for an `Int64` (Java's `long`) output.
  /// Equivalent to `AnyFunction<T, Int64>`.
  ///
  /// - Since: Java 8
  public typealias ToLongFunction<T> = AnyFunction<T, Int64>
}
