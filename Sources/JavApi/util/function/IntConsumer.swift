/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - IntConsumer

extension java.util.function {
  /// Represents an operation that accepts a single `Int` argument and returns no result.
  ///
  /// Primitive specialisation of ``Consumer`` for `Int` (Java's `int`).
  /// Equivalent to `AnyConsumer<Int>`.
  ///
  /// - Since: Java 8
  public typealias IntConsumer = AnyConsumer<Int>
}
