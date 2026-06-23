/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Demonstrates `JSplitPane` with a master/detail layout.
///
/// Left: JTree with a sample project structure (master).
/// Right: JTable showing file details (detail).
@MainActor
class SwingSplitPaneTab {

  static func build() -> java.awt.Component {
    // ── Master (left) — JTree wrapped in JScrollPane ─────────────────────────
    let root = javax.swing.tree.DefaultMutableTreeNode("Projekt")
    let srcNode  = javax.swing.tree.DefaultMutableTreeNode("Sources")
    let resNode  = javax.swing.tree.DefaultMutableTreeNode("Resources")
    let testNode = javax.swing.tree.DefaultMutableTreeNode("Tests")
    root.add(srcNode)
    root.add(resNode)
    root.add(testNode)
    srcNode.add(javax.swing.tree.DefaultMutableTreeNode("Main.swift"))
    srcNode.add(javax.swing.tree.DefaultMutableTreeNode("AppDelegate.swift"))
    resNode.add(javax.swing.tree.DefaultMutableTreeNode("Assets.xcassets"))
    resNode.add(javax.swing.tree.DefaultMutableTreeNode("Info.plist"))
    testNode.add(javax.swing.tree.DefaultMutableTreeNode("AppTests.swift"))
    let tree = javax.swing.JTree(root)
    let masterScroll = javax.swing.JScrollPane(
      tree,
      javax.swing.JScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED,
      javax.swing.JScrollPane.HORIZONTAL_SCROLLBAR_AS_NEEDED)

    // ── Detail (right) — JTable wrapped in JScrollPane ───────────────────────
    let tableModel = javax.swing.table.DefaultTableModel(
      [
        ["Main.swift",          "Swift", "2.1 KB", "2026-06-01"],
        ["AppDelegate.swift",   "Swift", "1.4 KB", "2026-05-28"],
        ["Assets.xcassets",     "Asset", "512 B",  "2026-04-10"],
        ["Info.plist",          "XML",   "800 B",  "2026-04-10"],
        ["AppTests.swift",      "Swift", "3.0 KB", "2026-06-14"],
      ],
      columnNames: ["Name", "Type", "Size", "Modified"])
    let table = javax.swing.JTable(tableModel)
    table.setAutoResizeMode(javax.swing.JTable.AUTO_RESIZE_OFF)
    table.setColumnWidth(0, 150)
    table.setColumnWidth(1, 60)
    table.setColumnWidth(2, 70)
    table.setColumnWidth(3, 100)
    let detailScroll = javax.swing.JScrollPane(
      table,
      javax.swing.JScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED,
      javax.swing.JScrollPane.HORIZONTAL_SCROLLBAR_AS_NEEDED)
    detailScroll.setColumnHeaderView(table.getTableHeader())

    // ── JSplitPane (horizontal: left | right) ─────────────────────────────
    let splitPane = javax.swing.JSplitPane(
      javax.swing.JSplitPane.HORIZONTAL_SPLIT,
      masterScroll,
      detailScroll)
    splitPane.setDividerLocation(180)

    return splitPane
  }
}
