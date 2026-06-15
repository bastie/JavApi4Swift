/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A command that encapsulates action state shared between multiple widgets.
  ///
  /// `Action` extends `ActionListener` by adding named properties (name, icon,
  /// tooltip, enabled flag).  Both a `JButton` and a `JMenuItem` can share the
  /// same `Action` instance; when the action is disabled, both widgets reflect
  /// that state automatically.
  ///
  /// ## Standard property keys
  ///
  /// | Constant | Meaning |
  /// |---|---|
  /// | `NAME` | Display text for the button / menu item |
  /// | `SMALL_ICON` | 16×16 icon |
  /// | `SHORT_DESCRIPTION` | Tooltip text |
  /// | `LONG_DESCRIPTION` | Extended description |
  /// | `MNEMONIC_KEY` | Keyboard mnemonic (Int) |
  /// | `ACTION_COMMAND_KEY` | Command string sent in `ActionEvent` |
  ///
  /// ## Usage
  ///
  /// ```swift
  /// class OpenAction: AbstractAction {
  ///   init() { super.init("Open…") }
  ///   override func actionPerformed(_ e: java.awt.event.ActionEvent) {
  ///     print("open!")
  ///   }
  /// }
  /// let action = OpenAction()
  /// toolbar.add(javax.swing.JButton(action))
  /// fileMenu.add(javax.swing.JMenuItem(action))
  /// ```
  ///
  @MainActor
  public protocol Action: java.awt.event.ActionListener {

    // -------------------------------------------------------------------------
    // MARK: Standard property keys
    // -------------------------------------------------------------------------

    static var NAME:               String { get }
    static var SMALL_ICON:         String { get }
    static var SHORT_DESCRIPTION:  String { get }
    static var LONG_DESCRIPTION:   String { get }
    static var MNEMONIC_KEY:       String { get }
    static var ACTION_COMMAND_KEY: String { get }

    // -------------------------------------------------------------------------
    // MARK: Required methods
    // -------------------------------------------------------------------------

    func getValue(_ key: String) -> AnyObject?
    func putValue(_ key: String, _ value: AnyObject?)

    func isEnabled() -> Bool
    func setEnabled(_ b: Bool)

    /// Registers a `PropertyChangeListener` that is notified when a property
    /// (including `enabled`) changes.  Currently a stub — listeners are kept for
    /// API compatibility.
    func addPropertyChangeListener(_ listener: java.beans.PropertyChangeListener)
    func removePropertyChangeListener(_ listener: java.beans.PropertyChangeListener)
  }
}

// ---------------------------------------------------------------------------
// MARK: - Default constants (on the protocol extension)
// ---------------------------------------------------------------------------

extension javax.swing.Action {
  public static var NAME:               String { "Name" }
  public static var SMALL_ICON:         String { "SmallIcon" }
  public static var SHORT_DESCRIPTION:  String { "ShortDescription" }
  public static var LONG_DESCRIPTION:   String { "LongDescription" }
  public static var MNEMONIC_KEY:       String { "MnemonicKey" }
  public static var ACTION_COMMAND_KEY: String { "ActionCommandKey" }
}
