/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.event {

  /// Event fired by a `TableColumnModel` when columns are added, removed,
  /// or moved.
  ///
  /// - Since: Java 1.2
  @MainActor
  public class TableColumnModelEvent: java.util.EventObject, @unchecked Sendable {

    /// Index of the column before the change (source index for moves;
    /// insertion index for adds; removal index for removes).
    public let fromIndex: Int

    /// Index of the column after the change (destination index for moves;
    /// same as `fromIndex` for adds/removes).
    public let toIndex: Int

    /// Creates a `TableColumnModelEvent`.
    ///
    /// - Parameters:
    ///   - source:    The `TableColumnModel` that fired this event.
    ///   - fromIndex: The "from" column index.
    ///   - toIndex:   The "to" column index.
    public init(_ source: AnyObject, _ fromIndex: Int, _ toIndex: Int) {
      self.fromIndex = fromIndex
      self.toIndex   = toIndex
      super.init(source)
    }

    public func getFromIndex() -> Int { fromIndex }
    public func getToIndex()   -> Int { toIndex }
  }
}
