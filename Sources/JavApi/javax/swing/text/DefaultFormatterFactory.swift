/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.text {

  /// A concrete `AbstractFormatterFactory` that manages up to four formatters:
  ///
  /// | Slot        | When used                                      |
  /// |-------------|------------------------------------------------|
  /// | `default`   | Fallback when no more-specific slot applies    |
  /// | `display`   | Field is not focused (read/display mode)       |
  /// | `edit`      | Field is focused (edit mode)                   |
  /// | `null`      | Field value is `nil`                           |
  ///
  /// `getFormatter(_:)` picks the most appropriate slot at runtime:
  /// - If the value is `nil` → null-formatter (fallback: default)
  /// - If the field is focused → edit-formatter (fallback: default)
  /// - Otherwise → display-formatter (fallback: default)
  ///
  /// The most common usage is the single-argument convenience init, which
  /// sets the default formatter and is used for all states:
  ///
  /// ```swift
  /// let factory = javax.swing.text.DefaultFormatterFactory(myFormatter)
  /// field.setFormatterFactory(factory)
  /// ```
  ///
  /// Mirrors `javax.swing.text.DefaultFormatterFactory`.
  ///
  /// - Since: Java 1.4
  @MainActor
  public final class DefaultFormatterFactory: javax.swing.JFormattedTextField.AbstractFormatterFactory {

    // -------------------------------------------------------------------------
    // MARK: Formatter slots
    // -------------------------------------------------------------------------

    private var defaultFormatter: javax.swing.JFormattedTextField.AbstractFormatter?
    private var displayFormatter: javax.swing.JFormattedTextField.AbstractFormatter?
    private var editFormatter: javax.swing.JFormattedTextField.AbstractFormatter?
    private var nullFormatter: javax.swing.JFormattedTextField.AbstractFormatter?

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    /// Creates a factory with no formatters set.
    public override init() {
      super.init()
    }

    /// Creates a factory using `defaultFormatter` for all states.
    public init(_ defaultFormatter: javax.swing.JFormattedTextField.AbstractFormatter) {
      self.defaultFormatter = defaultFormatter
      super.init()
    }

    /// Creates a factory with individual formatters for each state.
    ///
    /// Pass `nil` for any slot to fall back to the default formatter.
    public init(
      _ defaultFormatter: javax.swing.JFormattedTextField.AbstractFormatter?,
      _ displayFormatter: javax.swing.JFormattedTextField.AbstractFormatter?,
      _ editFormatter: javax.swing.JFormattedTextField.AbstractFormatter?,
      _ nullFormatter: javax.swing.JFormattedTextField.AbstractFormatter?
    ) {
      self.defaultFormatter = defaultFormatter
      self.displayFormatter = displayFormatter
      self.editFormatter    = editFormatter
      self.nullFormatter    = nullFormatter
      super.init()
    }

    // -------------------------------------------------------------------------
    // MARK: Slot accessors
    // -------------------------------------------------------------------------

    public func getDefaultFormatter() -> javax.swing.JFormattedTextField.AbstractFormatter? { defaultFormatter }
    public func setDefaultFormatter(_ f: javax.swing.JFormattedTextField.AbstractFormatter?) { defaultFormatter = f }

    public func getDisplayFormatter() -> javax.swing.JFormattedTextField.AbstractFormatter? { displayFormatter }
    public func setDisplayFormatter(_ f: javax.swing.JFormattedTextField.AbstractFormatter?) { displayFormatter = f }

    public func getEditFormatter() -> javax.swing.JFormattedTextField.AbstractFormatter? { editFormatter }
    public func setEditFormatter(_ f: javax.swing.JFormattedTextField.AbstractFormatter?) { editFormatter = f }

    public func getNullFormatter() -> javax.swing.JFormattedTextField.AbstractFormatter? { nullFormatter }
    public func setNullFormatter(_ f: javax.swing.JFormattedTextField.AbstractFormatter?) { nullFormatter = f }

    // -------------------------------------------------------------------------
    // MARK: AbstractFormatterFactory
    // -------------------------------------------------------------------------

    /// Returns the most appropriate formatter for the current field state.
    ///
    /// Selection order:
    /// 1. `nullFormatter` when the field's value is `nil`
    /// 2. `displayFormatter` when the field is not focused (best effort; falls back to `defaultFormatter`)
    /// 3. `editFormatter` when the field is focused (best effort; falls back to `defaultFormatter`)
    /// 4. `defaultFormatter` as universal fallback
    ///
    /// - Note: Focus detection relies on `javax.swing.JComponent.isFocusOwner()`.
    ///   In the current SwiftUI-backed implementation this always returns `false`,
    ///   so `displayFormatter` and `editFormatter` slots are only effective if
    ///   a concrete `JComponent` subclass tracks focus explicitly.
    override public func getFormatter(
      _ tf: javax.swing.JFormattedTextField
    ) -> javax.swing.JFormattedTextField.AbstractFormatter? {
      // 1. Null-value state — use _hasValue to avoid getValue() → getFormatter() recursion
      if !tf._hasValue, let nf = nullFormatter {
        return nf
      }
      // 2/3. Focus-dependent slots (best effort)
      if tf.isFocusOwner {
        if let ef = editFormatter { return ef }
      } else {
        if let df = displayFormatter { return df }
      }
      // 4. Universal fallback
      return defaultFormatter
    }
  }
}
