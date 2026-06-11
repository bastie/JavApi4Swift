/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// ActionListener that opens the BorderLayout demo dialog.
///
/// Demonstrates how BorderLayout organizes components into five regions:
/// NORTH, SOUTH, EAST, WEST, and CENTER. Each region can contain one component.
@MainActor
final class BorderLayoutDemoListener: java.awt.event.ActionListener {
  private weak var owner: java.awt.Frame?
  init(owner: java.awt.Frame) { self.owner = owner }
  
  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    guard let owner else { return }
    let dialog = BorderLayoutDemoDialog(owner: owner)
    dialog.validate()
    dialog.setVisible(true)
  }
}
