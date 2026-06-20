/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.table {

  /// The default implementation of `TableColumnModel`.
  ///
  /// Manages an ordered list of `TableColumn` objects and fires
  /// `TableColumnModelEvent` notifications to registered listeners.
  ///
  /// - Since: Java 1.2
  @MainActor
  open class DefaultTableColumnModel: javax.swing.table.TableColumnModel {

    // -------------------------------------------------------------------------
    // MARK: Storage
    // -------------------------------------------------------------------------

    private var columns:  [javax.swing.table.TableColumn] = []
    private var listeners: [javax.swing.event.TableColumnModelListener] = []
    private var _columnMargin:            Int  = 1
    private var _columnSelectionAllowed:  Bool = false
    private var selectedColumns_:         Set<Int> = []

    public init() {}

    // -------------------------------------------------------------------------
    // MARK: TableColumnModel — column access
    // -------------------------------------------------------------------------

    open func getColumnCount() -> Int { columns.count }

    open func getColumn(_ columnIndex: Int) -> javax.swing.table.TableColumn {
      columns[columnIndex]
    }

    open func getColumnIndex(_ identifier: AnyObject) -> Int {
      for (i, col) in columns.enumerated() {
        if let id = col.getIdentifier(), id === identifier { return i }
      }
      return -1
    }

    open func getTotalColumnWidth() -> Int {
      columns.reduce(0) { $0 + $1.getWidth() }
    }

    // -------------------------------------------------------------------------
    // MARK: TableColumnModel — column mutation
    // -------------------------------------------------------------------------

    open func addColumn(_ column: javax.swing.table.TableColumn) {
      columns.append(column)
      let idx = columns.count - 1
      fireColumnAdded(javax.swing.event.TableColumnModelEvent(self, 0, idx))
    }

    open func removeColumn(_ column: javax.swing.table.TableColumn) {
      guard let idx = columns.firstIndex(where: { $0 === column }) else { return }
      columns.remove(at: idx)
      fireColumnRemoved(javax.swing.event.TableColumnModelEvent(self, idx, 0))
    }

    open func moveColumn(_ columnIndex: Int, _ newIndex: Int) {
      guard columnIndex != newIndex else { return }
      let col = columns.remove(at: columnIndex)
      columns.insert(col, at: newIndex)
      fireColumnMoved(javax.swing.event.TableColumnModelEvent(self, columnIndex, newIndex))
    }

    // -------------------------------------------------------------------------
    // MARK: TableColumnModel — margin
    // -------------------------------------------------------------------------

    open func getColumnMargin() -> Int { _columnMargin }
    open func setColumnMargin(_ newMargin: Int) {
      _columnMargin = newMargin
      fireColumnMarginChanged()
    }

    // -------------------------------------------------------------------------
    // MARK: TableColumnModel — selection
    // -------------------------------------------------------------------------

    open func getColumnSelectionAllowed() -> Bool { _columnSelectionAllowed }
    open func setColumnSelectionAllowed(_ flag: Bool) { _columnSelectionAllowed = flag }

    open func getSelectedColumnCount() -> Int { selectedColumns_.count }
    open func getSelectedColumns() -> [Int]   { Array(selectedColumns_).sorted() }

    open func selectColumn(_ columnIndex: Int) {
      selectedColumns_.insert(columnIndex)
      fireColumnSelectionChanged()
    }

    open func clearColumnSelection() {
      selectedColumns_.removeAll()
      fireColumnSelectionChanged()
    }

    // -------------------------------------------------------------------------
    // MARK: TableColumnModel — listeners
    // -------------------------------------------------------------------------

    open func addColumnModelListener(_ l: javax.swing.event.TableColumnModelListener) {
      listeners.append(l)
    }
    open func removeColumnModelListener(_ l: javax.swing.event.TableColumnModelListener) {
      listeners.removeAll { $0 === (l as AnyObject) }
    }

    // -------------------------------------------------------------------------
    // MARK: Fire helpers
    // -------------------------------------------------------------------------

    open func fireColumnAdded(_ e: javax.swing.event.TableColumnModelEvent) {
      for l in listeners { l.columnAdded(e) }
    }
    open func fireColumnRemoved(_ e: javax.swing.event.TableColumnModelEvent) {
      for l in listeners { l.columnRemoved(e) }
    }
    open func fireColumnMoved(_ e: javax.swing.event.TableColumnModelEvent) {
      for l in listeners { l.columnMoved(e) }
    }
    open func fireColumnMarginChanged() {
      let e = javax.swing.event.ChangeEvent(self)
      for l in listeners { l.columnMarginChanged(e) }
    }
    open func fireColumnSelectionChanged() {
      let e = javax.swing.event.ListSelectionEvent(self, 0, columns.count - 1, false)
      for l in listeners { l.columnSelectionChanged(e) }
    }
  }
}
