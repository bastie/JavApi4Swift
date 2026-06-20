/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.basic {

  /// Default UI delegate for `JTableHeader`.
  ///
  /// Paints the column-header row: a raised background, column dividers, and
  /// column name labels.
  ///
  /// - Since: Java 1.2
  @MainActor
  open class BasicTableHeaderUI: javax.swing.plaf.ComponentUI {

    open class func createUI(_ c: javax.swing.JComponent) -> javax.swing.plaf.ComponentUI {
      return BasicTableHeaderUI()
    }

    // ── Preferred size ────────────────────────────────────────────────────────

    override open func getPreferredSize(_ component: javax.swing.JComponent) -> java.awt.Dimension? {
      let fm = java.awt.FontMetrics.make(for: component.font)
      let rowH = fm.getHeight() + 4   // same padding as table rows
      guard let header = component as? javax.swing.table.JTableHeader else {
        return java.awt.Dimension(0, rowH)
      }
      let cols   = header.getColumnCount()
      var totalW = 0
      for c in 0 ..< cols { totalW += header.getColumnWidth(c) }
      return java.awt.Dimension(max(0, totalW), rowH)
    }

    // ── Paint ─────────────────────────────────────────────────────────────────

    override open func paint(_ g: java.awt.Graphics, _ component: javax.swing.JComponent) {
      guard let header = component as? javax.swing.table.JTableHeader else { return }

      let w    = component.bounds.width
      let h    = component.bounds.height
      let cols = header.getColumnCount()
      let fm   = java.awt.FontMetrics.make(for: component.font)

      // Header background
      g.setColor(java.awt.Color(235, 235, 235))
      g.fillRect(0, 0, w, h)

      // Bottom border
      g.setColor(java.awt.Color(180, 180, 180))
      g.drawLine(0, h - 1, w - 1, h - 1)

      let textY = (h - fm.getHeight()) / 2 + fm.getAscent()
      var x = 0
      for col in 0 ..< cols {
        let colW = header.getEffectiveColumnWidth(col)
        let name = header.getColumnName(col)

        // Cell background
        g.setColor(java.awt.Color(235, 235, 235))
        g.fillRect(x, 0, colW, h)

        // Subtle top highlight (3-D feel)
        g.setColor(java.awt.Color(250, 250, 250))
        g.drawLine(x, 0, x + colW - 2, 0)

        // Column name
        g.setColor(java.awt.Color.black)
        // Clip text to column width to avoid overflow
        g.save()
        g.clipRect(x + 4, 0, max(0, colW - 8), h)
        g.drawString(name, x + 4, textY)
        g.restore()

        // Right divider
        g.setColor(java.awt.Color(190, 190, 190))
        g.drawLine(x + colW - 1, 1, x + colW - 1, h - 2)

        x += colW
      }
    }
  }
}
