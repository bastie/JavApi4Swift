/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// ActionListener that opens the GridLayout demo dialog.
///
/// Demonstrates how GridLayout arranges components in a uniform grid
/// with specified rows and columns. Each component gets equal space.
@MainActor
final class GridLayoutDemoListener: java.awt.event.ActionListener {
  private weak var owner: java.awt.Frame?
  init(owner: java.awt.Frame) { self.owner = owner }
  
  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    guard let owner else { return }
    let dialog = GridLayoutDemoDialog(owner: owner)
    dialog.validate()
    dialog.setVisible(true)
  }
}
