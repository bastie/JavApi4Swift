/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.basic {

  /// Default UI delegate for `JTabbedPane`.
  ///
  /// Paints a row of tabs at the top (TOP placement) and the content area
  /// below.  Each tab shows its title (and icon if set).  The selected tab
  /// is highlighted and its associated component fills the content area.
  ///
  /// When the tab layout policy is `SCROLL_TAB_LAYOUT` and the total tab
  /// width exceeds the available width, scroll buttons (◀ ▶) are shown at
  /// the right end of the tab strip.
  ///
  @MainActor
  open class BasicTabbedPaneUI: javax.swing.plaf.ComponentUI {

    // ── Geometry constants ────────────────────────────────────────────────────
    private let tabHeight   = 24
    private let tabPadX     = 10
    private let tabPadY     = 4
    private let borderW     = 1
    /// Width of each scroll arrow button (SCROLL_TAB_LAYOUT only).
    private let scrollBtnW  = 20

    // Track last laid-out size / selection to avoid redundant layouts.
    private var _lastValidatedSize:   java.awt.Dimension = java.awt.Dimension(0, 0)
    private var _lastValidatedSelIdx: Int = -1

    // ── Cached tab widths ─────────────────────────────────────────────────────
    /// Returns widths for every tab title using the given font metrics.
    private func tabWidths(_ tabs: [javax.swing.JTabbedPane.Tab],
                           _ fm: java.awt.FontMetrics) -> [Int] {
      tabs.map { fm.stringWidth($0.title) + tabPadX * 2 }
    }

    /// Total pixel width of all tabs (excluding scroll buttons).
    private func totalTabWidth(_ widths: [Int]) -> Int {
      widths.reduce(0, +) + widths.count  // +1 separator between each tab
    }

    // ── Preferred size ────────────────────────────────────────────────────────

    override open func getPreferredSize(_ component: javax.swing.JComponent) -> java.awt.Dimension? {
      guard let tp = component as? javax.swing.JTabbedPane else { return nil }
      var maxW = 200
      var maxH = 100
      for tab in tp.getTabs() {
        let ps = tab.component.getPreferredSize()
        maxW = Swift.max(maxW, ps.width)
        maxH = Swift.max(maxH, ps.height)
      }
      return java.awt.Dimension(maxW, maxH + tabHeight)
    }

    // ── Hit-test (called by JTabbedPane.indexAtLocation) ──────────────────────

    func tabIndexAt(_ x: Int, _ y: Int, in tp: javax.swing.JTabbedPane) -> Int {
      let tabs   = tp.getTabs()
      let fm     = java.awt.FontMetrics.make(for: javax.swing.JComponent().font)
      let widths = tabWidths(tabs, fm)
      let offset = tp._tabScrollOffset
      var tx     = borderW - offset
      for (i, tw) in widths.enumerated() {
        if x >= tx && x < tx + tw && y >= 0 && y < tabHeight {
          return i
        }
        tx += tw + 1
      }
      return -1
    }

    // ── Scroll-button hit-test ────────────────────────────────────────────────

    private func scrollButtonRects(
      availableWidth: Int
    ) -> (left: java.awt.Rectangle, right: java.awt.Rectangle) {
      let rightBtnX = availableWidth - scrollBtnW - borderW
      let leftBtnX  = rightBtnX - scrollBtnW - 1
      let r = java.awt.Rectangle(0, 0, scrollBtnW, tabHeight - 2)
      let left  = java.awt.Rectangle(leftBtnX,  1, scrollBtnW, tabHeight - 2)
      let right = java.awt.Rectangle(rightBtnX, 1, scrollBtnW, tabHeight - 2)
      _ = r  // suppress unused warning
      return (left, right)
    }

    // ── Unified click handler (called by JTabbedPane) ─────────────────────────

    func handleClick(_ x: Int, _ y: Int, in tp: javax.swing.JTabbedPane) {
      let tabs   = tp.getTabs()
      let fm     = java.awt.FontMetrics.make(for: javax.swing.JComponent().font)
      let widths = tabWidths(tabs, fm)
      let total  = totalTabWidth(widths)
      let bw     = tp.getBounds().width

      if tp.getTabLayoutPolicy() == javax.swing.JTabbedPane.SCROLL_TAB_LAYOUT
          && total > bw - scrollBtnW * 2 - borderW * 2
          && y >= 0 && y < tabHeight {
        let (leftBtn, rightBtn) = scrollButtonRects(availableWidth: bw)
        let step = Swift.max(bw / 3, 40)
        let maxOffset = Swift.max(0, total - (bw - scrollBtnW * 2 - borderW * 2 - 2))

        if leftBtn.contains(x, y) {
          tp._tabScrollOffset = Swift.max(0, tp._tabScrollOffset - step)
          return
        }
        if rightBtn.contains(x, y) {
          tp._tabScrollOffset = Swift.min(maxOffset, tp._tabScrollOffset + step)
          return
        }
      }

      // Regular tab click
      let idx = tabIndexAt(x, y, in: tp)
      if idx >= 0 && tp.isEnabledAt(idx) {
        tp.setSelectedIndex(idx)
        // Auto-scroll to make selected tab visible (SCROLL_TAB_LAYOUT only)
        if tp.getTabLayoutPolicy() == javax.swing.JTabbedPane.SCROLL_TAB_LAYOUT {
          scrollToVisible(idx: idx, widths: widths, in: tp, availableWidth: bw)
        }
      }
    }

    /// Adjusts `_tabScrollOffset` so the tab at `idx` is fully visible.
    private func scrollToVisible(
      idx: Int, widths: [Int],
      in tp: javax.swing.JTabbedPane,
      availableWidth: Int
    ) {
      let visibleW = availableWidth - scrollBtnW * 2 - borderW * 2 - 2
      var tabStart = borderW
      for i in 0..<idx { tabStart += widths[i] + 1 }
      let tabEnd = tabStart + widths[idx]

      let offset = tp._tabScrollOffset
      if tabStart - offset < 0 {
        tp._tabScrollOffset = tabStart
      } else if tabEnd - offset > visibleW {
        tp._tabScrollOffset = tabEnd - visibleW
      }
    }

    // ── Layout ────────────────────────────────────────────────────────────────

    private func layoutContent(of tp: javax.swing.JTabbedPane) {
      let b = tp.getBounds()
      let contentY = tabHeight
      let contentH = Swift.max(b.height - tabHeight, 0)
      for tab in tp.getTabs() {
        tab.component.bounds = java.awt.Rectangle(
          borderW, contentY,
          Swift.max(b.width - borderW * 2, 0),
          contentH)
        (tab.component as? java.awt.Container)?.doLayout()
      }
    }

    // ── Painting ──────────────────────────────────────────────────────────────

    override open func paint(_ g: java.awt.Graphics, _ component: javax.swing.JComponent) {
      guard let tp = component as? javax.swing.JTabbedPane else { return }
      let b      = tp.getBounds()
      let w      = b.width
      let h      = b.height
      let selIdx = tp.getSelectedIndex()
      let tabs   = tp.getTabs()
      let fm     = java.awt.FontMetrics.make(for: component.font)
      let widths = tabWidths(tabs, fm)
      let total  = totalTabWidth(widths)

      let isScrollLayout = tp.getTabLayoutPolicy() == javax.swing.JTabbedPane.SCROLL_TAB_LAYOUT
      let needsScroll    = isScrollLayout && total > w - scrollBtnW * 2 - borderW * 2

      // ── Background ──────────────────────────────────────────────────────────
      g.setColor(java.awt.SystemColor.control)
      g.fillRect(0, 0, w, h)

      // ── Content area border ──────────────────────────────────────────────────
      g.setColor(java.awt.SystemColor.controlShadow)
      g.drawRect(0, tabHeight - 1, w - 1, h - tabHeight)

      // ── Tab strip clip (leave room for scroll buttons if needed) ─────────────
      let tabAreaW = needsScroll ? w - scrollBtnW * 2 - borderW * 2 - 2 : w
      let scrollOffset = needsScroll ? tp._tabScrollOffset : 0

      g.save()
      g.clipRect(borderW, 0, tabAreaW, tabHeight)

      // ── Tabs ─────────────────────────────────────────────────────────────────
      var tx = borderW - scrollOffset
      for (i, tw) in widths.enumerated() {
        let isSelected = (i == selIdx)

        if tx + tw > borderW || tx < borderW + tabAreaW {
          // Tab background
          if isSelected {
            g.setColor(java.awt.SystemColor.window)
            g.fillRect(tx, 0, tw, tabHeight + 1)
          } else {
            g.setColor(java.awt.SystemColor.control)
            g.fillRect(tx, tabPadY / 2, tw, tabHeight - tabPadY / 2)
          }

          // Tab border (3 sides — bottom open on selected)
          g.setColor(java.awt.SystemColor.controlShadow)
          g.drawLine(tx, 0, tx + tw - 1, 0)
          g.drawLine(tx, 0, tx, tabHeight - 1)
          g.drawLine(tx + tw - 1, 0, tx + tw - 1, tabHeight - 1)
          if !isSelected {
            g.drawLine(tx, tabHeight - 1, tx + tw - 1, tabHeight - 1)
          }

          // Tab title
          let textX = tx + tabPadX
          let textY = (tabHeight - fm.getHeight()) / 2 + fm.getAscent()
          g.setColor(tabs[i].enabled ? java.awt.SystemColor.controlText
                                     : java.awt.SystemColor.controlShadow)
          g.drawString(tabs[i].title, textX, textY)
        }

        tx += tw + 1
      }

      g.restore()

      // ── Scroll buttons ────────────────────────────────────────────────────────
      if needsScroll {
        let (leftBtn, rightBtn) = scrollButtonRects(availableWidth: w)
        let textY = (tabHeight - fm.getHeight()) / 2 + fm.getAscent()

        for (rect, symbol, canScroll) in [
          (leftBtn,  "◀", scrollOffset > 0),
          (rightBtn, "▶", scrollOffset < Swift.max(0, total - tabAreaW))
        ] as [(java.awt.Rectangle, String, Bool)] {
          g.setColor(java.awt.SystemColor.control)
          g.fillRect(rect.x, rect.y, rect.width, rect.height)
          g.setColor(java.awt.SystemColor.controlShadow)
          g.drawRect(rect.x, rect.y, rect.width - 1, rect.height - 1)
          g.setColor(canScroll ? java.awt.SystemColor.controlText
                               : java.awt.SystemColor.controlShadow)
          let symW = fm.stringWidth(symbol)
          g.drawString(symbol, rect.x + (rect.width - symW) / 2, textY)
        }
      }

      // ── Content area ──────────────────────────────────────────────────────────
      layoutContent(of: tp)

      if selIdx >= 0 && selIdx < tabs.count {
        let sel = tabs[selIdx].component
        guard sel.isVisible() else { return }
        let currentSize = java.awt.Dimension(b.width, b.height)
        let needsLayout = currentSize.width  != _lastValidatedSize.width
                       || currentSize.height != _lastValidatedSize.height
                       || selIdx             != _lastValidatedSelIdx
        if needsLayout {
          if let container = sel as? java.awt.Container {
            container.validate()
          }
          _lastValidatedSize   = currentSize
          _lastValidatedSelIdx = selIdx
        }
        let sb = sel.bounds
        g.save()
        g.clipRect(sb.x, sb.y, sb.width, sb.height)
        g.translate(sb.x, sb.y)
        sel.paint(g)
        g.restore()
      }
    }
  }
}
