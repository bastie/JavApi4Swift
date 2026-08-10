/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - Supplier<T>

extension java.util.function {

  /// Represents a supplier of results.
  ///
  /// This is a Java-API-compatible functional interface whose functional method is ``get()``.
  ///
  /// Use ``AnySupplier`` to wrap a Swift closure:
  /// ```swift
  /// let counter = AnySupplier { 42 }
  /// counter.get() // 42
  /// ```
  public protocol Supplier<T> {
    associatedtype T
    /// Gets a result.
    func get() -> T
  }
}

// MARK: - AnySupplier<T> — closure-based concrete implementation

extension java.util.function {

  /// A concrete ``Supplier`` that wraps a Swift closure.
  public struct AnySupplier<T>: java.util.function.Supplier {
    private let _get: () -> T

    /// Creates a supplier from a Swift closure.
    public init(_ get: @escaping () -> T) {
      _get = get
    }

    public func get() -> T { _get() }
  }
}
