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

    /// `true` if this item is a visual separator rather than an actionable entry.
    ///
    /// Separators are created via `Menu.addSeparator()` or `Menu.insertSeparator(_:)`.
    /// - Rendering: native toolkits (AppKit, UIKit) draw a platform-native divider line;
    ///   TUI rendering falls back to `Menu._SEPARATOR_LINE` as a text representation.
    /// - Dark Mode: native rendering uses `NSColor.separatorColor` / `UIColor.separator`
    ///   which automatically adapts to the current appearance.
    public let isSeparator: Bool

    private var actionListeners: [java.awt.event.ActionListener] = []
    private var actionCommand:   String = ""

    public init(_ label: String = "") {
      self.label         = label
      self.actionCommand = label
      self.isSeparator   = false
    }

    /// Designated initializer for separator items.
    /// Use `Menu.addSeparator()` instead of calling this directly.
    public init(isSeparator: Bool) {
      self.isSeparator   = isSeparator
      self.label         = isSeparator ? Menu._SEPARATOR_LINE : ""
      self.actionCommand = ""
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
  // MARK: Separator factory
  // ---------------------------------------------------------------------------

  /// Creates a separator `MenuItem`.
  /// Prefer `Menu.addSeparator()` for adding separators to a menu.
  @MainActor
  public static func menuSeparator() -> MenuItem {
    MenuItem(isSeparator: true)
  }
}
