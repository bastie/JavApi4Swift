/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A single-line text-input component — mirrors `javax.swing.JTextField`.
  ///
  /// `JTextField` extends `JTextComponent` and adds:
  /// - A **columns** hint that drives the preferred width.
  /// - **`ActionListener`** support: listeners are called when the user
  ///   presses Return / Enter.
  /// - A settable **action command** string (defaults to the current text).
  ///
  /// ## Example
  ///
  /// ```swift
  /// let field = javax.swing.JTextField("Max Mustermann", 20)
  /// field.addActionListener(myListener)
  /// panel.add(field)
  /// ```
  ///
  /// - Since: Java 1.2
  @MainActor
  open class JTextField: javax.swing.text.JTextComponent {

    // -------------------------------------------------------------------------
    // MARK: Columns
    // -------------------------------------------------------------------------

    private var _columns: Int

    /// The number of columns used to calculate the preferred width.
    /// A value of 0 means "no hint".
    public func getColumns() -> Int { _columns }
    public func setColumns(_ columns: Int) {
      _columns = max(0, columns)
      invalidate()
    }

    // -------------------------------------------------------------------------
    // MARK: Action command
    // -------------------------------------------------------------------------

    private var _actionCommand: String? = nil

    /// The action command string sent with `ActionEvent` when Return is pressed.
    /// Defaults to `nil`, in which case the current text is used.
    public func getActionCommand() -> String { _actionCommand ?? getText() }
    public func setActionCommand(_ command: String?) { _actionCommand = command }

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    /// Creates an empty field with no column hint.
    public override init() {
      _columns = 0
      super.init()
      updateUI()
    }

    /// Creates a field pre-populated with `text`.
    public init(_ text: String) {
      _columns = 0
      super.init()
      setText(text)
      updateUI()
    }

    /// Creates an empty field with a column hint.
    public init(columns: Int) {
      _columns = max(0, columns)
      super.init()
      updateUI()
    }

    /// Creates a field with initial text and a column hint.
    public init(_ text: String, _ columns: Int) {
      _columns = max(0, columns)
      super.init()
      setText(text)
      updateUI()
    }

    /// Creates a field backed by the given document model.
    public init(document: javax.swing.text.Document, _ text: String, _ columns: Int) {
      _columns = max(0, columns)
      super.init(document: document)
      setText(text)
      updateUI()
    }

    // -------------------------------------------------------------------------
    // MARK: UI delegate
    // -------------------------------------------------------------------------

    override open func getUIClassID() -> String { "TextFieldUI" }

    // -------------------------------------------------------------------------
    // MARK: ActionListener support
    // -------------------------------------------------------------------------

    private var actionListeners: [java.awt.event.ActionListener] = []

    /// Adds a listener that is notified when the user presses Return.
    public func addActionListener(_ l: java.awt.event.ActionListener) {
      actionListeners.append(l)
    }

    /// Removes a previously registered action listener.
    public func removeActionListener(_ l: java.awt.event.ActionListener) {
      actionListeners.removeAll { $0 === l }
    }

    /// Returns all registered action listeners.
    public func getActionListeners() -> [java.awt.event.ActionListener] {
      actionListeners
    }

    /// Fires an `ActionEvent` to all registered listeners.
    ///
    /// Called by the platform layer (toolkit) when the user presses Return.
    public func fireActionPerformed() {
      guard !actionListeners.isEmpty else { return }
      let e = java.awt.event.ActionEvent(
        self,
        java.awt.event.ActionEvent.ACTION_PERFORMED,
        getActionCommand())
      for l in actionListeners { l.actionPerformed(e) }
    }
  }
}
