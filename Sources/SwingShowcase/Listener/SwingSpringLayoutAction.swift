/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

@MainActor
final class SwingSpringLayoutAction: SwingShowcaseAction {
  private weak var owner: javax.swing.JFrame?
  init(owner: javax.swing.JFrame) {
    self.owner = owner
    super.init("SpringLayout…")
    if let icon = SwingSpringLayoutAction.toolbarIcon(named: "toolbar-spring") {
      putValue(SwingSpringLayoutAction.SMALL_ICON, icon)
    }
    putValue(SwingSpringLayoutAction.SHORT_DESCRIPTION, "Show SpringLayout demo" as AnyObject)
  }
  override func actionPerformed(_ e: java.awt.event.ActionEvent) {
    guard let owner else { return }
    SwingSpringLayoutDemoDialog(owner).setVisible(true)
  }
}
