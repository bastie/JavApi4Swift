/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - ObjLongConsumer<T>

extension java.util.function {
  /// Represents an operation that accepts an object-valued and an `Int64`-valued argument
  /// and returns no result.
  ///
  /// Primitive specialisation of ``BiConsumer`` for an `Int64` (Java's `long`) second argument.
  /// Equivalent to `AnyBiConsumer<T, Int64>`.
  ///
  /// - Since: Java 8
  public typealias ObjLongConsumer<T> = AnyBiConsumer<T, Int64>
}
