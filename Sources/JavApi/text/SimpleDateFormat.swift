/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.text {

  /// Formats and parses dates using a user-defined pattern.
  ///
  /// Mirrors `java.text.SimpleDateFormat`.
  ///
  /// ## Pattern letters
  ///
  /// | Letter | Component         | Example |
  /// |--------|-------------------|---------|
  /// | `G`    | Era               | AD      |
  /// | `y`    | Year              | 2026    |
  /// | `Y`    | Week-year         | 2026    |
  /// | `M`/`L`| Month             | July / 07 |
  /// | `w`    | Week in year      | 27      |
  /// | `W`    | Week in month     | 2       |
  /// | `D`    | Day in year       | 189     |
  /// | `d`    | Day in month      | 10      |
  /// | `F`    | Day of week in month | 2   |
  /// | `E`    | Day name          | Tuesday |
  /// | `u`    | Day number (1=Mon)| 2       |
  /// | `a`    | AM/PM             | PM      |
  /// | `H`    | Hour 0-23         | 13      |
  /// | `k`    | Hour 1-24         | 13      |
  /// | `K`    | Hour 0-11         | 0       |
  /// | `h`    | Hour 1-12         | 12      |
  /// | `m`    | Minute            | 30      |
  /// | `s`    | Second            | 55      |
  /// | `S`    | Milliseconds      | 978     |
  /// | `z`    | General time zone | Pacific Standard Time |
  /// | `Z`    | RFC 822 offset    | -0800   |
  /// | `X`    | ISO 8601 offset   | -08     |
  ///
  /// Quoted literals are enclosed in single quotes: `'T'`, `''''` for a literal `'`.
  ///
  /// - Since: Java 1.1
  open class SimpleDateFormat: DateFormat {

    // -------------------------------------------------------------------------
    // MARK: Stored pattern (Java syntax)
    // -------------------------------------------------------------------------

    private var _pattern: String

    // -------------------------------------------------------------------------
    // MARK: Initializers
    // -------------------------------------------------------------------------

    /// Creates a `SimpleDateFormat` using the default locale and the given pattern.
    public init(_ pattern: String) {
      self._pattern = pattern
      let df = Foundation.DateFormatter()
      df.locale = java.util.Locale.getDefault().delegate ?? Foundation.Locale.current
      df.dateFormat = Self.toUnicodePattern(pattern)
      super.init(df)
    }

    /// Creates a `SimpleDateFormat` with an explicit locale.
    public init(_ pattern: String, _ locale: java.util.Locale) {
      self._pattern = pattern
      let df = Foundation.DateFormatter()
      df.locale = locale.delegate ?? Foundation.Locale.current
      df.dateFormat = Self.toUnicodePattern(pattern)
      super.init(df)
    }

    // -------------------------------------------------------------------------
    // MARK: Pattern access
    // -------------------------------------------------------------------------

    /// Returns the Java-style pattern string.
    public func toPattern() -> String { _pattern }

    /// Applies a new Java-style pattern.
    public func applyPattern(_ pattern: String) {
      _pattern = pattern
      formatter.dateFormat = Self.toUnicodePattern(pattern)
    }

    // -------------------------------------------------------------------------
    // MARK: Format / parse  (inherited from DateFormat)
    // -------------------------------------------------------------------------
    // DateFormat.format(_:) and parse(_:) delegate to self.formatter, so they
    // work automatically with the dateFormat we set above.

    // -------------------------------------------------------------------------
    // MARK: Java → Unicode CLDR pattern translation
    // -------------------------------------------------------------------------

    /// Converts a Java `SimpleDateFormat` pattern to a Unicode / CLDR pattern
    /// suitable for `Foundation.DateFormatter`.
    ///
    /// Most letters are identical between the two systems; the differences are:
    /// - Java `u` (day number, 1=Monday) → `e` in CLDR
    /// - Java `Y` (week year) is the same in CLDR
    /// - Quoted literals `'text'` → kept as-is (both use `'`)
    /// - `''''` (escaped single quote) → kept as-is
    static func toUnicodePattern(_ java: String) -> String {
      // The two pattern languages are almost identical; Foundation's DateFormatter
      // already accepts Unicode CLDR patterns which overlap ~95% with Java's.
      // We only need to handle the known divergences.
      var result = ""
      var i = java.startIndex
      while i < java.endIndex {
        let ch = java[i]
        // Quoted literal — copy verbatim (both systems use single-quote quoting)
        if ch == "'" {
          result.append(ch)
          i = java.index(after: i)
          while i < java.endIndex {
            let q = java[i]
            result.append(q)
            i = java.index(after: i)
            if q == "'" { break }
          }
          continue
        }
        // Java 'u' (ISO day-of-week, 1=Monday) → CLDR 'e' (same semantics)
        if ch == "u" {
          result.append("e")
          i = java.index(after: i)
          continue
        }
        // Everything else passes through unchanged
        result.append(ch)
        i = java.index(after: i)
      }
      return result
    }
  }
}
