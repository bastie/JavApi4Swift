/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.event {

  /// Listener interface for structural changes in a `TreeModel`.
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol TreeModelListener: java.util.EventListener {

    /// Called after one or more nodes in the tree have changed.
    func treeNodesChanged(_ e: javax.swing.event.TreeModelEvent)

    /// Called after one or more nodes have been inserted into the tree.
    func treeNodesInserted(_ e: javax.swing.event.TreeModelEvent)

    /// Called after one or more nodes have been removed from the tree.
    func treeNodesRemoved(_ e: javax.swing.event.TreeModelEvent)

    /// Called after the tree structure has changed radically (e.g. reload).
    func treeStructureChanged(_ e: javax.swing.event.TreeModelEvent)
  }
}
