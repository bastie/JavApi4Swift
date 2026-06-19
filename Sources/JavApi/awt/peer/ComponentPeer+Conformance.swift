/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - java.awt.Component conforms to ComponentPeer
//
// In JavApi⁴Swift components render themselves — there is no separate native
// peer object.  Each component IS its own peer.
extension java.awt.Component: java.awt.peer._deprecatedComponentPeer {

  // show(), hide(), enable(), disable() are defined as open func on Component directly
  // so they can be overridden in subclasses (e.g. JInternalFrame).

  /// Prints the component — default delegates to paint.
  public func print(_ g: java.awt.Graphics) { paint(g) }

  /// Repaints after `tm` ms, clipped to the given rectangle — delegates to repaint().
  public func repaint(_ tm: Int, _ x: Int, _ y: Int, _ width: Int, _ height: Int) {
    repaint()
  }

  /// Moves and resizes the component (Java 1.0 peer API).
  public func reshape(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {
    bounds = java.awt.Rectangle(x, y, width, height)
  }

  /// Dispatches a legacy `java.awt.Event`.
  /// - Returns: `false` by default
  @available(*, deprecated, message: "Java 1.0 peer API — use java.awt.event listeners for new code")
  public func handleEvent(_ e: java.awt.Event) -> Bool { false }

  /// Returns the minimum size — delegates to getMinimumSize().
  public func minimumSize()  -> java.awt.Dimension { getMinimumSize()  }
  /// Returns the preferred size — delegates to getPreferredSize().
  public func preferredSize() -> java.awt.Dimension { getPreferredSize() }

  /// Returns the default RGB color model.
  public func getColorModel() -> java.awt.image.ColorModel {
    java.awt.image.ColorModel.getRGBdefault()
  }

  // getGraphics() and dispose() are defined as open func on Component directly.

  /// Sets the foreground color.
  public func setForegroundColor(_ c: java.awt.Color) { foreground = c }
  /// Sets the background color.
  public func setBackgroundColor(_ c: java.awt.Color) { background = c }
  /// Sets the font.
  public func setFont(_ f: java.awt.Font) { font = f }

  /// Requests keyboard focus — stub.
  public func requestFocus() {}
  /// Transfers focus to next component — stub.
  public func nextFocus() {}

  /// Creates an image from a producer — returns a stub Image.
  public func createImage(_ producer: any java.awt.image.ImageProducer) -> java.awt.Image {
    java.awt.Image()
  }
  /// Creates an off-screen image — returns a stub Image.
  public func createImage(_ width: Int, _ height: Int) -> java.awt.Image {
    java.awt.Image()
  }
  /// Prepares an image for rendering — returns true (no async loading needed).
  public func prepareImage(_ image: java.awt.Image, _ width: Int, _ height: Int,
                            _ observer: any java.awt.ImageObserver) -> Bool { true }
  /// Checks image construction status — returns ALLBITS (fully available).
  public func checkImage(_ image: java.awt.Image, _ width: Int, _ height: Int,
                          _ observer: any java.awt.ImageObserver) -> Int {
    32 // ImageObserver.ALLBITS
  }
}

// MARK: - Button → ButtonPeer

@available(*, deprecated, message: "This API is not meant to be called by clients.")
extension java.awt.Button: java.awt.peer.ButtonPeer {
  // setLabel(_ label: String) already exists on Button
}

// MARK: - Checkbox → CheckboxPeer

@available(*, deprecated, message: "This API is not meant to be called by clients.")
extension java.awt.Checkbox: java.awt.peer.CheckboxPeer {
  // setState, setCheckboxGroup, setLabel already exist on Checkbox
}

// MARK: - List → ListPeer

@available(*, deprecated, message: "This API is not meant to be called by clients.")
extension java.awt.List: java.awt.peer.ListPeer {
  public func addItem(_ item: String, _ index: Int) { add(item, index) }
  public func delItems(_ start: Int, _ end: Int) {
    for i in stride(from: end, through: start, by: -1) { remove(i) }
  }
  public func clear() { removeAll() }
  public func setMultipleSelections(_ v: Bool) { setMultipleMode(v) }
  public func minimumSize(_ rows: Int) -> java.awt.Dimension { getMinimumSize() }
  public func preferredSize(_ rows: Int) -> java.awt.Dimension { getPreferredSize() }
}

// MARK: - Choice → ChoicePeer
// Choice already has select(_ index: Int) and insert(_ item:, _ index:) — no extra methods needed.
@available(*, deprecated, message: "This API is not meant to be called by clients.")
extension java.awt.Choice: java.awt.peer.ChoicePeer {
  public func addItem(_ item: String, _ index: Int) { insert(item, index) }
  // select(_ index: Int) already exists on Choice
}

// MARK: - Scrollbar → ScrollbarPeer

@available(*, deprecated, message: "This API is not meant to be called by clients.")
extension java.awt.Scrollbar: java.awt.peer.ScrollbarPeer {
  public func setValues(_ value: Int, _ visible: Int, _ minimum: Int, _ maximum: Int) {
    setValue(value)
    setVisibleAmount(visible)
    setMinimum(minimum)
    setMaximum(maximum)
  }
  public func setLineIncrement(_ l: Int) { setUnitIncrement(l)  }
  public func setPageIncrement(_ l: Int) { setBlockIncrement(l) }
}

// MARK: - TextComponent → TextComponentPeer (selection methods)

@available(*, deprecated, message: "This API is not meant to be called by clients.")
extension java.awt.TextComponent {
  public func getSelectionStart() -> Int { selectionStart }
  public func getSelectionEnd()   -> Int { selectionEnd   }
  public func select(_ selStart: Int, _ selEnd: Int) {
    selectionAnchor = selStart
    caretPosition   = selEnd
  }
}

// MARK: - TextField → TextFieldPeer

@available(*, deprecated, message: "This API is not meant to be called by clients.")
extension java.awt.TextField: java.awt.peer.TextFieldPeer {
  public func setEchoCharacter(_ c: Character) { setEchoChar(c) }
  public func preferredSize(_ cols: Int) -> java.awt.Dimension { getPreferredSize() }
  public func minimumSize(_ cols: Int) -> java.awt.Dimension { getMinimumSize() }
  // TextComponentPeer methods: getText/setText/setEditable etc. already exist
}

// MARK: - MenuItem → MenuItemPeer

@available(*, deprecated, message: "This API is not meant to be called by clients.")
extension java.awt.MenuItem: java.awt.peer.MenuItemPeer {
  // setLabel, enable, disable already exist on MenuItem
  public func dispose() {}
}

// MARK: - Menu → MenuPeer

@available(*, deprecated, message: "This API is not meant to be called by clients.")
extension java.awt.Menu: java.awt.peer.MenuPeer {
  public func addItem(_ item: java.awt.MenuItem) { add(item) }
  public func delItem(_ index: Int) { remove(index) }
}

// MARK: - MenuBar → MenuBarPeer

@available(*, deprecated, message: "This API is not meant to be called by clients.")
extension java.awt.MenuBar: java.awt.peer.MenuBarPeer {
  public func addMenu(_ m: java.awt.Menu)     { _ = add(m) }
  public func delMenu(_ index: Int)           { remove(index) }
  public func addHelpMenu(_ m: java.awt.Menu) { setHelpMenu(m) }
  public func dispose() {}
}

// MARK: - CheckboxMenuItem → CheckboxMenuItemPeer

@available(*, deprecated, message: "This API is not meant to be called by clients.")
extension java.awt.CheckboxMenuItem: java.awt.peer.CheckboxMenuItemPeer {
  // setState already exists on CheckboxMenuItem
}

// MARK: - TextArea → TextAreaPeer

@available(*, deprecated, message: "This API is not meant to be called by clients.")
extension java.awt.TextArea: java.awt.peer.TextAreaPeer {
  public func insertText(_ text: String, _ pos: Int) { insert(text, pos) }
  public func replaceText(_ text: String, _ start: Int, _ end: Int) {
    replaceRange(text, start, end)
  }
  public func preferredSize(_ rows: Int, _ cols: Int) -> java.awt.Dimension { getPreferredSize() }
  public func minimumSize(_ rows: Int, _ cols: Int) -> java.awt.Dimension { getMinimumSize() }
}
