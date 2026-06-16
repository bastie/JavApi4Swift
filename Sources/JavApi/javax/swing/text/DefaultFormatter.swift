/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.text {

  /// A concrete `AbstractFormatter` that converts objects to/from strings using
  /// `String(describing:)` and a configurable `valueClass`.
  ///
  /// Mirrors `javax.swing.text.DefaultFormatter`.
  ///
  /// `DefaultFormatter` is the base of the Swing formatter hierarchy:
  ///
  /// ```
  /// JFormattedTextField.AbstractFormatter
  ///   └── DefaultFormatter          ← this class
  ///         └── InternationalFormatter
  ///               ├── NumberFormatter
  ///               └── DateFormatter
  ///         └── MaskFormatter
  /// ```
  ///
  /// - Since: Java 1.4
  open class DefaultFormatter: javax.swing.JFormattedTextField.AbstractFormatter {

    // -------------------------------------------------------------------------
    // MARK: Configuration
    // -------------------------------------------------------------------------

    /// Whether the value should be committed on every keystroke (`true`) or
    /// only when the field loses focus (`false`). Default: `true`.
    private var _commitsOnValidEdit: Bool = true
    public func getCommitsOnValidEdit() -> Bool { _commitsOnValidEdit }
    public func setCommitsOnValidEdit(_ commit: Bool) { _commitsOnValidEdit = commit }

    /// Whether partial input is allowed while the user is typing. Default: `true`.
    private var _allowsInvalid: Bool = true
    public func getAllowsInvalid() -> Bool { _allowsInvalid }
    public func setAllowsInvalid(_ allow: Bool) { _allowsInvalid = allow }

    /// Whether the text length can grow beyond the current value's representation.
    /// Default: `true`.
    private var _overwriteMode: Bool = true
    public func getOverwriteMode() -> Bool { _overwriteMode }
    public func setOverwriteMode(_ overwrite: Bool) { _overwriteMode = overwrite }

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    public override init() {}

    // -------------------------------------------------------------------------
    // MARK: AbstractFormatter overrides
    // -------------------------------------------------------------------------

    /// Converts `value` to a string via `String(describing:)`.
    open override func valueToString(_ value: Any?) throws -> String {
      guard let v = value else { return "" }
      return String(describing: v)
    }

    /// Returns the raw string as-is (no conversion).
    ///
    /// Subclasses should override this to perform actual parsing.
    open override func stringToValue(_ text: String) throws -> Any? {
      return text
    }
  }
}
