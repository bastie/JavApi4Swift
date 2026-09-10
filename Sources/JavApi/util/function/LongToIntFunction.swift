/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - LongToIntFunction

extension java.util.function {
  /// Represents a function that accepts an Int64 (Java's long) input and an Int (Java's int) output.
  ///
  /// Primitive specialisation of ``Function`` used by the primitive streams
  /// (e.g. `IntStream.mapToLong`). Equivalent to `AnyFunction<Int64, Int>`.
  ///
  /// - Since: Java 8
  public typealias LongToIntFunction = AnyFunction<Int64, Int>
}
