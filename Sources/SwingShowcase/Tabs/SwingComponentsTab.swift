/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Builds the "Swing" tab panel for the SwingShowcase.
///
/// Shows Swing components that have no direct AWT equivalent.
/// Components with AWT pendants (e.g. Checkbox → JCheckBox, CheckboxGroup →
/// ButtonGroup/JRadioButton) are demonstrated in the AWT tab instead.
@MainActor
class SwingComponentsTab {

  static func build() -> javax.swing.JPanel {
    let panel = javax.swing.JPanel(java.awt.GridBagLayout())
    let gbc = java.awt.GridBagConstraints()

    func addLabel(_ text: String, row: Int) {
      gbc.gridx = 0; gbc.gridy = row
      gbc.gridwidth = 1; gbc.gridheight = 1
      gbc.anchor = java.awt.GridBagConstraints.NORTHWEST
      gbc.insets = java.awt.Insets(4, 8, 4, 8)
      gbc.weightx = 0.0; gbc.weighty = 0.0
      gbc.fill = java.awt.GridBagConstraints.NONE
      panel.add(javax.swing.JLabel(text), gbc)
    }

    func addComp(_ comp: java.awt.Component, row: Int, fill: Int = java.awt.GridBagConstraints.HORIZONTAL) {
      gbc.gridx = 1; gbc.gridy = row
      gbc.gridwidth = 1; gbc.gridheight = 1
      gbc.anchor = java.awt.GridBagConstraints.NORTHWEST
      gbc.insets = java.awt.Insets(4, 4, 4, 8)
      gbc.weightx = 1.0; gbc.weighty = 0.0
      gbc.fill = fill
      panel.add(comp, gbc)
    }

    // ── JToggleButton ─────────────────────────────────────────────────────────
    addLabel("JToggleButton:", row: 0)
    let toggleBtn = javax.swing.JToggleButton("Toggle me")
    toggleBtn.addItemListener(SwingToggleItemListener())
    addComp(toggleBtn, row: 0)

    // ── JComboBox ─────────────────────────────────────────────────────────────
    addLabel("JComboBox:", row: 1)
    let combo = javax.swing.JComboBox<String>(["Red", "Green", "Blue", "Yellow"])
    addComp(combo, row: 1)

    // ── JList ─────────────────────────────────────────────────────────────────
    addLabel("JList:", row: 2)
    let listModel = javax.swing.DefaultListModel<String>()
    listModel.addElement("Alpha")
    listModel.addElement("Beta")
    listModel.addElement("Gamma")
    listModel.addElement("Delta")
    let list = javax.swing.JList(model: listModel)
    list.setVisibleRowCount(4)
    let scrollPane = javax.swing.JScrollPane(list)
    addComp(scrollPane, row: 2, fill: java.awt.GridBagConstraints.HORIZONTAL)

    // ── JSpinner ──────────────────────────────────────────────────────────────
    addLabel("JSpinner:", row: 3)
    let spinner = javax.swing.JSpinner(javax.swing.SpinnerNumberModel(0, 0, 100, 1))
    addComp(spinner, row: 3)

    // ── Spacer row — pushes content to top ────────────────────────────────────
    gbc.gridx = 0; gbc.gridy = 99
    gbc.gridwidth = 2; gbc.weighty = 1.0
    gbc.fill = java.awt.GridBagConstraints.VERTICAL
    panel.add(javax.swing.JPanel(), gbc)

    return panel
  }
}
