/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

@MainActor
final class SwingCopyAction: SwingShowcaseAction {
  override init() {
    super.init("Copy")
    if let icon = SwingCopyAction.toolbarIcon(named: "toolbar-copy") {
      putValue(SwingCopyAction.SMALL_ICON, icon)
    }
    putValue(SwingCopyAction.SHORT_DESCRIPTION, "Copy selection" as AnyObject)
  }
  override func actionPerformed(_ e: java.awt.event.ActionEvent) {
    print("Edit > Copy")
  }
}
