/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

@MainActor
final class SwingGridLayoutAction: SwingShowcaseAction {
  private weak var owner: javax.swing.JFrame?
  init(owner: javax.swing.JFrame) {
    self.owner = owner
    super.init("GridLayout…")
    if let icon = SwingGridLayoutAction.toolbarIcon(named: "toolbar-grid") {
      putValue(SwingGridLayoutAction.SMALL_ICON, icon)
    }
    putValue(SwingGridLayoutAction.SHORT_DESCRIPTION, "Show GridLayout demo" as AnyObject)
  }
  override func actionPerformed(_ e: java.awt.event.ActionEvent) {
    guard let owner else { return }
    SwingGridLayoutDemoDialog(owner).setVisible(true)
  }
}
