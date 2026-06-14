/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// ActionListener that navigates between cards in a CardLayout (Swing variant).
///
/// Moves to the next or previous card when its action button is clicked.
/// Direction is determined by the initialization parameter: positive moves next,
/// negative moves previous.
@MainActor
final class SwingCardNavListener: java.awt.event.ActionListener {

  private let cards: java.awt.CardLayout
  private weak var box: javax.swing.JPanel?
  private let dir: Int   // -1 = previous, +1 = next

  init(cards: java.awt.CardLayout, box: javax.swing.JPanel, dir: Int) {
    self.cards = cards
    self.box   = box
    self.dir   = dir
  }

  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    guard let box else { return }
    if dir > 0 {
      cards.next(box)
    } else {
      cards.previous(box)
    }
  }
}
