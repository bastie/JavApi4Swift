/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

@MainActor
final class CardNavListener: java.awt.event.ActionListener {
  
  private let cards: java.awt.CardLayout
  private let box:   java.awt.Panel
  private let dir:   Int   // -1 = previous, +1 = next
  
  init (cards: java.awt.CardLayout, box: java.awt.Panel, dir: Int) {
    self.cards = cards; self.box = box; self.dir = dir
  }
  
  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    if dir > 0 {
      cards.next(box)
    }
    else {
      cards.previous(box)
    }
  }
}
