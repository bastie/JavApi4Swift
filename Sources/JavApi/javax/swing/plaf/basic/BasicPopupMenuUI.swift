/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.basic {

  /// Default UI delegate for `JPopupMenu`.
  ///
  /// Draws a drop-down panel containing `JMenuItem` labels.  Layout:
  ///
  /// - Each item is `itemHeight` pixels tall.
  /// - Separators are `separatorHeight` pixels tall (horizontal rule).
  /// - The panel has a 1-pixel border in `controlShadow`.
  /// - The hovered/armed item is highlighted in `textHighlight` background.
  ///
  /// ## Colours
  ///
  /// | Role | Source |
  /// |---|---|
  /// | Background | `SystemColor.menu` |
  /// | Item text | `SystemColor.menuText` |
  /// | Armed item background | `SystemColor.textHighlight` |
  /// | Armed item text | `SystemColor.textHighlightText` |
  /// | Border | `SystemColor.controlShadow` |
  /// | Separator | `SystemColor.controlShadow` |
  ///
  @MainActor
  open class BasicPopupMenuUI: javax.swing.plaf.ComponentUI {

    // -------------------------------------------------------------------------
    // MARK: Layout constants
    // -------------------------------------------------------------------------

    /// Vertical padding added above and below text within each item row.
    public static let itemVerticalPad: Int  = 4
    /// Height of a separator line (computed as fraction of item height).
    public static let separatorHeight: Int  = 5
    public static let padX: Int             = 12
    public static let minWidth: Int         = 120

    private let font = java.awt.Font("Dialog", java.awt.Font.PLAIN, 12)

    /// Item height computed from font metrics — not a hardcoded pixel value.
    private var itemHeight: Int {
      let fm = java.awt.FontMetrics.make(for: font)
      return fm.getHeight() + Self.itemVerticalPad
    }

    // -------------------------------------------------------------------------
    // MARK: Cached item rects
    // -------------------------------------------------------------------------

    /// One rect per item, rebuilt in `layoutItems`.
    private(set) var itemRects: [(item: javax.swing.JMenuItem, rect: java.awt.Rectangle)] = []

    // -------------------------------------------------------------------------
    // MARK: Preferred size
    // -------------------------------------------------------------------------

    override open func getPreferredSize(_ component: javax.swing.JComponent) -> java.awt.Dimension? {
      guard let popup = component as? javax.swing.JPopupMenu else { return nil }
      let fm = java.awt.FontMetrics.make(for: font)
      var maxW = Self.minWidth
      var totalH = 0
      for item in popup.getItems() {
        if item.isSeparator {
          totalH += Self.separatorHeight
        } else {
          let w = fm.stringWidth(item.getText()) + Self.padX * 2
          if w > maxW { maxW = w }
          totalH += itemHeight
        }
      }
      // Add 2px for top+bottom border
      return java.awt.Dimension(maxW, totalH + 2)
    }

    // -------------------------------------------------------------------------
    // MARK: Painting
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics, on component: javax.swing.JComponent) {
      guard let popup = component as? javax.swing.JPopupMenu else { return }
      let w = popup.bounds.width
      let h = popup.bounds.height
      let fm = java.awt.FontMetrics.make(for: font)

      // Rebuild item rects
      layoutItems(popup: popup)

      // Background
      g.setColor(java.awt.SystemColor.menu)
      g.fillRect(0, 0, w, h)

      // Border
      g.setColor(java.awt.SystemColor.controlShadow)
      g.drawRect(0, 0, w - 1, h - 1)

      // Items
      for (item, rect) in itemRects {
        if item.isSeparator {
          let midY = rect.y + rect.height / 2
          g.setColor(java.awt.SystemColor.controlShadow)
          g.drawLine(1, midY, w - 2, midY)
        } else {
          if item.isArmed {
            g.setColor(java.awt.SystemColor.textHighlight)
            g.fillRect(1, rect.y, w - 2, rect.height)
            g.setColor(java.awt.SystemColor.textHighlightText)
          } else {
            g.setColor(java.awt.SystemColor.menuText)
          }
          let textY = rect.y + (rect.height - fm.getHeight()) / 2 + fm.getAscent()
          g.drawString(item.getText(), rect.x + Self.padX, textY)
        }
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Layout helper
    // -------------------------------------------------------------------------

    private func layoutItems(popup: javax.swing.JPopupMenu) {
      itemRects.removeAll()
      var y = 1   // 1px top border
      for item in popup.getItems() {
        let h = item.isSeparator ? Self.separatorHeight : itemHeight
        let w = popup.bounds.width
        itemRects.append((item: item, rect: java.awt.Rectangle(0, y, w, h)))
        y += h
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Hit test
    // -------------------------------------------------------------------------

    /// Returns the `JMenuItem` whose rect contains `(x, y)` in popup-local
    /// coordinates, or `nil` if no item was hit or the hit was a separator.
    public func item(at x: Int, y: Int) -> javax.swing.JMenuItem? {
      return itemRects.first {
        !$0.item.isSeparator && $0.rect.contains(java.awt.Point(x, y))
      }?.item
    }

    /// Updates the `isArmed` state for all items, arming the one at `(x, y)`.
    /// Returns `true` if the armed item changed (caller should redraw).
    @discardableResult
    public func updateArmed(at x: Int, y: Int) -> Bool {
      var changed = false
      for (item, rect) in itemRects {
        let shouldArm = !item.isSeparator && rect.contains(java.awt.Point(x, y))
        if item.isArmed != shouldArm {
          item.isArmed = shouldArm
          changed = true
        }
      }
      return changed
    }
  }
}
