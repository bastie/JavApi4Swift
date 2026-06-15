/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.basic {

  /// Default UI delegate for `JToolBar`.
  ///
  /// Handles preferred-size calculation, child layout, and painting.
  /// Floatable drag/dock behaviour is not yet implemented.
  ///
  /// - TODO: Implement drag-out (MouseMotionListener), undecorared JDialog as
  ///   floating window, and BorderLayout docking zones (BasicToolBarUI in Java).
  ///
  @MainActor
  open class BasicToolBarUI: javax.swing.plaf.ComponentUI {

    private let pad = 4

    // -------------------------------------------------------------------------
    // MARK: Preferred size
    // -------------------------------------------------------------------------

    override open func getPreferredSize(_ component: javax.swing.JComponent) -> java.awt.Dimension? {
      guard let toolbar = component as? javax.swing.JToolBar else { return nil }
      let items = toolbar.getItems()
      let isHorizontal = toolbar.getOrientation() == javax.swing.JToolBar.HORIZONTAL

      var totalW = pad, totalH = pad, maxH = 0, maxW = 0
      for item in items {
        let ps = item.getPreferredSize()
        if isHorizontal {
          totalW += ps.width + pad
          maxH = Swift.max(maxH, ps.height)
        } else {
          totalH += ps.height + pad
          maxW = Swift.max(maxW, ps.width)
        }
      }
      if isHorizontal {
        return java.awt.Dimension(totalW, maxH + pad * 2)
      } else {
        return java.awt.Dimension(maxW + pad * 2, totalH)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Layout
    // -------------------------------------------------------------------------

    override open func installUI(_ c: javax.swing.JComponent) {
      // Nothing extra to install for now.
    }

    /// Positions all toolbar children within the toolbar's current bounds.
    private func layoutItems(of toolbar: javax.swing.JToolBar) {
      let items = toolbar.getItems()
      let b = toolbar.getBounds()
      let isHorizontal = toolbar.getOrientation() == javax.swing.JToolBar.HORIZONTAL

      if isHorizontal {
        var x = pad
        let y = pad
        let h = Swift.max(b.height - pad * 2, 1)
        for item in items {
          let w = item.getPreferredSize().width
          item.bounds = java.awt.Rectangle(x, y, w, h)
          x += w + pad
        }
      } else {
        let x = pad
        var y = pad
        let w = Swift.max(b.width - pad * 2, 1)
        for item in items {
          let h = item.getPreferredSize().height
          item.bounds = java.awt.Rectangle(x, y, w, h)
          y += h + pad
        }
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Painting
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics, on component: javax.swing.JComponent) {
      guard let toolbar = component as? javax.swing.JToolBar else { return }
      let b = toolbar.getBounds()
      let w = b.width
      let h = b.height

      // Background
      g.setColor(java.awt.SystemColor.control)
      g.fillRect(0, 0, w, h)

      // Bottom border line (horizontal) / right border line (vertical)
      g.setColor(java.awt.SystemColor.controlShadow)
      if toolbar.getOrientation() == javax.swing.JToolBar.HORIZONTAL {
        g.drawLine(0, h - 1, w - 1, h - 1)
      } else {
        g.drawLine(w - 1, 0, w - 1, h - 1)
      }

      // Layout children, then paint them
      layoutItems(of: toolbar)

      for item in toolbar.getItems() {
        guard item.isVisible() else { continue }
        let dx = item.bounds.x
        let dy = item.bounds.y
        g.translate(dx, dy)
        item.paint(g)
        g.translate(-dx, -dy)
      }
    }
  }
}
