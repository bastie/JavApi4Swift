/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Demonstrates `JSplitPane` with a master/detail layout.
///
/// The left pane is a placeholder for the future `JTree` master view;
/// the right pane is a placeholder for the future `JTable` detail view.
/// Replace the placeholder panels once `JTree` and `JTable` are implemented.
@MainActor
class SwingSplitPaneTab {

  static func build() -> java.awt.Component {
    // ── Master (left) — placeholder for JTree, wrapped in JScrollPane ────────
    let masterPanel = javax.swing.JPanel(java.awt.BorderLayout())
    let masterLabel = javax.swing.JLabel("Master (JTree – coming soon)")
    masterLabel.setHorizontalAlignment(javax.swing.JLabel.CENTER)
    masterPanel.add(masterLabel, java.awt.BorderLayout.CENTER)
    masterPanel.setBackground(java.awt.Color(230, 240, 255))
    let masterScroll = javax.swing.JScrollPane(masterPanel)

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
