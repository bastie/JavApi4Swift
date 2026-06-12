/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Demo dialog of all fice  BorderLayout regions.
///
/// ```
/// ┌─────────────────────────────────────┐
/// │            NORTH (blue)             │
/// ├──────────┬──────────────┬───────────┤
/// │  WEST    │    CENTER    │   EAST    │
/// │ (green)  │   (gray)     │  (lila)   │
/// ├──────────┴──────────────┴───────────┤
/// │            SOUTH (red)              │
/// └─────────────────────────────────────┘
///                              [Schließen]
/// ```
@MainActor
final class BorderLayoutDemoDialog: java.awt.Dialog {

  init (owner: java.awt.Frame) {
    super.init(owner, "LayoutManager – BorderLayout", true)
    let width = 440
    let height = 300
    setBounds(0, 0, width, height)
    setPreferredSize (java.awt.Dimension(width, height))
    // hgap/vgap=0: Regionen stoßen direkt aneinander, kein Rand nach außen.
    // Abstände entstehen nur durch setPreferredSize der einzelnen Regionen.
    setLayout (java.awt.BorderLayout(0, 0))

    // NORTH — volle Breite, 44px hoch
    let north = java.awt.Label("NORTH", java.awt.Label.CENTER)
    north.background = .blue
    north.foreground = .white
    north.setPreferredSize(java.awt.Dimension(width, 44))
    add(north, java.awt.BorderLayout.NORTH)

    // SOUTH — Panel mit BorderLayout(0,0): Label nimmt CENTER (gesamte Restbreite),
    // Schließen-Button sitzt im EAST mit fixer Breite.
    // hgap=0 → Panel geht exakt über die volle Dialog-Breite.
    let south = java.awt.Panel(java.awt.BorderLayout(0, 0))
    south.background = java.awt.Color(180, 0, 0)
    south.setPreferredSize(java.awt.Dimension(width, 44))
    let southLbl = java.awt.Label("SOUTH", java.awt.Label.CENTER)
    southLbl.background = java.awt.Color(180, 0, 0)
    southLbl.foreground = .white
    south.add(southLbl, java.awt.BorderLayout.CENTER)
    let closeBtn = java.awt.Button("Schließen")
    closeBtn.setPreferredSize(java.awt.Dimension(110, 44))
    closeBtn.addActionListener(DialogCloseListener(dialog: self))
    south.add(closeBtn, java.awt.BorderLayout.EAST)
    add(south, java.awt.BorderLayout.SOUTH)

    // WEST — 80px breit, Höhe vom BorderLayout bestimmt
    let west = java.awt.Label("WEST", java.awt.Label.CENTER)
    west.background = java.awt.Color(0, 140, 0)
    west.foreground = .white
    west.setPreferredSize(java.awt.Dimension(80, 212))
    add(west, java.awt.BorderLayout.WEST)

    // EAST — 80px breit
    let east = java.awt.Label("EAST", java.awt.Label.CENTER)
    east.background = java.awt.Color(120, 0, 180)
    east.foreground = .white
    east.setPreferredSize(java.awt.Dimension(80, 212))
    add(east, java.awt.BorderLayout.EAST)

    // CENTER — füllt den gesamten verbleibenden Platz.
    // Java-1.4-Aliases: PAGE_START=NORTH, PAGE_END=SOUTH, LINE_START=WEST, LINE_END=EAST
    let center = java.awt.Label("CENTER", java.awt.Label.CENTER)
    center.background = java.awt.SystemColor.control
    center.foreground = java.awt.SystemColor.controlText
    add(center, java.awt.BorderLayout.CENTER)
  }
}
