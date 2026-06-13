/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// A scrollable list component that lets the user select one or multiple
  /// items — mirrors `java.awt.List`.
  ///
  /// Each visible row is `itemHeight` pixels tall. A vertical scrollbar
  /// appears automatically when there are more items than visible rows.
  open class List: Component {

    // -------------------------------------------------------------------------
    // MARK: Model
    // -------------------------------------------------------------------------

    private var items: [String] = []
    private var selectedIndices: Set<Int> = []
    private var multipleMode: Bool
    private var rows: Int

    /// Index of the first visible item.
    var scrollOffset: Int = 0

    // -------------------------------------------------------------------------
    // MARK: UI constants
    // -------------------------------------------------------------------------

    let itemHeight:     Int = 20
    let scrollbarWidth: Int = 12

    // -------------------------------------------------------------------------
    // MARK: Scrollbar drag state  (used by _SwiftUIWindowHost)
    // -------------------------------------------------------------------------

    var isScrollbarDragging: Bool = false
    var scrollDragStartY:    Int  = 0
    var scrollDragStartOff:  Int  = 0

    // -------------------------------------------------------------------------
    // MARK: Listeners
    // -------------------------------------------------------------------------

    private var itemListeners:   [java.awt.event.ItemListener]   = []
    private var actionListeners: [java.awt.event.ActionListener] = []

    public func addItemListener(_ l: java.awt.event.ItemListener) {
      itemListeners.append(l)
    }
    public func removeItemListener(_ l: java.awt.event.ItemListener) {
      itemListeners.removeAll { $0 === l }
    }
    public func addActionListener(_ l: java.awt.event.ActionListener) {
      actionListeners.append(l)
    }
    public func removeActionListener(_ l: java.awt.event.ActionListener) {
      actionListeners.removeAll { $0 === l }
    }

    internal func fireItemEvent(index: Int, stateChange: Int) {
      guard index >= 0, index < items.count else { return }
      let e = java.awt.event.ItemEvent(
        self,
        java.awt.event.ItemEvent.ITEM_STATE_CHANGED,
        item: items[index] as AnyObject,
        stateChange: stateChange)
      itemListeners.forEach { $0.itemStateChanged(e) }
    }

    internal func fireActionEvent(index: Int) {
      guard index >= 0, index < items.count else { return }
      let e = java.awt.event.ActionEvent(
        self,
        java.awt.event.ActionEvent.ACTION_PERFORMED,
        items[index])
      actionListeners.forEach { $0.actionPerformed(e) }
    }

    // -------------------------------------------------------------------------
    // MARK: Constructors
    // -------------------------------------------------------------------------

    public init(_ rows: Int = 4, _ multipleMode: Bool = false) {
      self.rows         = rows
      self.multipleMode = multipleMode
      super.init()
      background = java.awt.SystemColor.window
    }

    // -------------------------------------------------------------------------
    // MARK: Item management  (Java API)
    // -------------------------------------------------------------------------

    public func add(_ item: String) { items.append(item) }
    public func add(_ item: String, _ index: Int) {
      items.insert(item, at: max(0, min(index, items.count)))
    }
    public func addItem(_ item: String) { add(item) }

    public func remove(_ index: Int) {
      guard index >= 0, index < items.count else { return }
      items.remove(at: index)
      selectedIndices = Set(selectedIndices.filter { $0 < items.count })
      scrollOffset = min(scrollOffset, maxScrollOffset())
    }
    public func remove(_ item: String) {
      if let idx = items.firstIndex(of: item) { remove(idx) }
    }
    public func removeAll() {
      items.removeAll()
      selectedIndices.removeAll()
      scrollOffset = 0
    }

    public func getItem(_ index: Int) -> String { items[index] }
    public func getItemCount() -> Int           { items.count }
    public func getItems() -> [String]          { items }
    public func getRows() -> Int                { rows }

    // -------------------------------------------------------------------------
    // MARK: Selection  (Java API)
    // -------------------------------------------------------------------------

    public func select(_ index: Int) {
      guard index >= 0, index < items.count else { return }
      if !multipleMode { selectedIndices.removeAll() }
      selectedIndices.insert(index)
    }

    public func deselect(_ index: Int) {
      selectedIndices.remove(index)
    }

    public func isIndexSelected(_ index: Int) -> Bool {
      selectedIndices.contains(index)
    }

    public func getSelectedIndex() -> Int          { selectedIndices.sorted().first ?? -1 }
    public func getSelectedIndexes() -> [Int]      { selectedIndices.sorted() }
    public func getSelectedItem() -> String? {
      let idx = getSelectedIndex()
      return idx >= 0 ? items[idx] : nil
    }
    public func getSelectedItems() -> [String] {
      getSelectedIndexes().compactMap { $0 < items.count ? items[$0] : nil }
    }

    public func isMultipleMode() -> Bool      { multipleMode }
    public func setMultipleMode(_ b: Bool)    { multipleMode = b }

    // -------------------------------------------------------------------------
    // MARK: Scroll helpers
    // -------------------------------------------------------------------------

    func visibleRows() -> Int { max(1, bounds.height / itemHeight) }

    func needsScrollbar() -> Bool { items.count > visibleRows() }

    func maxScrollOffset() -> Int { max(0, items.count - visibleRows()) }

    /// Returns the rect of the scroll-thumb, or `nil` when not scrollable.
    func scrollbarThumbRect() -> java.awt.Rectangle? {
      guard needsScrollbar(), items.count > 0 else { return nil }
      let trackX = bounds.x + bounds.width - scrollbarWidth
      let trackH = bounds.height
      let thumbH = max(12, trackH * visibleRows() / items.count)
      let maxOff = maxScrollOffset()
      let thumbY = bounds.y + (maxOff > 0
        ? (trackH - thumbH) * scrollOffset / maxOff
        : 0)
      return java.awt.Rectangle(trackX, thumbY, scrollbarWidth, thumbH)
    }

    /// Returns the full scrollbar track rect, or `nil` when not scrollable.
    func scrollbarTrackRect() -> java.awt.Rectangle? {
      guard needsScrollbar() else { return nil }
      return java.awt.Rectangle(bounds.x + bounds.width - scrollbarWidth,
                                bounds.y, scrollbarWidth, bounds.height)
    }

    /// The item index at AWT y coordinate `y` (frame space), or `nil`.
    /// Returns `nil` when `x` falls inside the scrollbar column.
    func itemIndex(atY y: Int) -> Int? {
      let relY = y - bounds.y
      guard relY >= 0, relY < bounds.height else { return nil }
      let idx = scrollOffset + relY / itemHeight
      return idx < items.count ? idx : nil
    }

    /// Scroll so that `index` is visible.
    public func makeVisible(_ index: Int) {
      if index < scrollOffset {
        scrollOffset = index
      } else if index >= scrollOffset + visibleRows() {
        scrollOffset = index - visibleRows() + 1
      }
      scrollOffset = max(0, min(scrollOffset, maxScrollOffset()))
    }

    // -------------------------------------------------------------------------
    // MARK: Paint
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics) {
      let x = bounds.x, y = bounds.y, w = bounds.width, h = bounds.height
      let fm    = getFontMetrics(font)
      let listW = needsScrollbar() ? w - scrollbarWidth : w

      // Background
      g.setColor(background)
      g.fillRect(x, y, w, h)

      // Items
      let vRows = visibleRows()
      for row in 0..<vRows {
        let idx = scrollOffset + row
        guard idx < items.count else { break }
        let iy = y + row * itemHeight

        if isIndexSelected(idx) {
          g.setColor(java.awt.SystemColor.textHighlight)
          g.fillRect(x, iy, listW, itemHeight)
          g.setColor(java.awt.SystemColor.textHighlightText)
        } else {
          g.setColor(foreground)
        }
        let ty = iy + (itemHeight - fm.getHeight()) / 2 + fm.getAscent()
        g.drawString(items[idx], x + 4, ty)
      }

      // Row separator lines
      g.setColor(java.awt.SystemColor.windowBorder)
      for row in 1..<vRows {
        let iy = y + row * itemHeight
        g.drawLine(x, iy, x + listW - 1, iy)
      }

      // Vertical scrollbar
      if needsScrollbar() {
        let trackX = x + w - scrollbarWidth
        g.setColor(java.awt.SystemColor.scrollbar)
        g.fillRect(trackX, y, scrollbarWidth, h)
        if let thumb = scrollbarThumbRect() {
          g.setColor(java.awt.SystemColor.control)
          g.fillRect(thumb.x, thumb.y, thumb.width, thumb.height)
          g.setColor(java.awt.SystemColor.controlShadow)
          g.drawLine(thumb.x,              thumb.y,              thumb.x + thumb.width - 1, thumb.y)
          g.drawLine(thumb.x,              thumb.y,              thumb.x,                   thumb.y + thumb.height - 1)
          g.drawLine(thumb.x + thumb.width-1, thumb.y,           thumb.x + thumb.width - 1, thumb.y + thumb.height - 1)
          g.drawLine(thumb.x,              thumb.y + thumb.height-1, thumb.x + thumb.width - 1, thumb.y + thumb.height - 1)
        }
      }

      // Border
      g.setColor(java.awt.SystemColor.windowBorder)
      g.drawLine(x,     y,     x+w-1, y)
      g.drawLine(x,     y,     x,     y+h-1)
      g.drawLine(x+w-1, y,     x+w-1, y+h-1)
      g.drawLine(x,     y+h-1, x+w-1, y+h-1)
    }
    override open func dispose() {
      itemListeners.removeAll()
      actionListeners.removeAll()
      super.dispose()
    }

  }
}
