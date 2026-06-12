/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

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
    let width = 440
    let height = 260
    setBounds(0, 0, width, height)
    setPreferredSize (java.awt.Dimension(width, height))
    setLayout (java.awt.BorderLayout())

    // Titel
    let title = java.awt.Label ("FlowLayout — LEFT / CENTER / RIGHT", java.awt.Label.CENTER)
    title.setPreferredSize (java.awt.Dimension(width, 28))
    add (title, java.awt.BorderLayout.NORTH)

    // Die drei Alignment-Varianten
    let centre = java.awt.Panel(java.awt.GridLayout(3, 1, 0, 4))
    centre.setPreferredSize(java.awt.Dimension(width, 160))

    for (alignment, label) in [
      (java.awt.FlowLayout.LEFT,   "LEFT"),
      (java.awt.FlowLayout.CENTER, "CENTER"),
      (java.awt.FlowLayout.RIGHT,  "RIGHT"),
    ] {
      let row = java.awt.Panel (java.awt.FlowLayout(alignment, 6, 4))
      row.setBackgroundColor(java.awt.SystemColor.control)

      // Beschriftung der Zeile
      let info = java.awt.Label ("\(label):", java.awt.Label.LEFT)
      info.setPreferredSize (java.awt.Dimension(60, 24))
      row.add (info)

      // Beispiel-Buttons
      for name in ["One", "Two", "Three", "Four"] {
        let btn = java.awt.Button (name)
        btn.setPreferredSize (java.awt.Dimension(60, 26))
        btn.addActionListener (ShowcaseActionListener())
        row.add (btn)
      }
      centre.add (row)
    }
    add(centre, java.awt.BorderLayout.CENTER)

    // Schließen
    let closeBtn = java.awt.Button ("Close")
    closeBtn.setPreferredSize (java.awt.Dimension(100, 28))
    closeBtn.addActionListener (DialogCloseListener(dialog: self))
    let south = java.awt.Panel (java.awt.FlowLayout(java.awt.FlowLayout.RIGHT, 8, 6))
    south.setPreferredSize (java.awt.Dimension(width, 44))
    south.add (closeBtn)
    add (south, java.awt.BorderLayout.SOUTH)
  }
}
