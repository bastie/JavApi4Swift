/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Opens the GridBagLayout demo dialog.
@MainActor
final class OpenGridBagDemoActionListener: java.awt.event.ActionListener {
  private weak var owner: java.awt.Frame?
  init(owner: java.awt.Frame) { self.owner = owner }
  
  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    guard let owner else { return }

    let dialog = GridBagDemoDialog(owner: owner)
    dialog.validate()
    dialog.setVisible(true)
  }
}
