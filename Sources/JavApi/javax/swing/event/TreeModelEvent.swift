/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.event {

  /// Encapsulates information describing changes to a tree model.
  ///
  /// Fired by `TreeModel` whenever nodes are inserted, removed, or changed.
  /// The `path` identifies the parent node; `childIndices` and `children`
  /// describe which children were affected.
  ///
  /// - Since: Java 1.2
  @MainActor
  public class TreeModelEvent: java.util.EventObject, @unchecked Sendable {

    /// The path to the parent of the changed/inserted/removed nodes.
    public let path: javax.swing.tree.TreePath

    /// The indices (in the parent) of the affected child nodes.
    public let childIndices: [Int]

    /// The affected child nodes themselves.
    public let children: [AnyObject]

    /// Creates a `TreeModelEvent`.
    ///
    /// - Parameters:
    ///   - source:        The `TreeModel` firing this event.
    ///   - path:          Path to the parent of the affected nodes.
    ///   - childIndices:  Sorted indices of the affected children in the parent.
    ///   - children:      The affected child node objects.
    public init(_ source: AnyObject,
                path: javax.swing.tree.TreePath,
                childIndices: [Int] = [],
                children: [AnyObject] = []) {
      self.path          = path
      self.childIndices  = childIndices
      self.children      = children
      super.init(source)
    }

    /// Returns the `TreePath` to the parent node.
    public func getTreePath() -> javax.swing.tree.TreePath { path }

    /// Returns the child indices.
    public func getChildIndices() -> [Int] { childIndices }

    /// Returns the child node objects.
    public func getChildren() -> [AnyObject] { children }
  }
}
