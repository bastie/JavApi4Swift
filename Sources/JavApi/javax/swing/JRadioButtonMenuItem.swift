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
    // MARK: State
    // -------------------------------------------------------------------------

    private var _selected: Bool = false

    private var itemListeners: [java.awt.event.ItemListener] = []

    // -------------------------------------------------------------------------
    // MARK: Initialisers
    // -------------------------------------------------------------------------

    public init(_ text: String = "", selected: Bool = false) {
      self._selected = selected
      super.init(text)
      updateUI()
    }

    public init(_ icon: javax.swing.Icon, selected: Bool = false) {
      self._selected = selected
      super.init("")
      updateUI()
    }

    public init(_ text: String, _ icon: javax.swing.Icon, selected: Bool = false) {
      self._selected = selected
      super.init(text)
      updateUI()
    }

    // -------------------------------------------------------------------------
    // MARK: UI class
    // -------------------------------------------------------------------------

    override open func getUIClassID() -> String { "RadioButtonMenuItemUI" }

    override open func updateUI() {
      setUI(javax.swing.plaf.basic.BasicRadioButtonMenuItemUI.createUI(self)
            as! javax.swing.plaf.basic.BasicRadioButtonMenuItemUI)
    }

    // -------------------------------------------------------------------------
    // MARK: Selected state
    // -------------------------------------------------------------------------

    override open func isSelected() -> Bool { _selected }

    public func setSelected(_ selected: Bool) {
      guard _selected != selected else { return }
      _selected = selected
      let state = selected
        ? java.awt.event.ItemEvent.SELECTED
        : java.awt.event.ItemEvent.DESELECTED
      fireItemStateChanged(state)
      invalidate()
    }

    // -------------------------------------------------------------------------
    // MARK: Radio behaviour — clicking a selected item does nothing
    // -------------------------------------------------------------------------

    override public func doClick() {
      guard !_selected else { return }
      setSelected(true)
      // Fire ActionEvent via super
      super.doClick()
    }

    // -------------------------------------------------------------------------
    // MARK: ItemListener
    // -------------------------------------------------------------------------

    public func addItemListener(_ listener: java.awt.event.ItemListener) {
      itemListeners.append(listener)
    }

    public func removeItemListener(_ listener: java.awt.event.ItemListener) {
      itemListeners.removeAll { $0 === (listener as AnyObject) }
    }

    private func fireItemStateChanged(_ stateChange: Int) {
      guard !itemListeners.isEmpty else { return }
      let e = java.awt.event.ItemEvent(self, java.awt.event.ItemEvent.ITEM_STATE_CHANGED,
                                       self, stateChange)
      itemListeners.forEach { $0.itemStateChanged(e) }
    }
  }
}
