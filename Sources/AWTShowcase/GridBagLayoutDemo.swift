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
// MARK: - GridBagLayout demo
// ---------------------------------------------------------------------------

/// Opens the GridBagLayout demo dialog.
@MainActor
final class GridBagDemoListener: java.awt.event.ActionListener {
  private weak var owner: java.awt.Frame?
  init(owner: java.awt.Frame) { self.owner = owner }

  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    guard let owner else { return }
    let dialog = GridBagDemoDialog(owner: owner)
    dialog.validate()
    dialog.setVisible(true)
  }
}

/// Dialog demonstrating GridBagLayout with a variety of constraints.
///
/// Layout overview (3 columns):
/// ```
/// [col 0]       [col 1]        [col 2]
/// Label "Name:" TextField (span 2 cols, weightx=1, HORIZONTAL)
/// Label "Stadt:" TextField (span 2 cols, weightx=1, HORIZONTAL)
/// Label "Notiz:" TextArea  (span 2 cols, weighty=1, BOTH) — fills remaining height
/// [spacer]      [Abbrechen]    [OK]
/// ```
@MainActor
final class GridBagDemoDialog: java.awt.Dialog {

  init(owner: java.awt.Frame) {
    super.init(owner, "LayoutManager – GridBagLayout", true)
    let W = 400, H = 300
    bounds = java.awt.Rectangle(0, 0, W, H)
    setPreferredSize(java.awt.Dimension(W, H))

    let gbl = java.awt.GridBagLayout()
    setLayout(gbl)

    let ins4 = java.awt.Insets(4, 4, 4, 4)

    // Helper: configure and add a component
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
      self.add(comp)
    }

    // Row 0 — Name
    let lblName = java.awt.Label("Name:", java.awt.Label.RIGHT)
    add(lblName, gx: 0, gy: 0)

    let tfName = java.awt.TextField("Max Mustermann", columns: 20)
    add(tfName, gx: 1, gy: 0, gw: 2, weightx: 1.0,
        fill: java.awt.GridBagConstraints.HORIZONTAL)

    // Row 1 — Stadt
    let lblStadt = java.awt.Label("Stadt:", java.awt.Label.RIGHT)
    add(lblStadt, gx: 0, gy: 1)

    let tfStadt = java.awt.TextField("Berlin", columns: 20)
    add(tfStadt, gx: 1, gy: 1, gw: 2, weightx: 1.0,
        fill: java.awt.GridBagConstraints.HORIZONTAL)

    // Row 2 — Notiz (expandable text area)
    let lblNotiz = java.awt.Label("Notiz:", java.awt.Label.RIGHT)
    add(lblNotiz, gx: 0, gy: 2, anchor: java.awt.GridBagConstraints.NORTHEAST)

    let ta = java.awt.TextArea("Hier Notizen eingeben…", 4, 20)
    add(ta, gx: 1, gy: 2, gw: 2, weightx: 1.0, weighty: 1.0,
        fill: java.awt.GridBagConstraints.BOTH)

    // Row 3 — Buttons (right-aligned via anchor)
    let btnCancel = java.awt.Button("Abbrechen")
    btnCancel.setPreferredSize(java.awt.Dimension(100, 28))
    btnCancel.addActionListener(DialogCloseListener(dialog: self))
    add(btnCancel, gx: 1, gy: 3,
        anchor: java.awt.GridBagConstraints.EAST,
        insets: java.awt.Insets(4, 4, 8, 2))

    let btnOK = java.awt.Button("OK")
    btnOK.setPreferredSize(java.awt.Dimension(70, 28))
    btnOK.addActionListener(GridBagOKListener(dialog: self,
                                              nameField: tfName,
                                              stadtField: tfStadt,
                                              textArea: ta))
    add(btnOK, gx: 2, gy: 3,
        anchor: java.awt.GridBagConstraints.EAST,
        insets: java.awt.Insets(4, 2, 8, 8))
  }
}

@MainActor
final class GridBagOKListener: java.awt.event.ActionListener {
  private weak var dialog: java.awt.Dialog?
  private weak var nameField:  java.awt.TextField?
  private weak var stadtField: java.awt.TextField?
  private weak var textArea:   java.awt.TextArea?

  init(dialog: java.awt.Dialog,
       nameField: java.awt.TextField,
       stadtField: java.awt.TextField,
       textArea: java.awt.TextArea) {
    self.dialog     = dialog
    self.nameField  = nameField
    self.stadtField = stadtField
    self.textArea   = textArea
  }

  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    print("GridBagLayout-Demo OK:")
    print("  Name : \(nameField?.getText()  ?? "-")")
    print("  Stadt: \(stadtField?.getText() ?? "-")")
    print("  Notiz: \(textArea?.getText()   ?? "-")")
    dialog?.dispose()
  }
}
