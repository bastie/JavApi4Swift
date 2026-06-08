/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi
import Foundation
#if canImport(AppKit)
import AppKit
#endif

// ---------------------------------------------------------------------------
// MARK: - FlowLayout demo
// ---------------------------------------------------------------------------

/// Öffnet den FlowLayout-Demo-Dialog.
@MainActor
final class FlowLayoutDemoListener: java.awt.event.ActionListener {
  private weak var owner: java.awt.Frame?
  init(owner: java.awt.Frame) { self.owner = owner }

  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    guard let owner else { return }
    let dialog = FlowLayoutDemoDialog(owner: owner)
    dialog.validate()
    dialog.setVisible(true)
  }
}

/// Dialog demonstriert FlowLayout mit allen drei Ausrichtungen (LEFT, CENTER, RIGHT).
///
/// Drei Panels übereinander (BorderLayout), jedes mit anderer FlowLayout-Ausrichtung:
/// ```
/// ┌─────────────────────────────────────┐
/// │ LEFT:    [Eins][Zwei][Drei][Vier]   │
/// ├─────────────────────────────────────┤
/// │ CENTER:     [Eins][Zwei][Drei]      │
/// ├─────────────────────────────────────┤
/// │ RIGHT:          [Eins][Zwei][Drei]  │
/// └─────────────────────────────────────┘
///                              [Schließen]
/// ```
@MainActor
final class FlowLayoutDemoDialog: java.awt.Dialog {

  init(owner: java.awt.Frame) {
    super.init(owner, "LayoutManager – FlowLayout", true)
    let W = 440, H = 260
    bounds = java.awt.Rectangle(0, 0, W, H)
    setPreferredSize(java.awt.Dimension(W, H))
    setLayout(java.awt.BorderLayout())

    // Titel
    let title = java.awt.Label(
      "FlowLayout — LEFT / CENTER / RIGHT",
      java.awt.Label.CENTER)
    title.setPreferredSize(java.awt.Dimension(W, 28))
    add(title, java.awt.BorderLayout.NORTH)

    // Die drei Alignment-Varianten
    let centre = java.awt.Panel(java.awt.GridLayout(3, 1, 0, 4))
    centre.setPreferredSize(java.awt.Dimension(W, 160))

    for (alignment, label) in [
      (java.awt.FlowLayout.LEFT,   "LEFT"),
      (java.awt.FlowLayout.CENTER, "CENTER"),
      (java.awt.FlowLayout.RIGHT,  "RIGHT"),
    ] {
      let row = java.awt.Panel(java.awt.FlowLayout(alignment, 6, 4))
      row.background = java.awt.SystemColor.control

      // Beschriftung der Zeile
      let info = java.awt.Label("\(label):", java.awt.Label.LEFT)
      info.setPreferredSize(java.awt.Dimension(60, 24))
      row.add(info)

      // Beispiel-Buttons
      for name in ["Eins", "Zwei", "Drei", "Vier"] {
        let btn = java.awt.Button(name)
        btn.setPreferredSize(java.awt.Dimension(60, 26))
        btn.addActionListener(ShowcaseActionListener())
        row.add(btn)
      }
      centre.add(row)
    }
    add(centre, java.awt.BorderLayout.CENTER)

    // Schließen
    let closeBtn = java.awt.Button("Schließen")
    closeBtn.setPreferredSize(java.awt.Dimension(100, 28))
    closeBtn.addActionListener(DialogCloseListener(dialog: self))
    let south = java.awt.Panel(java.awt.FlowLayout(java.awt.FlowLayout.RIGHT, 8, 6))
    south.setPreferredSize(java.awt.Dimension(W, 44))
    south.add(closeBtn)
    add(south, java.awt.BorderLayout.SOUTH)
  }
}
