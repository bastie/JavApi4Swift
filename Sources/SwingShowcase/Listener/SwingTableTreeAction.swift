/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Switches the showcase to the "Table & Tree" tab.
@MainActor
final class SwingTableTreeAction: SwingShowcaseAction {
  private weak var tabs: javax.swing.JTabbedPane?

  init(tabs: javax.swing.JTabbedPane) {
    self.tabs = tabs
    super.init("Table & Tree")
    if let icon = SwingTableTreeAction.toolbarIcon(named: "toolbar-table") {
      putValue(SwingTableTreeAction.SMALL_ICON, icon)
    }
    putValue(SwingTableTreeAction.SHORT_DESCRIPTION,
             "Show Table & Tree tab (TableColumn, TreeSelectionModel)" as AnyObject)
  }

  override func actionPerformed(_ e: java.awt.event.ActionEvent) {
    guard let tabs else { return }
    // Find the tab by title in case the order ever changes
    for i in 0..<tabs.getTabCount() {
      if tabs.getTitleAt(i) == "Table & Tree" {
        tabs.setSelectedIndex(i)
        return
      }
    }
  }
}
