/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - LongSupplier

extension java.util.function {
  /// Represents a supplier of `Int64` results.
  ///
  /// Primitive specialisation of ``Supplier`` for `Int64` (Java's `long`).
  /// Equivalent to `AnySupplier<Int64>`.
  ///
  /// - Since: Java 8
  public typealias LongSupplier = AnySupplier<Int64>
}
