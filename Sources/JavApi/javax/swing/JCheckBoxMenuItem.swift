/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A menu item with a checkbox toggle — mirrors `javax.swing.JCheckBoxMenuItem`.
  ///
  /// Each click toggles the `selected` state and fires both an `ActionEvent`
  /// and an `ItemEvent`.  The checkbox indicator is painted by
  /// `BasicCheckBoxMenuItemUI` which derives its size dynamically from the
  /// component font.
  ///
  /// ## Usage
  ///
  /// ```swift
  /// let item = javax.swing.JCheckBoxMenuItem("Show toolbar", selected: true)
  /// item.addActionListener { _ in toggleToolbar() }
  /// viewMenu.add(item)
  /// ```
  ///
  /// - Since: Java 1.2 / JFC 1.0
  @MainActor
  open class JCheckBoxMenuItem: javax.swing.JMenuItem {

    // -------------------------------------------------------------------------
    // MARK: Initialisers
    // -------------------------------------------------------------------------

    public init(_ text: String = "", selected: Bool = false) {
      super.init(text)
      setSelected(selected)
      updateUI()
    }

    public init(_ icon: javax.swing.Icon, selected: Bool = false) {
      super.init("", icon)
      setSelected(selected)
      updateUI()
    }

    public init(_ text: String, _ icon: javax.swing.Icon, selected: Bool = false) {
      super.init(text, icon)
      setSelected(selected)
      updateUI()
    }

    // -------------------------------------------------------------------------
    // MARK: UI class
    // -------------------------------------------------------------------------

    override open func getUIClassID() -> String { "CheckBoxMenuItemUI" }

    override open func updateUI() {
      setUI(javax.swing.plaf.basic.BasicCheckBoxMenuItemUI.createUI(self)
            as! javax.swing.plaf.basic.BasicCheckBoxMenuItemUI)
    }

    // -------------------------------------------------------------------------
    // MARK: Selected state — delegates to AbstractButton model
    // -------------------------------------------------------------------------

    override open func setSelected(_ selected: Bool) {
      guard isSelected() != selected else { return }
      super.setSelected(selected)
      let state = selected
        ? java.awt.event.ItemEvent.SELECTED
        : java.awt.event.ItemEvent.DESELECTED
      fireItemStateChanged(state)
      invalidate()
    }

    // -------------------------------------------------------------------------
    // MARK: Toggle on click — overrides JMenuItem.doClick()
    // -------------------------------------------------------------------------

    override open func doClick() {
      setSelected(!isSelected())
      super.doClick()
    }
  }
}
