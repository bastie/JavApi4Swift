/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.text {

  /// Formats and parses numbers in a locale-sensitive way.
  ///
  /// Mirrors `java.text.NumberFormat`.
  ///
  /// Use the factory methods (`getInstance`, `getIntegerInstance`,
  /// `getCurrencyInstance`, `getPercentInstance`) to obtain an instance
  /// rather than calling the initialiser directly.
  ///
  /// - Since: Java 1.1
  open class NumberFormat: Format {

    // -------------------------------------------------------------------------
    // MARK: Backing formatter
    // -------------------------------------------------------------------------

    let formatter: Foundation.NumberFormatter

    init(_ formatter: Foundation.NumberFormatter) {
      self.formatter = formatter
    }

    // -------------------------------------------------------------------------
    // MARK: Factory methods
    // -------------------------------------------------------------------------

    /// Returns a general-purpose number format for the default locale.
    public static func getInstance() -> NumberFormat {
      return getInstance(java.util.Locale.getDefault())
    }

    /// Returns a general-purpose number format for `locale`.
    public static func getInstance(_ locale: java.util.Locale) -> NumberFormat {
      let f = Foundation.NumberFormatter()
      f.numberStyle = .decimal
      f.locale = locale.delegate
      return NumberFormat(f)
    }

    /// Returns an integer number format for the default locale.
    public static func getIntegerInstance() -> NumberFormat {
      return getIntegerInstance(java.util.Locale.getDefault())
    }

    /// Returns an integer number format for `locale`.
    public static func getIntegerInstance(_ locale: java.util.Locale) -> NumberFormat {
      let f = Foundation.NumberFormatter()
      f.numberStyle = .decimal
      f.locale = locale.delegate
      f.maximumFractionDigits = 0
      f.isLenient = true
      return NumberFormat(f)
    }

    /// Returns a currency format for the default locale.
    public static func getCurrencyInstance() -> NumberFormat {
      return getCurrencyInstance(java.util.Locale.getDefault())
    }

    /// Returns a currency format for `locale`.
    public static func getCurrencyInstance(_ locale: java.util.Locale) -> NumberFormat {
      let f = Foundation.NumberFormatter()
      f.numberStyle = .currency
      f.locale = locale.delegate
      return NumberFormat(f)
    }

    /// Returns a percentage format for the default locale.
    public static func getPercentInstance() -> NumberFormat {
      return getPercentInstance(java.util.Locale.getDefault())
    }

    /// Returns a percentage format for `locale`.
    public static func getPercentInstance(_ locale: java.util.Locale) -> NumberFormat {
      let f = Foundation.NumberFormatter()
      f.numberStyle = .percent
      f.locale = locale.delegate
      return NumberFormat(f)
    }

    // -------------------------------------------------------------------------
    // MARK: Configuration
    // -------------------------------------------------------------------------

    public func isGroupingUsed() -> Bool { formatter.usesGroupingSeparator }
    public func setGroupingUsed(_ use: Bool) { formatter.usesGroupingSeparator = use }

    public func getMinimumIntegerDigits() -> Int { formatter.minimumIntegerDigits }
    public func setMinimumIntegerDigits(_ n: Int) { formatter.minimumIntegerDigits = n }

    public func getMaximumIntegerDigits() -> Int { formatter.maximumIntegerDigits }
    public func setMaximumIntegerDigits(_ n: Int) { formatter.maximumIntegerDigits = n }

    public func getMinimumFractionDigits() -> Int { formatter.minimumFractionDigits }
    public func setMinimumFractionDigits(_ n: Int) { formatter.minimumFractionDigits = n }

    public func getMaximumFractionDigits() -> Int { formatter.maximumFractionDigits }
    public func setMaximumFractionDigits(_ n: Int) { formatter.maximumFractionDigits = n }

    // -------------------------------------------------------------------------
    // MARK: Format overrides
    // -------------------------------------------------------------------------

    /// Formats a number object (`Double`, `Int`, `Int64`, `NSNumber`, …) into
    /// `toAppendTo` and returns the result.
    open override func format(_ obj: Any, toAppendTo: inout String, pos: FieldPosition) -> String {
      let number: NSNumber
      switch obj {
      case let v as Double:  number = NSNumber(value: v)
      case let v as Float:   number = NSNumber(value: v)
      case let v as Int:     number = NSNumber(value: v)
      case let v as Int64:   number = NSNumber(value: v)
      case let v as Int32:   number = NSNumber(value: v)
      case let v as NSNumber: number = v
      default:
        toAppendTo += "\(obj)"
        return toAppendTo
      }
      let str = formatter.string(from: number) ?? "\(obj)"
      toAppendTo += str
      return toAppendTo
    }

    /// Formats any number directly to a `String`.
    public func format(_ number: Double) -> String {
      formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }

    /// Formats any integer directly to a `String`.
    public func format(_ number: Int64) -> String {
      formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }

    // -------------------------------------------------------------------------
    // MARK: Parse overrides
    // -------------------------------------------------------------------------

    open override func parseObject(_ source: String, pos: ParsePosition) -> Any? {
      return parse(source, pos: pos)
    }

    /// Parses `source` from the current index in `pos`.
    public func parse(_ source: String, pos: ParsePosition) -> NSNumber? {
      let start = pos.getIndex()
      let sub = String(source[source.index(source.startIndex, offsetBy: start)...])
      if let number = formatter.number(from: sub) {
        pos.setIndex(source.count)
        return number
      }
      pos.setErrorIndex(start)
      return nil
    }

    /// Parses `source` from the beginning.
    ///
    /// - Throws: `ParseException` if the string cannot be parsed.
    public func parse(_ source: String) throws -> NSNumber {
      let pos = ParsePosition(0)
      guard let result = parse(source, pos: pos) else {
        throw ParseException("NumberFormat.parse(\"\(source)\") failed", pos.getErrorIndex())
      }
      return result
    }
  }
}
