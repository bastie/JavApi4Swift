/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

@MainActor
final class SwingOpenAction: SwingShowcaseAction {
  override init() {
    super.init("Open…")
    if let icon = SwingOpenAction.toolbarIcon(named: "toolbar-open") {
      putValue(SwingOpenAction.SMALL_ICON, icon)
    }
    putValue(SwingOpenAction.SHORT_DESCRIPTION, "Open a file" as AnyObject)
  }
  override func actionPerformed(_ e: java.awt.event.ActionEvent) {
    print("File > Open…")
  }
}
