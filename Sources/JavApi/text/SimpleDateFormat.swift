/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.text {

  /// Formats and parses dates using a user-defined pattern.
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
    // MARK: Format / parse
    // -------------------------------------------------------------------------
    // Foundation's DateFormatter does not support Java's `S` (milliseconds)
    // pattern letter.  We handle it by replacing each unquoted S-run with a
    // unique quoted placeholder before passing the pattern to Foundation, then
    // substituting the real millisecond value in the output string.

    /// Formats a `java.util.Date` to a `String` using the stored pattern.
    ///
    /// Handles the `S` (millisecond) pattern letter which Foundation does not support.
    public override func format(_ date: java.util.Date) -> String {
      // Fast path: no 'S' in pattern at all
      guard _pattern.contains("S") else {
        return formatter.string(from: date.delegate)
      }
      let ms = Int(date.getTime() % 1000)
      // Build a temporary Foundation pattern with S-runs replaced by placeholders,
      // format, then swap placeholders back for the real millisecond string.
      let (tempPattern, tokens) = Self.extractSTokens(from: Self.toUnicodePattern(_pattern))
      let tempFormatter = Foundation.DateFormatter()
      tempFormatter.locale = formatter.locale
      tempFormatter.timeZone = formatter.timeZone
      tempFormatter.dateFormat = tempPattern
      var output = tempFormatter.string(from: date.delegate)
      // Replace placeholders in reverse order (to keep indices stable)
      for (placeholder, width) in tokens.reversed() {
        let msStr = String(format: "%03d", ms)
        let replacement: String
        if width <= 3 {
          replacement = String(msStr.prefix(width))
        } else {
          replacement = msStr + String(repeating: "0", count: width - 3)
        }
        output = output.replacingOccurrences(of: placeholder, with: replacement)
      }
      return output
    }

    /// Scans `pattern` for unquoted `S+` runs, replaces each with a unique
    /// quoted placeholder, and returns the modified pattern together with a list
    /// of `(placeholder, originalWidth)` pairs in appearance order.
    private static func extractSTokens(from pattern: String) -> (String, [(String, Int)]) {
      var result = ""
      var tokens: [(String, Int)] = []
      var tokenIndex = 0
      var i = pattern.startIndex
      while i < pattern.endIndex {
        let ch = pattern[i]
        if ch == "'" {
          // Quoted literal — copy verbatim
          result.append(ch)
          i = pattern.index(after: i)
          while i < pattern.endIndex {
            let q = pattern[i]
            result.append(q)
            i = pattern.index(after: i)
            if q == "'" { break }
          }
          continue
        }
        if ch == "S" {
          var count = 0
          while i < pattern.endIndex && pattern[i] == "S" {
            count += 1
            i = pattern.index(after: i)
          }
          // Use a placeholder that Foundation will output literally.
          // We use a distinctive string unlikely to appear in date output.
          let placeholder = "\u{FFFE}\(tokenIndex)\u{FFFE}"
          tokens.append((placeholder, count))
          tokenIndex += 1
          result += "'\(placeholder)'"
          continue
        }
        result.append(ch)
        i = pattern.index(after: i)
      }
      return (result, tokens)
    }

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
