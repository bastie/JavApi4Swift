/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - BiPredicate<T, U>

extension java.util.function {
  /// Represents a predicate (boolean-valued function) of two arguments.
  ///
  /// This is a Java-API-compatible functional interface whose functional method is ``test(_:_:)``.
  ///
  /// Use ``AnyBiPredicate`` to wrap a Swift closure:
  /// ```swift
  /// let bothPositive = AnyBiPredicate<Int, Int> { $0 > 0 && $1 > 0 }
  /// bothPositive.test(1, 2)  // true
  /// bothPositive.test(1, -1) // false
  /// ```
  ///
  /// - Since: Java 8
  public protocol BiPredicate<T, U> {
    associatedtype T
    associatedtype U
    /// Evaluates this predicate on the given arguments.
    func test(_ t: T, _ u: U) -> Bool
  }
}

// MARK: - Default methods (Java-compatible)

extension java.util.function.BiPredicate {
  /// Returns a composed predicate that is the logical AND of this and `other`.
  public func and(_ other: some java.util.function.BiPredicate<T, U>) -> java.util.function.AnyBiPredicate<T, U> {
    java.util.function.AnyBiPredicate<T, U> { [self] t, u in self.test(t, u) && other.test(t, u) }
  }

  /// Returns a composed predicate that is the logical OR of this and `other`.
  public func or(_ other: some java.util.function.BiPredicate<T, U>) -> java.util.function.AnyBiPredicate<T, U> {
    java.util.function.AnyBiPredicate<T, U> { [self] t, u in self.test(t, u) || other.test(t, u) }
  }

  /// Returns a predicate that is the logical negation of this predicate.
  public func negate() -> java.util.function.AnyBiPredicate<T, U> {
    java.util.function.AnyBiPredicate<T, U> { [self] t, u in !self.test(t, u) }
  }
}

// MARK: - AnyBiPredicate<T, U> — closure-based concrete implementation

extension java.util.function {
  /// A concrete ``BiPredicate`` that wraps a Swift closure.
  ///
  /// Use this to bridge Swift closures into the Java-API-compatible ``BiPredicate`` protocol.
  public struct AnyBiPredicate<T, U>: java.util.function.BiPredicate {
    private let _test: (T, U) -> Bool

    /// Creates a bi-predicate from a Swift closure.
    public init(_ test: @escaping (T, U) -> Bool) {
      _test = test
    }

    public func test(_ t: T, _ u: U) -> Bool { _test(t, u) }
  }
}
