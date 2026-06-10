/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

// ---------------------------------------------------------------------------
// MARK: - CursorDemoDialog
// ---------------------------------------------------------------------------

@MainActor
final class CursorDemoDialog {

  static func show(owner: java.awt.Frame) {
    let dialog = java.awt.Dialog(owner, "Cursor-Demo", false)
    dialog.setLayout(java.awt.BorderLayout())
    dialog.bounds = java.awt.Rectangle(0, 0, 320, 160)

    // ── Cursor-Panel (wiederverwendet bestehende Logik) ───────────────────
    let panel = CursorDemoPanel()
    panel.setPreferredSize(java.awt.Dimension(320, 100))
    dialog.add(panel, java.awt.BorderLayout.CENTER)

    // ── Schließen-Button ──────────────────────────────────────────────────
    let closeBtn = java.awt.Button("Schließen")
    closeBtn.setPreferredSize(java.awt.Dimension(100, 28))
    closeBtn.addActionListener(DialogCloseListener(dialog: dialog))
    let south = java.awt.Panel(java.awt.FlowLayout(java.awt.FlowLayout.CENTER))
    south.setPreferredSize(java.awt.Dimension(320, 42))
    south.add(closeBtn)
    dialog.add(south, java.awt.BorderLayout.SOUTH)

    dialog.validate()
    dialog.setVisible(true)
  }
}

// ---------------------------------------------------------------------------
// MARK: - Listener
// ---------------------------------------------------------------------------

@MainActor
final class OpenCursorDemoListener: java.awt.event.ActionListener {
  private weak var owner: java.awt.Frame?
  init(owner: java.awt.Frame) { self.owner = owner }

  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    if let owner { CursorDemoDialog.show(owner: owner) }
  }
}
