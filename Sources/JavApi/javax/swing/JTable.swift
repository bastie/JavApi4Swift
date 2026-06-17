/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A component that displays data in a two-dimensional table grid.
  ///
  /// `JTable` renders a `TableModel` via a `TableCellRenderer` (stamp pattern).
  /// Step 1: non-editable display, single-row selection, fixed row height.
  ///
  /// - Since: Java 1.2
  @MainActor
  open class JTable: javax.swing.JComponent {

    // -------------------------------------------------------------------------
    // MARK: Model
    // -------------------------------------------------------------------------

    private var _model: (any javax.swing.table.TableModel)?

    open func getModel() -> (any javax.swing.table.TableModel)? { _model }
    open func setModel(_ model: (any javax.swing.table.TableModel)?) {
      _model = model
      repaint()
    }

    // -------------------------------------------------------------------------
    // MARK: Cell renderer
    // -------------------------------------------------------------------------

    private var _defaultRenderer: (any javax.swing.table.TableCellRenderer) =
      javax.swing.table.DefaultTableCellRenderer()

    open func getDefaultRenderer(forColumn column: Int) -> any javax.swing.table.TableCellRenderer {
      _defaultRenderer
    }
    open func setDefaultRenderer(_ renderer: any javax.swing.table.TableCellRenderer) {
      _defaultRenderer = renderer
      repaint()
    }

    // -------------------------------------------------------------------------
    // MARK: Auto-resize mode
    // -------------------------------------------------------------------------

    /// Mirrors `JTable.AUTO_RESIZE_*` constants from Java.
    public static let AUTO_RESIZE_OFF:                Int = 0
    public static let AUTO_RESIZE_NEXT_COLUMN:        Int = 1
    public static let AUTO_RESIZE_SUBSEQUENT_COLUMNS: Int = 2
    public static let AUTO_RESIZE_LAST_COLUMN:        Int = 3
    public static let AUTO_RESIZE_ALL_COLUMNS:        Int = 4

    private var _autoResizeMode: Int = JTable.AUTO_RESIZE_ALL_COLUMNS
    open func getAutoResizeMode() -> Int       { _autoResizeMode }
    open func setAutoResizeMode(_ m: Int)      { _autoResizeMode = m; repaint() }

    // -------------------------------------------------------------------------
    // MARK: Row / column geometry
    // -------------------------------------------------------------------------

    private var _rowHeight:    Int = 20
    private var _columnWidths: [Int] = []   // preferred / explicit widths

    open func getRowHeight() -> Int  { _rowHeight }
    open func setRowHeight(_ h: Int) { _rowHeight = h }

    /// Returns the *preferred* width of column `col` as set by `setColumnWidth`.
    /// Falls back to an equal share of the component width when none is set.
    open func getColumnWidth(_ col: Int) -> Int {
      if col < _columnWidths.count { return _columnWidths[col] }
      guard let m = _model, m.getColumnCount() > 0 else { return 80 }
      return max(1, bounds.width / m.getColumnCount())
    }

    open func setColumnWidth(_ col: Int, _ width: Int) {
      while _columnWidths.count <= col { _columnWidths.append(80) }
      _columnWidths[col] = width
    }

    /// Returns the *actual rendered* width of column `col`, taking
    /// `autoResizeMode` into account.
    ///
    /// When `AUTO_RESIZE_ALL_COLUMNS` is active (the default) and the table
    /// has a known width, the preferred widths are scaled proportionally so
    /// that the columns fill the component exactly — no horizontal scroll.
    open func getEffectiveColumnWidth(_ col: Int) -> Int {
      guard _autoResizeMode != JTable.AUTO_RESIZE_OFF,
            let m = _model else {
        return getColumnWidth(col)
      }
      let cols = m.getColumnCount()
      guard cols > 0, bounds.width > 0 else { return getColumnWidth(col) }

      // Sum of preferred widths
      let totalPref = (0 ..< cols).reduce(0) { $0 + getColumnWidth($1) }
      guard totalPref > 0 else { return bounds.width / cols }

      // Distribute proportionally; last column absorbs rounding remainder
      let available = bounds.width
      if col == cols - 1 {
        let sumOthers = (0 ..< cols - 1).reduce(0) {
          $0 + max(1, available * getColumnWidth($1) / totalPref)
        }
        return max(1, available - sumOthers)
      }
      return max(1, available * getColumnWidth(col) / totalPref)
    }

    // -------------------------------------------------------------------------
    // MARK: Table header
    // -------------------------------------------------------------------------

    /// The column-header component — place in JScrollPane's column header viewport.
    private lazy var _tableHeader: javax.swing.table.JTableHeader =
      javax.swing.table.JTableHeader(table: self)

    open func getTableHeader() -> javax.swing.table.JTableHeader { _tableHeader }

    // -------------------------------------------------------------------------
    // MARK: Selection (single row)
    // -------------------------------------------------------------------------

    private var _selectedRow: Int = -1

    open func getSelectedRow() -> Int { _selectedRow }
    open func setSelectedRow(_ row: Int) {
      _selectedRow = row
      repaint()
    }
    open func clearSelection() { setSelectedRow(-1) }

    // -------------------------------------------------------------------------
    // MARK: Initializers
    // -------------------------------------------------------------------------

    public override convenience init() {
      self.init(nil as (any javax.swing.table.TableModel)?)
    }

    public init(_ model: (any javax.swing.table.TableModel)?) {
      super.init()
      _model = model
      updateUI()
    }

    /// Convenience: build from column names and row data.
    public convenience init(_ rowData: [[Any?]], _ columnNames: [String]) {
      self.init(javax.swing.table.DefaultTableModel(rowData, columnNames: columnNames))
    }

    // -------------------------------------------------------------------------
    // MARK: UI delegate
    // -------------------------------------------------------------------------

    open override func getUIClassID() -> String { "TableUI" }

    open override func updateUI() {
      if let factory = javax.swing.UIManager.getUI(self) {
        ui = factory
      }
    }



    // -------------------------------------------------------------------------
    // MARK: Mouse — single-row selection
    // -------------------------------------------------------------------------

    open override func processMouseEvent(_ e: java.awt.event.MouseEvent) {
      if e.getID() == java.awt.event.MouseEvent.MOUSE_CLICKED {
        if let ui = ui as? javax.swing.plaf.basic.BasicTableUI {
          let row = ui.rowAtPoint(e.getX(), e.getY(), in: self)
          if row >= 0 { setSelectedRow(row) }
        }
      }
    }
  }
}
