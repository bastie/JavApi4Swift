/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - BinaryOperator<T>

extension java.util.function {
  /// Represents an operation upon two operands of the same type, producing a result of the same type.
  ///
  /// This extends ``BiFunction`` where all types (both inputs and result) are the same.
  /// The functional method is ``apply(_:_:)``, inherited from ``BiFunction``.
  ///
  /// Use ``AnyBinaryOperator`` to wrap a Swift closure:
  /// ```swift
  /// let add = AnyBinaryOperator<Int> { $0 + $1 }
  /// add.apply(3, 4) // 7
  /// ```
  public protocol BinaryOperator<T>: java.util.function.BiFunction where U == T, R == T {}
}

// MARK: - Default methods (Java-compatible)

extension java.util.function.BinaryOperator {
  /// Returns a binary operator that returns the lesser of two elements according to `comparator`.
  public static func minBy(_ comparator: some java.util.Comparator<T>) -> java.util.function.AnyBinaryOperator<T> {
    java.util.function.AnyBinaryOperator<T> { a, b in
      comparator.compare(a, b) <= 0 ? a : b
    }
  }

  /// Returns a binary operator that returns the greater of two elements according to `comparator`.
  public static func maxBy(_ comparator: some java.util.Comparator<T>) -> java.util.function.AnyBinaryOperator<T> {
    java.util.function.AnyBinaryOperator<T> { a, b in
      comparator.compare(a, b) >= 0 ? a : b
    }
  }
}

// MARK: - AnyBinaryOperator<T> — closure-based concrete implementation

extension java.util.function {
  /// A concrete ``BinaryOperator`` that wraps a Swift closure.
  public struct AnyBinaryOperator<T>: java.util.function.BinaryOperator {
    public typealias U = T
    public typealias R = T
    private let _apply: (T, T) -> T

    /// Creates a binary operator from a Swift closure.
    public init(_ apply: @escaping (T, T) -> T) {
      _apply = apply
    }

    public func apply(_ t: T, _ u: T) -> T { _apply(t, u) }
  }
}
