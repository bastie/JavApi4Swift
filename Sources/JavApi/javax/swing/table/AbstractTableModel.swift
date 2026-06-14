/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.table {

  /// Abstract base class for `TableModel` implementations.
  ///
  /// `AbstractTableModel` provides listener management and all fire-helpers.
  /// Subclasses must implement:
  /// - `getRowCount() -> Int`
  /// - `getColumnCount() -> Int`
  /// - `getValueAt(_:_:) -> Any?`
  ///
  /// Default implementations are provided for `getColumnName(_:)` (A, B, …),
  /// `isCellEditable(_:_:)` (returns `false`), and `setValueAt(_:_:_:)` (no-op).
  ///
  /// - Since: Java 1.2
  @MainActor
  open class AbstractTableModel: javax.swing.table.TableModel {

    // -------------------------------------------------------------------------
    // MARK: Listeners
    // -------------------------------------------------------------------------

    private var listeners: [javax.swing.event.TableModelListener] = []

    public init() {}

    // -------------------------------------------------------------------------
    // MARK: TableModel — subclass must override
    // -------------------------------------------------------------------------

    open func getRowCount() -> Int {
      fatalError("\(type(of: self)).getRowCount() must be overridden")
    }

    open func getColumnCount() -> Int {
      fatalError("\(type(of: self)).getColumnCount() must be overridden")
    }

    open func getValueAt(_ rowIndex: Int, _ columnIndex: Int) -> Any? {
      fatalError("\(type(of: self)).getValueAt(_:_:) must be overridden")
    }

    // -------------------------------------------------------------------------
    // MARK: TableModel — defaults
    // -------------------------------------------------------------------------

    /// Default: spreadsheet-style column names (A, B, … Z, AA, …).
    open func getColumnName(_ columnIndex: Int) -> String {
      AbstractTableModel.defaultColumnName(columnIndex)
    }

    /// Default: returns `Any.self` (equivalent to Java's `Object.class`).
    open func getColumnClass(_ columnIndex: Int) -> Any.Type { Any.self }

    /// Default: cells are not editable.
    open func isCellEditable(_ rowIndex: Int, _ columnIndex: Int) -> Bool { false }

    /// Default: no-op (override together with `isCellEditable`).
    open func setValueAt(_ value: Any?, _ rowIndex: Int, _ columnIndex: Int) {}

    // -------------------------------------------------------------------------
    // MARK: TableModel — listeners
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

    open func fireTableStructureChanged() {
      fireTableChanged(javax.swing.event.TableModelEvent(
        self,
        firstRow: javax.swing.event.TableModelEvent.HEADER_ROW,
        lastRow:  javax.swing.event.TableModelEvent.HEADER_ROW,
        column:   javax.swing.event.TableModelEvent.ALL_COLUMNS,
        type:     javax.swing.event.TableModelEvent.UPDATE))
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
    // MARK: Column name helper (shared with DefaultTableModel)
    // -------------------------------------------------------------------------

    internal static func defaultColumnName(_ index: Int) -> String {
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
