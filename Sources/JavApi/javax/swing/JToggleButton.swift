/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A two-state button that stays pressed after a click — mirrors
  /// `javax.swing.JToggleButton`.
  ///
  /// Each click toggles the `selected` state of the `ButtonModel` and fires
  /// both an `ActionEvent` and an `ItemEvent`.  `JCheckBox` and `JRadioButton`
  /// extend this class.
  ///
  /// ```swift
  /// let toggle = javax.swing.JToggleButton("Bold")
  /// toggle.addItemListener(myListener)
  /// panel.add(toggle)
  /// ```
  ///
  /// - Since: Java 1.2
  @MainActor
  open class JToggleButton: javax.swing.AbstractButton {

    override open func getUIClassID() -> String { "ToggleButtonUI" }

    // -------------------------------------------------------------------------
    // MARK: Initialisers
    // -------------------------------------------------------------------------

    public override init() {
      super.init()
      updateUI()
    }

    public init(_ text: String, _ selected: Bool = false) {
      super.init(text)
      setSelected(selected)
      updateUI()
    }

    public init(_ icon: javax.swing.Icon, _ selected: Bool = false) {
      super.init("", icon)
      setSelected(selected)
      updateUI()
    }

    public init(_ text: String, _ icon: javax.swing.Icon, _ selected: Bool = false) {
      super.init(text, icon)
      setSelected(selected)
      updateUI()
    }

    // -------------------------------------------------------------------------
    // MARK: Toggle on click
    // -------------------------------------------------------------------------

    override open func buttonClicked() {
      let nowSelected = !isSelected()
      setSelected(nowSelected)
      fireActionPerformed()
      fireItemStateChanged(nowSelected
        ? java.awt.event.ItemEvent.SELECTED
        : java.awt.event.ItemEvent.DESELECTED)
    }
  }
}
