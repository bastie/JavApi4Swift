/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Switches the showcase to the "Dialogs" tab.
@MainActor
final class SwingDialogsAction: SwingShowcaseAction {
  private weak var tabs: javax.swing.JTabbedPane?

  init(tabs: javax.swing.JTabbedPane) {
    self.tabs = tabs
    super.init("Dialogs")
    if let icon = SwingDialogsAction.toolbarIcon(named: "toolbar-dialog") {
      putValue(SwingDialogsAction.SMALL_ICON, icon)
    }
    putValue(SwingDialogsAction.SHORT_DESCRIPTION,
             "Show Dialogs tab (JOptionPane, JFileChooser, JColorChooser)" as AnyObject)
  }

  override func actionPerformed(_ e: java.awt.event.ActionEvent) {
    guard let tabs else { return }
    for i in 0..<tabs.getTabCount() {
      if tabs.getTitleAt(i) == "Dialogs" {
        tabs.setSelectedIndex(i)
        return
      }
    }
  }
}
