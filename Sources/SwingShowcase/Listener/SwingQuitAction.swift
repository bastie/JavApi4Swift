/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

@MainActor
final class SwingQuitAction: SwingShowcaseAction {
  override init() {
    super.init("Quit")
    putValue(SwingQuitAction.SHORT_DESCRIPTION, "Quit the application" as AnyObject)
  }
  override func actionPerformed(_ e: java.awt.event.ActionEvent) {
    java.lang.System.exit(0)
  }
}
