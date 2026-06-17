/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

@MainActor
final class SwingBoxLayoutAction: SwingShowcaseAction {
  private weak var owner: javax.swing.JFrame?
  init(owner: javax.swing.JFrame) {
    self.owner = owner
    super.init("BoxLayout…")
    if let icon = SwingBoxLayoutAction.toolbarIcon(named: "toolbar-box") {
      putValue(SwingBoxLayoutAction.SMALL_ICON, icon)
    }
    putValue(SwingBoxLayoutAction.SHORT_DESCRIPTION, "Show BoxLayout demo" as AnyObject)
  }
  override func actionPerformed(_ e: java.awt.event.ActionEvent) {
    guard let owner else { return }
    SwingBoxLayoutDemoDialog(owner).setVisible(true)
  }
}
