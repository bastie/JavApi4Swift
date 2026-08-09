/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - BiFunction<T,U,R>

extension java.util.function {
  /// Represents a function that accepts two arguments and produces a result.
  ///
  /// This is a Java-API-compatible functional interface whose functional method is ``apply(_:_:)``.
  ///
  /// Use ``AnyBiFunction`` to wrap a Swift closure:
  /// ```swift
  /// let concat = AnyBiFunction<String, String, String> { a, b in a + b }
  /// concat.apply("Hello, ", "World!") // "Hello, World!"
  /// ```
  public protocol BiFunction<T, U, R> {
    associatedtype T
    associatedtype U
    associatedtype R
    /// Applies this function to the given arguments.
    func apply(_ t: T, _ u: U) -> R
  }
}

// MARK: - Default methods (Java-compatible)

extension java.util.function.BiFunction {
  /// Returns a composed function that applies this, then `after` to the result.
  public func andThen<V>(_ after: some java.util.function.Function<R, V>) -> java.util.function.AnyBiFunction<T, U, V> {
    java.util.function.AnyBiFunction<T, U, V> { [self] t, u in after.apply(self.apply(t, u)) }
  }
}

// MARK: - AnyBiFunction<T,U,R> — closure-based concrete implementation

extension java.util.function {
  /// A concrete ``BiFunction`` that wraps a Swift closure.
  public struct AnyBiFunction<T, U, R>: java.util.function.BiFunction {
    private let _apply: (T, U) -> R

    /// Creates a bi-function from a Swift closure.
    public init(_ apply: @escaping (T, U) -> R) {
      _apply = apply
    }

    public func apply(_ t: T, _ u: U) -> R { _apply(t, u) }
  }
}
