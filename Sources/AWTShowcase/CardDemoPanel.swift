/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

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
    card1.setBackgroundColor(.blue)
    card1.setForegroundColor(.white)
    let card2 = java.awt.Label("Karte 2 — Mitte", java.awt.Label.CENTER)
    card2.setBackgroundColor(.green)
    card2.setForegroundColor(.white)
    let card3 = java.awt.Label("Karte 3 — Ende",  java.awt.Label.CENTER)
    card3.setBackgroundColor(.red)
    card3.setForegroundColor(.white)
    
    cardBox.add(card1, "1")
    cardBox.add(card2, "2")
    cardBox.add(card3, "3")
    
    add(cardBox, java.awt.BorderLayout.CENTER)
    
    // Navigationsleiste
    let nav = java.awt.Panel (
      java.awt.FlowLayout(java.awt.FlowLayout.CENTER, 4, 2)
    )
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
