/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Swing-Pendant zu `FlowLayoutDemoDialog` im AWTShowcase.
///
/// Zeigt FlowLayout in drei Ausrichtungen (LEFT, CENTER, RIGHT) mit JButtons.
///
/// ```
/// ┌─────────────────────────────────────┐
/// │  FlowLayout — LEFT / CENTER / RIGHT │
/// ├─────────────────────────────────────┤
/// │ LEFT:   [One][Two][Three][Four]     │
/// │ CENTER:    [One][Two][Three]        │
/// │ RIGHT:          [One][Two][Three]   │
/// └─────────────────────────────────────┘
///                              [Schließen]
/// ```
@MainActor
final class SwingFlowLayoutDemoDialog: javax.swing.JDialog {

  init(_ owner: javax.swing.JFrame) {
    super.init(owner, "LayoutManager – FlowLayout", false)
    setSize(440, 260)

    // Titel
    let title = javax.swing.JLabel("FlowLayout — LEFT / CENTER / RIGHT")
    title.setHorizontalAlignment(javax.swing.JLabel.CENTER)
    title.setPreferredSize(java.awt.Dimension(440, 28))
    add(title, java.awt.BorderLayout.NORTH)

    // Drei Zeilen übereinander
    let rows = javax.swing.JPanel(java.awt.GridLayout(3, 1, 0, 4))
    rows.setPreferredSize(java.awt.Dimension(440, 160))

    let alignments: [(Int, String)] = [
      (java.awt.FlowLayout.LEFT,   "LEFT"),
      (java.awt.FlowLayout.CENTER, "CENTER"),
      (java.awt.FlowLayout.RIGHT,  "RIGHT"),
    ]
    for (alignment, alignLabel) in alignments {
      let row = javax.swing.JPanel(java.awt.FlowLayout(alignment, 6, 4))
      row.setBackground(java.awt.SystemColor.control)

      let info = javax.swing.JLabel("\(alignLabel):")
      info.setPreferredSize(java.awt.Dimension(65, 24))
      row.add(info)

      for name in ["One", "Two", "Three", "Four"] {
        let btn = javax.swing.JButton(name)
        btn.setPreferredSize(java.awt.Dimension(60, 26))
        let al = alignLabel
        btn.addActionListener(SwingPrintActionListener("FlowLayout \(al): \(name)"))
        row.add(btn)
      }
      rows.add(row)
    }
    add(rows, java.awt.BorderLayout.CENTER)

    // Schließen-Button
    let south = javax.swing.JPanel(java.awt.FlowLayout(java.awt.FlowLayout.RIGHT, 8, 6))
    south.setPreferredSize(java.awt.Dimension(440, 44))
    let closeBtn = javax.swing.JButton("Schließen")
    closeBtn.addActionListener(SwingDialogCloseListener(dialog: self))
    south.add(closeBtn)
    add(south, java.awt.BorderLayout.SOUTH)
  }
}

// ---------------------------------------------------------------------------
// MARK: - Listener
// ---------------------------------------------------------------------------

@MainActor
final class SwingFlowLayoutDemoListener: java.awt.event.ActionListener {
  private weak var owner: javax.swing.JFrame?
  init(owner: javax.swing.JFrame) { self.owner = owner }

  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    guard let owner else { return }
    SwingFlowLayoutDemoDialog(owner).setVisible(true)
  }
}
