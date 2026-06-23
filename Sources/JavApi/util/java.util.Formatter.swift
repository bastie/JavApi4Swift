/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.util {

  /// A Java-compatible `java.util.Formatter`.
  ///
  /// Accumulates formatted output in an internal `StringBuilder` and delegates
  /// all format-string translation to `Java2SwiftFormatter`.
  ///
  /// ## Typical usage
  ///
  /// ```swift
  /// let f = java.util.Formatter()
  /// f.format("Hello, %s! You have %,d messages.%n", "Alice", 1_234)
  /// print(f.toString())
  /// ```
  ///
  /// The class is intentionally minimal: it covers the common API surface that
  /// Java code exercises via `String.format(...)` / `System.out.printf(...)`.
  public class Formatter {

    private var buffer = StringBuilder()

    // -------------------------------------------------------------------------
    // MARK: Initialisierung
    // -------------------------------------------------------------------------

    /// Creates a `Formatter` that writes to an internal `StringBuilder`.
    public init() {}

    // -------------------------------------------------------------------------
    // MARK: format
    // -------------------------------------------------------------------------

    /// Formats `args` according to the Java format string `fmt` and appends
    /// the result to the internal buffer.
    ///
    /// - Parameters:
    ///   - fmt:  A Java-style format string.
    ///   - args: The arguments referenced by the format string.
    /// - Returns: `self` (Java convention; allows chaining).
    @discardableResult
    public func format(_ fmt: String, _ args: Any?...) -> Formatter {
      _ = buffer.append(Java2SwiftFormatter.format(fmt, args: args))
      return self
    }

    /// Array overload — used when the caller already has `[Any?]`.
    @discardableResult
    public func format(_ fmt: String, args: [Any?]) -> Formatter {
      _ = buffer.append(Java2SwiftFormatter.format(fmt, args: args))
      return self
    }

    // -------------------------------------------------------------------------
    // MARK: Output
    // -------------------------------------------------------------------------

    /// Returns the accumulated output as a `String`.
    public func toString() -> String {
      buffer.toString()
    }

    /// Returns the underlying `StringBuilder` (Java `out()` returns `Appendable`).
    public func out() -> StringBuilder {
      buffer
    }

    /// Clears the internal buffer (not in Java API, but useful in Swift).
    public func clear() {
      buffer = StringBuilder()
    }
  }
}
