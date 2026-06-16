/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.text {

  /// A `DefaultFormatter` that delegates formatting and parsing to a
  /// `java.text.Format`.
  ///
  /// Mirrors `javax.swing.text.InternationalFormatter`.
  ///
  /// Subclasses (`NumberFormatter`, `DateFormatter`) configure the backing
  /// `java.text.Format` in their initialisers.
  ///
  /// - Since: Java 1.4
  open class InternationalFormatter: DefaultFormatter {

    // -------------------------------------------------------------------------
    // MARK: Backing format
    // -------------------------------------------------------------------------

    private var _format: java.text.Format?

    /// The `java.text.Format` used to convert values to/from strings.
    public func getFormat() -> java.text.Format? { _format }
    public func setFormat(_ format: java.text.Format?) { _format = format }

    // -------------------------------------------------------------------------
    // MARK: Min / max value (for number/date ranges)
    // -------------------------------------------------------------------------

    /// The minimum allowed value. `nil` means no lower bound.
    private var _minimum: Any? = nil
    public func getMinimum() -> Any? { _minimum }
    public func setMinimum(_ min: Any?) { _minimum = min }

    /// The maximum allowed value. `nil` means no upper bound.
    private var _maximum: Any? = nil
    public func getMaximum() -> Any? { _maximum }
    public func setMaximum(_ max: Any?) { _maximum = max }

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    public override init() {
      super.init()
    }

    /// Creates an `InternationalFormatter` backed by `format`.
    public init(_ format: java.text.Format) {
      super.init()
      _format = format
    }

    // -------------------------------------------------------------------------
    // MARK: AbstractFormatter overrides
    // -------------------------------------------------------------------------

    /// Formats `value` using the backing `java.text.Format`, or falls back to
    /// `DefaultFormatter` behaviour if no format is set.
    open override func valueToString(_ value: Any?) throws -> String {
      guard let v = value else { return "" }
      guard let fmt = _format else { return try super.valueToString(v) }
      return fmt.format(v)
    }

    /// Parses `text` using the backing `java.text.Format`.
    ///
    /// - Throws: `java.text.ParseException` if parsing fails or no format is set.
    open override func stringToValue(_ text: String) throws -> Any? {
      guard let fmt = _format else { return try super.stringToValue(text) }
      return try fmt.parseObject(text)
    }
  }
}
