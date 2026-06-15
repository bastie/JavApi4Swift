/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.event {

  /// Encapsulates a change to a `TableModel`.
  ///
  /// Describes which rows and column were affected and the type of change.
  ///
  /// | Constant        | Meaning                              |
  /// |-----------------|--------------------------------------|
  /// | `UPDATE`        | Cell values changed                  |
  /// | `INSERT`        | Rows were inserted                   |
  /// | `DELETE`        | Rows were deleted                    |
  ///
  /// Special sentinel values:
  /// - `ALL_COLUMNS` (-1) — the entire row changed
  /// - `HEADER_ROW` (-1) — column structure changed (used for firstRow)
  ///
  /// - Since: Java 1.2
  @MainActor
  public class TableModelEvent: java.util.EventObject, @unchecked Sendable {

    // -------------------------------------------------------------------------
    // MARK: Type constants
    // -------------------------------------------------------------------------

    public static let UPDATE: Int = 0
    public static let INSERT: Int = 1
    public static let DELETE: Int = 2

    // -------------------------------------------------------------------------
    // MARK: Sentinel constants
    // -------------------------------------------------------------------------

    /// Passed as `column` to indicate all columns changed.
    public static let ALL_COLUMNS: Int = -1

    /// Passed as `firstRow` to indicate the column structure changed.
    public static let HEADER_ROW:  Int = -1

    // -------------------------------------------------------------------------
    // MARK: Properties
    // -------------------------------------------------------------------------

    public let type:      Int
    public let firstRow:  Int
    public let lastRow:   Int
    public let column:    Int

    // -------------------------------------------------------------------------
    // MARK: Initializers
    // -------------------------------------------------------------------------

    /// Creates a `TableModelEvent` for a cell or row range change.
    ///
    /// Java: `TableModelEvent(Object source, int firstRow, int lastRow, int column, int type)`
    public init(_ source: AnyObject,
                _ firstRow: Int,
                _ lastRow:  Int,
                _ column:   Int = TableModelEvent.ALL_COLUMNS,
                _ type:     Int = TableModelEvent.UPDATE) {
      self.firstRow = firstRow
      self.lastRow  = lastRow
      self.column   = column
      self.type     = type
      super.init(source)
    }

    /// Convenience factory: creates a `TableModelEvent` signalling that the
    /// entire table changed (equivalent to `init(source, HEADER_ROW, Int.max, ALL_COLUMNS, UPDATE)`).
    @MainActor
    public static func allChanged(_ source: AnyObject) -> TableModelEvent {
      TableModelEvent(source, -1, Int.max, -1, 0)
    }

    // -------------------------------------------------------------------------
    // MARK: Accessors
    // -------------------------------------------------------------------------

    public func getType()     -> Int { type }
    public func getFirstRow() -> Int { firstRow }
    public func getLastRow()  -> Int { lastRow }
    public func getColumn()   -> Int { column }
  }
}
