/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension javax.swing.text {

  /// An `InternationalFormatter` specialised for numbers.
  ///
  /// Mirrors `javax.swing.text.NumberFormatter`.
  ///
  /// Uses `java.text.NumberFormat` as its backing formatter, so all
  /// locale-specific grouping separators, decimal symbols, and currency
  /// symbols are handled automatically.
  ///
  /// ## Example
  ///
  /// ```swift
  /// let fmt = javax.swing.text.NumberFormatter(
  ///   java.text.NumberFormat.getCurrencyInstance())
  /// let field = javax.swing.JFormattedTextField(value: 1234.56 as NSNumber)
  /// // install via JFormattedTextField.AbstractFormatterFactory if needed
  /// ```
  ///
  /// - Since: Java 1.4
  open class NumberFormatter: InternationalFormatter {

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    /// Creates a `NumberFormatter` backed by a default `NumberFormat`.
    public override init() {
      super.init(java.text.NumberFormat.getInstance())
    }

    /// Creates a `NumberFormatter` backed by `format`.
    public init(_ format: java.text.NumberFormat) {
      super.init(format)
    }

    // -------------------------------------------------------------------------
    // MARK: Convenience accessor
    // -------------------------------------------------------------------------

    /// Returns the backing format cast to `java.text.NumberFormat`.
    public func getNumberFormat() -> java.text.NumberFormat? {
      return getFormat() as? java.text.NumberFormat
    }

    /// Replaces the backing format.
    public func setNumberFormat(_ format: java.text.NumberFormat) {
      setFormat(format)
    }

    // -------------------------------------------------------------------------
    // MARK: Parse override — return NSNumber
    // -------------------------------------------------------------------------

    open override func stringToValue(_ text: String) throws -> Any? {
      guard let nf = getNumberFormat() else {
        return try super.stringToValue(text)
      }
      return try nf.parse(text)
    }
  }
}
