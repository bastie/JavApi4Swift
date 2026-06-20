/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.table {

  /// The interface that defines the data model for a `JTable`'s column
  /// structure.
  ///
  /// `TableColumnModel` manages an ordered list of `TableColumn` objects and
  /// fires `TableColumnModelEvent` notifications to registered
  /// `TableColumnModelListener`s whenever the column set changes.
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol TableColumnModel: AnyObject {

    // -------------------------------------------------------------------------
    // MARK: Column access
    // -------------------------------------------------------------------------

    /// Returns the number of columns.
    func getColumnCount() -> Int

    /// Returns the `TableColumn` at `columnIndex`.
    func getColumn(_ columnIndex: Int) -> javax.swing.table.TableColumn

    /// Returns the index of the column with the given identifier, or -1.
    func getColumnIndex(_ identifier: AnyObject) -> Int

    /// Returns the total width of all columns (sum of preferred widths).
    func getTotalColumnWidth() -> Int

    // -------------------------------------------------------------------------
    // MARK: Column mutation
    // -------------------------------------------------------------------------

    /// Appends `column` to the end of the column list.
    func addColumn(_ column: javax.swing.table.TableColumn)

    /// Removes `column` from the column list.
    func removeColumn(_ column: javax.swing.table.TableColumn)

    /// Moves the column at `columnIndex` to `newIndex`.
    func moveColumn(_ columnIndex: Int, _ newIndex: Int)

    // -------------------------------------------------------------------------
    // MARK: Column spacing
    // -------------------------------------------------------------------------

    /// Returns the inter-column spacing in pixels.
    func getColumnMargin() -> Int

    /// Sets the inter-column spacing.
    func setColumnMargin(_ newMargin: Int)

    // -------------------------------------------------------------------------
    // MARK: Column selection
    // -------------------------------------------------------------------------

    /// Returns `true` if column selection is allowed.
    func getColumnSelectionAllowed() -> Bool

    /// Enables or disables column selection.
    func setColumnSelectionAllowed(_ flag: Bool)

    /// Returns the number of selected columns.
    func getSelectedColumnCount() -> Int

    /// Returns the indices of all selected columns.
    func getSelectedColumns() -> [Int]

    // -------------------------------------------------------------------------
    // MARK: Listeners
    // -------------------------------------------------------------------------

    func addColumnModelListener(_ l: javax.swing.event.TableColumnModelListener)
    func removeColumnModelListener(_ l: javax.swing.event.TableColumnModelListener)
  }
}
