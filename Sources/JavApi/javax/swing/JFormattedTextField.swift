/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A `JTextField` that validates or converts its value through a
  /// `java.text.Format` (or a custom `AbstractFormatter`).
  ///
  /// Mirrors `javax.swing.JFormattedTextField`.
  ///
  /// ## Typical use
  ///
  /// ```swift
  /// // Number field
  /// let fmt   = java.text.NumberFormat.getIntegerInstance()
  /// let field = javax.swing.JFormattedTextField(fmt)
  /// field.setValue(42 as NSNumber)
  ///
  /// // Date field
  /// let dfmt  = java.text.DateFormat.getDateInstance()
  /// let dfield = javax.swing.JFormattedTextField(dfmt)
  /// dfield.setValue(java.util.Date())
  /// ```
  ///
  /// - Since: Java 1.4
  @MainActor
  open class JFormattedTextField: javax.swing.JTextField {

    // -------------------------------------------------------------------------
    // MARK: Inner types
    // -------------------------------------------------------------------------

    /// Abstract base for all formatters used by `JFormattedTextField`.
    ///
    /// Mirrors `javax.swing.JFormattedTextField.AbstractFormatter`.
    open class AbstractFormatter {
      public init() {}

      /// Converts a value object to the string displayed in the field.
      ///
      /// - Parameter value: The value to convert.
      /// - Returns: String representation, or `nil` if conversion is not possible.
      /// - Throws: `java.text.ParseException` if the value cannot be formatted.
      open func valueToString(_ value: Any?) throws -> String {
        fatalError("Subclasses of AbstractFormatter must override valueToString(_:)")
      }

      /// Converts the string in the field back to a value object.
      ///
      /// - Parameter text: The text currently in the field.
      /// - Returns: The parsed value object.
      /// - Throws: `java.text.ParseException` if the text cannot be parsed.
      open func stringToValue(_ text: String) throws -> Any? {
        fatalError("Subclasses of AbstractFormatter must override stringToValue(_:)")
      }
    }

    /// Abstract factory that vends `AbstractFormatter` instances.
    ///
    /// Mirrors `javax.swing.JFormattedTextField.AbstractFormatterFactory`.
    open class AbstractFormatterFactory {
      public init() {}
      /// Returns the formatter to use for `tf`.
      @MainActor
      open func getFormatter(_ tf: JFormattedTextField) -> AbstractFormatter? {
        fatalError("Subclasses of AbstractFormatterFactory must override getFormatter(_:)")
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Built-in formatter backed by java.text.Format
    // -------------------------------------------------------------------------

    /// A concrete `AbstractFormatter` that delegates to a `java.text.Format`.
    public final class FormatFormatter: AbstractFormatter {

      private let format: java.text.Format

      public init(_ format: java.text.Format) {
        self.format = format
      }

      public override func valueToString(_ value: Any?) throws -> String {
        guard let v = value else { return "" }
        return format.format(v)
      }

      public override func stringToValue(_ text: String) throws -> Any? {
        return try format.parseObject(text)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: State
    // -------------------------------------------------------------------------

    private var _value: Any? = nil

    /// Internal: returns `true` if a value has been explicitly set.
    /// Used by `DefaultFormatterFactory` to select the null-formatter slot
    /// without triggering a recursive `getValue()` → `getFormatter()` call.
    internal var _hasValue: Bool { _value != nil }
    private var _formatter: AbstractFormatter? = nil
    private var _formatterFactory: AbstractFormatterFactory? = nil

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    /// Creates an empty field with no formatter.
    public override init() {
      super.init()
      updateUI()
    }

    /// Creates a field backed by `format`.
    public init(_ format: java.text.Format) {
      super.init()
      _formatter = FormatFormatter(format)
      updateUI()
    }

    /// Creates a field with an initial `value`, using `format` to display it.
    public init(_ format: java.text.Format, _ value: Any) {
      super.init()
      _formatter = FormatFormatter(format)
      _value = value
      if let str = try? _formatter!.valueToString(value) {
        setText(str)
      }
      updateUI()
    }

    /// Creates a field with an initial `value` and no formatter.
    /// The value is displayed via its `description`.
    public init(_ value: Any) {
      super.init()
      _value = value
      setText("\(value)")
      updateUI()
    }

    /// Creates a field with a custom `AbstractFormatterFactory`.
    public init(_ factory: AbstractFormatterFactory) {
      super.init()
      _formatterFactory = factory
      _formatter = factory.getFormatter(self)
      updateUI()
    }

    // -------------------------------------------------------------------------
    // MARK: Java API
    // -------------------------------------------------------------------------

    /// Returns the current formatter, asking the factory if needed.
    public func getFormatter() -> AbstractFormatter? {
      if let f = _formatter { return f }
      _formatter = _formatterFactory?.getFormatter(self)
      return _formatter
    }

    /// Replaces the formatter factory. Triggers a re-format of the current value.
    public func setFormatterFactory(_ factory: AbstractFormatterFactory?) {
      _formatterFactory = factory
      _formatter = factory?.getFormatter(self)
      if let v = _value, let f = _formatter, let str = try? f.valueToString(v) {
        setText(str)
      }
      invalidate()
    }

    /// Returns the logical value held by the field.
    ///
    /// Calling `getValue()` first attempts to commit any pending text edits.
    public func getValue() -> Any? {
      // Try to commit the current text as a new value
      if let f = getFormatter(), let parsed = try? f.stringToValue(getText()) {
        _value = parsed
      }
      return _value
    }

    /// Sets the logical value and updates the displayed text.
    public func setValue(_ value: Any?) {
      _value = value
      if let v = value, let f = getFormatter(), let str = try? f.valueToString(v) {
        setText(str)
      } else {
        setText(value.map { "\($0)" } ?? "")
      }
      invalidate()
    }

    /// Commits the current text to the value, using the formatter.
    ///
    /// - Throws: `java.text.ParseException` if the text cannot be parsed.
    public func commitEdit() throws {
      guard let f = getFormatter() else { return }
      _value = try f.stringToValue(getText())
    }

    // -------------------------------------------------------------------------
    // MARK: UI delegate
    // -------------------------------------------------------------------------

    open override func getUIClassID() -> String { "FormattedTextFieldUI" }
  }
}
