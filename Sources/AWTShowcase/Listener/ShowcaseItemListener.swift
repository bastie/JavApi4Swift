/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// ItemListener für Choice und List - print the selected item on clonsole
@MainActor
final class ShowcaseItemListener: java.awt.event.ItemListener {
  private let label: String
  init(label: String) { self.label = label }
  func itemStateChanged(_ e: java.awt.event.ItemEvent) {
    let state = e.stateChange == java.awt.event.ItemEvent.SELECTED ? "selected" : "deselected"
    let item  = e.item as? String ?? "?"
    System.out.println ("\(label): \(item) \(state)")
  }
}
