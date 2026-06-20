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
  /// ## Public API types
  ///
  /// All public method signatures use plain Swift value types (`Double`, `Int64`).
  /// `Foundation.NumberFormatter` and `NSNumber` are used **internally only**
  /// for locale-sensitive formatting; they are not part of the public contract.
  ///
  /// - Since: Java 1.1
  open class NumberFormat: Format {

    // -------------------------------------------------------------------------
    // MARK: Field constants
    // -------------------------------------------------------------------------

    public static let FRACTION_FIELD: Int = 0
    public static let INTEGER_FIELD:  Int = 1

    // -------------------------------------------------------------------------
    // MARK: Backing formatter (internal — subclasses may use it)
    // -------------------------------------------------------------------------

    let formatter: Foundation.NumberFormatter

    // -------------------------------------------------------------------------
    // MARK: Initialisers
    // -------------------------------------------------------------------------

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
    // MARK: Format
    // -------------------------------------------------------------------------

    /// Formats a number object (`Double`, `Int`, `Int64`, `Float`, …) into
    /// `toAppendTo` and returns the result.
    open override func format(_ obj: Any, toAppendTo: inout String, pos: FieldPosition) -> String {
      switch obj {
      case let v as Double:  toAppendTo += format(v)
      case let v as Float:   toAppendTo += format(Double(v))
      case let v as Int:     toAppendTo += format(Int64(v))
      case let v as Int64:   toAppendTo += format(v)
      case let v as Int32:   toAppendTo += format(Int64(v))
      default:               toAppendTo += "\(obj)"
      }
      return toAppendTo
    }

    /// Formats a `Double` to a locale-sensitive `String`.
    public func format(_ number: Double) -> String {
      formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }

    /// Formats an `Int64` to a locale-sensitive `String`.
    public func format(_ number: Int64) -> String {
      formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }

    // -------------------------------------------------------------------------
    // MARK: Parse
    // -------------------------------------------------------------------------

    open override func parseObject(_ source: String, pos: ParsePosition) -> Any? {
      return parse(source, pos: pos)
    }

    /// Parses a number from `source` starting at `pos.getIndex()`.
    ///
    /// - Returns: A `Double`, or `nil` on failure (sets `pos.errorIndex`).
    public func parse(_ source: String, pos: ParsePosition) -> Double? {
      let start = pos.getIndex()
      let sub = start < source.count
        ? String(source[source.index(source.startIndex, offsetBy: start)...])
        : source
      if let number = formatter.number(from: sub) {
        pos.setIndex(source.count)
        return number.doubleValue
      }
      if let d = Double(sub) {
        pos.setIndex(source.count)
        return d
      }
      pos.setErrorIndex(start)
      return nil
    }

    /// Parses a number from `source`.
    ///
    /// - Throws: `ParseException` if the string cannot be parsed.
    /// - Returns: A `Double`.
    public func parse(_ source: String) throws -> Double {
      let pos = ParsePosition(0)
      guard let result = parse(source, pos: pos) else {
        throw ParseException("NumberFormat.parse(\"\(source)\") failed", pos.getErrorIndex())
      }
      return result
    }
  }
}
