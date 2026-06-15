/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Builds the "Swing (AWT analogue)" tab panel for the SwingShowcase.
///
/// Shows Swing components that have a direct AWT equivalent — for example
/// `JCheckBox` (AWT: `java.awt.Checkbox`) and `JRadioButton` together with
/// `ButtonGroup` (AWT: `java.awt.CheckboxGroup`).
@MainActor
class SwingComponentsWithAnalogueInAWTTab {

  // ButtonGroup must be kept alive for the lifetime of the tab panel.
  // Store it as a static property so ARC does not release it after build() returns.
  private static var _radioGroup: javax.swing.ButtonGroup?

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

    // ── JCheckBox (AWT analogue: java.awt.Checkbox) ───────────────────────────
    addLabel("JCheckBox:", row: 0)
    let checkPanel = javax.swing.JPanel(java.awt.FlowLayout(java.awt.FlowLayout.LEFT))
    let cb1 = javax.swing.JCheckBox("Option A", true)
    let cb2 = javax.swing.JCheckBox("Option B")
    let cb3 = javax.swing.JCheckBox("Option C")
    checkPanel.add(cb1); checkPanel.add(cb2); checkPanel.add(cb3)
    addComp(checkPanel, row: 0)

    // ── JRadioButton + ButtonGroup (AWT analogue: Checkbox + CheckboxGroup) ───
    addLabel("JRadioButton:", row: 1)
    let radioPanel = javax.swing.JPanel(java.awt.FlowLayout(java.awt.FlowLayout.LEFT))
    let group = javax.swing.ButtonGroup()
    _radioGroup = group   // retain beyond build() so listeners stay alive
    let rb1 = javax.swing.JRadioButton("Alpha", true)
    let rb2 = javax.swing.JRadioButton("Beta")
    let rb3 = javax.swing.JRadioButton("Gamma")
    group.add(rb1); group.add(rb2); group.add(rb3)
    radioPanel.add(rb1); radioPanel.add(rb2); radioPanel.add(rb3)
    addComp(radioPanel, row: 1)

    // ── Spacer row — pushes content to top ────────────────────────────────────
    gbc.gridx = 0; gbc.gridy = 99
    gbc.gridwidth = 2; gbc.weighty = 1.0
    gbc.fill = java.awt.GridBagConstraints.VERTICAL
    panel.add(javax.swing.JPanel(), gbc)

    return panel
  }
}
