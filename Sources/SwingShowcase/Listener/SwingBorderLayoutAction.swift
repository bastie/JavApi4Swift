/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

@MainActor
final class SwingBorderLayoutAction: SwingShowcaseAction {
  private weak var owner: javax.swing.JFrame?
  init(owner: javax.swing.JFrame) {
    self.owner = owner
    super.init("BorderLayout…")
    if let icon = SwingBorderLayoutAction.toolbarIcon(named: "toolbar-border") {
      putValue(SwingBorderLayoutAction.SMALL_ICON, icon)
    }
    putValue(SwingBorderLayoutAction.SHORT_DESCRIPTION, "Show BorderLayout demo" as AnyObject)
  }
  override func actionPerformed(_ e: java.awt.event.ActionEvent) {
    guard let owner else { return }
    SwingBorderLayoutDemoDialog(owner).setVisible(true)
  }
}
