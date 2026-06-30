/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A menu item with a radio button indicator — mirrors
  /// `javax.swing.JRadioButtonMenuItem`.
  ///
  /// Radio button menu items are typically added to a `ButtonGroup` so that
  /// selecting one automatically deselects all others in the group.
  /// Unlike `JCheckBoxMenuItem`, clicking a selected radio button menu item
  /// has no effect — it can only be deselected implicitly by the `ButtonGroup`.
  ///
  /// The radio indicator is painted by `BasicRadioButtonMenuItemUI` which
  /// derives its size dynamically from the component font.
  ///
  /// ## Usage
  ///
  /// ```swift
  /// let group = javax.swing.ButtonGroup()
  /// let small  = javax.swing.JRadioButtonMenuItem("Small",  selected: true)
  /// let medium = javax.swing.JRadioButtonMenuItem("Medium")
  /// let large  = javax.swing.JRadioButtonMenuItem("Large")
  /// for item in [small, medium, large] {
  ///   group.add(item)
  ///   sizeMenu.add(item)
  /// }
  /// ```
  ///
  /// - Since: Java 1.2 / JFC 1.0
  @MainActor
  open class JRadioButtonMenuItem: javax.swing.JMenuItem {

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

    override open func getUIClassID() -> String { "RadioButtonMenuItemUI" }

    override open func updateUI() {
      super.updateUI()
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
    // MARK: Radio behaviour — clicking a selected item does nothing
    // -------------------------------------------------------------------------

    override open func doClick() {
      guard !isSelected() else { return }
      setSelected(true)
      super.doClick()
    }
  }
}
