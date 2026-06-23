/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Switches the `DefaultTreeSelectionModel` mode when the combo box selection changes.
@MainActor
class SwingTableTreeModeListener: java.awt.event.ItemListener {

  private let selModel: javax.swing.tree.DefaultTreeSelectionModel
  private let selLabel: javax.swing.JLabel
  private let modeCombo: javax.swing.JComboBox<String>

  init(selModel: javax.swing.tree.DefaultTreeSelectionModel,
       selLabel: javax.swing.JLabel,
       modeCombo: javax.swing.JComboBox<String>) {
    self.selModel  = selModel
    self.selLabel  = selLabel
    self.modeCombo = modeCombo
  }

  func itemStateChanged(_ e: java.awt.event.ItemEvent) {
    guard e.getStateChange() == java.awt.event.ItemEvent.SELECTED else { return }
    switch modeCombo.getSelectedIndex() {
    case 1:
      selModel.setSelectionMode(
        javax.swing.tree.DefaultTreeSelectionModel.SINGLE_TREE_SELECTION)
    case 2:
      selModel.setSelectionMode(
        javax.swing.tree.DefaultTreeSelectionModel.CONTIGUOUS_TREE_SELECTION)
    default:
      selModel.setSelectionMode(
        javax.swing.tree.DefaultTreeSelectionModel.DISCONTIGUOUS_TREE_SELECTION)
    }
    selModel.clearSelection()
    selLabel.setText("Selection: —")
  }
}
