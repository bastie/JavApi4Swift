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
    public var text: String

    /// `true` when this item is a visual separator (drawn as a horizontal rule).
    /// Create separators with `JMenuItem.separator()`.
    public var isSeparator: Bool = false

    // -------------------------------------------------------------------------
    // MARK: Model
    // -------------------------------------------------------------------------

    private var _model: javax.swing.ButtonModel = javax.swing.DefaultButtonModel()

    public func getModel() -> javax.swing.ButtonModel { _model }
    public func setModel(_ model: javax.swing.ButtonModel) { _model = model }

    /// Whether the mouse is hovering over this item — delegates to model.
    internal var isArmed: Bool {
      get { _model.isArmed }
      set { _model.isArmed = newValue }
    }

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    public init(_ text: String = "") {
      self.text = text
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

    public func getText() -> String     { text }
    public func setText(_ t: String)    { text = t; invalidate() }

    // -------------------------------------------------------------------------
    // MARK: ActionListener
    // -------------------------------------------------------------------------

    private var actionListeners: [java.awt.event.ActionListener] = []

    /// Registers an `ActionListener` object (Java-style).
    @discardableResult
    public func addActionListener(_ listener: java.awt.event.ActionListener) -> javax.swing.JMenuItem {
      actionListeners.append(listener)
      return self
    }

    /// Convenience overload: wraps a closure in an `ActionListener`.
    @discardableResult
    public func addActionListener(_ handler: @escaping (java.awt.event.ActionEvent) -> Void) -> javax.swing.JMenuItem {
      actionListeners.append(_SwingClosureActionListener(handler))
      return self
    }

    /// Removes all action listeners.
    public func removeActionListeners() {
      actionListeners.removeAll()
    }

    /// Fires an `ACTION_PERFORMED` event to all registered listeners.
    public func doClick() {
      guard !isSeparator else { return }
      let e = java.awt.event.ActionEvent(self, java.awt.event.ActionEvent.ACTION_PERFORMED, text, 0, 0)
      actionListeners.forEach { $0.actionPerformed(e) }
    }
  }
}
