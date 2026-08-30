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
  /// try f.format("Hello, %s! You have %,d messages.%n", "Alice", 1_234)
  /// print(try f.toString())
  /// ```
  ///
  /// The class is intentionally minimal: it covers the common API surface that
  /// Java code exercises via `String.format(...)` / `System.out.printf(...)`.
  public class Formatter {

    private var buffer = StringBuilder()

    /// Whether a `Locale` was passed explicitly to the constructor — Java
    /// distinguishes "no locale specified" (use the global default at
    /// format-time) from "explicit `nil` locale" (no localization at all,
    /// `Locale.ROOT`-like behaviour); `hasExplicitLocale` records which case
    /// applies, `explicitLocale` holds the value for the latter two cases.
    private var hasExplicitLocale = false
    private var explicitLocale: java.util.Locale?

    /// Whether `close()` has been called — every subsequent `format`/`out`/
    /// `toString`/`flush` call throws `FormatterClosedException`, matching
    /// Java's documented behaviour.
    private var _closed = false

    // -------------------------------------------------------------------------
    // MARK: Initialisierung
    // -------------------------------------------------------------------------

    /// Creates a `Formatter` that writes to an internal `StringBuilder`,
    /// using the global `java.util.Locale.getDefault()` for every `format`
    /// call — matches Java's `Formatter()`.
    public init() {}

    /// Creates a `Formatter` with an explicit `Locale`, used for every
    /// subsequent `format(_:_:)` call unless overridden per-call — matches
    /// Java's `Formatter(Locale l)`.
    ///
    /// - Parameter locale: The `Locale` to format with, or `nil` for no
    ///   localization (matches Java's documented `null`-`Locale` behaviour).
    public init(_ locale: java.util.Locale?) {
      self.hasExplicitLocale = true
      self.explicitLocale = locale
    }

    // -------------------------------------------------------------------------
    // MARK: format
    // -------------------------------------------------------------------------

    /// Formats `args` according to the Java format string `fmt` and appends
    /// the result to the internal buffer, using this `Formatter`'s locale
    /// (explicit constructor locale if given, otherwise the global
    /// `java.util.Locale.getDefault()` at call time).
    ///
    /// - Parameters:
    ///   - fmt:  A Java-style format string.
    ///   - args: The arguments referenced by the format string.
    /// - Returns: `self` (Java convention; allows chaining).
    /// - Throws: `FormatterClosedException` if `close()` has already been
    ///   called on this `Formatter`, or an appropriate
    ///   `java.util.IllegalFormatException` subclass if `fmt`/`args` don't
    ///   match — see `Java2SwiftFormatter.format(_:args:)`.
    @discardableResult
    public func format(_ fmt: String, _ args: Any?...) throws -> Formatter {
      try checkNotClosed()
      _ = buffer.append(try formatted(fmt, args: args))
      return self
    }

    /// Array overload — used when the caller already has `[Any?]`.
    ///
    /// - Throws: `FormatterClosedException` if `close()` has already been
    ///   called on this `Formatter`, or an appropriate
    ///   `java.util.IllegalFormatException` subclass if `fmt`/`args` don't
    ///   match — see `Java2SwiftFormatter.format(_:args:)`.
    @discardableResult
    public func format(_ fmt: String, args: [Any?]) throws -> Formatter {
      try checkNotClosed()
      _ = buffer.append(try formatted(fmt, args: args))
      return self
    }

    /// Formats `args` with an explicit `Locale` for this call only — matches
    /// Java's `Formatter.format(Locale l, String format, Object... args)`.
    /// This does **not** change the `Locale` used by subsequent calls to the
    /// no-locale `format(_:_:)` overload.
    ///
    /// - Parameters:
    ///   - locale: The `Locale` to format this call with, or `nil` for no
    ///     localization.
    ///   - fmt:    A Java-style format string.
    ///   - args:   The arguments referenced by the format string.
    /// - Returns: `self` (Java convention; allows chaining).
    ///
    /// - Throws: `FormatterClosedException` if `close()` has already been
    ///   called on this `Formatter`, or an appropriate
    ///   `java.util.IllegalFormatException` subclass if `fmt`/`args` don't
    ///   match — see `Java2SwiftFormatter.format(_:args:locale:)`.
    @discardableResult
    public func format(_ locale: java.util.Locale?, _ fmt: String, _ args: Any?...) throws -> Formatter {
      try checkNotClosed()
      _ = buffer.append(try Java2SwiftFormatter.format(fmt, args: args, locale: locale))
      return self
    }

    /// Array overload of `format(_:_:_:)`.
    ///
    /// - Throws: `FormatterClosedException` if `close()` has already been
    ///   called on this `Formatter`, or an appropriate
    ///   `java.util.IllegalFormatException` subclass if `fmt`/`args` don't
    ///   match — see `Java2SwiftFormatter.format(_:args:locale:)`.
    @discardableResult
    public func format(_ locale: java.util.Locale?, _ fmt: String, args: [Any?]) throws -> Formatter {
      try checkNotClosed()
      _ = buffer.append(try Java2SwiftFormatter.format(fmt, args: args, locale: locale))
      return self
    }

    /// Returns the `Locale` this `Formatter` was constructed with, or the
    /// current global default if none was specified — matches Java's
    /// `Formatter.locale()`.
    public func locale() -> java.util.Locale? {
      hasExplicitLocale ? explicitLocale : java.util.Locale.getDefault()
    }

    /// Routes to the explicit-locale or default-locale `Java2SwiftFormatter`
    /// entry point depending on how this `Formatter` was constructed.
    private func formatted(_ fmt: String, args: [Any?]) throws -> String {
      try hasExplicitLocale
        ? Java2SwiftFormatter.format(fmt, args: args, locale: explicitLocale)
        : Java2SwiftFormatter.format(fmt, args: args)
    }

    // -------------------------------------------------------------------------
    // MARK: Output
    // -------------------------------------------------------------------------

    /// Returns the accumulated output as a `String`.
    ///
    /// - Throws: `FormatterClosedException` if `close()` has already been
    ///   called on this `Formatter`.
    public func toString() throws -> String {
      try checkNotClosed()
      return buffer.toString()
    }

    /// Returns the underlying `StringBuilder` (Java `out()` returns `Appendable`).
    ///
    /// - Throws: `FormatterClosedException` if `close()` has already been
    ///   called on this `Formatter`.
    public func out() throws -> StringBuilder {
      try checkNotClosed()
      return buffer
    }

    /// Flushes this `Formatter` — a no-op beyond the closed-state check,
    /// since the backing `StringBuilder` has no buffering of its own.
    ///
    /// - Throws: `FormatterClosedException` if `close()` has already been
    ///   called on this `Formatter`.
    public func flush() throws {
      try checkNotClosed()
    }

    /// Closes this `Formatter`. Once closed, `format(...)`, `out()`,
    /// `toString()`, and `flush()` all throw `FormatterClosedException`.
    /// Calling `close()` on an already-closed `Formatter` has no effect,
    /// matching Java's documented behaviour.
    public func close() {
      _closed = true
    }

    /// Returns the last `IOException` thrown by this `Formatter`'s
    /// destination, or `nil` if none was thrown.
    ///
    /// Always returns `nil` in this port: the backing store is an in-memory
    /// `StringBuilder`, which never throws an I/O exception.
    public func ioException() -> (any Error)? {
      nil
    }

    /// Clears the internal buffer (not in Java API, but useful in Swift).
    public func clear() {
      buffer = StringBuilder()
    }

    /// - Throws: `FormatterClosedException` if this `Formatter` has been
    ///   closed via `close()`.
    private func checkNotClosed() throws {
      if _closed {
        throw FormatterClosedException()
      }
    }
  }
}
