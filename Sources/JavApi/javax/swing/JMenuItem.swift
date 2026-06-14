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

    /// Whether the mouse is hovering over this item (used by the UI delegate).
    internal var isArmed: Bool = false

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

    private var actionListeners: [(java.awt.event.ActionEvent) -> Void] = []

    /// Appends a listener that is called when this item is clicked.
    public func addActionListener(_ listener: @escaping (java.awt.event.ActionEvent) -> Void) {
      actionListeners.append(listener)
    }

    /// Removes all action listeners.
    public func removeActionListeners() {
      actionListeners.removeAll()
    }

    /// Fires an `ACTION_PERFORMED` event to all registered listeners.
    public func doClick() {
      guard !isSeparator else { return }
      let e = java.awt.event.ActionEvent(self, java.awt.event.ActionEvent.ACTION_PERFORMED, text, 0, 0)
      actionListeners.forEach { $0(e) }
    }
  }
}
