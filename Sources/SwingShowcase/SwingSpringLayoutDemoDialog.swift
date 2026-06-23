/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Demonstriert `SpringLayout` — constraint-basiertes Formular-Layout.
///
/// Drei Label-Textfeld-Paare werden so angeordnet:
/// - Labels bündig am linken Rand (WEST → Container WEST + 8)
/// - Textfelder bündig am rechten Rand (EAST → Container EAST - 8)
/// - Textfelder beginnen 8 px rechts vom jeweiligen Label (WEST → Label EAST + 8)
/// - Jede Zeile 8 px unterhalb der vorherigen (NORTH → vorh. SOUTH + 8)
///
/// ```
/// ┌──────────────────────────────────────────┐
/// │  SpringLayout — constraint-basiert       │
/// ├──────────────────────────────────────────┤
/// │                                          │
/// │  Name:    [_____________________________]│
/// │  E-Mail:  [_____________________________]│
/// │  Telefon: [_____________________________]│
/// │                                          │
/// │                           [Schließen]    │
/// └──────────────────────────────────────────┘
/// ```
@MainActor
final class SwingSpringLayoutDemoDialog: javax.swing.JDialog {

  init(_ owner: javax.swing.JFrame) {
    super.init(owner, "LayoutManager – SpringLayout", false)
    setSize(440, 260)

    // ── Titel ────────────────────────────────────────────────────────────────
    let title = javax.swing.JLabel("SpringLayout — constraint-basiertes Formular-Layout")
    title.setHorizontalAlignment(javax.swing.JLabel.CENTER)
    add(title, java.awt.BorderLayout.NORTH)

    // ── Formular-Panel mit SpringLayout ──────────────────────────────────────
    let form   = javax.swing.JPanel()
    let layout = javax.swing.SpringLayout()
    form.setLayout(layout)

    let rows: [(label: String, value: String)] = [
      ("Name:",    ""),
      ("E-Mail:",  ""),
      ("Telefon:", ""),
    ]

    var labels: [javax.swing.JLabel]     = []
    var fields: [javax.swing.JTextField] = []

    for row in rows {
      let lbl = javax.swing.JLabel(row.label)
      let fld = javax.swing.JTextField(row.value)
      fld.setPreferredSize(java.awt.Dimension(200, 24))
      form.add(lbl)
      form.add(fld)
      labels.append(lbl)
      fields.append(fld)
    }

    // ── Constraints setzen ───────────────────────────────────────────────────
    let pad     = 8
    let rowH    = 32   // Zeilenhöhe (Label/Feld + Abstand)
    let labelW  = 70   // feste Breite der Labels

    for (i, lbl) in labels.enumerated() {
      let fld  = fields[i]
      let topY = pad + i * rowH

      // Label: WEST an Container WEST + pad; NORTH = topY
      layout.putConstraint(javax.swing.SpringLayout.WEST,  lbl, pad,    javax.swing.SpringLayout.WEST,  form)
      layout.putConstraint(javax.swing.SpringLayout.NORTH, lbl, topY,   javax.swing.SpringLayout.NORTH, form)

      // Textfeld: WEST = Label WEST + labelW + pad; NORTH = topY; EAST an Container EAST - pad
      layout.putConstraint(javax.swing.SpringLayout.WEST,  fld, labelW + pad, javax.swing.SpringLayout.WEST,  form)
      layout.putConstraint(javax.swing.SpringLayout.NORTH, fld, topY,         javax.swing.SpringLayout.NORTH, form)
      layout.putConstraint(javax.swing.SpringLayout.EAST,  fld, -pad,         javax.swing.SpringLayout.EAST,  form)
    }

    add(form, java.awt.BorderLayout.CENTER)

    // ── Schließen ────────────────────────────────────────────────────────────
    let south = javax.swing.JPanel(java.awt.FlowLayout(java.awt.FlowLayout.RIGHT, 8, 6))
    let closeBtn = javax.swing.JButton("Schließen")
    closeBtn.addActionListener(SwingDialogCloseListener(dialog: self))
    south.add(closeBtn)
    add(south, java.awt.BorderLayout.SOUTH)
  }
}
