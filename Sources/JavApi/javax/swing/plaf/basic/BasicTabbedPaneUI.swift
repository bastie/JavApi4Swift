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
  @MainActor
  open class BasicTabbedPaneUI: javax.swing.plaf.ComponentUI {

    // Height of the tab strip
    private let tabHeight  = 24
    private let tabPadX    = 10   // horizontal padding inside each tab
    private let tabPadY    = 4
    private let borderW    = 1

    // -------------------------------------------------------------------------
    // MARK: Preferred size
    // -------------------------------------------------------------------------

    override open func getPreferredSize(of component: javax.swing.JComponent) -> java.awt.Dimension? {
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

    // -------------------------------------------------------------------------
    // MARK: Hit-test helpers (called by JTabbedPane.indexAtLocation)
    // -------------------------------------------------------------------------

    /// Returns the tab index whose rendered bounds contain `(x, y)`,
    /// or -1 if none.
    func tabIndexAt(_ x: Int, _ y: Int, in tp: javax.swing.JTabbedPane) -> Int {
      let tabs  = tp.getTabs()
      let fm    = java.awt.FontMetrics.make(for: javax.swing.JComponent().font)
      var tx    = borderW
      for (i, tab) in tabs.enumerated() {
        let tw = fm.stringWidth(tab.title) + tabPadX * 2
        if x >= tx && x < tx + tw && y >= 0 && y < tabHeight {
          return i
        }
        tx += tw + 1
      }
      return -1
    }

    // -------------------------------------------------------------------------
    // MARK: Layout — position the selected child in the content area
    // -------------------------------------------------------------------------

    private func layoutContent(of tp: javax.swing.JTabbedPane) {
      let b = tp.getBounds()
      let contentY = tabHeight
      let contentH = Swift.max(b.height - tabHeight, 0)
      for tab in tp.getTabs() {
        tab.component.bounds = java.awt.Rectangle(
          borderW, contentY,
          Swift.max(b.width - borderW * 2, 0),
          contentH)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Painting
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics, on component: javax.swing.JComponent) {
      guard let tp = component as? javax.swing.JTabbedPane else { return }
      let b        = tp.getBounds()
      let w        = b.width
      let h        = b.height
      let selIdx   = tp.getSelectedIndex()
      let tabs     = tp.getTabs()
      let fm       = java.awt.FontMetrics.make(for: component.font)

      // ── Background ──────────────────────────────────────────────────────────
      g.setColor(java.awt.SystemColor.control)
      g.fillRect(0, 0, w, h)

      // ── Content area border ──────────────────────────────────────────────────
      g.setColor(java.awt.SystemColor.controlShadow)
      g.drawRect(0, tabHeight - 1, w - 1, h - tabHeight)

      // ── Tabs ─────────────────────────────────────────────────────────────────
      var tx = borderW
      for (i, tab) in tabs.enumerated() {
        let tw   = fm.stringWidth(tab.title) + tabPadX * 2
        let isSelected = (i == selIdx)

        // Tab background
        if isSelected {
          g.setColor(java.awt.SystemColor.window)
          // Extend one pixel below tab strip to merge with content area
          g.fillRect(tx, 0, tw, tabHeight + 1)
        } else {
          g.setColor(java.awt.SystemColor.control)
          g.fillRect(tx, tabPadY / 2, tw, tabHeight - tabPadY / 2)
        }

        // Tab border (3 sides — bottom open on selected)
        g.setColor(java.awt.SystemColor.controlShadow)
        g.drawLine(tx, 0, tx + tw - 1, 0)          // top
        g.drawLine(tx, 0, tx, tabHeight - 1)        // left
        g.drawLine(tx + tw - 1, 0, tx + tw - 1, tabHeight - 1) // right
        if !isSelected {
          g.drawLine(tx, tabHeight - 1, tx + tw - 1, tabHeight - 1) // bottom
        }

        // Tab title
        let textX = tx + tabPadX
        let textY = (tabHeight - fm.getHeight()) / 2 + fm.getAscent()
        if tab.enabled {
          g.setColor(java.awt.SystemColor.controlText)
        } else {
          g.setColor(java.awt.SystemColor.controlShadow)
        }
        g.drawString(tab.title, textX, textY)

        tx += tw + 1
      }

      // ── Content area ─────────────────────────────────────────────────────────
      layoutContent(of: tp)

      if selIdx >= 0 && selIdx < tabs.count {
        let sel = tabs[selIdx].component
        guard sel.isVisible() else { return }
        // Let the child's own layout manager position its children.
        if let container = sel as? java.awt.Container {
          container.doLayout()
        }
        let dx = sel.bounds.x
        let dy = sel.bounds.y
        g.translate(dx, dy)
        sel.paint(g)
        g.translate(-dx, -dy)
      }
    }
  }
}
