/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - LongConsumer

extension java.util.function {
  /// Represents an operation that accepts a single `Int64` argument and returns no result.
  ///
  /// Primitive specialisation of ``Consumer`` for `Int64` (Java's `long`).
  /// Equivalent to `AnyConsumer<Int64>`.
  ///
  /// - Since: Java 8
  public typealias LongConsumer = AnyConsumer<Int64>
}
