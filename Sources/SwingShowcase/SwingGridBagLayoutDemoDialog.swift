/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Swing-Pendant zu `GridBagDemoDialog` im AWTShowcase.
///
/// Demonstriert GridBagLayout mit einem formähnlichen Aufbau
/// unter Verwendung echter Swing-Texteingabekomponenten.
///
/// Layout (3 Spalten):
/// ```
/// [col 0]       [col 1+2: span 2, weightx=1]
/// "Name:"       [ JTextField — Max Mustermann      ]
/// "Stadt:"      [ JTextField — Berlin              ]
/// "Notiz:"      [ JTextArea  — mehrzeilig (scroll) ]
///               [Abbrechen]  [OK]
/// ```
@MainActor
final class SwingGridBagLayoutDemoDialog: javax.swing.JDialog {

  init(_ owner: javax.swing.JFrame) {
    super.init(owner, "LayoutManager – GridBagLayout", false)
    setSize(420, 380)

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

    // Row 0 — Name
    let lblName = javax.swing.JLabel("Name:")
    add(lblName, gx: 0, gy: 0)
    let tfName = javax.swing.JTextField(
      java.util.Locale.getDefault().getLanguage() == "de" ? "Max Mustermann" : "Jane Doe", 20)
    add(tfName, gx: 1, gy: 0, gw: 2, weightx: 1.0, fill: java.awt.GridBagConstraints.HORIZONTAL)

    // Row 1 — Stadt
    let lblStadt = javax.swing.JLabel("Stadt:")
    add(lblStadt, gx: 0, gy: 1)
    let tfStadt = javax.swing.JTextField("Berlin", 20)
    add(tfStadt, gx: 1, gy: 1, gw: 2, weightx: 1.0, fill: java.awt.GridBagConstraints.HORIZONTAL)

    // Row 2 — Passwort
    let lblPw = javax.swing.JLabel("Passwort:")
    add(lblPw, gx: 0, gy: 2)
    let pfPw = javax.swing.JPasswordField(20)
    add(pfPw, gx: 1, gy: 2, gw: 2, weightx: 1.0, fill: java.awt.GridBagConstraints.HORIZONTAL)

    // Row 3 — Notiz (expandable, wrapped in JScrollPane)
    let lblNotiz = javax.swing.JLabel("Notiz:")
    add(lblNotiz, gx: 0, gy: 3, anchor: java.awt.GridBagConstraints.NORTHWEST)
    let taNotiz = javax.swing.JTextArea(
      java.util.Locale.getDefault().getLanguage() == "de" ? "Anmerkungen hier…" : "Insert notes here…",
      4, 20)
    taNotiz.setLineWrap(true)
    taNotiz.setWrapStyleWord(true)
    let scrollNotiz = javax.swing.JScrollPane(taNotiz)
    add(scrollNotiz, gx: 1, gy: 3, gw: 2, weightx: 1.0, weighty: 1.0,
        fill: java.awt.GridBagConstraints.BOTH)

    // Row 4 — Buttons
    let btnCancel = javax.swing.JButton("Abbrechen")
    btnCancel.setPreferredSize(java.awt.Dimension(100, 28))
    btnCancel.addActionListener(SwingDialogCloseListener(dialog: self))
    add(btnCancel, gx: 1, gy: 4, anchor: java.awt.GridBagConstraints.EAST,
        insets: java.awt.Insets(4, 4, 8, 2))

    let btnOK = javax.swing.JButton("OK")
    btnOK.setPreferredSize(java.awt.Dimension(70, 28))
    btnOK.addActionListener(SwingGridBagOKListener(dialog: self,
                                                    nameField: tfName,
                                                    stadtField: tfStadt,
                                                    passwordField: pfPw,
                                                    notizArea: taNotiz))
    add(btnOK, gx: 2, gy: 4, anchor: java.awt.GridBagConstraints.EAST,
        insets: java.awt.Insets(4, 2, 8, 8))
  }
}

// ---------------------------------------------------------------------------
// MARK: - Listener
// ---------------------------------------------------------------------------

@MainActor
final class SwingGridBagOKListener: java.awt.event.ActionListener {
  private weak var dialog:         javax.swing.JDialog?
  private weak var nameField:      javax.swing.JTextField?
  private weak var stadtField:     javax.swing.JTextField?
  private weak var passwordField:  javax.swing.JPasswordField?
  private weak var notizArea:      javax.swing.JTextArea?

  init(dialog:         javax.swing.JDialog,
       nameField:      javax.swing.JTextField,
       stadtField:     javax.swing.JTextField,
       passwordField:  javax.swing.JPasswordField,
       notizArea:      javax.swing.JTextArea) {
    self.dialog        = dialog
    self.nameField     = nameField
    self.stadtField    = stadtField
    self.passwordField = passwordField
    self.notizArea     = notizArea
  }

  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    let name  = nameField?.getText()                        ?? ""
    let stadt = stadtField?.getText()                       ?? ""
    let pw    = String(passwordField?.getPassword() ?? [])
    let notiz = notizArea?.getText()                        ?? ""
    print("GridBagLayout-Demo OK: name=\(name) stadt=\(stadt) pw=\(pw) notiz=\(notiz)")
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
