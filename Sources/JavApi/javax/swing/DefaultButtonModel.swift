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
    // MARK: State
    // -------------------------------------------------------------------------

    public var isArmed: Bool = false {
      didSet { if isArmed != oldValue { fireStateChanged() } }
    }
    public var isPressed: Bool = false {
      didSet { if isPressed != oldValue { fireStateChanged() } }
    }
    public var isRollover: Bool = false {
      didSet { if isRollover != oldValue { fireStateChanged() } }
    }
    public var isSelected: Bool = false {
      didSet { if isSelected != oldValue { fireStateChanged() } }
    }
    public var isEnabled: Bool = true {
      didSet { if isEnabled != oldValue { fireStateChanged() } }
    }

    // -------------------------------------------------------------------------
    // MARK: Action command / mnemonic
    // -------------------------------------------------------------------------

    public var actionCommand: String? = nil
    public var mnemonic: Int = 0

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
