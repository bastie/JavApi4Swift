/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Demonstrates all `javax.swing.border` border types.
@MainActor
class SwingBorderTab {

  static func build() -> javax.swing.JScrollPane {
    let outer = javax.swing.JPanel(java.awt.GridBagLayout())
    let gbc = java.awt.GridBagConstraints()

    func addRow(_ label: String, _ panel: javax.swing.JPanel, row: Int) {
      // Label
      gbc.gridx = 0; gbc.gridy = row
      gbc.anchor = java.awt.GridBagConstraints.NORTHWEST
      gbc.insets = java.awt.Insets(6, 8, 6, 8)
      gbc.weightx = 0.0; gbc.weighty = 0.0
      gbc.fill = java.awt.GridBagConstraints.NONE
      outer.add(javax.swing.JLabel(label), gbc)

      // Preferred width — height is determined by content + border insets
      panel.setPreferredSize(java.awt.Dimension(240, 44))
      gbc.gridx = 1; gbc.gridy = row
      gbc.anchor = java.awt.GridBagConstraints.NORTHWEST
      gbc.insets = java.awt.Insets(6, 4, 6, 8)
      gbc.weightx = 1.0; gbc.weighty = 0.0
      gbc.fill = java.awt.GridBagConstraints.HORIZONTAL
      outer.add(panel, gbc)
    }

    func samplePanel() -> javax.swing.JPanel {
      let p = javax.swing.JPanel()
      p.setOpaque(true)
      return p
    }

    // ── EmptyBorder ──────────────────────────────────────────────────────────
    let emptyPanel = samplePanel()
    emptyPanel.setBorder(javax.swing.BorderFactory.createEmptyBorder(8, 8, 8, 8))
    emptyPanel.add(javax.swing.JLabel("EmptyBorder (8px padding)"))
    addRow("EmptyBorder:", emptyPanel, row: 0)

    // ── LineBorder ───────────────────────────────────────────────────────────
    let linePanel = samplePanel()
    linePanel.setBorder(javax.swing.BorderFactory.createLineBorder(java.awt.Color.blue, 2))
    linePanel.add(javax.swing.JLabel("LineBorder (blue, 2px)"))
    addRow("LineBorder:", linePanel, row: 1)

    // ── LineBorder rounded ───────────────────────────────────────────────────
    let lineRoundPanel = samplePanel()
    lineRoundPanel.setBorder(javax.swing.BorderFactory.createLineBorder(java.awt.Color.red, 2, true))
    lineRoundPanel.add(javax.swing.JLabel("LineBorder (red, rounded)"))
    addRow("LineBorder (rounded):", lineRoundPanel, row: 2)

    // ── EtchedBorder LOWERED ─────────────────────────────────────────────────
    let etchLowPanel = samplePanel()
    etchLowPanel.setBorder(javax.swing.BorderFactory.createEtchedBorder())
    etchLowPanel.add(javax.swing.JLabel("EtchedBorder (LOWERED)"))
    addRow("EtchedBorder:", etchLowPanel, row: 3)

    // ── EtchedBorder RAISED ──────────────────────────────────────────────────
    let etchRaisePanel = samplePanel()
    etchRaisePanel.setBorder(
      javax.swing.BorderFactory.createEtchedBorder(javax.swing.border.EtchedBorder.RAISED))
    etchRaisePanel.add(javax.swing.JLabel("EtchedBorder (RAISED)"))
    addRow("EtchedBorder raised:", etchRaisePanel, row: 4)

    // ── BevelBorder RAISED ───────────────────────────────────────────────────
    let bevelRaisedPanel = samplePanel()
    bevelRaisedPanel.setBorder(javax.swing.BorderFactory.createRaisedBevelBorder())
    bevelRaisedPanel.add(javax.swing.JLabel("BevelBorder (RAISED)"))
    addRow("BevelBorder raised:", bevelRaisedPanel, row: 5)

    // ── BevelBorder LOWERED ──────────────────────────────────────────────────
    let bevelLowPanel = samplePanel()
    bevelLowPanel.setBorder(javax.swing.BorderFactory.createLoweredBevelBorder())
    bevelLowPanel.add(javax.swing.JLabel("BevelBorder (LOWERED)"))
    addRow("BevelBorder lowered:", bevelLowPanel, row: 6)

    // ── TitledBorder ─────────────────────────────────────────────────────────
    let titledPanel = samplePanel()
    titledPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("My Group"))
    titledPanel.add(javax.swing.JLabel("TitledBorder"))
    addRow("TitledBorder:", titledPanel, row: 7)

    // ── TitledBorder über LineBorder ─────────────────────────────────────────
    let titledLinePanel = samplePanel()
    titledLinePanel.setBorder(
      javax.swing.BorderFactory.createTitledBorder(
        javax.swing.BorderFactory.createLineBorder(java.awt.Color.gray),
        "Options"))
    titledLinePanel.add(javax.swing.JLabel("Titled + LineBorder"))
    addRow("TitledBorder (line):", titledLinePanel, row: 8)

    // ── CompoundBorder ───────────────────────────────────────────────────────
    let compoundPanel = samplePanel()
    compoundPanel.setBorder(
      javax.swing.BorderFactory.createCompoundBorder(
        javax.swing.BorderFactory.createLineBorder(java.awt.Color.darkGray, 2),
        javax.swing.BorderFactory.createEmptyBorder(4, 4, 4, 4)))
    compoundPanel.add(javax.swing.JLabel("CompoundBorder (line + empty)"))
    addRow("CompoundBorder:", compoundPanel, row: 9)

    // ── MatteBorder (symmetrisch) ─────────────────────────────────────────────
    let mattePanel = samplePanel()
    mattePanel.setBorder(
      javax.swing.BorderFactory.createMatteBorder(6, 6, 6, 6, java.awt.Color.green))
    mattePanel.add(javax.swing.JLabel("MatteBorder (green, 6px)"))
    addRow("MatteBorder:", mattePanel, row: 10)

    // ── MatteBorder (asymmetrisch) ────────────────────────────────────────────
    let mattePanel2 = samplePanel()
    mattePanel2.setBorder(
      javax.swing.BorderFactory.createMatteBorder(2, 12, 2, 12, java.awt.Color.orange))
    mattePanel2.add(javax.swing.JLabel("MatteBorder (orange, t2 l12 b2 r12)"))
    addRow("MatteBorder (asym):", mattePanel2, row: 11)

    // ── Spacer ───────────────────────────────────────────────────────────────
    gbc.gridx = 0; gbc.gridy = 99
    gbc.gridwidth = 2; gbc.weighty = 1.0
    gbc.fill = java.awt.GridBagConstraints.VERTICAL
    outer.add(javax.swing.JPanel(), gbc)

    return javax.swing.JScrollPane(outer)
  }
}
