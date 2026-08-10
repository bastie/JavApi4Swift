/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - Callable<V>

extension java.util.concurrent {

  /// A task that returns a result and may throw an exception.
  ///
  /// Mirrors `java.util.concurrent.Callable<V>` (Java 5).
  ///
  /// Unlike ``java.util.function.Supplier``, `Callable` explicitly declares
  /// that `call()` may throw — it is intended for computations that produce a
  /// value and may fail.
  ///
  /// Use ``AnyCallable`` to wrap a Swift closure:
  /// ```swift
  /// let compute: any java.util.concurrent.Callable<Int> =
  ///     java.util.concurrent.AnyCallable { 6 * 7 }
  /// let result = try compute.call()  // 42
  /// ```
  ///
  /// - Since: Java 5
  public protocol Callable<V> {
    associatedtype V
    /// Computes a result, or throws an exception if unable to do so.
    func call() throws -> V
  }
}

// MARK: - AnyCallable<V> — closure-based concrete implementation

extension java.util.concurrent {

  /// A concrete ``Callable`` that wraps a Swift closure.
  public struct AnyCallable<V>: java.util.concurrent.Callable {
    private let _call: () throws -> V

    /// Creates a callable from a Swift closure.
    public init(_ call: @escaping () throws -> V) {
      _call = call
    }

    public func call() throws -> V { try _call() }
  }
}
