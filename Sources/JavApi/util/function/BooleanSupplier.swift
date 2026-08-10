/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - BooleanSupplier

extension java.util.function {
  /// Represents a supplier of `Bool` results.
  ///
  /// Primitive specialisation of ``Supplier`` for `Bool` (Java's `boolean`).
  /// Equivalent to `AnySupplier<Bool>`.
  ///
  /// - Since: Java 8
  public typealias BooleanSupplier = AnySupplier<Bool>
}
