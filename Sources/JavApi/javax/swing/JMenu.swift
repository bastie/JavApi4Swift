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
    private var _text: String

    // -------------------------------------------------------------------------
    // MARK: Model (ButtonModel — inherited from AbstractButton in Java)
    // -------------------------------------------------------------------------

    private var _model: javax.swing.ButtonModel = javax.swing.DefaultButtonModel()

    public func getModel() -> javax.swing.ButtonModel { _model }
    public func setModel(_ model: javax.swing.ButtonModel) { _model = model }

    /// Returns `true` while the popup is open (delegates to model).
    public func isSelected() -> Bool { _model.isSelected() }
    /// Sets the popup-open state (delegates to model).
    public func setSelected(_ b: Bool) { _model.setSelected(b) }

    /// The popup that drops down when this menu is clicked.
    public let swingPopupMenu: javax.swing.JPopupMenu = javax.swing.JPopupMenu()

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    public init(_ text: String = "") {
      self._text = text
      super.init()
    }

    // -------------------------------------------------------------------------
    // MARK: Accessors
    // -------------------------------------------------------------------------

    public func getText() -> String      { _text }
    public func setText(_ t: String)     { _text = t; invalidate() }

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
