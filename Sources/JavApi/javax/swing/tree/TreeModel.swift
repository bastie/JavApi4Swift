/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.tree {

  /// The data model for a `JTree`.
  ///
  /// `TreeModel` defines the tree structure that a `JTree` displays.
  /// It provides access to the root node, child nodes by index, and
  /// determines which nodes are leaves.
  ///
  /// Implementations fire `TreeModelEvent` notifications to registered
  /// `TreeModelListener`s whenever the structure or node values change.
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol TreeModel: AnyObject {

    /// Returns the root of the tree, or `nil` if the tree is empty.
    func getRoot() -> AnyObject?

    /// Returns the child of `parent` at `index`.
    func getChild(_ parent: AnyObject, _ index: Int) -> AnyObject?

    /// Returns the number of children of `parent`.
    func getChildCount(_ parent: AnyObject) -> Int

    /// Returns `true` if `node` is a leaf.
    func isLeaf(_ node: AnyObject) -> Bool

    /// Returns the index of `child` in `parent`, or -1 if not found.
    func getIndexOfChild(_ parent: AnyObject, _ child: AnyObject) -> Int

    /// Called when the user has altered the value of the item at `path`
    /// to `newValue`.
    func valueForPathChanged(_ path: javax.swing.tree.TreePath, newValue: Any?)

    func addTreeModelListener(_ l: javax.swing.event.TreeModelListener)
    func removeTreeModelListener(_ l: javax.swing.event.TreeModelListener)
  }
}
