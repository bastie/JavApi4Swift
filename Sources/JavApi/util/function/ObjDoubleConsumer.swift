/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - ObjDoubleConsumer<T>

extension java.util.function {
  /// Represents an operation that accepts an object-valued and a `Double`-valued argument
  /// and returns no result.
  ///
  /// Primitive specialisation of ``BiConsumer`` for a `Double` (Java's `double`) second argument.
  /// Equivalent to `AnyBiConsumer<T, Double>`.
  ///
  /// - Since: Java 8
  public typealias ObjDoubleConsumer<T> = AnyBiConsumer<T, Double>
}
