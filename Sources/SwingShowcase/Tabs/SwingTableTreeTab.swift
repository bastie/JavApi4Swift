/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Builds the "Table & Tree" tab for the SwingShowcase.
///
/// Demonstrates:
/// - `TableColumn` / `TableColumnModel` / `DefaultTableColumnModel`
///   (column resizing, reordering, per-column renderer)
/// - `TreeSelectionModel` with all three selection modes
///   (`SINGLE_TREE_SELECTION`, `CONTIGUOUS_TREE_SELECTION`,
///    `DISCONTIGUOUS_TREE_SELECTION`)
@MainActor
class SwingTableTreeTab {

  static func build() -> javax.swing.JPanel {
    let panel = javax.swing.JPanel(java.awt.BorderLayout(4, 4))

    let splitPane = javax.swing.JSplitPane(
      javax.swing.JSplitPane.HORIZONTAL_SPLIT,
      buildTablePanel(),
      buildTreePanel())
    splitPane.setDividerLocation(340)
    splitPane.setResizeWeight(0.5)

    panel.add(splitPane, java.awt.BorderLayout.CENTER)
    return panel
  }

  // ---------------------------------------------------------------------------
  // MARK: Left — JTable with TableColumn / DefaultTableColumnModel
  // ---------------------------------------------------------------------------

  @MainActor
  private static func buildTablePanel() -> javax.swing.JPanel {
    let panel = javax.swing.JPanel(java.awt.BorderLayout(2, 2))

    let titleLabel = javax.swing.JLabel("JTable + TableColumnModel")
    titleLabel.setBorder(javax.swing.border.EmptyBorder(4, 6, 2, 6))
    panel.add(titleLabel, java.awt.BorderLayout.NORTH)

    // ── Data model ────────────────────────────────────────────────────────
    let model = javax.swing.table.DefaultTableModel(
      [
        ["Alice",   "Engineering", "Senior",  "92 000"],
        ["Bob",     "Marketing",   "Junior",  "58 000"],
        ["Carol",   "Engineering", "Lead",    "115 000"],
        ["Dave",    "HR",          "Manager", "78 000"],
        ["Eve",     "Engineering", "Senior",  "98 000"],
        ["Frank",   "Finance",     "Junior",  "54 000"],
      ],
      columnNames: ["Name", "Department", "Level", "Salary (€)"])

    // ── Column model with explicit TableColumn objects ─────────────────────
    let columnModel = javax.swing.table.DefaultTableColumnModel()

    let colName = javax.swing.table.TableColumn(modelIndex: 0, width: 90)
    colName.setHeaderValue("Name")
    columnModel.addColumn(colName)

    let colDept = javax.swing.table.TableColumn(modelIndex: 1, width: 110)
    colDept.setHeaderValue("Department")
    columnModel.addColumn(colDept)

    let colLevel = javax.swing.table.TableColumn(modelIndex: 2, width: 70)
    colLevel.setHeaderValue("Level")
    columnModel.addColumn(colLevel)

    let colSalary = javax.swing.table.TableColumn(modelIndex: 3, width: 90)
    colSalary.setHeaderValue("Salary (€)")
    columnModel.addColumn(colSalary)

    // ── JTable ────────────────────────────────────────────────────────────
    let table = javax.swing.JTable(model)
    table.setAutoResizeMode(javax.swing.JTable.AUTO_RESIZE_OFF)
    for i in 0..<columnModel.getColumnCount() {
      table.setColumnWidth(i, columnModel.getColumn(i).getWidth())
    }
    table.setRowHeight(22)

    let scroll = javax.swing.JScrollPane(table)
    scroll.setColumnHeaderView(table.getTableHeader())
    panel.add(scroll, java.awt.BorderLayout.CENTER)

    // ── Controls ──────────────────────────────────────────────────────────
    let controls = javax.swing.JPanel(java.awt.FlowLayout(java.awt.FlowLayout.LEFT, 4, 4))

    let addBtn = javax.swing.JButton("Add Row")
    addBtn.addActionListener(SwingTableAddRowAction(model: model))
    controls.add(addBtn)

    let delBtn = javax.swing.JButton("Delete Selected")
    delBtn.addActionListener(SwingTableDeleteRowAction(model: model, table: table))
    controls.add(delBtn)

    controls.add(javax.swing.JLabel("Columns: \(columnModel.getColumnCount())"))

    panel.add(controls, java.awt.BorderLayout.SOUTH)
    return panel
  }

  // ---------------------------------------------------------------------------
  // MARK: Right — JTree with TreeSelectionModel
  // ---------------------------------------------------------------------------

  @MainActor
  private static func buildTreePanel() -> javax.swing.JPanel {
    let panel = javax.swing.JPanel(java.awt.BorderLayout(2, 2))

    let titleLabel = javax.swing.JLabel("JTree + TreeSelectionModel")
    titleLabel.setBorder(javax.swing.border.EmptyBorder(4, 6, 2, 6))
    panel.add(titleLabel, java.awt.BorderLayout.NORTH)

    // ── Tree model ────────────────────────────────────────────────────────
    let root = javax.swing.tree.DefaultMutableTreeNode("World")

    let europe = javax.swing.tree.DefaultMutableTreeNode("Europe")
    europe.add(javax.swing.tree.DefaultMutableTreeNode("Germany"))
    europe.add(javax.swing.tree.DefaultMutableTreeNode("France"))
    europe.add(javax.swing.tree.DefaultMutableTreeNode("Italy"))
    europe.add(javax.swing.tree.DefaultMutableTreeNode("Spain"))
    root.add(europe)

    let americas = javax.swing.tree.DefaultMutableTreeNode("Americas")
    americas.add(javax.swing.tree.DefaultMutableTreeNode("USA"))
    americas.add(javax.swing.tree.DefaultMutableTreeNode("Canada"))
    americas.add(javax.swing.tree.DefaultMutableTreeNode("Brazil"))
    root.add(americas)

    let asia = javax.swing.tree.DefaultMutableTreeNode("Asia")
    asia.add(javax.swing.tree.DefaultMutableTreeNode("Japan"))
    asia.add(javax.swing.tree.DefaultMutableTreeNode("China"))
    asia.add(javax.swing.tree.DefaultMutableTreeNode("India"))
    root.add(asia)

    let tree = javax.swing.JTree(root)
    tree.setRootVisible(true)

    // ── TreeSelectionModel ────────────────────────────────────────────────
    let selModel = javax.swing.tree.DefaultTreeSelectionModel()
    selModel.setSelectionMode(
      javax.swing.tree.DefaultTreeSelectionModel.DISCONTIGUOUS_TREE_SELECTION)
    tree.setSelectionModel(selModel)

    // Selection info label
    let selLabel = javax.swing.JLabel("Selection: —")
    selLabel.setBorder(javax.swing.border.EmptyBorder(2, 6, 2, 6))

    tree.addTreeSelectionListener(TableTreeSelectionListener(label: selLabel))

    let scroll = javax.swing.JScrollPane(tree)
    panel.add(scroll, java.awt.BorderLayout.CENTER)

    // ── Selection mode selector ───────────────────────────────────────────
    let controls = javax.swing.JPanel(java.awt.BorderLayout(2, 0))

    let modePanel = javax.swing.JPanel(java.awt.FlowLayout(java.awt.FlowLayout.LEFT, 4, 2))
    modePanel.add(javax.swing.JLabel("Mode:"))

    let modeCombo = javax.swing.JComboBox<String>(
      ["DISCONTIGUOUS", "SINGLE", "CONTIGUOUS"])
    modeCombo.addItemListener(
      SwingTableTreeModeListener(selModel: selModel, selLabel: selLabel, modeCombo: modeCombo))
    modePanel.add(modeCombo)

    controls.add(modePanel, java.awt.BorderLayout.NORTH)
    controls.add(selLabel, java.awt.BorderLayout.SOUTH)
    panel.add(controls, java.awt.BorderLayout.SOUTH)

    return panel
  }
}

// ---------------------------------------------------------------------------
// MARK: TreeSelectionListener (file-private)
// ---------------------------------------------------------------------------

@MainActor
private class TableTreeSelectionListener: javax.swing.event.TreeSelectionListener {

  private let label: javax.swing.JLabel

  init(label: javax.swing.JLabel) { self.label = label }

  func valueChanged(_ e: javax.swing.event.TreeSelectionEvent) {
    let paths = e.getPaths()
    let selected = paths
      .filter { e.isAddedPath($0) }
      .map { "\($0.getLastPathComponent())" }
    if selected.isEmpty {
      label.setText("Selection: —")
    } else {
      label.setText("Selection: " + selected.joined(separator: ", "))
    }
  }
}
