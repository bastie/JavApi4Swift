/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A top-level menu entry shown in a `JMenuBar`.
  ///
  /// When clicked, `JMenu` opens its `JPopupMenu` in `POPUP_LAYER` of the
  /// owning frame's `JLayeredPane`, painting above the content pane without
  /// the X11 clipping problems of native menus.
  ///
  /// ## Usage
  ///
  /// ```swift
  /// let file = javax.swing.JMenu("File")
  /// file.add(javax.swing.JMenuItem("New"))
  /// file.add(javax.swing.JMenuItem("Open…"))
  /// file.addSeparator()
  /// file.add(javax.swing.JMenuItem("Quit"))
  /// menuBar.add(file)
  /// ```
  ///
  @MainActor
  open class JMenu: javax.swing.JComponent {

    // -------------------------------------------------------------------------
    // MARK: Properties
    // -------------------------------------------------------------------------

    /// The text label shown in the menu bar.
    public var text: String

    /// `true` while the popup is open (used by `BasicMenuBarUI` to highlight).
    public internal(set) var isSelected: Bool = false

    /// The popup that drops down when this menu is clicked.
    public let swingPopupMenu: javax.swing.JPopupMenu = javax.swing.JPopupMenu()

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    public init(_ text: String = "") {
      self.text = text
      super.init()
    }

    // -------------------------------------------------------------------------
    // MARK: Accessors
    // -------------------------------------------------------------------------

    public func getText() -> String      { text }
    public func setText(_ t: String)     { text = t; invalidate() }

    // -------------------------------------------------------------------------
    // MARK: Item management
    // -------------------------------------------------------------------------

    /// Appends a `JMenuItem` to the popup.
    @discardableResult
    public func add(_ item: javax.swing.JMenuItem) -> javax.swing.JMenuItem {
      swingPopupMenu.add(item)
      return item
    }

    /// Appends a separator to the popup.
    public func addSeparator() {
      swingPopupMenu.addSeparator()
    }

    /// Returns all items in the popup (for hit-testing / painting).
    public func getItems() -> [javax.swing.JMenuItem] {
      swingPopupMenu.getItems()
    }

    /// Returns the number of items in the popup.
    public func getItemCount() -> Int { swingPopupMenu.getItemCount() }
  }
}
