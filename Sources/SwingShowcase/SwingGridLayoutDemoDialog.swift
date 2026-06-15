/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Swing-Pendant zu `GridLayoutDemoDialog` im AWTShowcase.
///
/// Zeigt ein 3×2-GridLayout mit farbigen JPanels.
///
/// ```
/// ┌──────────┬──────────┬──────────┐
/// │   Rot    │  Grün    │   Blau   │
/// ├──────────┼──────────┼──────────┤
/// │   Gelb   │  Cyan    │ Magenta  │
/// └──────────┴──────────┴──────────┘
///                          [Schließen]
/// ```
@MainActor
final class SwingGridLayoutDemoDialog: javax.swing.JDialog {

  init(_ owner: javax.swing.JFrame) {
    super.init(owner, "LayoutManager – GridLayout", false)
    setSize(420, 220)

    // Titel
    let title = javax.swing.JLabel("GridLayout(2, 3, 2, 2) — 2 Zeilen × 3 Spalten, Abstand 2px")
    title.setHorizontalAlignment(javax.swing.JLabel.CENTER)
    title.setPreferredSize(java.awt.Dimension(420, 28))
    add(title, java.awt.BorderLayout.NORTH)

    // Farb-Grid
    let grid = javax.swing.JPanel(java.awt.GridLayout(2, 3, 2, 2))
    grid.setPreferredSize(java.awt.Dimension(420, 140))

    let colours: [(java.awt.Color, String)] = [
      (.red,     "Rot"),
      (.green,   "Grün"),
      (.blue,    "Blau"),
      (.yellow,  "Gelb"),
      (.cyan,    "Cyan"),
      (.magenta, "Magenta"),
    ]
    for (colour, name) in colours {
      let cell = javax.swing.JPanel(java.awt.BorderLayout())
      cell.setBackground(colour)
      let lbl = javax.swing.JLabel(name)
      lbl.setHorizontalAlignment(javax.swing.JLabel.CENTER)
      lbl.setForeground(java.awt.Color.white)
      cell.add(lbl, java.awt.BorderLayout.CENTER)
      grid.add(cell)
    }
    add(grid, java.awt.BorderLayout.CENTER)

    // Schließen-Button
    let south = javax.swing.JPanel(java.awt.FlowLayout(java.awt.FlowLayout.RIGHT, 8, 6))
    south.setPreferredSize(java.awt.Dimension(420, 44))
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
final class SwingGridLayoutDemoListener: java.awt.event.ActionListener {
  private weak var owner: javax.swing.JFrame?
  init(owner: javax.swing.JFrame) { self.owner = owner }

  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    guard let owner else { return }
    SwingGridLayoutDemoDialog(owner).setVisible(true)
  }
}
