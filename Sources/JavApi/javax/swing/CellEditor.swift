/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// Base interface for cell editors used by `JTable` and `JTree`.
  ///
  /// Defines the editing lifecycle: start, validate, stop/cancel, and the
  /// ability to add/remove `CellEditorListener`s that are notified when
  /// editing stops or is cancelled.
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol CellEditor: AnyObject {

    /// Returns the current value held by the editor.
    func getCellEditorValue() -> Any?

    /// Returns `true` if the cell should become editable given the event.
    ///
    /// A typical implementation returns `true` for a double-click.
    func isCellEditable(_ anEvent: java.util.EventObject?) -> Bool

    /// Returns `true` if the cell at the given location should be selected
    /// before editing begins.
    func shouldSelectCell(_ anEvent: java.util.EventObject?) -> Bool

    /// Stops editing and accepts the current value.
    ///
    /// - Returns: `false` if the value is invalid and editing should continue.
    @discardableResult func stopCellEditing() -> Bool

    /// Cancels editing, discarding any changes.
    func cancelCellEditing()

    /// Adds a listener that is notified when editing stops or is cancelled.
    func addCellEditorListener(_ l: javax.swing.event.CellEditorListener)

    /// Removes a previously registered listener.
    func removeCellEditorListener(_ l: javax.swing.event.CellEditorListener)
  }
}
