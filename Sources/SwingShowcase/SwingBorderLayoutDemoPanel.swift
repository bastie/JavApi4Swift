/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Swing-Pendant zu `BorderLayoutDemoDialog` im AWTShowcase.
///
/// Zeigt alle fünf BorderLayout-Regionen als farbige JPanel:
///
/// ```
/// ┌─────────────────────────────────────┐
/// │            NORTH (blau)             │
/// ├──────────┬──────────────┬───────────┤
/// │   WEST   │    CENTER    │   EAST    │
/// │ (grün)   │   (grau)     │  (lila)   │
/// ├──────────┴──────────────┴───────────┤
/// │            SOUTH (rot)   [Schließen]│
/// └─────────────────────────────────────┘
/// ```
@MainActor
final class SwingBorderLayoutDemoDialog: javax.swing.JDialog {

  init(_ owner: javax.swing.JFrame) {
    super.init(owner, "LayoutManager – BorderLayout", false)
    setSize(440, 300)

    // NORTH — volle Breite, 44 px hoch
    let north = Self.makeRegionPanel("NORTH", bg: java.awt.Color.blue)
    north.setPreferredSize(java.awt.Dimension(440, 44))
    add(north, java.awt.BorderLayout.NORTH)

    // WEST — 80 px breit
    let west = Self.makeRegionPanel("WEST", bg: java.awt.Color(0, 140, 0))
    west.setPreferredSize(java.awt.Dimension(80, 212))
    add(west, java.awt.BorderLayout.WEST)

    // EAST — 80 px breit
    let east = Self.makeRegionPanel("EAST", bg: java.awt.Color(120, 0, 180))
    east.setPreferredSize(java.awt.Dimension(80, 212))
    add(east, java.awt.BorderLayout.EAST)

    // CENTER — füllt den verbleibenden Platz
    let center = Self.makeRegionPanel("CENTER",
                                     bg: java.awt.SystemColor.control,
                                     fg: java.awt.SystemColor.controlText)
    add(center, java.awt.BorderLayout.CENTER)

    // SOUTH — Panel(BorderLayout): Label im CENTER, Schließen-Button im EAST
    let south = javax.swing.JPanel(java.awt.BorderLayout(0, 0))
    south.setBackground(java.awt.Color(180, 0, 0))
    south.setPreferredSize(java.awt.Dimension(440, 44))

    let southLabel = javax.swing.JLabel("SOUTH")
    southLabel.setHorizontalAlignment(javax.swing.JLabel.CENTER)
    southLabel.setForeground(java.awt.Color.white)
    south.add(southLabel, java.awt.BorderLayout.CENTER)

    let closeBtn = javax.swing.JButton("Schließen")
    closeBtn.setPreferredSize(java.awt.Dimension(110, 44))
    closeBtn.addActionListener(SwingDialogCloseListener(dialog: self))
    south.add(closeBtn, java.awt.BorderLayout.EAST)

    add(south, java.awt.BorderLayout.SOUTH)
  }

  /// Erzeugt ein farbiges JPanel mit zentriertem JLabel.
  private static func makeRegionPanel(
    _ text: String,
    bg: java.awt.Color,
    fg: java.awt.Color = java.awt.Color.white
  ) -> javax.swing.JPanel {
    let panel = javax.swing.JPanel(java.awt.BorderLayout())
    panel.setBackground(bg)
    let label = javax.swing.JLabel(text)
    label.setHorizontalAlignment(javax.swing.JLabel.CENTER)
    label.setForeground(fg)
    panel.add(label, java.awt.BorderLayout.CENTER)
    return panel
  }
}
