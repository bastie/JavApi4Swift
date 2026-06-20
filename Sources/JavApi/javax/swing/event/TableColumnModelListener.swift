/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.event {

  /// Listener for `TableColumnModel` changes.
  ///
  /// Implement this protocol to be notified when columns are added, removed,
  /// moved, or when the column margin or selection changes.
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol TableColumnModelListener: AnyObject {

    /// Called after a column is added to the model.
    func columnAdded(_ e: javax.swing.event.TableColumnModelEvent)

    /// Called after a column is removed from the model.
    func columnRemoved(_ e: javax.swing.event.TableColumnModelEvent)

    /// Called after a column is moved in the model.
    func columnMoved(_ e: javax.swing.event.TableColumnModelEvent)

    /// Called after the column margin changes.
    func columnMarginChanged(_ e: javax.swing.event.ChangeEvent)

    /// Called after the column selection changes.
    func columnSelectionChanged(_ e: javax.swing.event.ListSelectionEvent)
  }
}
