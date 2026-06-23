/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A push button — mirrors `javax.swing.JButton`.
  ///
  /// Clicking fires all registered `ActionListener`s.  The visual appearance
  /// is delegated to `BasicButtonUI`.  State (pressed, rollover, armed,
  /// enabled) is managed by a `ButtonModel` (`DefaultButtonModel` by default).
  ///
  /// ```swift
  /// let btn = javax.swing.JButton("OK")
  /// btn.addActionListener { _ in dialog.setVisible(false) }
  /// panel.add(btn)
  /// ```
  ///
  /// - Since: Java 1.0 (AWT Button); Swing variant since Java 1.2
  @MainActor
  open class JButton: javax.swing.AbstractButton {

    // -------------------------------------------------------------------------
    // MARK: Initialisers
    // -------------------------------------------------------------------------

    public override init() {
      super.init()
      updateUI()
    }

    public init(_ text: String) {
      super.init(text)
      updateUI()
    }

    public init(icon: javax.swing.Icon) {
      super.init("", icon)
      updateUI()
    }

    public init(_ text: String, icon: javax.swing.Icon) {
      super.init(text, icon)
      updateUI()
    }

    /// Creates a button bound to an `Action`.
    ///
    /// The button adopts the action's `NAME` as label, `SMALL_ICON` as icon,
    /// `SHORT_DESCRIPTION` as tooltip, and enabled state.  The action itself
    /// is registered as `ActionListener`.
    public init(_ action: javax.swing.Action) {
      let label = (action.getValue(javax.swing.AbstractAction.NAME) as? String) ?? ""
      let icon  = action.getValue(javax.swing.AbstractAction.SMALL_ICON) as? javax.swing.Icon
      super.init(label, icon)
      addActionListener(action)
      updateUI()
    }

    // -------------------------------------------------------------------------
    // MARK: UI delegate
    // -------------------------------------------------------------------------

    override open func getUIClassID() -> String { "ButtonUI" }

    override open func updateUI() {
      super.updateUI()
    }
  }
}
