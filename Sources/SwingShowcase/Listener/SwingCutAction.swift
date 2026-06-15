/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

@MainActor
final class SwingCutAction: SwingShowcaseAction {
  override init() {
    super.init("Cut")
    if let icon = SwingCutAction.toolbarIcon(named: "toolbar-cut") {
      putValue(SwingCutAction.SMALL_ICON, icon)
    }
    putValue(SwingCutAction.SHORT_DESCRIPTION, "Cut selection" as AnyObject)
  }
  override func actionPerformed(_ e: java.awt.event.ActionEvent) {
    print("Edit > Cut")
  }
}
