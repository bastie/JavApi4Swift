/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A horizontal menu bar that holds top-level `JMenu` entries.
  ///
  /// `JMenuBar` is a `JComponent` — unlike `java.awt.MenuBar` it draws itself
  /// via the active Look & Feel delegate (`MenuBarUI`).  It is placed in the
  /// `FRAME_CONTENT_LAYER` of a `JRootPane`'s `JLayeredPane`, sitting above the
  /// content pane and below any pop-up overlays.
  ///
  /// ## Usage
  ///
  /// ```swift
  /// let menuBar = javax.swing.JMenuBar()
  /// menuBar.add(javax.swing.JMenu("File"))
  /// menuBar.add(javax.swing.JMenu("Edit"))
  /// frame.setJMenuBar(menuBar)
  /// ```
  ///
  /// ## Overlay note
  ///
  /// The menu bar occupies its own layer in `JLayeredPane` (`FRAME_CONTENT_LAYER`).
  /// Later, `JPopupMenu` (the drop-down) will live in `POPUP_LAYER` above it.
  /// This avoids the clipping problems experienced with AWT's X11 menu rendering,
  /// where the dropdown had to be drawn as a separate X11 window overlay.
  ///
  @MainActor
  open class JMenuBar: javax.swing.JComponent {

    // -------------------------------------------------------------------------
    // MARK: Height constant
    // -------------------------------------------------------------------------

    /// Default height of the menu bar in pixels.
    /// `BasicMenuBarUI` uses this; a custom L&F may override via `getPreferredSize`.
    public static let defaultHeight: Int = 24

    // -------------------------------------------------------------------------
    // MARK: Menus
    // -------------------------------------------------------------------------

    private var menus: [javax.swing.JMenu] = []

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    public override init() {
      super.init()
      setOpaque(true)
      updateUI()
    }

    // -------------------------------------------------------------------------
    // MARK: UI delegate
    // -------------------------------------------------------------------------

    override open func updateUI() {
      setUI(javax.swing.plaf.basic.BasicMenuBarUI())
    }

    // -------------------------------------------------------------------------
    // MARK: Menu management
    // -------------------------------------------------------------------------

    /// Appends `menu` to the right of the last menu.
    @discardableResult
    public func add(_ menu: javax.swing.JMenu) -> javax.swing.JMenu {
      menus.append(menu)
      menu.parent = self          // wire up AWT parent for layout / repaint
      invalidate()
      return menu
    }

    /// Removes `menu` from the bar.
    public func remove(_ menu: javax.swing.JMenu) {
      menus.removeAll { $0 === menu }
      menu.parent = nil
      invalidate()
    }

    /// Returns the menu at `index`.
    public func getMenu(_ index: Int) -> javax.swing.JMenu {
      menus[index]
    }

    /// Returns the number of menus in this bar.
    public func getMenuCount() -> Int { menus.count }

    /// Returns all menus (for use by the UI delegate during painting).
    public func getMenus() -> [javax.swing.JMenu] { menus }
  }
}
