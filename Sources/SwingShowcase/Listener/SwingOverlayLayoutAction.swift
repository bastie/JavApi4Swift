/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

@MainActor
final class SwingOverlayLayoutAction: SwingShowcaseAction {
  private weak var owner: javax.swing.JFrame?
  init(owner: javax.swing.JFrame) {
    self.owner = owner
    super.init("OverlayLayout…")
    if let icon = SwingOverlayLayoutAction.toolbarIcon(named: "toolbar-overlay") {
      putValue(SwingOverlayLayoutAction.SMALL_ICON, icon)
    }
    putValue(SwingOverlayLayoutAction.SHORT_DESCRIPTION, "Show OverlayLayout demo" as AnyObject)
  }
  override func actionPerformed(_ e: java.awt.event.ActionEvent) {
    guard let owner else { return }
    SwingOverlayLayoutDemoDialog(owner).setVisible(true)
  }
}
