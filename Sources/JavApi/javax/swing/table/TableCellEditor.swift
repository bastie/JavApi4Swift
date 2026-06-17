/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.table {

  /// Defines the interface for objects that can edit a `JTable` cell in place.
  ///
  /// `JTable` calls `getTableCellEditorComponent` to obtain the editing widget
  /// and `getCellEditorValue` to retrieve the edited value when editing stops.
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol TableCellEditor: javax.swing.CellEditor {

    /// Returns the component used to edit the cell.
    ///
    /// - Parameters:
    ///   - table:      The `JTable` being edited.
    ///   - value:      The current cell value.
    ///   - isSelected: Whether the cell is selected.
    ///   - row:        Row index.
    ///   - column:     Column index.
    func getTableCellEditorComponent(
      _ table:      javax.swing.JTable,
      _ value:      Any?,
      _ isSelected: Bool,
      _ row:        Int,
      _ column:     Int
    ) -> java.awt.Component
  }
}
