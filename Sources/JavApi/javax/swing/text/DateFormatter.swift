/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.text {

  /// An `InternationalFormatter` specialised for dates.
  ///
  /// Mirrors `javax.swing.text.DateFormatter`.
  ///
  /// Uses `java.text.DateFormat` as its backing formatter.
  ///
  /// ## Example
  ///
  /// ```swift
  /// let df = javax.swing.text.DateFormatter(
  ///   java.text.DateFormat.getDateInstance(.SHORT))
  /// let field = javax.swing.JFormattedTextField(value: java.util.Date())
  /// ```
  ///
  /// - Since: Java 1.4
  open class DateFormatter: InternationalFormatter {

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    /// Creates a `DateFormatter` backed by a default `DateFormat`.
    public override init() {
      super.init(java.text.DateFormat.getDateInstance())
    }

    /// Creates a `DateFormatter` backed by `format`.
    public init(_ format: java.text.DateFormat) {
      super.init(format)
    }

    // -------------------------------------------------------------------------
    // MARK: Convenience accessor
    // -------------------------------------------------------------------------

    /// Returns the backing format cast to `java.text.DateFormat`.
    public func getDateFormat() -> java.text.DateFormat? {
      return getFormat() as? java.text.DateFormat
    }

    /// Replaces the backing format.
    public func setDateFormat(_ format: java.text.DateFormat) {
      setFormat(format)
    }

    // -------------------------------------------------------------------------
    // MARK: Parse override — return java.util.Date
    // -------------------------------------------------------------------------

    open override func stringToValue(_ text: String) throws -> Any? {
      guard let df = getDateFormat() else {
        return try super.stringToValue(text)
      }
      return try df.parse(text)
    }
  }
}
