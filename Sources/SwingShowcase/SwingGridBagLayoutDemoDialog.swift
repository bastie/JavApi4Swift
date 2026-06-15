/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Swing-Pendant zu `GridBagDemoDialog` im AWTShowcase.
///
/// Demonstriert GridBagLayout mit einem formähnlichen Aufbau.
/// Da JTextField/JTextArea noch nicht im Swing-Paket vorhanden sind,
/// werden JLabel-Platzhalter mit Rahmen-Optik verwendet.
///
/// Layout (3 Spalten):
/// ```
/// [col 0]       [col 1+2: span 2, weightx=1]
/// "Name:"       [ Platzhalter — Max Mustermann      ]
/// "Stadt:"      [ Platzhalter — Berlin              ]
/// "Notiz:"      [ Platzhalter — mehrzeilig          ]
///               [Abbrechen]  [OK]
/// ```
@MainActor
final class SwingGridBagLayoutDemoDialog: javax.swing.JDialog {

  init(_ owner: javax.swing.JFrame) {
    super.init(owner, "LayoutManager – GridBagLayout", false)
    setSize(400, 300)

    let gbl = java.awt.GridBagLayout()
    getContentPane().setLayout(gbl)

    let ins4 = java.awt.Insets(4, 4, 4, 4)

    // Helper: add with constraints
    func add(_ comp: java.awt.Component,
             gx: Int, gy: Int,
             gw: Int = 1, gh: Int = 1,
             weightx: Double = 0.0, weighty: Double = 0.0,
             fill: Int = java.awt.GridBagConstraints.NONE,
             anchor: Int = java.awt.GridBagConstraints.WEST,
             insets: java.awt.Insets = ins4) {
      let c = java.awt.GridBagConstraints(
        gridx: gx, gridy: gy,
        gridwidth: gw, gridheight: gh,
        weightx: weightx, weighty: weighty,
        anchor: anchor, fill: fill,
        insets: insets)
      gbl.setConstraints(comp, c)
      getContentPane().add(comp)
    }

    // Helper: field placeholder (styled JLabel)
    func makeField(_ text: String) -> javax.swing.JLabel {
      let lbl = javax.swing.JLabel(text)
      lbl.setOpaque(true)
      lbl.setBackground(java.awt.Color.white)
      lbl.setPreferredSize(java.awt.Dimension(200, 24))
      return lbl
    }

    // Row 0 — Name
    let lblName = javax.swing.JLabel("Name:")
    add(lblName, gx: 0, gy: 0)
    let tfName = makeField(java.util.Locale.getDefault().getLanguage() == "de" ? "Max Mustermann" : "Jane Doe")
    add(tfName, gx: 1, gy: 0, gw: 2, weightx: 1.0, fill: java.awt.GridBagConstraints.HORIZONTAL)

    // Row 1 — Stadt
    let lblStadt = javax.swing.JLabel("Stadt:")
    add(lblStadt, gx: 0, gy: 1)
    let tfStadt = makeField("Berlin")
    add(tfStadt, gx: 1, gy: 1, gw: 2, weightx: 1.0, fill: java.awt.GridBagConstraints.HORIZONTAL)

    // Row 2 — Notiz (expandable)
    let lblNotiz = javax.swing.JLabel("Notiz:")
    add(lblNotiz, gx: 0, gy: 2, anchor: java.awt.GridBagConstraints.NORTHWEST)
    let taNotiz = makeField("Anmerkungen hier…")
    taNotiz.setVerticalAlignment(javax.swing.JLabel.TOP)
    taNotiz.setPreferredSize(java.awt.Dimension(200, 80))
    add(taNotiz, gx: 1, gy: 2, gw: 2, weightx: 1.0, weighty: 1.0, fill: java.awt.GridBagConstraints.BOTH)

    // Row 3 — Buttons
    let btnCancel = javax.swing.JButton("Abbrechen")
    btnCancel.setPreferredSize(java.awt.Dimension(100, 28))
    btnCancel.addActionListener(SwingDialogCloseListener(dialog: self))
    add(btnCancel, gx: 1, gy: 3, anchor: java.awt.GridBagConstraints.EAST,
        insets: java.awt.Insets(4, 4, 8, 2))

    let btnOK = javax.swing.JButton("OK")
    btnOK.setPreferredSize(java.awt.Dimension(70, 28))
    btnOK.addActionListener(SwingGridBagOKListener(dialog: self))
    add(btnOK, gx: 2, gy: 3, anchor: java.awt.GridBagConstraints.EAST,
        insets: java.awt.Insets(4, 2, 8, 8))
  }
}

// ---------------------------------------------------------------------------
// MARK: - Listener
// ---------------------------------------------------------------------------

@MainActor
final class SwingGridBagOKListener: java.awt.event.ActionListener {
  private weak var dialog: javax.swing.JDialog?
  init(dialog: javax.swing.JDialog) { self.dialog = dialog }

  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    print("GridBagLayout-Demo OK button pressed")
    dialog?.setVisible(false)
  }
}

@MainActor
final class SwingGridBagLayoutDemoListener: java.awt.event.ActionListener {
  private weak var owner: javax.swing.JFrame?
  init(owner: javax.swing.JFrame) { self.owner = owner }

  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    guard let owner else { return }
    SwingGridBagLayoutDemoDialog(owner).setVisible(true)
  }
}
