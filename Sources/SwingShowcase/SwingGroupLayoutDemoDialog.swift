/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Demonstriert `GroupLayout` — parallele und sequenzielle Gruppen.
///
/// Klassisches Formular mit drei Label-Textfeld-Paaren.
/// Horizontal: sequenziell (Labels | Textfelder).
/// Vertikal: sequenziell (Zeile1, Zeile2, Zeile3), je eine parallele Gruppe
/// pro Zeile (Label und Feld auf gleicher Höhe).
///
/// ```
/// ┌─────────────────────────────────────────┐
/// │  GroupLayout — parallele/seq. Gruppen   │
/// ├─────────────────────────────────────────┤
/// │                                         │
/// │  Name:     [_________________________]  │
/// │  Vorname:  [_________________________]  │
/// │  Stadt:    [_________________________]  │
/// │                                         │
/// │                          [Schließen]    │
/// └─────────────────────────────────────────┘
/// ```
@MainActor
final class SwingGroupLayoutDemoDialog: javax.swing.JDialog {

  init(_ owner: javax.swing.JFrame) {
    super.init(owner, "LayoutManager – GroupLayout", false)
    setSize(440, 260)

    // ── Titel ────────────────────────────────────────────────────────────────
    let title = javax.swing.JLabel("GroupLayout — parallele und sequenzielle Gruppen")
    title.setHorizontalAlignment(javax.swing.JLabel.CENTER)
    add(title, java.awt.BorderLayout.NORTH)

    // ── Formular-Panel ───────────────────────────────────────────────────────
    let form   = javax.swing.JPanel()
    let layout = javax.swing.GroupLayout(form)
    form.setLayout(layout)

    // Komponenten
    let lblName    = javax.swing.JLabel("Name:")
    let lblVorname = javax.swing.JLabel("Vorname:")
    let lblStadt   = javax.swing.JLabel("Stadt:")

    let fldName    = javax.swing.JTextField("")
    let fldVorname = javax.swing.JTextField("")
    let fldStadt   = javax.swing.JTextField("")

    // Preferred-Größen setzen
    let labelSize = java.awt.Dimension(80, 24)
    let fieldSize = java.awt.Dimension(260, 24)
    for lbl in [lblName, lblVorname, lblStadt] {
      lbl.setPreferredSize(labelSize)
    }
    for fld in [fldName, fldVorname, fldStadt] {
      fld.setPreferredSize(fieldSize)
    }

    form.add(lblName);    form.add(fldName)
    form.add(lblVorname); form.add(fldVorname)
    form.add(lblStadt);   form.add(fldStadt)

    // ── Horizontale Gruppe ───────────────────────────────────────────────────
    // Sequential: [gap 8] [ParallelGroup Labels] [gap 8] [ParallelGroup Fields] [gap 8]
    layout.setHorizontalGroup(
      layout.createSequentialGroup()
        .addGap(8)
        .addGroup(
          layout.createParallelGroup(javax.swing.GroupLayout.TRAILING)
            .addComponent(lblName)
            .addComponent(lblVorname)
            .addComponent(lblStadt)
        )
        .addGap(8)
        .addGroup(
          layout.createParallelGroup(javax.swing.GroupLayout.LEADING)
            .addComponent(fldName)
            .addComponent(fldVorname)
            .addComponent(fldStadt)
        )
        .addGap(8)
    )

    // ── Vertikale Gruppe ─────────────────────────────────────────────────────
    // Sequential: [gap 8] [Zeile1] [gap 6] [Zeile2] [gap 6] [Zeile3] [gap 8]
    layout.setVerticalGroup(
      layout.createSequentialGroup()
        .addGap(8)
        .addGroup(
          layout.createParallelGroup(javax.swing.GroupLayout.BASELINE)
            .addComponent(lblName)
            .addComponent(fldName)
        )
        .addGap(6)
        .addGroup(
          layout.createParallelGroup(javax.swing.GroupLayout.BASELINE)
            .addComponent(lblVorname)
            .addComponent(fldVorname)
        )
        .addGap(6)
        .addGroup(
          layout.createParallelGroup(javax.swing.GroupLayout.BASELINE)
            .addComponent(lblStadt)
            .addComponent(fldStadt)
        )
        .addGap(8)
    )

    add(form, java.awt.BorderLayout.CENTER)

    // ── Schließen ────────────────────────────────────────────────────────────
    let south = javax.swing.JPanel(java.awt.FlowLayout(java.awt.FlowLayout.RIGHT, 8, 6))
    let closeBtn = javax.swing.JButton("Schließen")
    closeBtn.addActionListener(SwingDialogCloseListener(dialog: self))
    south.add(closeBtn)
    add(south, java.awt.BorderLayout.SOUTH)
  }
}
