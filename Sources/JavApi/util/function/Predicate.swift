/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - Predicate<T>

extension java.util.function {
  /// Represents a predicate (boolean-valued function) of one argument.
  ///
  /// This is a Java-API-compatible functional interface whose functional method is ``test(_:)``.
  ///
  /// Use ``AnyPredicate`` to wrap a Swift closure as a ``Predicate``:
  /// ```swift
  /// let isPositive = AnyPredicate<Int> { $0 > 0 }
  /// isPositive.test(42) // true
  /// ```
  public protocol Predicate<T> {
    associatedtype T
    /// Evaluates this predicate on the given argument.
    func test(_ t: T) -> Bool
  }
}

// MARK: - Default methods (Java-compatible)

extension java.util.function.Predicate {
  /// Returns a composed predicate that is the logical AND of this and `other`.
  public func and(_ other: some java.util.function.Predicate<T>) -> java.util.function.AnyPredicate<T> {
    java.util.function.AnyPredicate<T> { [self] t in self.test(t) && other.test(t) }
  }

  /// Returns a composed predicate that is the logical OR of this and `other`.
  public func or(_ other: some java.util.function.Predicate<T>) -> java.util.function.AnyPredicate<T> {
    java.util.function.AnyPredicate<T> { [self] t in self.test(t) || other.test(t) }
  }

  /// Returns a predicate that is the logical negation of this predicate.
  public func negate() -> java.util.function.AnyPredicate<T> {
    java.util.function.AnyPredicate<T> { [self] t in !self.test(t) }
  }

  /// Returns a predicate that is the logical negation of `target`.
  public static func not(_ target: some java.util.function.Predicate<T>) -> java.util.function.AnyPredicate<T> {
    target.negate()
  }
}

// MARK: - AnyPredicate<T> — closure-based concrete implementation

extension java.util.function {
  /// A concrete ``Predicate`` that wraps a Swift closure.
  ///
  /// Use this to bridge Swift closures into the Java-API-compatible ``Predicate`` protocol.
  public struct AnyPredicate<T>: java.util.function.Predicate {
    private let _test: (T) -> Bool

    /// Creates a predicate from a Swift closure.
    public init(_ test: @escaping (T) -> Bool) {
      _test = test
    }

    public func test(_ t: T) -> Bool { _test(t) }
  }
}
