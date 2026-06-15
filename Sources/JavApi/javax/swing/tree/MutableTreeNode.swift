/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.tree {

  /// A `TreeNode` that can be modified: children and user object can be set.
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol MutableTreeNode: javax.swing.tree.TreeNode {

    /// Inserts `child` at `index`.
    func insert(_ child: any javax.swing.tree.MutableTreeNode, _ index: Int)

    /// Removes the child at `index`.
    func remove(_ index: Int)

    /// Removes `node` from the children.
    func remove(_ node: any javax.swing.tree.MutableTreeNode)

    /// Removes this node from its parent.
    func removeFromParent()

    /// Sets the parent of this node.
    func setParent(_ parent: (any javax.swing.tree.MutableTreeNode)?)

    /// Sets the user object associated with this node.
    func setUserObject(_ object: Any?)
  }
}
