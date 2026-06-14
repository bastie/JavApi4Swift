/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// The model for button-like components (`JButton`, `JMenuItem`, `JToggleButton`, …).
  ///
  /// `ButtonModel` separates the button's *state* from its *view* (UI delegate).
  /// The model tracks whether the button is armed, pressed, rollover, selected,
  /// or enabled, and notifies registered listeners when state changes.
  ///
  /// ## State semantics
  ///
  /// | State      | Meaning |
  /// |------------|---------|
  /// | `armed`    | Mouse is pressed and still over the button — release will fire the action |
  /// | `pressed`  | Mouse button is currently held down |
  /// | `rollover` | Mouse cursor is hovering over the button |
  /// | `selected` | Button is in a toggled-on state (`JToggleButton`, `JCheckBox`, …) |
  /// | `enabled`  | Button can be interacted with |
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol ButtonModel: AnyObject {

    // -------------------------------------------------------------------------
    // MARK: State accessors
    // -------------------------------------------------------------------------

    var isArmed:    Bool { get set }
    var isPressed:  Bool { get set }
    var isRollover: Bool { get set }
    var isSelected: Bool { get set }
    var isEnabled:  Bool { get set }

    // -------------------------------------------------------------------------
    // MARK: Action command
    // -------------------------------------------------------------------------

    var actionCommand: String? { get set }
    var mnemonic: Int { get set }

    // -------------------------------------------------------------------------
    // MARK: Listener management
    // -------------------------------------------------------------------------

    func addChangeListener(_ l: javax.swing.event.ChangeListener)
    func removeChangeListener(_ l: javax.swing.event.ChangeListener)

    func addActionListener(_ l: java.awt.event.ActionListener)
    func removeActionListener(_ l: java.awt.event.ActionListener)

    func addItemListener(_ l: java.awt.event.ItemListener)
    func removeItemListener(_ l: java.awt.event.ItemListener)
  }
}
