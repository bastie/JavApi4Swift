/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */


extension javax.swing {

  /// A single item inside a `JPopupMenu`.
  ///
  /// In the full Swing hierarchy `JMenuItem` extends `AbstractButton`.
  /// This stub provides the label and `ActionListener` support needed
  /// for `BasicPopupMenuUI` to paint and dispatch clicks.
  ///
  /// ## Usage
  ///
  /// ```swift
  /// let item = javax.swing.JMenuItem("Open…")
  /// item.addActionListener { _ in openDocument() }
  /// menu.add(item)
  /// ```
  ///
  @MainActor
  open class JMenuItem: javax.swing.JComponent {

    // -------------------------------------------------------------------------
    // MARK: Properties
    // -------------------------------------------------------------------------

    /// The label displayed in the popup menu.
    private var _text: String

    /// `true` when this item is a visual separator (drawn as a horizontal rule).
    /// Create separators with `JMenuItem.separator()`.
    public private(set) var isSeparator: Bool = false

    // -------------------------------------------------------------------------
    // MARK: Model
    // -------------------------------------------------------------------------

    private var _model: javax.swing.ButtonModel = javax.swing.DefaultButtonModel()

    public func getModel() -> javax.swing.ButtonModel { _model }
    public func setModel(_ model: javax.swing.ButtonModel) { _model = model }

    /// Whether the mouse is hovering over this item — delegates to model.
    internal var isArmed: Bool {
      get { _model.isArmed() }
      set { _model.setArmed(newValue) }
    }

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    public init(_ text: String = "") {
      self._text = text
      super.init()
    }

    /// Factory for a visual separator line.
    public static func separator() -> JMenuItem {
      let s = JMenuItem("")
      s.isSeparator = true
      return s
    }

    // -------------------------------------------------------------------------
    // MARK: Accessors
    // -------------------------------------------------------------------------

    public func getText() -> String     { _text }
    public func setText(_ t: String)    { _text = t; invalidate() }

    // -------------------------------------------------------------------------
    // MARK: ActionListener
    // -------------------------------------------------------------------------

    private var actionListeners: [java.awt.event.ActionListener] = []

    /// Registers an `ActionListener` object (Java-style).
    public func addActionListener(_ listener: java.awt.event.ActionListener) {
      actionListeners.append(listener)
    }

    /// Convenience overload: wraps a closure in an `ActionListener`.
    public func addActionListener(_ handler: @escaping (java.awt.event.ActionEvent) -> Void) {
      actionListeners.append(_SwingClosureActionListener(handler))
    }

    /// Removes all action listeners.
    public func removeActionListeners() {
      actionListeners.removeAll()
    }

    /// Fires an `ACTION_PERFORMED` event to all registered listeners.
    public func doClick() {
      guard !isSeparator else { return }
      let e = java.awt.event.ActionEvent(self, java.awt.event.ActionEvent.ACTION_PERFORMED, _text, 0, 0)
      actionListeners.forEach { $0.actionPerformed(e) }
    }
  }
}
