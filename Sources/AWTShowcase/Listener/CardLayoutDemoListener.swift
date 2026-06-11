/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// ActionListener that opens the CardLayout demo dialog.
///
/// Demonstrates how CardLayout works by displaying a dialog with cards
/// that can be navigated through via CardNavListener.
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
