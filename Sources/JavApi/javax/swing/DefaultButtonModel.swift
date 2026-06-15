/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// Default implementation of `ButtonModel`.
  ///
  /// Used by `JButton` and `JMenuItem` unless replaced via `setModel(_:)`.
  /// State changes fire a `ChangeEvent` to all registered `ChangeListener`s.
  /// `ActionEvent` is fired by the component itself (via `doClick()`), not by
  /// the model — consistent with Java's Swing design.
  ///
  /// - Since: Java 1.2
  @MainActor
  open class DefaultButtonModel: javax.swing.ButtonModel {

    // -------------------------------------------------------------------------
    // MARK: State storage
    // -------------------------------------------------------------------------

    private var _armed:    Bool = false
    private var _pressed:  Bool = false
    private var _rollover: Bool = false
    private var _selected: Bool = false
    private var _enabled:  Bool = true

    // -------------------------------------------------------------------------
    // MARK: State accessors — Java-style methods
    // -------------------------------------------------------------------------

    open func isArmed()    -> Bool { _armed }
    open func setArmed(_ b: Bool) {
      guard b != _armed else { return }
      _armed = b; fireStateChanged()
    }

    open func isPressed()  -> Bool { _pressed }
    open func setPressed(_ b: Bool) {
      guard b != _pressed else { return }
      _pressed = b; fireStateChanged()
    }

    open func isRollover() -> Bool { _rollover }
    open func setRollover(_ b: Bool) {
      guard b != _rollover else { return }
      _rollover = b; fireStateChanged()
    }

    open func isSelected() -> Bool { _selected }
    open func setSelected(_ b: Bool) {
      guard b != _selected else { return }
      _selected = b; fireStateChanged()
    }

    open func isEnabled()  -> Bool { _enabled }
    open func setEnabled(_ b: Bool) {
      guard b != _enabled else { return }
      _enabled = b; fireStateChanged()
    }

    // -------------------------------------------------------------------------
    // MARK: Action command / mnemonic
    // -------------------------------------------------------------------------

    private var _actionCommand: String? = nil
    private var _mnemonic: Int = 0

    open func getActionCommand() -> String?      { _actionCommand }
    open func setActionCommand(_ command: String?) { _actionCommand = command }

    open func getMnemonic() -> Int               { _mnemonic }
    open func setMnemonic(_ mnemonic: Int)       { _mnemonic = mnemonic }

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    public init() {}

    // -------------------------------------------------------------------------
    // MARK: ChangeListener
    // -------------------------------------------------------------------------

    private var changeListeners: [javax.swing.event.ChangeListener] = []

    public func addChangeListener(_ l: javax.swing.event.ChangeListener) {
      changeListeners.append(l)
    }

    public func removeChangeListener(_ l: javax.swing.event.ChangeListener) {
      changeListeners.removeAll { $0 === l }
    }

    /// Notifies all `ChangeListener`s that the model state has changed.
    open func fireStateChanged() {
      let e = javax.swing.event.ChangeEvent(self)
      for l in changeListeners { l.stateChanged(e) }
    }

    // -------------------------------------------------------------------------
    // MARK: ActionListener
    // -------------------------------------------------------------------------

    private var actionListeners: [java.awt.event.ActionListener] = []

    public func addActionListener(_ l: java.awt.event.ActionListener) {
      actionListeners.append(l)
    }

    public func removeActionListener(_ l: java.awt.event.ActionListener) {
      actionListeners.removeAll { $0 === l }
    }

    // -------------------------------------------------------------------------
    // MARK: ItemListener
    // -------------------------------------------------------------------------

    private var itemListeners: [java.awt.event.ItemListener] = []

    public func addItemListener(_ l: java.awt.event.ItemListener) {
      itemListeners.append(l)
    }

    public func removeItemListener(_ l: java.awt.event.ItemListener) {
      itemListeners.removeAll { $0 === l }
    }
  }
}
