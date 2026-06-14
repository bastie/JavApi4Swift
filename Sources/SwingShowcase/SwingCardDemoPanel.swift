/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Swing-Panel mit CardLayout — drei farbige Karten, umschaltbar per ◀ ▶ Buttons.
///
/// Analogon zu `CardDemoPanel` im AWTShowcase, aber mit Swing-Komponenten:
/// `JLabel`, `JButton`, `JPanel`, `javax.swing.JPanel` mit `BorderLayout`.
@MainActor
final class SwingCardDemoPanel: javax.swing.JPanel {

  private let cards   = java.awt.CardLayout()
  private let cardBox = javax.swing.JPanel()

  init() {
    super.init(java.awt.BorderLayout())

    cardBox.setLayout(cards)

    // Drei farbige Karten
    let card1 = makeCard("Karte 1 — Start", java.awt.Color(0x33, 0x66, 0xFF))
    let card2 = makeCard("Karte 2 — Mitte", java.awt.Color(0x22, 0xAA, 0x44))
    let card3 = makeCard("Karte 3 — Ende",  java.awt.Color(0xCC, 0x33, 0x33))
    cardBox.add(card1, "1")
    cardBox.add(card2, "2")
    cardBox.add(card3, "3")

    add(cardBox, java.awt.BorderLayout.CENTER)

    // Navigationsleiste
    let nav = javax.swing.JPanel()
    nav.setLayout(java.awt.FlowLayout())

    let prevBtn = javax.swing.JButton("◀")
    prevBtn.addActionListener(SwingCardNavListener(cards: cards, box: cardBox, dir: -1))
    let nextBtn = javax.swing.JButton("▶")
    nextBtn.addActionListener(SwingCardNavListener(cards: cards, box: cardBox, dir: 1))
    nav.add(prevBtn)
    nav.add(nextBtn)
    nav.setPreferredSize(java.awt.Dimension(200, 36))

    add(nav, java.awt.BorderLayout.SOUTH)
  }

  private func makeCard(_ text: String, _ bg: java.awt.Color) -> javax.swing.JPanel {
    let panel = javax.swing.JPanel()
    panel.setLayout(java.awt.BorderLayout())
    panel.setBackground(bg)

    let label = javax.swing.JLabel(text)
    label.setHorizontalAlignment(javax.swing.JLabel.CENTER)
    label.setVerticalAlignment(javax.swing.JLabel.CENTER)
    label.setForeground(java.awt.Color.white)
    panel.add(label, java.awt.BorderLayout.CENTER)
    return panel
  }
}
