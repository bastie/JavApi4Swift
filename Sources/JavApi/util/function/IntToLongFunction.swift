/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - IntToLongFunction

extension java.util.function {
  /// Represents a function that accepts an Int (Java's int) input and an Int64 (Java's long) output.
  ///
  /// Primitive specialisation of ``Function`` used by the primitive streams
  /// (e.g. `IntStream.mapToLong`). Equivalent to `AnyFunction<Int, Int64>`.
  ///
  /// - Since: Java 8
  public typealias IntToLongFunction = AnyFunction<Int, Int64>
}
