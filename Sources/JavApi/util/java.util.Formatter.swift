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

    /// Whether a `Locale` was passed explicitly to the constructor — Java
    /// distinguishes "no locale specified" (use the global default at
    /// format-time) from "explicit `nil` locale" (no localization at all,
    /// `Locale.ROOT`-like behaviour); `hasExplicitLocale` records which case
    /// applies, `explicitLocale` holds the value for the latter two cases.
    private var hasExplicitLocale = false
    private var explicitLocale: java.util.Locale?

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
    @discardableResult
    public func format(_ fmt: String, _ args: Any?...) -> Formatter {
      _ = buffer.append(formatted(fmt, args: args))
      return self
    }

    /// Array overload — used when the caller already has `[Any?]`.
    @discardableResult
    public func format(_ fmt: String, args: [Any?]) -> Formatter {
      _ = buffer.append(formatted(fmt, args: args))
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
    @discardableResult
    public func format(_ locale: java.util.Locale?, _ fmt: String, _ args: Any?...) -> Formatter {
      _ = buffer.append(Java2SwiftFormatter.format(fmt, args: args, locale: locale))
      return self
    }

    /// Array overload of `format(_:_:_:)`.
    @discardableResult
    public func format(_ locale: java.util.Locale?, _ fmt: String, args: [Any?]) -> Formatter {
      _ = buffer.append(Java2SwiftFormatter.format(fmt, args: args, locale: locale))
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
    private func formatted(_ fmt: String, args: [Any?]) -> String {
      hasExplicitLocale
        ? Java2SwiftFormatter.format(fmt, args: args, locale: explicitLocale)
        : Java2SwiftFormatter.format(fmt, args: args)
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
