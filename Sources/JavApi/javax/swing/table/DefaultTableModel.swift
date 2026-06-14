/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.table {

  /// The default implementation of `TableModel`, extending `AbstractTableModel`.
  ///
  /// Data is stored as a two-dimensional array (`[[Any?]]`).
  /// Column names are stored separately; if no names are provided, columns
  /// are labelled `"A"`, `"B"`, `"C"`, … (spreadsheet convention).
  ///
  /// All mutations fire the appropriate `TableModelEvent` via the
  /// fire-helpers inherited from `AbstractTableModel`.
  ///
  /// ## Example
  ///
  /// ```swift
  /// let model = javax.swing.table.DefaultTableModel(
  ///   [["Alice", 30], ["Bob", 25]],
  ///   columnNames: ["Name", "Age"])
  /// model.getValueAt(0, 0) // "Alice"
  /// model.addRow(["Carol", 28])
  /// model.getRowCount() // 3
  /// ```
  ///
  /// - Since: Java 1.2
  @MainActor
  open class DefaultTableModel: javax.swing.table.AbstractTableModel {

    // -------------------------------------------------------------------------
    // MARK: Storage
    // -------------------------------------------------------------------------

    private var dataVector:  [[Any?]]
    private var columnNames: [String]

    // -------------------------------------------------------------------------
    // MARK: Initializers
    // -------------------------------------------------------------------------

    /// Creates an empty model with `rowCount` empty rows and `columnCount` columns.
    public init(rowCount: Int = 0, columnCount: Int = 0) {
      columnNames = (0..<columnCount).map { AbstractTableModel.defaultColumnName($0) }
      dataVector  = Array(repeating: Array(repeating: nil, count: columnCount),
                          count: rowCount)
      super.init()
    }

    /// Creates a model from existing data and column names.
    public init(_ data: [[Any?]], columnNames: [String]) {
      self.columnNames = columnNames
      self.dataVector  = data
      super.init()
    }

    /// Creates a model with the given column names and `rowCount` empty rows.
    public init(columnNames: [String], rowCount: Int = 0) {
      self.columnNames = columnNames
      self.dataVector  = Array(repeating: Array(repeating: nil, count: columnNames.count),
                               count: rowCount)
      super.init()
    }

    // -------------------------------------------------------------------------
    // MARK: AbstractTableModel — overrides
    // -------------------------------------------------------------------------

    override open func getRowCount()    -> Int { dataVector.count }
    override open func getColumnCount() -> Int { columnNames.count }

    override open func getColumnName(_ columnIndex: Int) -> String {
      guard columnIndex >= 0, columnIndex < columnNames.count else {
        return AbstractTableModel.defaultColumnName(columnIndex)
      }
      return columnNames[columnIndex]
    }

    override open func getValueAt(_ rowIndex: Int, _ columnIndex: Int) -> Any? {
      guard rowIndex >= 0, rowIndex < dataVector.count,
            columnIndex >= 0, columnIndex < columnNames.count else { return nil }
      return dataVector[rowIndex][columnIndex]
    }

    override open func setValueAt(_ value: Any?, _ rowIndex: Int, _ columnIndex: Int) {
      guard rowIndex >= 0, rowIndex < dataVector.count,
            columnIndex >= 0, columnIndex < columnNames.count else { return }
      dataVector[rowIndex][columnIndex] = value
      fireTableCellUpdated(rowIndex, columnIndex)
    }

    /// Default: all cells are editable (Java default for `DefaultTableModel`).
    override open func isCellEditable(_ rowIndex: Int, _ columnIndex: Int) -> Bool { true }

    // -------------------------------------------------------------------------
    // MARK: Column name mutation
    // -------------------------------------------------------------------------

    open func setColumnName(_ columnIndex: Int, _ name: String) {
      guard columnIndex >= 0, columnIndex < columnNames.count else { return }
      columnNames[columnIndex] = name
      fireTableStructureChanged()
    }

    // -------------------------------------------------------------------------
    // MARK: Row mutation
    // -------------------------------------------------------------------------

    /// Appends a new row with `rowData` (padded/truncated to column count).
    open func addRow(_ rowData: [Any?]) {
      let row = padded(rowData)
      dataVector.append(row)
      let idx = dataVector.count - 1
      fireTableRowsInserted(idx, idx)
    }

    /// Inserts a new row at `index`.
    open func insertRow(_ index: Int, rowData: [Any?]) {
      let row = padded(rowData)
      dataVector.insert(row, at: index)
      fireTableRowsInserted(index, index)
    }

    /// Removes the row at `index`.
    open func removeRow(_ index: Int) {
      dataVector.remove(at: index)
      fireTableRowsDeleted(index, index)
    }

    /// Adjusts the row count; removes or appends empty rows as needed.
    open func setRowCount(_ rowCount: Int) {
      let oldCount = dataVector.count
      if rowCount < oldCount {
        dataVector.removeLast(oldCount - rowCount)
        fireTableRowsDeleted(rowCount, oldCount - 1)
      } else if rowCount > oldCount {
        let newRows = Array(repeating: Array(repeating: nil as Any?, count: columnNames.count),
                            count: rowCount - oldCount)
        dataVector.append(contentsOf: newRows)
        fireTableRowsInserted(oldCount, rowCount - 1)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Private helpers
    // -------------------------------------------------------------------------

    private func padded(_ row: [Any?]) -> [Any?] {
      let count = columnNames.count
      if row.count >= count { return Array(row.prefix(count)) }
      return row + Array(repeating: nil, count: count - row.count)
    }
  }
}
