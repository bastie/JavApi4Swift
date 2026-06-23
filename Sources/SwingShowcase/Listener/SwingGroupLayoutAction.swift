/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

@MainActor
final class SwingGroupLayoutAction: SwingShowcaseAction {
  private weak var owner: javax.swing.JFrame?
  init(owner: javax.swing.JFrame) {
    self.owner = owner
    super.init("GroupLayout…")
    if let icon = SwingGroupLayoutAction.toolbarIcon(named: "toolbar-group") {
      putValue(SwingGroupLayoutAction.SMALL_ICON, icon)
    }
    putValue(SwingGroupLayoutAction.SHORT_DESCRIPTION, "Show GroupLayout demo" as AnyObject)
  }
  override func actionPerformed(_ e: java.awt.event.ActionEvent) {
    guard let owner else { return }
    SwingGroupLayoutDemoDialog(owner).setVisible(true)
  }
}
