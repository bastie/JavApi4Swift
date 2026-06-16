/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Demonstrates `JSplitPane` with a master/detail layout.
///
/// Left: JTree with a sample project structure.
/// Right: Placeholder for the future JTable detail view.
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
    let masterScroll = javax.swing.JScrollPane(tree)

    // ── Detail (right) — placeholder for JTable, wrapped in JScrollPane ──────
    let detailPanel = javax.swing.JPanel(java.awt.BorderLayout())
    let detailLabel = javax.swing.JLabel("Detail (JTable – coming soon)")
    detailLabel.setHorizontalAlignment(javax.swing.JLabel.CENTER)
    detailPanel.add(detailLabel, java.awt.BorderLayout.CENTER)
    detailPanel.setBackground(java.awt.Color(255, 245, 225))
    let detailScroll = javax.swing.JScrollPane(detailPanel)

    // ── JSplitPane (horizontal: left | right) ─────────────────────────────
    let splitPane = javax.swing.JSplitPane(
      javax.swing.JSplitPane.HORIZONTAL_SPLIT,
      masterScroll,
      detailScroll)
    splitPane.setDividerLocation(180)

    return splitPane
  }
}
