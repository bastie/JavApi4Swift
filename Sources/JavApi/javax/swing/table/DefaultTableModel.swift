/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.table {

  /// The default implementation of `TableModel`.
  ///
  /// Data is stored as a two-dimensional array (`[[Any?]]`).
  /// Column names are stored separately; if no names are provided, columns
  /// are labelled `"A"`, `"B"`, `"C"`, … (Java uses numeric indices by default,
  /// but letter labels are more readable and match spreadsheet convention).
  ///
  /// All mutations fire the appropriate `TableModelEvent`.
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
  open class DefaultTableModel: javax.swing.table.TableModel {

    // -------------------------------------------------------------------------
    // MARK: Storage
    // -------------------------------------------------------------------------

    private var dataVector:   [[Any?]]
    private var columnNames:  [String]
    private var listeners:    [javax.swing.event.TableModelListener] = []

    // -------------------------------------------------------------------------
    // MARK: Initializers
    // -------------------------------------------------------------------------

    /// Creates an empty model with `rowCount` empty rows and `columnCount` columns.
    public init(rowCount: Int = 0, columnCount: Int = 0) {
      columnNames = (0..<columnCount).map { DefaultTableModel.defaultColumnName($0) }
      dataVector  = Array(repeating: Array(repeating: nil, count: columnCount),
                          count: rowCount)
    }

    /// Creates a model from existing data and column names.
    public init(_ data: [[Any?]], columnNames: [String]) {
      self.columnNames = columnNames
      self.dataVector  = data
    }

    /// Creates a model with the given column names and `rowCount` empty rows.
    public init(columnNames: [String], rowCount: Int = 0) {
      self.columnNames = columnNames
      self.dataVector  = Array(repeating: Array(repeating: nil, count: columnNames.count),
                               count: rowCount)
    }

    // -------------------------------------------------------------------------
    // MARK: TableModel — counts
    // -------------------------------------------------------------------------

    open func getRowCount()    -> Int { dataVector.count }
    open func getColumnCount() -> Int { columnNames.count }

    // -------------------------------------------------------------------------
    // MARK: TableModel — column names
    // -------------------------------------------------------------------------

    open func getColumnName(_ columnIndex: Int) -> String {
      guard columnIndex >= 0, columnIndex < columnNames.count else {
        return DefaultTableModel.defaultColumnName(columnIndex)
      }
      return columnNames[columnIndex]
    }

    open func setColumnName(_ columnIndex: Int, _ name: String) {
      guard columnIndex >= 0, columnIndex < columnNames.count else { return }
      columnNames[columnIndex] = name
      fireTableChanged(javax.swing.event.TableModelEvent(
        self,
        firstRow: javax.swing.event.TableModelEvent.HEADER_ROW,
        lastRow:  javax.swing.event.TableModelEvent.HEADER_ROW))
    }

    // -------------------------------------------------------------------------
    // MARK: TableModel — cell access
    // -------------------------------------------------------------------------

    open func getValueAt(_ rowIndex: Int, _ columnIndex: Int) -> Any? {
      guard rowIndex >= 0, rowIndex < dataVector.count,
            columnIndex >= 0, columnIndex < columnNames.count else { return nil }
      return dataVector[rowIndex][columnIndex]
    }

    open func setValueAt(_ value: Any?, _ rowIndex: Int, _ columnIndex: Int) {
      guard rowIndex >= 0, rowIndex < dataVector.count,
            columnIndex >= 0, columnIndex < columnNames.count else { return }
      dataVector[rowIndex][columnIndex] = value
      fireTableCellUpdated(rowIndex, columnIndex)
    }

    open func isCellEditable(_ rowIndex: Int, _ columnIndex: Int) -> Bool { true }

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

    /// Removes all rows.
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
    // MARK: Listeners
    // -------------------------------------------------------------------------

    open func addTableModelListener(_ l: javax.swing.event.TableModelListener) {
      listeners.append(l)
    }

    open func removeTableModelListener(_ l: javax.swing.event.TableModelListener) {
      listeners.removeAll { $0 === (l as AnyObject) }
    }

    // -------------------------------------------------------------------------
    // MARK: Fire helpers
    // -------------------------------------------------------------------------

    open func fireTableChanged(_ e: javax.swing.event.TableModelEvent) {
      for l in listeners { l.tableChanged(e) }
    }

    open func fireTableDataChanged() {
      fireTableChanged(javax.swing.event.TableModelEvent.allChanged(self))
    }

    open func fireTableCellUpdated(_ row: Int, _ column: Int) {
      fireTableChanged(javax.swing.event.TableModelEvent(
        self, firstRow: row, lastRow: row, column: column,
        type: javax.swing.event.TableModelEvent.UPDATE))
    }

    open func fireTableRowsInserted(_ firstRow: Int, _ lastRow: Int) {
      fireTableChanged(javax.swing.event.TableModelEvent(
        self, firstRow: firstRow, lastRow: lastRow,
        column: javax.swing.event.TableModelEvent.ALL_COLUMNS,
        type: javax.swing.event.TableModelEvent.INSERT))
    }

    open func fireTableRowsDeleted(_ firstRow: Int, _ lastRow: Int) {
      fireTableChanged(javax.swing.event.TableModelEvent(
        self, firstRow: firstRow, lastRow: lastRow,
        column: javax.swing.event.TableModelEvent.ALL_COLUMNS,
        type: javax.swing.event.TableModelEvent.DELETE))
    }

    open func fireTableRowsUpdated(_ firstRow: Int, _ lastRow: Int) {
      fireTableChanged(javax.swing.event.TableModelEvent(
        self, firstRow: firstRow, lastRow: lastRow,
        column: javax.swing.event.TableModelEvent.ALL_COLUMNS,
        type: javax.swing.event.TableModelEvent.UPDATE))
    }

    // -------------------------------------------------------------------------
    // MARK: Private helpers
    // -------------------------------------------------------------------------

    private func padded(_ row: [Any?]) -> [Any?] {
      let count = columnNames.count
      if row.count >= count { return Array(row.prefix(count)) }
      return row + Array(repeating: nil, count: count - row.count)
    }

    private static func defaultColumnName(_ index: Int) -> String {
      // A, B, …, Z, AA, AB, … (spreadsheet style)
      var result = ""
      var i = index
      repeat {
        result = String(UnicodeScalar(65 + (i % 26))!) + result
        i = i / 26 - 1
      } while i >= 0
      return result
    }
  }
}
