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

    override open func getUIClassID() -> String { "CheckBoxMenuItemUI" }

    override open func updateUI() {
      setUI(javax.swing.plaf.basic.BasicCheckBoxMenuItemUI.createUI(self)
            as! javax.swing.plaf.basic.BasicCheckBoxMenuItemUI)
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
    // MARK: Toggle on click — overrides JMenuItem.doClick()
    // -------------------------------------------------------------------------

    override public func doClick() {
      setSelected(!_selected)
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
