/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.tree {

  /// The read-only interface for a node in a tree data structure.
  ///
  /// A `TreeNode` knows its parent and its children.  Leaf nodes have no
  /// children; the root node has no parent.
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol TreeNode: AnyObject {

    /// Returns the parent of this node, or `nil` if this is the root.
    func getParent() -> (any javax.swing.tree.TreeNode)?

    /// Returns the child at `index`.
    func getChildAt(_ index: Int) -> any javax.swing.tree.TreeNode

    /// Returns the number of children.
    func getChildCount() -> Int

    /// Returns the index of `node` among the children, or -1 if not found.
    func getIndex(of node: any javax.swing.tree.TreeNode) -> Int

    /// Returns `true` if this node is a leaf (no children allowed or present).
    func isLeaf() -> Bool

    /// Returns `true` if this node allows children.
    func getAllowsChildren() -> Bool
  }
}
