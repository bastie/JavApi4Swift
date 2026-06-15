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
      gbc.gridwidth = 1
      gbc.anchor = java.awt.GridBagConstraints.WEST
      gbc.insets = java.awt.Insets(4, 8, 4, 8)
      gbc.weightx = 0.0; gbc.fill = java.awt.GridBagConstraints.NONE
      panel.add(javax.swing.JLabel(text), gbc)
    }

    func addComp(_ comp: java.awt.Component, row: Int) {
      gbc.gridx = 1; gbc.gridy = row
      gbc.gridwidth = 1
      gbc.anchor = java.awt.GridBagConstraints.WEST
      gbc.insets = java.awt.Insets(4, 4, 4, 8)
      gbc.weightx = 1.0; gbc.fill = java.awt.GridBagConstraints.HORIZONTAL
      panel.add(comp, gbc)
    }

    // ── JToggleButton ─────────────────────────────────────────────────────────
    addLabel("JToggleButton:", row: 0)
    let toggleBtn = javax.swing.JToggleButton("Toggle me")
    toggleBtn.addItemListener(SwingToggleItemListener())
    addComp(toggleBtn, row: 0)

    // ── Spacer row — pushes content to top ────────────────────────────────────
    gbc.gridx = 0; gbc.gridy = 99
    gbc.gridwidth = 2; gbc.weighty = 1.0
    gbc.fill = java.awt.GridBagConstraints.VERTICAL
    panel.add(javax.swing.JPanel(), gbc)

    return panel
  }
}
