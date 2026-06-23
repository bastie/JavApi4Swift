/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.table {

  /// The column-header component for a `JTable`.
  ///
  /// `JTableHeader` is placed in the column-header viewport of a `JScrollPane`
  /// so it stays fixed while the table body scrolls vertically.
  ///
  /// Painting is delegated to `BasicTableHeaderUI` following the standard
  /// UI-delegate pattern.
  ///
  /// - Since: Java 1.2
  @MainActor
  open class JTableHeader: javax.swing.JComponent {

    // -------------------------------------------------------------------------
    // MARK: Table reference
    // -------------------------------------------------------------------------

    /// The table this header belongs to.  Weak to avoid retain cycles.
    private weak var _table: javax.swing.JTable?

    open func getTable() -> javax.swing.JTable? { _table }

    // -------------------------------------------------------------------------
    // MARK: Column model access (delegated to the table's model)
    // -------------------------------------------------------------------------

    /// Returns the column count from the table model.
    open func getColumnCount() -> Int {
      _table?.getModel()?.getColumnCount() ?? 0
    }

    /// Returns the name of column `col` from the table model.
    open func getColumnName(_ col: Int) -> String {
      _table?.getModel()?.getColumnName(col) ?? ""
    }

    /// Returns the preferred width of column `col` as configured on the table.
    open func getColumnWidth(_ col: Int) -> Int {
      _table?.getColumnWidth(col) ?? 80
    }

    /// Returns the effective (AUTO_RESIZE-scaled) width of column `col`.
    open func getEffectiveColumnWidth(_ col: Int) -> Int {
      _table?.getEffectiveColumnWidth(col) ?? getColumnWidth(col)
    }

    // -------------------------------------------------------------------------
    // MARK: Initializer
    // -------------------------------------------------------------------------

    public init(table: javax.swing.JTable) {
      _table = table
      super.init()
      updateUI()
    }

    // -------------------------------------------------------------------------
    // MARK: UI delegate
    // -------------------------------------------------------------------------

    open override func getUIClassID() -> String { "TableHeaderUI" }

    open override func updateUI() {
      if let factory = javax.swing.UIManager.getUI(self) {
        ui = factory
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Preferred size (delegates to UI)
    // -------------------------------------------------------------------------

    open override func getPreferredSize() -> java.awt.Dimension {
      if let size = ui?.getPreferredSize(self) { return size }
      return java.awt.Dimension(bounds.width, 22)
    }
  }
}
