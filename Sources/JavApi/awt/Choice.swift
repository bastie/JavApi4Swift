/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// A drop-down selection list that shows the currently selected item and
  /// expands to let the user pick another — mirrors `java.awt.Choice`.
  ///
  /// The popup is rendered by `paint()` as an overlay directly below the
  /// component. Because the frame paints children in add-order (and controls
  /// panels are typically added last), the overlay appears on top of earlier
  /// content.
  open class Choice: Component {

    // -------------------------------------------------------------------------
    // MARK: Model
    // -------------------------------------------------------------------------

    private var items: [String] = []
    private var selectedIndex: Int = -1

    // -------------------------------------------------------------------------
    // MARK: Popup state  (managed by _SwiftUIWindowHost)
    // -------------------------------------------------------------------------

    /// `true` while the drop-down popup is visible.
    var isOpen: Bool = false

    // -------------------------------------------------------------------------
    // MARK: UI constants
    // -------------------------------------------------------------------------

    let arrowWidth:         Int = 20
    let itemHeight:         Int = 20
    let maxVisiblePopupRows: Int = 6

    // -------------------------------------------------------------------------
    // MARK: Listeners
    // -------------------------------------------------------------------------

    private var itemListeners: [java.awt.event.ItemListener] = []

    public func addItemListener(_ l: java.awt.event.ItemListener) {
      itemListeners.append(l)
    }
    public func removeItemListener(_ l: java.awt.event.ItemListener) {
      itemListeners.removeAll { $0 === l }
    }

    internal func fireItemEvent(index: Int) {
      guard index >= 0, index < items.count else { return }
      let e = java.awt.event.ItemEvent(
        self,
        java.awt.event.ItemEvent.ITEM_STATE_CHANGED,
        items[index] as AnyObject,
        java.awt.event.ItemEvent.SELECTED)
      itemListeners.forEach { $0.itemStateChanged(e) }
    }

    // -------------------------------------------------------------------------
    // MARK: Constructors
    // -------------------------------------------------------------------------

    public override init() {
      super.init()
    }

    // -------------------------------------------------------------------------
    // MARK: Item management  (Java API)
    // -------------------------------------------------------------------------

    public func add(_ item: String) {
      items.append(item)
      if selectedIndex < 0 { selectedIndex = 0 }
    }

    public func addItem(_ item: String) { add(item) }

    public func insert(_ item: String, _ index: Int) {
      let i = max(0, min(index, items.count))
      items.insert(item, at: i)
      if selectedIndex < 0 { selectedIndex = 0 }
    }

    public func remove(_ index: Int) {
      guard index >= 0, index < items.count else { return }
      items.remove(at: index)
      selectedIndex = min(selectedIndex, items.count - 1)
    }

    public func remove(_ item: String) {
      if let idx = items.firstIndex(of: item) { remove(idx) }
    }

    public func removeAll() {
      items.removeAll()
      selectedIndex = -1
    }

    public func getItem(_ index: Int) -> String { items[index] }
    public func getItemCount() -> Int           { items.count }
    public func getItems() -> [String]          { items }

    public func select(_ index: Int) {
      guard index >= 0, index < items.count else { return }
      selectedIndex = index
    }

    public func select(_ item: String) {
      if let idx = items.firstIndex(of: item) { selectedIndex = idx }
    }

    public func getSelectedIndex() -> Int          { selectedIndex }
    public func getSelectedItem() -> String? {
      selectedIndex >= 0 && selectedIndex < items.count ? items[selectedIndex] : nil
    }

    // -------------------------------------------------------------------------
    // MARK: Popup geometry  (used by platform Toolkit _XXXWindowHost for hit-testing)
    // -------------------------------------------------------------------------

    /// The bounding rectangle of the popup list (below the component).
    public func popupRect() -> java.awt.Rectangle {
      let visRows = min(items.count, maxVisiblePopupRows)
      return java.awt.Rectangle(bounds.x, bounds.y + bounds.height,
                                bounds.width, visRows * itemHeight)
    }

    /// The index of the item at popup-local AWT y coordinate `y`, or `nil`.
    public func popupItemIndex(atY y: Int) -> Int? {
      let pr = popupRect()
      guard y >= pr.y, y < pr.y + pr.height else { return nil }
      let idx = (y - pr.y) / itemHeight
      return idx < items.count ? idx : nil
    }

    // -------------------------------------------------------------------------
    // MARK: Preferred size
    // -------------------------------------------------------------------------

    override public func getPreferredSize() -> java.awt.Dimension {
      if let d = _preferredSize { return d }
      let fm    = getFontMetrics(font)
      let maxW  = items.map { fm.stringWidth($0) }.max() ?? 0
      let w     = maxW + arrowWidth + 8   // text + arrow button + padding
      let h     = itemHeight + 4
      return java.awt.Dimension(w, h)
    }

    // -------------------------------------------------------------------------
    // MARK: Paint
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics) {
      // Paint in LOCAL coordinates (0,0) — Container.paint() has already
      // translated the graphics context to this component's origin.
      let x = 0, y = 0, w = bounds.width, h = bounds.height
      let fm = getFontMetrics(font)

      // Background
      g.setColor(java.awt.SystemColor.window)
      g.fillRect(x, y, w, h)

      // Selected item text
      if let sel = getSelectedItem() {
        g.setColor(java.awt.SystemColor.windowText)
        let ty = y + (h - fm.getHeight()) / 2 + fm.getAscent()
        g.drawString(sel, x + 4, ty)
      }

      // Arrow button strip
      let arrowX = x + w - arrowWidth
      g.setColor(java.awt.SystemColor.windowBorder)
      g.drawLine(arrowX, y + 1, arrowX, y + h - 2)
      let midX = arrowX + arrowWidth / 2
      let midY = y + h / 2 - 1
      g.setColor(java.awt.SystemColor.windowText)
      for i in 0..<4 {
        let row = 3 - i
        g.drawLine(midX - row, midY + i, midX + row, midY + i)
      }

      // Border
      g.setColor(java.awt.SystemColor.windowBorder)
      g.drawLine(x, y, x+w-1, y)
      g.drawLine(x, y, x, y+h-1)
      g.drawLine(x+w-1, y, x+w-1, y+h-1)
      g.drawLine(x, y+h-1, x+w-1, y+h-1)

      // ── Popup overlay ──────────────────────────────────────────────────────
      guard isOpen, !items.isEmpty else { return }

      // Popup is drawn in local coordinates: directly below the component (y = h).
      let visRows = min(items.count, maxVisiblePopupRows)
      let px = 0, py = h, pw = w, ph = visRows * itemHeight

      // Popup background
      g.setColor(java.awt.SystemColor.window)
      g.fillRect(px, py, pw, ph)

      // Items
      for i in 0..<visRows {
        let iy = py + i * itemHeight
        if i == selectedIndex {
          g.setColor(java.awt.SystemColor.textHighlight)
          g.fillRect(px + 1, iy, pw - 2, itemHeight)
          g.setColor(java.awt.SystemColor.textHighlightText)
        }
        else {
          g.setColor(java.awt.SystemColor.controlText)
        }
        let ty = iy + (itemHeight - fm.getHeight()) / 2 + fm.getAscent()
        g.drawString(items[i], px + 4, ty)
      }

      // Popup border
      g.setColor(java.awt.SystemColor.windowBorder)
      g.drawLine(px, py, px + pw - 1, py)
      g.drawLine(px, py, px, py + ph - 1)
      g.drawLine(px + pw - 1, py, px + pw - 1, py + ph - 1)
      g.drawLine(px, py + ph - 1, px + pw - 1, py + ph - 1)
    }
    override open func dispose() {
      itemListeners.removeAll()
      super.dispose()
    }

  }
}
