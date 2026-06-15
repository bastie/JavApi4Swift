/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Dialog mit einem 3×2-GridLayout-Panel und einer Erklärung.
///
/// Layout:
/// ```
/// ┌─────────────────────────────────┐
/// │  red     │  green │  blue       │
/// ├─────────────────────────────────┤
/// │  yellow  │  cyan  │  magenta    │
/// └─────────────────────────────────┘
///                             [close]
/// ```
@MainActor
final class GridLayoutDemoDialog: java.awt.Dialog {

  init(owner: java.awt.Frame) {
    super.init(owner, "LayoutManager – GridLayout", true)
    
    let width = 420
    let height = 220
    setBounds(0, 0, width, height)
    setPreferredSize(java.awt.Dimension(width, height))
    setLayout(java.awt.BorderLayout())

    // Titel-Label
    let title = try! java.awt.Label( "GridLayout(2, 3, 2, 2) — 2 Zeilen × 3 Spalten, Abstand 2px", java.awt.Label.CENTER)
    title.setPreferredSize(java.awt.Dimension(width, 28))
    add(title, java.awt.BorderLayout.NORTH)

    // Farb-Grid
    let grid = makeGridPanel(width: width, height: 140)
    add(grid, java.awt.BorderLayout.CENTER)

    // Schließen-Button
    let closeBtn = java.awt.Button("Schließen")
    closeBtn.setPreferredSize(java.awt.Dimension(100, 28))
    closeBtn.addActionListener(DialogCloseListener(dialog: self))
    let south = java.awt.Panel(java.awt.FlowLayout(java.awt.FlowLayout.RIGHT, 8, 6))
    south.setPreferredSize(java.awt.Dimension(width, 44))
    south.add(closeBtn)
    add(south, java.awt.BorderLayout.SOUTH)
  }
  
  /// Erzeugt ein 3×2-GridLayout-Panel mit farbigen Label-Zellen.
  @MainActor
  func makeGridPanel(width: Int, height: Int) -> java.awt.Panel {
    let panel = java.awt.Panel(java.awt.GridLayout(2, 3, 2, 2))
    panel.setPreferredSize(java.awt.Dimension(width, height))
    let colours: [(java.awt.Color, String)] = [
      (.red,     "Rot"),    (.green,   "Grün"),  (.blue,   "Blau"),
      (.yellow,  "Gelb"),   (.cyan,    "Cyan"),  (.magenta,"Magenta")
    ]
    for (col, name) in colours {
      let lbl = try! java.awt.Label(name, java.awt.Label.CENTER)
      lbl.setBackgroundColor(col)
      lbl.setForegroundColor(.white)
      panel.add(lbl)
    }
    return panel
  }

}
