/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Demonstriert `GroupLayout` — parallele und sequenzielle Gruppen.
///
/// ```
/// ┌─────────────────────────────────────┐
/// │  GroupLayout — Gruppen-basiert      │
/// │                                     │
/// │  Label1  [Feld1________________]    │
/// │  Label2  [Feld2________________]    │
/// │  Label3  [Feld3________________]    │
/// │                                     │
/// │                          [Schließen]│
/// └─────────────────────────────────────┘
/// ```
@MainActor
final class SwingGroupLayoutDemoDialog: javax.swing.JDialog {

  init(_ owner: javax.swing.JFrame) {
    super.init(owner, "LayoutManager – GroupLayout", false)
    setSize(420, 280)

    let title = javax.swing.JLabel("GroupLayout — parallele und sequenzielle Gruppen")
    title.setHorizontalAlignment(javax.swing.JLabel.CENTER)
    add(title, java.awt.BorderLayout.NORTH)

    let content = javax.swing.JPanel()
    content.setLayout(java.awt.FlowLayout(java.awt.FlowLayout.LEFT))

    let placeholder = javax.swing.JLabel("⚠ GroupLayout noch nicht implementiert – Demo folgt")
    content.add(placeholder)

    add(content, java.awt.BorderLayout.CENTER)

    let south = javax.swing.JPanel(java.awt.FlowLayout(java.awt.FlowLayout.RIGHT, 8, 6))
    let closeBtn = javax.swing.JButton("Schließen")
    closeBtn.addActionListener(SwingDialogCloseListener(dialog: self))
    south.add(closeBtn)
    add(south, java.awt.BorderLayout.SOUTH)
  }
}
