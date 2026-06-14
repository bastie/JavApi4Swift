/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// ActionListener that opens the Swing CardLayout demo dialog.
@MainActor
final class SwingCardLayoutDemoListener: java.awt.event.ActionListener {
  private weak var owner: javax.swing.JFrame?
  init(owner: javax.swing.JFrame) { self.owner = owner }

  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    guard let owner else { return }
    let dialog = javax.swing.JDialog(owner, "LayoutManager – CardLayout", false)
    dialog.setSize(380, 240)

    let title = javax.swing.JLabel("CardLayout — 3 Karten, umschaltbar per ◀ ▶")
    title.setHorizontalAlignment(javax.swing.JLabel.CENTER)
    dialog.add(title, java.awt.BorderLayout.NORTH)

    dialog.add(SwingCardDemoPanel(), java.awt.BorderLayout.CENTER)

    let south = javax.swing.JPanel(java.awt.FlowLayout())
    let closeBtn = javax.swing.JButton("Schließen")
    closeBtn.addActionListener(SwingDialogCloseListener(dialog: dialog))
    south.add(closeBtn)
    dialog.add(south, java.awt.BorderLayout.SOUTH)

    dialog.setVisible(true)
  }
}
