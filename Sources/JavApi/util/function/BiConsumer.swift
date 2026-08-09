/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - BiConsumer<T,U>

extension java.util.function {
  /// Represents an operation that accepts two input arguments and returns no result.
  ///
  /// This is a Java-API-compatible functional interface whose functional method is ``accept(_:_:)``.
  ///
  /// Use ``AnyBiConsumer`` to wrap a Swift closure:
  /// ```swift
  /// let printer = AnyBiConsumer<String, Int> { key, val in print("\(key)=\(val)") }
  /// printer.accept("age", 42)
  /// ```
  public protocol BiConsumer<T, U> {
    associatedtype T
    associatedtype U
    /// Performs this operation on the two given arguments.
    func accept(_ t: T, _ u: U)
  }
}

// MARK: - Default methods (Java-compatible)

extension java.util.function.BiConsumer {
  /// Returns a composed bi-consumer that performs this, then `after`.
  public func andThen(_ after: some java.util.function.BiConsumer<T, U>) -> java.util.function.AnyBiConsumer<T, U> {
    java.util.function.AnyBiConsumer<T, U> { [self] t, u in
      self.accept(t, u)
      after.accept(t, u)
    }
  }
}

// MARK: - AnyBiConsumer<T,U> — closure-based concrete implementation

extension java.util.function {
  /// A concrete ``BiConsumer`` that wraps a Swift closure.
  public struct AnyBiConsumer<T, U>: java.util.function.BiConsumer {
    private let _accept: (T, U) -> Void

    /// Creates a bi-consumer from a Swift closure.
    public init(_ accept: @escaping (T, U) -> Void) {
      _accept = accept
    }

    public func accept(_ t: T, _ u: U) { _accept(t, u) }
  }
}
