/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A floating popup menu displayed below a `JMenu` title in the `JMenuBar`.
  ///
  /// `JPopupMenu` lives in `POPUP_LAYER` of the owning frame's `JLayeredPane`,
  /// so it paints above the `JMenuBar` and the content pane — the same approach
  /// that solved the X11 overlay clipping problem for AWT menus.
  ///
  /// ## Layer architecture
  ///
  /// ```
  /// JLayeredPane
  ///   ├── DEFAULT_LAYER      → contentPane
  ///   ├── FRAME_CONTENT_LAYER → JMenuBar
  ///   └── POPUP_LAYER        → JPopupMenu  ← this component
  /// ```
  ///
  /// ## Usage
  ///
  /// ```swift
  /// let popup = javax.swing.JPopupMenu()
  /// popup.add(javax.swing.JMenuItem("Cut"))
  /// popup.show(invoker: menuBarBounds, x: 0, y: 24)
  /// ```
  ///
  @MainActor
  open class JPopupMenu: javax.swing.JComponent {

    // -------------------------------------------------------------------------
    // MARK: Items
    // -------------------------------------------------------------------------

    private var items: [javax.swing.JMenuItem] = []

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
      setUI(javax.swing.plaf.basic.BasicPopupMenuUI())
    }

    // -------------------------------------------------------------------------
    // MARK: Item management
    // -------------------------------------------------------------------------

    /// Appends a `JMenuItem` to this popup.
    @discardableResult
    public func add(_ item: javax.swing.JMenuItem) -> javax.swing.JMenuItem {
      items.append(item)
      item.parent = self
      invalidate()
      return item
    }

    /// Appends a separator line.
    public func addSeparator() {
      add(javax.swing.JMenuItem.separator())
    }

    /// Removes all menu items from this popup.
    public func removeAllItems() {
      items.forEach { $0.parent = nil }
      items.removeAll()
      invalidate()
    }

    /// Returns all items (including separators).
    public func getItems() -> [javax.swing.JMenuItem] { items }

    /// Returns the number of items.
    public func getItemCount() -> Int { items.count }

    // -------------------------------------------------------------------------
    // MARK: Visibility
    // -------------------------------------------------------------------------

    /// Places this popup at `(x, y)` in the coordinate system of the
    /// `JLayeredPane` and makes it visible.
    ///
    /// The caller is responsible for adding the popup to the layered pane
    /// before calling `show`.
    public func show(x: Int, y: Int) {
      // Measure preferred height via UI delegate, fall back to item count
      let prefSize = getPreferredSize()
      bounds = java.awt.Rectangle(x, y, prefSize.width, prefSize.height)
      setVisible(true)
    }

    /// Hides the popup.
    public func closePopup() {
      setVisible(false)
    }

    // -------------------------------------------------------------------------
    // MARK: Hit test helper
    // -------------------------------------------------------------------------

    /// Returns the `JMenuItem` at screen-local point `(x, y)` within this
    /// popup's coordinate space, or `nil` if no item was hit.
    public func itemAt(x: Int, y: Int) -> javax.swing.JMenuItem? {
      guard let ui = self.ui as? javax.swing.plaf.basic.BasicPopupMenuUI else { return nil }
      return ui.item(at: x, y: y)
    }
  }
}
