/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - Consumer<T>

extension java.util.function {
  /// Represents an operation that accepts a single input argument and returns no result.
  ///
  /// This is a Java-API-compatible functional interface whose functional method is ``accept(_:)``.
  ///
  /// Use ``AnyConsumer`` to wrap a Swift closure:
  /// ```swift
  /// let printer = AnyConsumer<String> { print($0) }
  /// printer.accept("hello")
  /// ```
  public protocol Consumer<T> {
    associatedtype T
    /// Performs this operation on the given argument.
    func accept(_ t: T)
  }
}

// MARK: - Default methods (Java-compatible)

extension java.util.function.Consumer {
  /// Returns a composed consumer that performs this, then `after`.
  public func andThen(_ after: some java.util.function.Consumer<T>) -> java.util.function.AnyConsumer<T> {
    java.util.function.AnyConsumer<T> { [self] t in
      self.accept(t)
      after.accept(t)
    }
  }
}

// MARK: - AnyConsumer<T> — closure-based concrete implementation

extension java.util.function {
  /// A concrete ``Consumer`` that wraps a Swift closure.
  public struct AnyConsumer<T>: java.util.function.Consumer {
    private let _accept: (T) -> Void

    /// Creates a consumer from a Swift closure.
    public init(_ accept: @escaping (T) -> Void) {
      _accept = accept
    }

    public func accept(_ t: T) { _accept(t) }
  }
}
