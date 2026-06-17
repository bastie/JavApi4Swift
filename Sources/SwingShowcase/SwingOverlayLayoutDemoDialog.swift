/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Demonstriert `OverlayLayout` — Komponenten werden übereinandergelegt.
///
/// ```
/// ┌─────────────────────────────────────┐
/// │  OverlayLayout — Komponenten stapeln│
/// │  ┌───────────────────┐             │
/// │  │ [Hintergrund-Panel│             │
/// │  │   [Icon oben links│             │
/// │  └───────────────────┘             │
/// │                          [Schließen]│
/// └─────────────────────────────────────┘
/// ```
@MainActor
final class SwingOverlayLayoutDemoDialog: javax.swing.JDialog {

  init(_ owner: javax.swing.JFrame) {
    super.init(owner, "LayoutManager – OverlayLayout", false)
    setSize(420, 280)

    let title = javax.swing.JLabel("OverlayLayout — Komponenten übereinanderlegen")
    title.setHorizontalAlignment(javax.swing.JLabel.CENTER)
    add(title, java.awt.BorderLayout.NORTH)

    let content = javax.swing.JPanel()
    content.setLayout(java.awt.FlowLayout(java.awt.FlowLayout.LEFT))

    let placeholder = javax.swing.JLabel("⚠ OverlayLayout noch nicht implementiert – Demo folgt")
    content.add(placeholder)

    add(content, java.awt.BorderLayout.CENTER)

    let south = javax.swing.JPanel(java.awt.FlowLayout(java.awt.FlowLayout.RIGHT, 8, 6))
    let closeBtn = javax.swing.JButton("Schließen")
    closeBtn.addActionListener(SwingDialogCloseListener(dialog: self))
    south.add(closeBtn)
    add(south, java.awt.BorderLayout.SOUTH)
  }
}
