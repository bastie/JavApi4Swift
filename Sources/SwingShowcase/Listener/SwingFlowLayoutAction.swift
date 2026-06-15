/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

@MainActor
final class SwingFlowLayoutAction: SwingShowcaseAction {
  private weak var owner: javax.swing.JFrame?
  init(owner: javax.swing.JFrame) {
    self.owner = owner
    super.init("FlowLayout…")
    if let icon = SwingFlowLayoutAction.toolbarIcon(named: "toolbar-flow") {
      putValue(SwingFlowLayoutAction.SMALL_ICON, icon)
    }
    putValue(SwingFlowLayoutAction.SHORT_DESCRIPTION, "Show FlowLayout demo" as AnyObject)
  }
  override func actionPerformed(_ e: java.awt.event.ActionEvent) {
    guard let owner else { return }
    SwingFlowLayoutDemoDialog(owner).setVisible(true)
  }
}
