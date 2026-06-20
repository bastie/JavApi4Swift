/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.basic {

  /// Default UI delegate for `JTable`.
  ///
  /// Paints only the data grid — the column header is a separate `JTableHeader`
  /// component painted by `BasicTableHeaderUI` in the JScrollPane's column-
  /// header viewport.
  ///
  /// Each cell is rendered by the `TableCellRenderer` stamp pattern:
  /// `getTableCellRendererComponent` returns a `Component` whose `paint(g)` is
  /// called after translating `g` to the cell origin.  The component is never
  /// added to the hierarchy, so any `JComponent` subclass (including `JPanel`
  /// composites) works as a renderer.
  ///
  /// - Since: Java 1.2
  @MainActor
  open class BasicTableUI: javax.swing.plaf.ComponentUI {

    // ── Factory ───────────────────────────────────────────────────────────────

    open class func createUI(_ c: javax.swing.JComponent) -> javax.swing.plaf.ComponentUI {
      return BasicTableUI()
    }

    // ── Preferred size ────────────────────────────────────────────────────────

    override open func getPreferredSize(_ component: javax.swing.JComponent) -> java.awt.Dimension? {
      guard let table = component as? javax.swing.JTable,
            let model = table.getModel() else {
        return java.awt.Dimension(0, 0)
      }
      let rows   = model.getRowCount()
      let cols   = model.getColumnCount()
      let rowH   = table.getRowHeight()
      var totalW = 0
      for c in 0 ..< cols { totalW += table.getColumnWidth(c) }
      // Header is in its own viewport — not counted here
      // Return the actual content size — JScrollPane decides whether to scroll.
      return java.awt.Dimension(max(1, totalW), max(1, rows * rowH))
    }

    // ── Paint ─────────────────────────────────────────────────────────────────

    override open func paint(_ g: java.awt.Graphics, _ component: javax.swing.JComponent) {
      guard let table = component as? javax.swing.JTable,
            let model = table.getModel() else { return }

      let w      = table.bounds.width
      let h      = table.bounds.height
      let rowH   = table.getRowHeight()
      let rows   = model.getRowCount()
      let cols   = model.getColumnCount()
      let selRow = table.getSelectedRow()

      // ── Background ────────────────────────────────────────────────────────
      g.setColor(java.awt.Color.white)
      g.fillRect(0, 0, w, h)

      // ── Data rows ─────────────────────────────────────────────────────────
      let renderer = table.getDefaultRenderer(forColumn: 0)
      var x = 0
      for col in 0 ..< cols {
        let colW = table.getEffectiveColumnWidth(col)
        for row in 0 ..< rows {
          let rowY = row * rowH
          guard rowY < h else { break }
          let isSelected = (row == selRow)
          let value = model.getValueAt(row, col)
          let cell  = renderer.getTableCellRendererComponent(
            table, value, isSelected, false, row, col)
          cell.bounds = java.awt.Rectangle(x, rowY, colW, rowH)
          (cell as? java.awt.Container)?.doLayout()
          g.save()
          g.clipRect(x, rowY, colW, rowH)
          g.translate(x, rowY)
          cell.paint(g)
          g.restore()
          // Cell border
          g.setColor(java.awt.Color(220, 220, 220))
          g.drawRect(x, rowY, colW - 1, rowH - 1)
        }
        x += colW
      }

      // ── Outer border ──────────────────────────────────────────────────────
      g.setColor(java.awt.Color(180, 180, 180))
      g.drawRect(0, 0, w - 1, h - 1)
    }

    // ── Hit-test: row at point ────────────────────────────────────────────────

    /// Returns the data row index at local `(x, y)`, or -1.
    /// Header is now in its own viewport, so no offset needed.
    func rowAtPoint(_ x: Int, _ y: Int, in table: javax.swing.JTable) -> Int {
      let rowH = table.getRowHeight()
      guard let model = table.getModel(), y >= 0 else { return -1 }
      let row = y / rowH
      return row < model.getRowCount() ? row : -1
    }
  }
}
