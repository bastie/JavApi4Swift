/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - ObjIntConsumer<T>

extension java.util.function {
  /// Represents an operation that accepts an object-valued and an `Int`-valued argument
  /// and returns no result.
  ///
  /// Primitive specialisation of ``BiConsumer`` for an `Int` (Java's `int`) second argument.
  /// Equivalent to `AnyBiConsumer<T, Int>`.
  ///
  /// - Since: Java 8
  public typealias ObjIntConsumer<T> = AnyBiConsumer<T, Int>
}
