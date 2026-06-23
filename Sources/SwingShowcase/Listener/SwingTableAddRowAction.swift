/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Adds an empty row to the demo table model.
@MainActor
class SwingTableAddRowAction: java.awt.event.ActionListener {

  private let model: javax.swing.table.DefaultTableModel

  init(model: javax.swing.table.DefaultTableModel) {
    self.model = model
  }

  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    model.addRow(["New", "—", "—", "0"])
  }
}
