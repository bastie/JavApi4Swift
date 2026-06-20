/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.tree {

  /// The data model for a `JTree`'s selection state.
  ///
  /// `TreeSelectionModel` manages which `TreePath`s are selected and fires
  /// `TreeSelectionEvent` notifications to registered `TreeSelectionListener`s.
  ///
  /// Three selection modes are supported:
  /// - `SINGLE_TREE_SELECTION`      — at most one path at a time.
  /// - `CONTIGUOUS_TREE_SELECTION`  — contiguous paths only.
  /// - `DISCONTIGUOUS_TREE_SELECTION` — any paths (the default).
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol TreeSelectionModel: AnyObject {

    // -------------------------------------------------------------------------
    // MARK: Selection mode constants
    // -------------------------------------------------------------------------

    /// Only one path may be selected at a time.
    static var SINGLE_TREE_SELECTION: Int { get }

    /// Only contiguous paths may be selected.
    static var CONTIGUOUS_TREE_SELECTION: Int { get }

    /// Any combination of paths may be selected.
    static var DISCONTIGUOUS_TREE_SELECTION: Int { get }

    // -------------------------------------------------------------------------
    // MARK: Selection mode
    // -------------------------------------------------------------------------

    func getSelectionMode() -> Int
    func setSelectionMode(_ mode: Int)

    // -------------------------------------------------------------------------
    // MARK: Path mutation
    // -------------------------------------------------------------------------

    func setSelectionPath(_ path: javax.swing.tree.TreePath?)
    func setSelectionPaths(_ paths: [javax.swing.tree.TreePath]?)
    func addSelectionPath(_ path: javax.swing.tree.TreePath)
    func addSelectionPaths(_ paths: [javax.swing.tree.TreePath])
    func removeSelectionPath(_ path: javax.swing.tree.TreePath)
    func removeSelectionPaths(_ paths: [javax.swing.tree.TreePath])
    func clearSelection()

    // -------------------------------------------------------------------------
    // MARK: Path query
    // -------------------------------------------------------------------------

    func getSelectionPath() -> javax.swing.tree.TreePath?
    func getSelectionPaths() -> [javax.swing.tree.TreePath]?
    func getSelectionCount() -> Int
    func isPathSelected(_ path: javax.swing.tree.TreePath) -> Bool
    func isSelectionEmpty() -> Bool

    // -------------------------------------------------------------------------
    // MARK: Lead / anchor paths
    // -------------------------------------------------------------------------

    func getLeadSelectionPath() -> javax.swing.tree.TreePath?
    func getLeadSelectionRow() -> Int

    // -------------------------------------------------------------------------
    // MARK: Listeners
    // -------------------------------------------------------------------------

    func addTreeSelectionListener(_ l: javax.swing.event.TreeSelectionListener)
    func removeTreeSelectionListener(_ l: javax.swing.event.TreeSelectionListener)
  }

  // ---------------------------------------------------------------------------
  // MARK: Default constant values (protocol extension)
  // ---------------------------------------------------------------------------

}

extension javax.swing.tree.TreeSelectionModel {
  public static var SINGLE_TREE_SELECTION:       Int { 1 }
  public static var CONTIGUOUS_TREE_SELECTION:   Int { 2 }
  public static var DISCONTIGUOUS_TREE_SELECTION: Int { 4 }
}
