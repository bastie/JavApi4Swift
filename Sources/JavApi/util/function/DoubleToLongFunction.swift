/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - DoubleToLongFunction

extension java.util.function {
  /// Represents a function that accepts a Double (Java's double) input and an Int64 (Java's long) output.
  ///
  /// Primitive specialisation of ``Function`` used by the primitive streams
  /// (e.g. `IntStream.mapToLong`). Equivalent to `AnyFunction<Double, Int64>`.
  ///
  /// - Since: Java 8
  public typealias DoubleToLongFunction = AnyFunction<Double, Int64>
}
