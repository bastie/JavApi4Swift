/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.table {

  /// The data model for a `JTable`.
  ///
  /// `TableModel` defines the rectangular grid of data a `JTable` displays.
  /// It provides row/column counts, cell values, column names, cell
  /// editability, and column class information.
  ///
  /// Implementations fire `TableModelEvent` notifications to registered
  /// `TableModelListener`s whenever the data changes.
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol TableModel: AnyObject {

    /// Returns the number of rows.
    func getRowCount() -> Int

    /// Returns the number of columns.
    func getColumnCount() -> Int

    /// Returns the name of column `columnIndex`.
    func getColumnName(_ columnIndex: Int) -> String

    /// Returns the value at `(rowIndex, columnIndex)`.
    func getValueAt(_ rowIndex: Int, _ columnIndex: Int) -> Any?

    /// Sets the value at `(rowIndex, columnIndex)`.
    func setValueAt(_ value: Any?, _ rowIndex: Int, _ columnIndex: Int)

    /// Returns `true` if the cell at `(rowIndex, columnIndex)` is editable.
    func isCellEditable(_ rowIndex: Int, _ columnIndex: Int) -> Bool

    func addTableModelListener(_ l: javax.swing.event.TableModelListener)
    func removeTableModelListener(_ l: javax.swing.event.TableModelListener)
  }
}
