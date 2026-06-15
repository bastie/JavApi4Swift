/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

@MainActor
final class SwingSaveAction: SwingShowcaseAction {
  override init() {
    super.init("Save…")
    if let icon = SwingSaveAction.toolbarIcon(named: "toolbar-save") {
      putValue(SwingSaveAction.SMALL_ICON, icon)
    }
    putValue(SwingSaveAction.SHORT_DESCRIPTION, "Save the file" as AnyObject)
  }
  override func actionPerformed(_ e: java.awt.event.ActionEvent) {
    print("File > Save…")
  }
}
