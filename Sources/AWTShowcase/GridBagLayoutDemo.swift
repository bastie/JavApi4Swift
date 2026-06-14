/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

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
    super.init (owner, "LayoutManager – GridBagLayout", true)
    let width = 400
    let height = 300
    setBounds(0, 0, width, height)
    setPreferredSize (java.awt.Dimension(width, height))

    let gbl = java.awt.GridBagLayout()
    setLayout (gbl)

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
      gbl.setConstraints (comp, c)
      self.add (comp)
    }

    // Row 0 — Name
    let lblName = try! java.awt.Label ("Name:", java.awt.Label.RIGHT)
    add (lblName, gx: 0, gy: 0)

    let tfName = java.awt.TextField (java.util.Locale.getDefault().getLanguage() == "de" ? "Max Mustermann" : "Jane Doe", columns: 20)
    add (tfName, gx: 1, gy: 0, gw: 2, weightx: 1.0, fill: java.awt.GridBagConstraints.HORIZONTAL)

    // Row 1 — Stadt
    let lblStadt = try! java.awt.Label ("City:", java.awt.Label.RIGHT)
    add (lblStadt, gx: 0, gy: 1)

    let tfStadt = java.awt.TextField ("Berlin", columns: 20)
    add (tfStadt, gx: 1, gy: 1, gw: 2, weightx: 1.0, fill: java.awt.GridBagConstraints.HORIZONTAL)

    // Row 2 — Note (expandable text area)
    let lblNotiz = try! java.awt.Label ("Note:", java.awt.Label.RIGHT)
    add (lblNotiz, gx: 0, gy: 2, anchor: java.awt.GridBagConstraints.NORTHEAST)

    let ta = java.awt.TextArea ("Insert notes here…", 4, 20)
    add (ta, gx: 1, gy: 2, gw: 2, weightx: 1.0, weighty: 1.0, fill: java.awt.GridBagConstraints.BOTH)

    // Row 3 — Buttons (right-aligned via anchor)
    let btnCancel = java.awt.Button ("Cancel")
    btnCancel.setPreferredSize (java.awt.Dimension(100, 28))
    btnCancel.addActionListener (DialogCloseListener(dialog: self))
    add (btnCancel, gx: 1, gy: 3, anchor: java.awt.GridBagConstraints.EAST, insets: java.awt.Insets(4, 4, 8, 2))

    let btnOK = java.awt.Button ("OK")
    btnOK.setPreferredSize (java.awt.Dimension(70, 28))
    btnOK.addActionListener (GridBagDemoOKListener(dialog: self, nameField: tfName, stadtField: tfStadt, textArea: ta))
    add (btnOK, gx: 2, gy: 3, anchor: java.awt.GridBagConstraints.EAST, insets: java.awt.Insets(4, 2, 8, 8))
  }
}

