/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// The selection model for list-like components such as `JList` and `JTable`.
  ///
  /// `ListSelectionModel` supports three selection modes:
  ///
  /// | Constant                  | Meaning                                     |
  /// |---------------------------|---------------------------------------------|
  /// | `SINGLE_SELECTION`        | At most one index can be selected           |
  /// | `SINGLE_INTERVAL_SELECTION` | One contiguous range of indices           |
  /// | `MULTIPLE_INTERVAL_SELECTION` | Any number of indices / ranges (default) |
  ///
  /// Selected indices are queried with `isSelectedIndex(_:)`, `getMinSelectionIndex()`,
  /// and `getMaxSelectionIndex()`.  Range operations (`setSelectionInterval`,
  /// `addSelectionInterval`, `removeSelectionInterval`) modify the selection and
  /// fire `ListSelectionEvent` notifications.
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol ListSelectionModel: AnyObject {

    // -------------------------------------------------------------------------
    // MARK: Selection mode constants
    // -------------------------------------------------------------------------

    /// At most one index can be selected at a time.
    static var SINGLE_SELECTION:            Int { get }
    /// One contiguous interval may be selected.
    static var SINGLE_INTERVAL_SELECTION:   Int { get }
    /// Any number of indices / intervals may be selected (default).
    static var MULTIPLE_INTERVAL_SELECTION: Int { get }

    // -------------------------------------------------------------------------
    // MARK: Selection mode
    // -------------------------------------------------------------------------

    /// One of `SINGLE_SELECTION`, `SINGLE_INTERVAL_SELECTION`,
    /// `MULTIPLE_INTERVAL_SELECTION`.
    var selectionMode: Int { get set }

    // -------------------------------------------------------------------------
    // MARK: Modifying the selection
    // -------------------------------------------------------------------------

    /// Replaces the current selection with the single index `index`.
    func setSelectionInterval(_ index0: Int, _ index1: Int)

    /// Adds the range `[index0, index1]` to the selection.
    func addSelectionInterval(_ index0: Int, _ index1: Int)

    /// Removes the range `[index0, index1]` from the selection.
    func removeSelectionInterval(_ index0: Int, _ index1: Int)

    /// Clears the entire selection.
    func clearSelection()

    // -------------------------------------------------------------------------
    // MARK: Querying the selection
    // -------------------------------------------------------------------------

    /// Returns `true` if no index is selected.
    func isSelectionEmpty() -> Bool

    /// Returns `true` if `index` is selected.
    func isSelectedIndex(_ index: Int) -> Bool

    /// Returns the smallest selected index, or -1 if the selection is empty.
    func getMinSelectionIndex() -> Int

    /// Returns the largest selected index, or -1 if the selection is empty.
    func getMaxSelectionIndex() -> Int

    // -------------------------------------------------------------------------
    // MARK: Adjusting flag
    // -------------------------------------------------------------------------

    /// When `true`, the selection is undergoing a rapid series of changes
    /// (e.g. mouse drag).
    var valueIsAdjusting: Bool { get set }

    // -------------------------------------------------------------------------
    // MARK: Anchor / lead
    // -------------------------------------------------------------------------

    /// The anchor of the most recent selection operation.
    var anchorSelectionIndex: Int { get set }

    /// The lead (end) of the most recent selection operation.
    var leadSelectionIndex: Int { get set }

    // -------------------------------------------------------------------------
    // MARK: Listeners
    // -------------------------------------------------------------------------

    func addListSelectionListener(_ l: javax.swing.event.ListSelectionListener)
    func removeListSelectionListener(_ l: javax.swing.event.ListSelectionListener)
  }
}

extension javax.swing.ListSelectionModel {
  public static var SINGLE_SELECTION:            Int { 0 }
  public static var SINGLE_INTERVAL_SELECTION:   Int { 1 }
  public static var MULTIPLE_INTERVAL_SELECTION: Int { 2 }
}
