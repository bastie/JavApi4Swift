/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// ActionListener that opens the FlowLayout demo dialog.
///
/// Demonstrates how FlowLayout arranges components in rows, flowing from
/// left to right and wrapping to the next line when space is exhausted.
@MainActor
final class FlowLayoutDemoListener: java.awt.event.ActionListener {
  private weak var owner: java.awt.Frame?
  init(owner: java.awt.Frame) { self.owner = owner }
  
  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    guard let owner else { return }
    
    let dialog = FlowLayoutDemoDialog(owner: owner)
    dialog.validate()
    dialog.setVisible(true)
  }
}
