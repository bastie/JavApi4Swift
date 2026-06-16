/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.text {

  /// Formats and parses dates in a locale-sensitive way.
  ///
  /// Mirrors `java.text.DateFormat`.
  ///
  /// Use the factory methods to obtain an instance rather than calling the
  /// initialiser directly.
  ///
  /// - Since: Java 1.1
  open class DateFormat: Format {

    // -------------------------------------------------------------------------
    // MARK: Style constants (mirrors java.text.DateFormat)
    // -------------------------------------------------------------------------

    public static let FULL:   Int = 0
    public static let LONG:   Int = 1
    public static let MEDIUM: Int = 2
    public static let SHORT:  Int = 3
    public static let DEFAULT: Int = MEDIUM

    // -------------------------------------------------------------------------
    // MARK: Backing formatter
    // -------------------------------------------------------------------------

    let formatter: Foundation.DateFormatter

    init(_ formatter: Foundation.DateFormatter) {
      self.formatter = formatter
    }

    // -------------------------------------------------------------------------
    // MARK: Factory methods
    // -------------------------------------------------------------------------

    /// Returns a date-only format with `DEFAULT` style for the default locale.
    public static func getDateInstance() -> DateFormat {
      return getDateInstance(DEFAULT, locale: java.util.Locale.getDefault())
    }

    /// Returns a date-only format for `locale`.
    public static func getDateInstance(_ style: Int, locale: java.util.Locale = java.util.Locale.getDefault()) -> DateFormat {
      let f = Foundation.DateFormatter()
      f.locale = locale.delegate
      f.timeStyle = .none
      f.dateStyle = dateStyle(for: style)
      return DateFormat(f)
    }

    /// Returns a time-only format with `DEFAULT` style for the default locale.
    public static func getTimeInstance() -> DateFormat {
      return getTimeInstance(DEFAULT, locale: java.util.Locale.getDefault())
    }

    /// Returns a time-only format for `locale`.
    public static func getTimeInstance(_ style: Int, locale: java.util.Locale = java.util.Locale.getDefault()) -> DateFormat {
      let f = Foundation.DateFormatter()
      f.locale = locale.delegate
      f.dateStyle = .none
      f.timeStyle = dateStyle(for: style)
      return DateFormat(f)
    }

    /// Returns a date+time format with `DEFAULT` style for the default locale.
    public static func getDateTimeInstance() -> DateFormat {
      return getDateTimeInstance(DEFAULT, timeStyle: DEFAULT, locale: java.util.Locale.getDefault())
    }

    /// Returns a date+time format for `locale`.
    public static func getDateTimeInstance(_ dateStyle: Int, timeStyle: Int, locale: java.util.Locale = java.util.Locale.getDefault()) -> DateFormat {
      let f = Foundation.DateFormatter()
      f.locale = locale.delegate
      f.dateStyle = Self.dateStyle(for: dateStyle)
      f.timeStyle = Self.dateStyle(for: timeStyle)
      return DateFormat(f)
    }

    // -------------------------------------------------------------------------
    // MARK: Format overrides
    // -------------------------------------------------------------------------

    /// Formats a `java.util.Date` (or `Foundation.Date`) appended to `toAppendTo`.
    open override func format(_ obj: Any, toAppendTo: inout String, pos: FieldPosition) -> String {
      let date: Foundation.Date
      switch obj {
      case let d as java.util.Date: date = d.delegate
      case let d as Foundation.Date: date = d
      default:
        toAppendTo += "\(obj)"
        return toAppendTo
      }
      toAppendTo += formatter.string(from: date)
      return toAppendTo
    }

    /// Formats a `java.util.Date` to a `String`.
    public func format(_ date: java.util.Date) -> String {
      formatter.string(from: date.delegate)
    }

    // -------------------------------------------------------------------------
    // MARK: Parse overrides
    // -------------------------------------------------------------------------

    open override func parseObject(_ source: String, pos: ParsePosition) -> Any? {
      return parse(source, pos: pos)
    }

    /// Parses `source` starting at `pos` and returns a `java.util.Date`.
    public func parse(_ source: String, pos: ParsePosition) -> java.util.Date? {
      let start = pos.getIndex()
      let sub = String(source[source.index(source.startIndex, offsetBy: start)...])
      if let date = formatter.date(from: sub) {
        pos.setIndex(source.count)
        return java.util.Date(Int64(date.timeIntervalSince1970 * 1000))
      }
      pos.setErrorIndex(start)
      return nil
    }

    /// Parses `source` from the beginning and returns a `java.util.Date`.
    ///
    /// - Throws: `ParseException` if the string cannot be parsed.
    public func parse(_ source: String) throws -> java.util.Date {
      let pos = ParsePosition(0)
      guard let result = parse(source, pos: pos) else {
        throw ParseException("DateFormat.parse(\"\(source)\") failed", pos.getErrorIndex())
      }
      return result
    }

    // -------------------------------------------------------------------------
    // MARK: Helper
    // -------------------------------------------------------------------------

    private static func dateStyle(for style: Int) -> Foundation.DateFormatter.Style {
      switch style {
      case FULL:   return .full
      case LONG:   return .long
      case MEDIUM: return .medium
      case SHORT:  return .short
      default:     return .medium
      }
    }
  }
}
