/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

@MainActor
final class SwingGridBagLayoutAction: SwingShowcaseAction {
  private weak var owner: javax.swing.JFrame?
  init(owner: javax.swing.JFrame) {
    self.owner = owner
    super.init("GridBagLayout…")
    if let icon = SwingGridBagLayoutAction.toolbarIcon(named: "toolbar-gridbag") {
      putValue(SwingGridBagLayoutAction.SMALL_ICON, icon)
    }
    putValue(SwingGridBagLayoutAction.SHORT_DESCRIPTION, "Show GridBagLayout demo" as AnyObject)
  }
  override func actionPerformed(_ e: java.awt.event.ActionEvent) {
    guard let owner else { return }
    SwingGridBagLayoutDemoDialog(owner).setVisible(true)
  }
}
