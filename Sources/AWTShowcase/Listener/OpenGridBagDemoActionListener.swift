/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// ActionListener that opens the GridBagLayout demo dialog.
///
/// Demonstrates how GridBagLayout allows precise control over component
/// positioning using grid cells and constraints. The demo dialog contains
/// form fields arranged in a grid with customizable spacing and alignment.
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
