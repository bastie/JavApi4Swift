/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Demonstriert `SpringLayout` — constraint-basiertes Layout über Springs.
///
/// ```
/// ┌─────────────────────────────────────┐
/// │  SpringLayout — constraint-basiert  │
/// │                                     │
/// │    Name:  [___________________]     │
/// │    Email: [___________________]     │
/// │                                     │
/// │                          [Schließen]│
/// └─────────────────────────────────────┘
/// ```
@MainActor
final class SwingSpringLayoutDemoDialog: javax.swing.JDialog {

  init(_ owner: javax.swing.JFrame) {
    super.init(owner, "LayoutManager – SpringLayout", false)
    setSize(420, 280)

    let title = javax.swing.JLabel("SpringLayout — constraint-basiertes Layout")
    title.setHorizontalAlignment(javax.swing.JLabel.CENTER)
    add(title, java.awt.BorderLayout.NORTH)

    let content = javax.swing.JPanel()
    content.setLayout(java.awt.FlowLayout(java.awt.FlowLayout.LEFT))

    let placeholder = javax.swing.JLabel("⚠ SpringLayout noch nicht implementiert – Demo folgt")
    content.add(placeholder)

    add(content, java.awt.BorderLayout.CENTER)

    let south = javax.swing.JPanel(java.awt.FlowLayout(java.awt.FlowLayout.RIGHT, 8, 6))
    let closeBtn = javax.swing.JButton("Schließen")
    closeBtn.addActionListener(SwingDialogCloseListener(dialog: self))
    south.add(closeBtn)
    add(south, java.awt.BorderLayout.SOUTH)
  }
}
