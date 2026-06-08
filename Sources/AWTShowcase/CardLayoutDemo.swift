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
// MARK: - CardLayout demo
// ---------------------------------------------------------------------------

/// Öffnet den CardLayout-Demo-Dialog.
@MainActor
final class CardLayoutDemoListener: java.awt.event.ActionListener {
  private weak var owner: java.awt.Frame?
  init(owner: java.awt.Frame) { self.owner = owner }

  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    guard let owner else { return }
    let dialog = CardLayoutDemoDialog(owner: owner)
    dialog.validate()
    dialog.setVisible(true)
  }
}

/// Panel mit CardLayout — drei Karten, umschaltbar per Buttons.
@MainActor
final class CardDemoPanel: java.awt.Panel {

  private let cards   = java.awt.CardLayout()
  private let cardBox: java.awt.Panel

  override init() {
    cardBox = java.awt.Panel(cards)
    super.init()
    setLayout(java.awt.BorderLayout())

    // Drei Karten
    let card1 = java.awt.Label("Karte 1 — Start", java.awt.Label.CENTER)
    card1.background = .blue
    card1.foreground = .white
    let card2 = java.awt.Label("Karte 2 — Mitte", java.awt.Label.CENTER)
    card2.background = .green
    card2.foreground = .white
    let card3 = java.awt.Label("Karte 3 — Ende",  java.awt.Label.CENTER)
    card3.background = .red
    card3.foreground = .white

    cardBox.add(card1, "1")
    cardBox.add(card2, "2")
    cardBox.add(card3, "3")

    add(cardBox, java.awt.BorderLayout.CENTER)

    // Navigationsleiste
    let nav = java.awt.Panel(java.awt.FlowLayout(java.awt.FlowLayout.CENTER, 4, 2))
    let prevBtn = java.awt.Button("◀")
    prevBtn.setPreferredSize(java.awt.Dimension(36, 22))
    prevBtn.addActionListener(CardNavListener(cards: cards, box: cardBox, dir: -1))
    let nextBtn = java.awt.Button("▶")
    nextBtn.setPreferredSize(java.awt.Dimension(36, 22))
    nextBtn.addActionListener(CardNavListener(cards: cards, box: cardBox, dir: 1))
    nav.add(prevBtn)
    nav.add(nextBtn)
    nav.setPreferredSize(java.awt.Dimension(100, 28))
    add(nav, java.awt.BorderLayout.SOUTH)
  }
}

@MainActor
final class CardNavListener: java.awt.event.ActionListener {
  private let cards: java.awt.CardLayout
  private let box:   java.awt.Panel
  private let dir:   Int   // -1 = previous, +1 = next
  init(cards: java.awt.CardLayout, box: java.awt.Panel, dir: Int) {
    self.cards = cards; self.box = box; self.dir = dir
  }
  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    if dir > 0 { cards.next(box) } else { cards.previous(box) }
  }
}

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
