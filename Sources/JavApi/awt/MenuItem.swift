/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Ein einzelner Menüeintrag — mirrors `java.awt.MenuItem`.
  @MainActor
  open class MenuItem: MenuComponent {

    public private(set) var label: String
    public var enabled: Bool = true
    public var shortcut: MenuShortcut? = nil

    private var actionListeners: [java.awt.event.ActionListener] = []
    private var actionCommand:   String = ""

    public init(_ label: String = "") {
      self.label         = label
      self.actionCommand = label
    }

    public convenience init(_ label: String, _ shortcut: MenuShortcut) {
      self.init(label)
      self.shortcut = shortcut
    }

    // -------------------------------------------------------------------------
    // MARK: Label
    // -------------------------------------------------------------------------

    public func getLabel() -> String  { label }
    public func setLabel(_ l: String) { label = l }

    // -------------------------------------------------------------------------
    // MARK: ActionCommand
    // -------------------------------------------------------------------------

    public func getActionCommand() -> String  { actionCommand }
    public func setActionCommand(_ s: String) { actionCommand = s }

    // -------------------------------------------------------------------------
    // MARK: Enabled
    // -------------------------------------------------------------------------

    public func isEnabled() -> Bool      { enabled }
    public func setEnabled(_ b: Bool)    { enabled = b }
    /// Java 1.0 Alias
    public func enable()                 { enabled = true }
    public func disable()                { enabled = false }

    // -------------------------------------------------------------------------
    // MARK: Listeners
    // -------------------------------------------------------------------------

    public func addActionListener(_ l: java.awt.event.ActionListener) {
      actionListeners.append(l)
    }
    public func removeActionListener(_ l: java.awt.event.ActionListener) {
      actionListeners.removeAll { $0 === l }
    }

    /// Feuert einen ActionEvent an alle registrierten Listener.
    public func doAction() {
      guard enabled else { return }
      let e = java.awt.event.ActionEvent(
        self as AnyObject,
        java.awt.event.ActionEvent.ACTION_PERFORMED,
        actionCommand)
      actionListeners.forEach { $0.actionPerformed(e) }
    }
  }

  // ---------------------------------------------------------------------------
  // MARK: Separator-Hilfsmethode
  // ---------------------------------------------------------------------------

  /// Erzeugt einen Trennstrich-Eintrag (`"-"`).
  @MainActor
  public static func menuSeparator() -> MenuItem {
    MenuItem("-")
  }
}
