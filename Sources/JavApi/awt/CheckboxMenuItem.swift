/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Ein Menüeintrag mit Häkchen-Zustand — mirrors `java.awt.CheckboxMenuItem`.
  @MainActor
  open class CheckboxMenuItem: MenuItem {

    private var state: Bool
    private var itemListeners: [java.awt.event.ItemListener] = []

    public init(_ label: String = "", _ state: Bool = false) {
      self.state = state
      super.init(label)
    }

    // -------------------------------------------------------------------------
    // MARK: Zustand
    // -------------------------------------------------------------------------

    public func getState() -> Bool  { state }
    public func setState(_ b: Bool) {
      guard state != b else { return }
      state = b
      fireItemEvent()
    }

    // -------------------------------------------------------------------------
    // MARK: Listeners
    // -------------------------------------------------------------------------

    public func addItemListener(_ l: java.awt.event.ItemListener) {
      itemListeners.append(l)
    }
    public func removeItemListener(_ l: java.awt.event.ItemListener) {
      itemListeners.removeAll { $0 === l }
    }

    private func fireItemEvent() {
      let change = state
        ? java.awt.event.ItemEvent.SELECTED
        : java.awt.event.ItemEvent.DESELECTED
      let e = java.awt.event.ItemEvent(
        self as AnyObject,
        java.awt.event.ItemEvent.ITEM_STATE_CHANGED,
        label as AnyObject,
        change)
      itemListeners.forEach { $0.itemStateChanged(e) }
    }

    // -------------------------------------------------------------------------
    // MARK: Override doAction — togglet den Zustand beim Klick
    // -------------------------------------------------------------------------

    public override func doAction() {
      guard enabled else { return }
      setState(!state)
      super.doAction()
    }
  }
}
