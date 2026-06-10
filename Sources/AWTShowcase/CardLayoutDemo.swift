/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Dialog mit einem CardLayout-Panel und ◀ / ▶ Navigation.
///
/// Layout:
/// ```
/// ┌──────────────────────────────────┐
/// │       Karte 1 — Start            │  ← farbige Karte (CENTER)
/// │           ◀   ▶                  │  ← Navigation (SOUTH des Panels)
/// └──────────────────────────────────┘
///                          [Schließen]
/// ```
@MainActor
final class CardLayoutDemoDialog: java.awt.Dialog {

  init(owner: java.awt.Frame) {
    super.init(owner, "LayoutManager – CardLayout", true)
    let W = 380, H = 220
    bounds = java.awt.Rectangle(0, 0, W, H)
    setPreferredSize(java.awt.Dimension(W, H))
    setLayout(java.awt.BorderLayout())

    // Titel-Label
    let title = java.awt.Label(
      "CardLayout — 3 Karten, umschaltbar per ◀ ▶",
      java.awt.Label.CENTER)
    title.setPreferredSize(java.awt.Dimension(W, 28))
    add(title, java.awt.BorderLayout.NORTH)

    // CardDemoPanel
    let cardPanel = CardDemoPanel()
    cardPanel.setPreferredSize(java.awt.Dimension(W, 148))
    add(cardPanel, java.awt.BorderLayout.CENTER)

    // Schließen-Button
    let closeBtn = java.awt.Button("Schließen")
    closeBtn.setPreferredSize(java.awt.Dimension(100, 28))
    closeBtn.addActionListener(DialogCloseListener(dialog: self))
    let south = java.awt.Panel(java.awt.FlowLayout(java.awt.FlowLayout.RIGHT, 8, 6))
    south.setPreferredSize(java.awt.Dimension(W, 44))
    south.add(closeBtn)
    add(south, java.awt.BorderLayout.SOUTH)
  }
}
