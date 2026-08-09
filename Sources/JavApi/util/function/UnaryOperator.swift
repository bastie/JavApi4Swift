/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - UnaryOperator<T>

extension java.util.function {
  /// Represents an operation on a single operand that produces a result of the same type.
  ///
  /// This extends ``Function`` where the input and output type are the same.
  /// The functional method is ``apply(_:)``, inherited from ``Function``.
  ///
  /// Use ``AnyUnaryOperator`` to wrap a Swift closure:
  /// ```swift
  /// let negate = AnyUnaryOperator<Int> { -$0 }
  /// negate.apply(5) // -5
  /// ```
  public protocol UnaryOperator<T>: java.util.function.Function where R == T {}
}

// MARK: - AnyUnaryOperator<T> — closure-based concrete implementation

extension java.util.function {
  /// A concrete ``UnaryOperator`` that wraps a Swift closure.
  public struct AnyUnaryOperator<T>: java.util.function.UnaryOperator {
    public typealias R = T
    private let _apply: (T) -> T

    /// Creates a unary operator from a Swift closure.
    public init(_ apply: @escaping (T) -> T) {
      _apply = apply
    }

    public func apply(_ t: T) -> T { _apply(t) }
  }
}
