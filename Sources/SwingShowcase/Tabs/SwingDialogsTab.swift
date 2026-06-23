/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Builds the "Dialogs" tab for the SwingShowcase.
///
/// Demonstrates `JOptionPane` (all four dialog variants),
/// `JFileChooser`, and `JColorChooser`.
@MainActor
class SwingDialogsTab {

  static func build() -> javax.swing.JPanel {
    let panel = javax.swing.JPanel(java.awt.BorderLayout())

    // ── Result label at the bottom ─────────────────────────────────────────
    let resultLabel = javax.swing.JLabel("Result: —")
    resultLabel.setBorder(javax.swing.border.EmptyBorder(4, 8, 4, 8))
    panel.add(resultLabel, java.awt.BorderLayout.SOUTH)

    // ── Center: grid of buttons ────────────────────────────────────────────
    let grid = javax.swing.JPanel(java.awt.GridBagLayout())
    let gbc = java.awt.GridBagConstraints()
    gbc.insets = java.awt.Insets(6, 10, 6, 10)
    gbc.fill = java.awt.GridBagConstraints.HORIZONTAL
    gbc.weightx = 1.0
    gbc.gridwidth = 1

    // ── JOptionPane — showMessageDialog ───────────────────────────────────
    addSectionLabel(grid, gbc, "JOptionPane.showMessageDialog", row: 0)

    addButton(grid, gbc, "Information", col: 0, row: 2,
              listener: SwingDialogInfoAction(resultLabel: resultLabel))
    addButton(grid, gbc, "Warning", col: 1, row: 2,
              listener: SwingDialogWarningAction(resultLabel: resultLabel))
    addButton(grid, gbc, "Error", col: 0, row: 3,
              listener: SwingDialogErrorAction(resultLabel: resultLabel))
    addButton(grid, gbc, "Plain", col: 1, row: 3,
              listener: SwingDialogPlainAction(resultLabel: resultLabel))

    // ── JOptionPane — showConfirmDialog ───────────────────────────────────
    addSectionLabel(grid, gbc, "JOptionPane.showConfirmDialog", row: 4)

    addButton(grid, gbc, "YES_NO", col: 0, row: 6,
              listener: SwingDialogConfirmYesNoAction(resultLabel: resultLabel))
    addButton(grid, gbc, "YES_NO_CANCEL", col: 1, row: 6,
              listener: SwingDialogConfirmYesNoCancelAction(resultLabel: resultLabel))

    // ── JOptionPane — showInputDialog ─────────────────────────────────────
    addSectionLabel(grid, gbc, "JOptionPane.showInputDialog", row: 7)

    addButton(grid, gbc, "Text input", col: 0, row: 9,
              listener: SwingDialogInputAction(resultLabel: resultLabel))
    addButton(grid, gbc, "With title", col: 1, row: 9,
              listener: SwingDialogInputTitledAction(resultLabel: resultLabel))

    // ── JFileChooser ──────────────────────────────────────────────────────
    addSectionLabel(grid, gbc, "JFileChooser", row: 10)

    addButton(grid, gbc, "Open Dialog", col: 0, row: 12,
              listener: SwingDialogFileOpenAction(resultLabel: resultLabel))
    addButton(grid, gbc, "Save Dialog", col: 1, row: 12,
              listener: SwingDialogFileSaveAction(resultLabel: resultLabel))

    // ── JColorChooser ─────────────────────────────────────────────────────
    addSectionLabel(grid, gbc, "JColorChooser", row: 13)

    let colorPreview = javax.swing.JLabel("    ")
    colorPreview.setOpaque(true)
    colorPreview.setBackground(java.awt.Color.blue)
    colorPreview.setBorder(javax.swing.border.LineBorder(java.awt.Color.gray))

    addButton(grid, gbc, "Choose Color", col: 0, row: 15,
              listener: SwingDialogColorAction(resultLabel: resultLabel,
                                              colorPreview: colorPreview))

    gbc.gridx = 1; gbc.gridy = 15; gbc.gridwidth = 1
    grid.add(colorPreview, gbc)

    // ── Spacer ─────────────────────────────────────────────────────────────
    gbc.gridx = 0; gbc.gridy = 16; gbc.gridwidth = 2
    gbc.weighty = 1.0; gbc.fill = java.awt.GridBagConstraints.BOTH
    grid.add(javax.swing.JPanel(), gbc)

    let scroll = javax.swing.JScrollPane(grid)
    panel.add(scroll, java.awt.BorderLayout.CENTER)

    return panel
  }

  // ---------------------------------------------------------------------------
  // MARK: Layout helpers
  // ---------------------------------------------------------------------------

  @MainActor
  private static func addSectionLabel(_ grid: javax.swing.JPanel,
                                      _ gbc: java.awt.GridBagConstraints,
                                      _ title: String,
                                      row: Int) {
    gbc.gridx = 0; gbc.gridy = row; gbc.gridwidth = 2
    gbc.fill = java.awt.GridBagConstraints.HORIZONTAL
    gbc.insets = java.awt.Insets(12, 10, 2, 10)
    gbc.weighty = 0.0
    grid.add(javax.swing.JLabel(title), gbc)

    gbc.gridy = row + 1
    gbc.insets = java.awt.Insets(0, 10, 6, 10)
    grid.add(javax.swing.JSeparator(), gbc)

    gbc.gridwidth = 1
    gbc.fill = java.awt.GridBagConstraints.HORIZONTAL
    gbc.insets = java.awt.Insets(6, 10, 6, 10)
  }

  @MainActor
  private static func addButton(_ grid: javax.swing.JPanel,
                                _ gbc: java.awt.GridBagConstraints,
                                _ label: String,
                                col: Int,
                                row: Int,
                                listener: java.awt.event.ActionListener) {
    let btn = javax.swing.JButton(label)
    btn.addActionListener(listener)
    gbc.gridx = col; gbc.gridy = row; gbc.gridwidth = 1
    gbc.weighty = 0.0
    grid.add(btn, gbc)
  }
}
