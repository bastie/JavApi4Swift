/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Removes the currently selected row from the demo table.
@MainActor
class SwingTableDeleteRowAction: java.awt.event.ActionListener {

  private let model: javax.swing.table.DefaultTableModel
  private let table: javax.swing.JTable

  init(model: javax.swing.table.DefaultTableModel, table: javax.swing.JTable) {
    self.model = model
    self.table = table
  }

  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    let row = table.getSelectedRow()
    if row >= 0 {
      model.removeRow(row)
    }
  }
}
