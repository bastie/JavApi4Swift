/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// ItemListener that logs selection changes in Choice and List components.
///
/// Prints each item selection/deselection event to the console with the item
/// name and whether it was selected or deselected. Useful for tracking
/// user interactions with dropdown menus and lists.
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
