/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Demonstrates `JToggleButton` by updating the button label when toggled.
@MainActor
class SwingToggleItemListener: java.awt.event.ItemListener {

  func itemStateChanged(_ e: java.awt.event.ItemEvent) {
    guard let btn = e.getSource() as? javax.swing.JToggleButton else { return }
    let selected = e.getStateChange() == java.awt.event.ItemEvent.SELECTED
    btn.setText(selected ? "ON" : "OFF")
    btn.repaint()
  }
}
