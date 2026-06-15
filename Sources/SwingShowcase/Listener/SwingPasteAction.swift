/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

@MainActor
final class SwingPasteAction: SwingShowcaseAction {
  override init() {
    super.init("Paste")
    if let icon = SwingPasteAction.toolbarIcon(named: "toolbar-paste") {
      putValue(SwingPasteAction.SMALL_ICON, icon)
    }
    putValue(SwingPasteAction.SHORT_DESCRIPTION, "Paste from clipboard" as AnyObject)
  }
  override func actionPerformed(_ e: java.awt.event.ActionEvent) {
    print("Edit > Paste")
  }
}
