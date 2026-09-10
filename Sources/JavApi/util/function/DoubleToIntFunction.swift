/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - DoubleToIntFunction

extension java.util.function {
  /// Represents a function that accepts a Double (Java's double) input and an Int (Java's int) output.
  ///
  /// Primitive specialisation of ``Function`` used by the primitive streams
  /// (e.g. `IntStream.mapToLong`). Equivalent to `AnyFunction<Double, Int>`.
  ///
  /// - Since: Java 8
  public typealias DoubleToIntFunction = AnyFunction<Double, Int>
}
