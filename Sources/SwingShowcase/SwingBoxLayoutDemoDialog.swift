/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Demonstriert `BoxLayout` mit X_AXIS und Y_AXIS.
///
/// ```
/// ┌─────────────────────────────────────────┐
/// │   BoxLayout — X_AXIS und Y_AXIS         │
/// ├─────────────────────────────────────────┤
/// │  X_AXIS (horizontal):                   │
/// │  ┌────────┬────────┬────────┐           │
/// │  │  Rot   │  Grün  │  Blau  │           │
/// │  └────────┴────────┴────────┘           │
/// │                                         │
/// │  Y_AXIS (vertikal):                     │
/// │  ┌───────────────────────────┐          │
/// │  │          Alpha            │          │
/// │  ├───────────────────────────┤          │
/// │  │          Beta             │          │
/// │  ├───────────────────────────┤          │
/// │  │          Gamma            │          │
/// │  └───────────────────────────┘          │
/// │                           [Schließen]   │
/// └─────────────────────────────────────────┘
/// ```
@MainActor
final class SwingBoxLayoutDemoDialog: javax.swing.JDialog {

  init(_ owner: javax.swing.JFrame) {
    super.init(owner, "LayoutManager – BoxLayout", false)
    setSize(440, 340)

    // ── Titel ────────────────────────────────────────────────────────────────
    let title = javax.swing.JLabel("BoxLayout — X_AXIS und Y_AXIS")
    title.setHorizontalAlignment(javax.swing.JLabel.CENTER)
    add(title, java.awt.BorderLayout.NORTH)

    // ── Inhaltsbereich ───────────────────────────────────────────────────────
    // Äußerer Container: Y_AXIS stapelt die beiden Demo-Blöcke vertikal.
    let content = javax.swing.JPanel()
    content.setLayout(javax.swing.BoxLayout(content, javax.swing.BoxLayout.Y_AXIS))

    // -- X_AXIS-Block --------------------------------------------------------
    let xLabel = javax.swing.JLabel("X_AXIS (horizontal):")
    content.add(xLabel)

    let xBox = javax.swing.JPanel()
    xBox.setLayout(javax.swing.BoxLayout(xBox, javax.swing.BoxLayout.X_AXIS))
    xBox.setPreferredSize(java.awt.Dimension(400, 48))

    let xColours: [(java.awt.Color, String)] = [
      (.red,   "Rot"),
      (.green, "Grün"),
      (.blue,  "Blau"),
    ]
    for (colour, name) in xColours {
      let cell = javax.swing.JPanel(java.awt.BorderLayout())
      cell.setBackground(colour)
      cell.setPreferredSize(java.awt.Dimension(120, 48))
      let lbl = javax.swing.JLabel(name)
      lbl.setHorizontalAlignment(javax.swing.JLabel.CENTER)
      lbl.setForeground(java.awt.Color.white)
      cell.add(lbl, java.awt.BorderLayout.CENTER)
      xBox.add(cell)
    }
    content.add(xBox)

    // Abstandshalter zwischen den beiden Blöcken
    let spacer = javax.swing.JPanel()
    spacer.setPreferredSize(java.awt.Dimension(1, 12))
    content.add(spacer)

    // -- Y_AXIS-Block --------------------------------------------------------
    let yLabel = javax.swing.JLabel("Y_AXIS (vertikal):")
    content.add(yLabel)

    let yBox = javax.swing.JPanel()
    yBox.setLayout(javax.swing.BoxLayout(yBox, javax.swing.BoxLayout.Y_AXIS))
    yBox.setPreferredSize(java.awt.Dimension(400, 120))

    let yItems = ["Alpha", "Beta", "Gamma"]
    for name in yItems {
      let row = javax.swing.JPanel(java.awt.BorderLayout())
      row.setPreferredSize(java.awt.Dimension(400, 36))
      let lbl = javax.swing.JLabel(name)
      lbl.setHorizontalAlignment(javax.swing.JLabel.CENTER)
      row.add(lbl, java.awt.BorderLayout.CENTER)
      yBox.add(row)
    }
    content.add(yBox)

    add(content, java.awt.BorderLayout.CENTER)

    // ── Schließen ────────────────────────────────────────────────────────────
    let south = javax.swing.JPanel(java.awt.FlowLayout(java.awt.FlowLayout.RIGHT, 8, 6))
    let closeBtn = javax.swing.JButton("Schließen")
    closeBtn.addActionListener(SwingDialogCloseListener(dialog: self))
    south.add(closeBtn)
    add(south, java.awt.BorderLayout.SOUTH)
  }
}
