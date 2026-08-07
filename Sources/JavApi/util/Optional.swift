/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  /// Swift implementation of `java.util.Optional`.
  ///
  /// A container object that may or may not contain a non-null value.
  /// Designed to avoid `NullPointerException` (i.e., forced Swift unwrapping)
  /// by making the absence of a value explicit in the type system.
  ///
  /// **Difference from Swift's built-in `Optional<T>`:** `java.util.Optional`
  /// is a *class* (reference type) with its own API surface (`isPresent()`,
  /// `get()`, `orElse(_:)`, …) and must be referred to by its fully-qualified
  /// name `java.util.Optional<T>` to distinguish it from Swift's `T?`.
  ///
  /// - Since: Java 8
  open class Optional<T> {

    // MARK: - Backing store

    private let _value: T?

    // MARK: - Private init

    private init(_ value: T?) {
      self._value = value
    }

    // MARK: - Factory methods

    /// Returns an empty `Optional` instance (no value present).
    public static func empty() -> java.util.Optional<T> {
      java.util.Optional<T>(nil)
    }

    /// Returns an `Optional` describing the given non-nil value.
    ///
    /// - Parameter value: The value to describe (must not be nil for the
    ///   intended Java semantics; use `ofNullable(_:)` when nil is possible).
    public static func of(_ value: T) -> java.util.Optional<T> {
      java.util.Optional<T>(value)
    }

    /// Returns an `Optional` describing the given value, or an empty
    /// `Optional` if the value is nil.
    public static func ofNullable(_ value: T?) -> java.util.Optional<T> {
      java.util.Optional<T>(value)
    }

    // MARK: - Value access

    /// Returns the contained value.
    ///
    /// - Throws: `NoSuchElementException` if no value is present.
    open func get() throws -> T {
      guard let v = _value else {
        throw java.util.NoSuchElementException("No value present")
      }
      return v
    }

    // MARK: - Presence checks

    /// Returns `true` if a value is present.
    open func isPresent() -> Bool { _value != nil }

    /// Returns `true` if no value is present (Java 11+).
    open func isEmpty() -> Bool { _value == nil }

    // MARK: - Conditional execution

    /// Calls `consumer` with the contained value if present; otherwise does nothing.
    open func ifPresent(_ consumer: (T) -> Void) {
      if let v = _value { consumer(v) }
    }

    /// If a value is present and matches `predicate`, calls `consumer`;
    /// otherwise does nothing (Java 9+).
    open func ifPresentOrElse(_ consumer: (T) -> Void, _ emptyAction: () -> Void) {
      if let v = _value { consumer(v) } else { emptyAction() }
    }

    // MARK: - Alternative value

    /// Returns the contained value if present, otherwise returns `other`.
    open func orElse(_ other: T) -> T { _value ?? other }

    /// Returns the contained value if present, otherwise invokes `supplier`
    /// and returns its result.
    open func orElseGet(_ supplier: () -> T) -> T { _value ?? supplier() }

    /// Returns the contained value if present, otherwise throws an exception
    /// produced by `exceptionSupplier`.
    ///
    /// - Throws: The exception returned by `exceptionSupplier` when empty.
    open func orElseThrow<X: Error>(_ exceptionSupplier: () -> X) throws -> T {
      guard let v = _value else { throw exceptionSupplier() }
      return v
    }

    /// Returns the contained value if present, otherwise throws
    /// `NoSuchElementException` (Java 10+).
    ///
    /// - Throws: `NoSuchElementException` if no value is present.
    open func orElseThrow() throws -> T {
      guard let v = _value else {
        throw java.util.NoSuchElementException("No value present")
      }
      return v
    }

    // MARK: - Transformation

    /// If a value is present, applies `mapper` to it and returns an
    /// `Optional` describing the result; otherwise returns an empty `Optional`.
    open func map<U>(_ mapper: (T) -> U?) -> java.util.Optional<U> {
      guard let v = _value else { return java.util.Optional<U>.empty() }
      return java.util.Optional<U>.ofNullable(mapper(v))
    }

    /// If a value is present, applies `mapper` to it and returns the result
    /// (which must itself be an `Optional`); otherwise returns empty.
    open func flatMap<U>(_ mapper: (T) -> java.util.Optional<U>) -> java.util.Optional<U> {
      guard let v = _value else { return java.util.Optional<U>.empty() }
      return mapper(v)
    }

    /// If a value is present and matches `predicate`, returns this `Optional`;
    /// otherwise returns an empty `Optional`.
    open func filter(_ predicate: (T) -> Bool) -> java.util.Optional<T> {
      guard let v = _value, predicate(v) else { return java.util.Optional<T>.empty() }
      return self
    }

    /// If a value is present, returns this `Optional`; otherwise returns the
    /// `Optional` produced by `supplier` (Java 9+).
    open func or(_ supplier: () -> java.util.Optional<T>) -> java.util.Optional<T> {
      _value != nil ? self : supplier()
    }

    // MARK: - Swift interop

    /// Returns the underlying Swift `Optional<T>` value for bridging.
    open func swiftOptional() -> T? { _value }
  }
}

// MARK: - Equatable conformance

extension java.util.Optional: Equatable where T: Equatable {
  public static func == (lhs: java.util.Optional<T>, rhs: java.util.Optional<T>) -> Bool {
    lhs._value == rhs._value
  }
}

// MARK: - CustomStringConvertible

extension java.util.Optional: CustomStringConvertible {
  public var description: String {
    if let v = _value { return "Optional[\(v)]" }
    return "Optional.empty"
  }
}
