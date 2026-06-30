/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */


extension javax.swing {

  /// A single item inside a `JPopupMenu`.
  ///
  /// Mirrors the Java Swing hierarchy: `JMenuItem` extends `AbstractButton`,
  /// giving it a `ButtonModel`, `ActionListener`/`ItemListener` support,
  /// `getText`/`setText`, `isSelected`/`setSelected`, and `doClick()`.
  ///
  /// ## Usage
  ///
  /// ```swift
  /// let item = javax.swing.JMenuItem("Open…")
  /// item.addActionListener { _ in openDocument() }
  /// menu.add(item)
  /// ```
  ///
  /// - Since: Java 1.2 / JFC 1.0
  @MainActor
  open class JMenuItem: javax.swing.AbstractButton {

    // -------------------------------------------------------------------------
    // MARK: Properties
    // -------------------------------------------------------------------------

    /// `true` when this item is a visual separator (drawn as a horizontal rule).
    /// Create separators with `JMenuItem.separator()`.
    public private(set) var isSeparator: Bool = false

    /// Whether the mouse is hovering over this item — delegates to model.
    internal var isArmed: Bool {
      get { getModel().isArmed() }
      set { getModel().setArmed(newValue) }
    }

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    public override init(_ text: String = "", _ icon: javax.swing.Icon? = nil) {
      super.init(text, icon)
      updateUI()
    }

    /// Creates a menu item that delegates to an `Action`.
    ///
    /// Adopts `Action.NAME` as label and registers the action as listener.
    public init(_ action: javax.swing.Action) {
      let name = (action.getValue(javax.swing.AbstractAction.NAME) as? String) ?? ""
      super.init(name)
      addActionListener(action)
      updateUI()
    }

    // -------------------------------------------------------------------------
    // MARK: UI
    // -------------------------------------------------------------------------

    override open func getUIClassID() -> String { "MenuItemUI" }

    override open func updateUI() {
      setUI(javax.swing.plaf.basic.BasicMenuItemUI.createUI(self)
            as! javax.swing.plaf.basic.BasicMenuItemUI)
    }

    // -------------------------------------------------------------------------
    // MARK: Factory
    // -------------------------------------------------------------------------

    /// Factory for a visual separator line.
    public static func separator() -> JMenuItem {
      let s = JMenuItem("")
      s.isSeparator = true
      return s
    }

    // -------------------------------------------------------------------------
    // MARK: Click dispatch
    // -------------------------------------------------------------------------

    override open func doClick() {
      guard !isSeparator else { return }
      fireActionPerformed(getText())
    }

    override open func buttonClicked() {
      doClick()
    }
  }
}
