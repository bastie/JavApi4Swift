/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.table {

  /// Defines the interface for an object that renders a single table cell.
  ///
  /// `JTable` calls `getTableCellRendererComponent` for each visible cell.
  /// The returned `Component` is painted by the UI delegate as a stamp —
  /// it is never added to the component hierarchy.
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol TableCellRenderer: AnyObject {

    /// Returns a component configured to render the given cell.
    ///
    /// - Parameters:
    ///   - table:      The `JTable` being painted.
    ///   - value:      The cell value.
    ///   - isSelected: Whether the cell's row is selected.
    ///   - hasFocus:   Whether the cell has keyboard focus.
    ///   - row:        Row index.
    ///   - column:     Column index.
    func getTableCellRendererComponent(
      _ table:      javax.swing.JTable,
      _ value:      Any?,
      _ isSelected: Bool,
      _ hasFocus:   Bool,
      _ row:        Int,
      _ column:     Int
    ) -> java.awt.Component
  }
}
