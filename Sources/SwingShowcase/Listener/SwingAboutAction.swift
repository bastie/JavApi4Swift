/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

@MainActor
final class SwingAboutAction: SwingShowcaseAction {
  private weak var owner: javax.swing.JFrame?
  init(owner: javax.swing.JFrame) {
    self.owner = owner
    super.init("About JavApi⁴Swift…")
    if let icon = SwingAboutAction.toolbarIcon(named: "JavApi4Swift256") {
      putValue(SwingAboutAction.SMALL_ICON, icon)
    }
    putValue(SwingAboutAction.SHORT_DESCRIPTION, "Show about dialog" as AnyObject)
  }
  override func actionPerformed(_ e: java.awt.event.ActionEvent) {
    guard let owner else { return }
    SwingAboutDialog(owner).setVisible(true)
  }
}
