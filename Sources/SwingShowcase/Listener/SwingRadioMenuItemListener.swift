/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Demonstrates `JRadioButtonMenuItem` group behaviour.
///
/// Since `JRadioButtonMenuItem` does not extend `AbstractButton` in this port,
/// `ButtonGroup` cannot be used directly.  This listener emulates the group
/// logic: when one item is selected it deselects all others and prints the
/// active choice.
@MainActor
class SwingRadioMenuItemListener: java.awt.event.ItemListener {

  private let items: [javax.swing.JRadioButtonMenuItem]

  init(items: [javax.swing.JRadioButtonMenuItem]) {
    self.items = items
  }

  func itemStateChanged(_ e: java.awt.event.ItemEvent) {
    guard e.getStateChange() == java.awt.event.ItemEvent.SELECTED,
          let selected = e.getSource() as? javax.swing.JRadioButtonMenuItem
    else { return }

    // Deselect all others in the group
    for item in items where item !== selected {
      item.setSelected(false)
    }

    print("JRadioButtonMenuItem selected: '\(selected.getText())'")
  }
}
