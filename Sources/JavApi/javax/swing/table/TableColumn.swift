/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.table {

  /// Represents a single column in a `JTable`.
  ///
  /// `TableColumn` stores the display properties for one column: its model
  /// index, header value, preferred/min/max widths, renderer, and editor.
  ///
  /// All width mutations notify the owning `TableColumnModel` indirectly via
  /// `PropertyChangeEvent` (not yet wired here — stub for JFC 1.0 coverage).
  ///
  /// - Since: Java 1.2
  @MainActor
  open class TableColumn: @unchecked Sendable {

    // -------------------------------------------------------------------------
    // MARK: Constants
    // -------------------------------------------------------------------------

    public static let COLUMN_WIDTH_PROPERTY:         String = "columWidth"
    public static let HEADER_VALUE_PROPERTY:         String = "headerValue"
    public static let HEADER_RENDERER_PROPERTY:      String = "headerRenderer"
    public static let CELL_RENDERER_PROPERTY:        String = "cellRenderer"

    // -------------------------------------------------------------------------
    // MARK: Properties
    // -------------------------------------------------------------------------

    /// Index of this column in the `TableModel`.
    open var modelIndex: Int

    /// Arbitrary object used as the column header — typically a `String`.
    open var headerValue: Any?

    /// Renderer for the header cell.  `nil` uses the `JTable` default.
    open var headerRenderer: (any javax.swing.table.TableCellRenderer)?

    /// Renderer for data cells.  `nil` uses the `JTable` default.
    open var cellRenderer: (any javax.swing.table.TableCellRenderer)?

    /// Editor for data cells.  `nil` uses the `JTable` default.
    open var cellEditor: (any javax.swing.CellEditor)?

    open var width:         Int
    open var minWidth:      Int
    open var maxWidth:      Int
    open var preferredWidth: Int
    open var isResizable:   Bool

    /// Arbitrary user-defined identifier (used by `TableColumnModel.getColumnIndex`).
    open var identifier: AnyObject?

    // -------------------------------------------------------------------------
    // MARK: Initializers
    // -------------------------------------------------------------------------

    public init(modelIndex: Int = 0,
                width: Int = 75,
                cellRenderer: (any javax.swing.table.TableCellRenderer)? = nil,
                cellEditor: (any javax.swing.CellEditor)? = nil) {
      self.modelIndex    = modelIndex
      self.width         = width
      self.preferredWidth = width
      self.minWidth      = 15
      self.maxWidth      = Int.max
      self.isResizable   = true
      self.cellRenderer  = cellRenderer
      self.cellEditor    = cellEditor
    }

    // -------------------------------------------------------------------------
    // MARK: Accessors (Java-style getters/setters)
    // -------------------------------------------------------------------------

    open func getModelIndex()    -> Int    { modelIndex }
    open func setModelIndex(_ i: Int)      { modelIndex = i }

    open func getHeaderValue()   -> Any?   { headerValue }
    open func setHeaderValue(_ v: Any?)    { headerValue = v }

    open func getWidth()         -> Int    { width }
    open func setWidth(_ w: Int)           { width = max(minWidth, min(maxWidth, w)) }

    open func getMinWidth()      -> Int    { minWidth }
    open func setMinWidth(_ w: Int)        { minWidth = w; if width < w { width = w } }

    open func getMaxWidth()      -> Int    { maxWidth }
    open func setMaxWidth(_ w: Int)        { maxWidth = w; if width > w { width = w } }

    open func getPreferredWidth() -> Int   { preferredWidth }
    open func setPreferredWidth(_ w: Int)  { preferredWidth = max(minWidth, min(maxWidth, w)) }

    open func getResizable()     -> Bool   { isResizable }
    open func setResizable(_ r: Bool)      { isResizable = r }

    open func getIdentifier()    -> AnyObject? { identifier ?? (headerValue as AnyObject?) }
    open func setIdentifier(_ id: AnyObject?)  { identifier = id }

    open func getCellRenderer()  -> (any javax.swing.table.TableCellRenderer)? { cellRenderer }
    open func setCellRenderer(_ r: (any javax.swing.table.TableCellRenderer)?) { cellRenderer = r }

    open func getCellEditor()    -> (any javax.swing.CellEditor)? { cellEditor }
    open func setCellEditor(_ e: (any javax.swing.CellEditor)?)   { cellEditor = e }

    open func getHeaderRenderer() -> (any javax.swing.table.TableCellRenderer)? { headerRenderer }
    open func setHeaderRenderer(_ r: (any javax.swing.table.TableCellRenderer)?) { headerRenderer = r }

    // -------------------------------------------------------------------------
    // MARK: sizeWidthToFit
    // -------------------------------------------------------------------------

    /// Adjusts the column width to match the preferred width (no-op stub).
    open func sizeWidthToFit() {
      setWidth(preferredWidth)
    }
  }
}
