/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - DoubleSupplier

extension java.util.function {
  /// Represents a supplier of `Double` results.
  ///
  /// Primitive specialisation of ``Supplier`` for `Double` (Java's `double`).
  /// Equivalent to `AnySupplier<Double>`.
  ///
  /// - Since: Java 8
  public typealias DoubleSupplier = AnySupplier<Double>
}
