/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.util {

  /// Conformers get full control over their own `%s`/`%S` rendering inside
  /// `java.util.Formatter`/`String.format`, instead of falling back to a
  /// plain `toString()`-based conversion.
  ///
  /// Mirrors `java.util.Formattable` (Java 5).
  ///
  /// ## Usage
  ///
  /// ```swift
  /// struct Money: java.util.Formattable {
  ///   let cents: Int
  ///   func formatTo(_ formatter: java.util.Formatter, _ flags: Int, _ width: Int, _ precision: Int) throws {
  ///     let upper = flags & java.util.FormattableFlags.UPPERCASE != 0
  ///     var s = String(format: "%d.%02d", cents / 100, cents % 100)
  ///     if upper { s = s.uppercased() }
  ///     _ = try formatter.out().append(s)
  ///   }
  /// }
  ///
  /// String.format("%s", Money(cents: 1234)) // "12.34"
  /// ```
  ///
  /// - Since: Java 5
  public protocol Formattable {

    /// Formats `self` using the given `formatter`, appending the result to
    /// `formatter`'s output.
    ///
    /// - Parameters:
    ///   - formatter: The `Formatter` to append output to.
    ///   - flags:     A bitmask of `FormattableFlags` values (`LEFT_JUSTIFY`,
    ///                `UPPERCASE`, `ALTERNATE`).
    ///   - width:     The minimum number of characters to write, or `-1` if
    ///                no width was specified.
    ///   - precision: The maximum number of characters to write, or `-1` if
    ///                no precision was specified.
    /// - Throws: Any error raised while appending to `formatter`'s output
    ///   (e.g. `FormatterClosedException`).
    func formatTo(_ formatter: java.util.Formatter, _ flags: Int, _ width: Int, _ precision: Int) throws
  }

  /// Flag constants for ``Formattable/formatTo(_:_:_:_:)``.
  ///
  /// Java declares these as static constants directly on the `Formattable`
  /// interface (`Formattable.LEFT_JUSTIFY`, etc.). Swift protocols cannot
  /// host static members that are reachable through the protocol name
  /// itself (only through a conforming concrete type), so this port groups
  /// them under a dedicated, Java2Swift.md-style companion type instead.
  ///
  /// - Since: Java 5
  public enum FormattableFlags {

    /// The output should be left-justified, i.e. `'-'` was present.
    public static let LEFT_JUSTIFY: Int = 1

    /// The output should be converted to upper case, i.e. the `'S'`
    /// conversion (rather than `'s'`) was used.
    public static let UPPERCASE: Int = 2

    /// The output should use an alternate form, i.e. `'#'` was present.
    public static let ALTERNATE: Int = 4
  }
}
