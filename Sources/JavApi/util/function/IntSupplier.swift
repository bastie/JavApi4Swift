/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - IntSupplier

extension java.util.function {
  /// Represents a supplier of `Int` results.
  ///
  /// Primitive specialisation of ``Supplier`` for `Int` (Java's `int`).
  /// Equivalent to `AnySupplier<Int>`.
  ///
  /// - Since: Java 8
  public typealias IntSupplier = AnySupplier<Int>
}
