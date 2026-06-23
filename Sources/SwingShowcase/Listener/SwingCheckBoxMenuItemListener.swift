/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Demonstrates `JCheckBoxMenuItem` by printing the new selected state.
@MainActor
class SwingCheckBoxMenuItemListener: java.awt.event.ItemListener {

  func itemStateChanged(_ e: java.awt.event.ItemEvent) {
    guard let item = e.getSource() as? javax.swing.JCheckBoxMenuItem else { return }
    let state = item.isSelected() ? "enabled" : "disabled"
    print("JCheckBoxMenuItem '\(item.getText())' → \(state)")
  }
}
