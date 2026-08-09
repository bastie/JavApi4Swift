/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - Function<T,R>

extension java.util.function {
  /// Represents a function that accepts one argument and produces a result.
  ///
  /// This is a Java-API-compatible functional interface whose functional method is ``apply(_:)``.
  ///
  /// Use ``AnyFunction`` to wrap a Swift closure:
  /// ```swift
  /// let toLength = AnyFunction<String, Int> { $0.count }
  /// toLength.apply("hello") // 5
  /// ```
  public protocol Function<T, R> {
    associatedtype T
    associatedtype R
    /// Applies this function to the given argument.
    func apply(_ t: T) -> R
  }
}

// MARK: - Default methods (Java-compatible)

extension java.util.function.Function {
  /// Returns a composed function that first applies this, then `after`.
  public func andThen<V>(_ after: some java.util.function.Function<R, V>) -> java.util.function.AnyFunction<T, V> {
    java.util.function.AnyFunction<T, V> { [self] t in after.apply(self.apply(t)) }
  }

  /// Returns a composed function that first applies `before`, then this.
  public func compose<V>(_ before: some java.util.function.Function<V, T>) -> java.util.function.AnyFunction<V, R> {
    java.util.function.AnyFunction<V, R> { [self] v in self.apply(before.apply(v)) }
  }

  /// Returns a function that always returns its input argument.
  public static func identity() -> java.util.function.AnyFunction<T, T> {
    java.util.function.AnyFunction<T, T> { t in t }
  }
}

// MARK: - AnyFunction<T,R> — closure-based concrete implementation

extension java.util.function {
  /// A concrete ``Function`` that wraps a Swift closure.
  public struct AnyFunction<T, R>: java.util.function.Function {
    private let _apply: (T) -> R

    /// Creates a function from a Swift closure.
    public init(_ apply: @escaping (T) -> R) {
      _apply = apply
    }

    public func apply(_ t: T) -> R { _apply(t) }
  }
}
