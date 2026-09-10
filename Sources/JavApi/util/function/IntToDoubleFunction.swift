/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - IntToDoubleFunction

extension java.util.function {
  /// Represents a function that accepts an Int (Java's int) input and a Double (Java's double) output.
  ///
  /// Primitive specialisation of ``Function`` used by the primitive streams
  /// (e.g. `IntStream.mapToLong`). Equivalent to `AnyFunction<Int, Double>`.
  ///
  /// - Since: Java 8
  public typealias IntToDoubleFunction = AnyFunction<Int, Double>
}
