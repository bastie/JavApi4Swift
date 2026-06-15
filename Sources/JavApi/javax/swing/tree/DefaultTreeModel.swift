/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.tree {

  /// The default implementation of `TreeModel`, backed by `TreeNode` objects.
  ///
  /// `DefaultTreeModel` works with any `TreeNode`; it is most commonly used
  /// with `DefaultMutableTreeNode`.
  ///
  /// ## Example
  ///
  /// ```swift
  /// let root  = javax.swing.tree.DefaultMutableTreeNode("Root")
  /// let child = javax.swing.tree.DefaultMutableTreeNode("Child")
  /// root.add(child)
  /// let model = javax.swing.tree.DefaultTreeModel(root)
  /// model.getChildCount(root) // 1
  /// ```
  ///
  /// - Since: Java 1.2
  @MainActor
  open class DefaultTreeModel: javax.swing.tree.TreeModel {

    // -------------------------------------------------------------------------
    // MARK: Storage
    // -------------------------------------------------------------------------

    private var root:      (any javax.swing.tree.TreeNode)?
    private var listeners: [javax.swing.event.TreeModelListener] = []

    /// When `true`, a node is considered a leaf only if it has no children.
    /// When `false`, a node is a leaf if `getAllowsChildren()` returns `false`.
    open var asksAllowsChildren: Bool = false

    // -------------------------------------------------------------------------
    // MARK: Initializers
    // -------------------------------------------------------------------------

    /// Creates a model with the given root node.
    public init(_ root: (any javax.swing.tree.TreeNode)?) {
      self.root = root
    }

    // -------------------------------------------------------------------------
    // MARK: TreeModel
    // -------------------------------------------------------------------------

    open func getRoot() -> AnyObject? { root.map { $0 as AnyObject } }

    open func getChild(_ parent: AnyObject, _ index: Int) -> AnyObject? {
      guard let node = parent as? any javax.swing.tree.TreeNode else { return nil }
      guard index >= 0, index < node.getChildCount() else { return nil }
      return node.getChildAt(index) as AnyObject
    }

    open func getChildCount(_ parent: AnyObject) -> Int {
      (parent as? any javax.swing.tree.TreeNode)?.getChildCount() ?? 0
    }

    open func isLeaf(_ node: AnyObject) -> Bool {
      guard let treeNode = node as? any javax.swing.tree.TreeNode else { return true }
      if asksAllowsChildren { return !treeNode.getAllowsChildren() }
      return treeNode.isLeaf()
    }

    open func getIndexOfChild(_ parent: AnyObject, _ child: AnyObject) -> Int {
      guard let parentNode = parent as? any javax.swing.tree.TreeNode,
            let childNode  = child  as? any javax.swing.tree.TreeNode else { return -1 }
      return parentNode.getIndex( childNode)
    }

    open func valueForPathChanged(_ path: javax.swing.tree.TreePath, newValue: Any?) {
      guard let node = path.getLastPathComponent() as? javax.swing.tree.DefaultMutableTreeNode else { return }
      node.setUserObject(newValue)
      nodeChanged(node)
    }

    open func addTreeModelListener(_ l: javax.swing.event.TreeModelListener) {
      listeners.append(l)
    }

    open func removeTreeModelListener(_ l: javax.swing.event.TreeModelListener) {
      listeners.removeAll { $0 === (l as AnyObject) }
    }

    // -------------------------------------------------------------------------
    // MARK: Root access
    // -------------------------------------------------------------------------

    /// Replaces the root node and fires `treeStructureChanged`.
    open func setRoot(_ newRoot: (any javax.swing.tree.TreeNode)?) {
      root = newRoot
      if let r = newRoot {
        let path = javax.swing.tree.TreePath(r as AnyObject)
        fireTreeStructureChanged(path)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Mutation helpers (notify listeners)
    // -------------------------------------------------------------------------

    /// Notifies listeners that the given node's data changed.
    open func nodeChanged(_ node: any javax.swing.tree.TreeNode) {
      guard let parent = node.getParent() else {
        // Root changed
        if let r = root {
          let path = javax.swing.tree.TreePath(r as AnyObject)
          fireTreeNodesChanged(path, childIndices: [], children: [])
        }
        return
      }
      let idx = parent.getIndex( node)
      guard idx >= 0 else { return }
      let path = pathToNode(parent)
      fireTreeNodesChanged(path, childIndices: [idx], children: [node as AnyObject])
    }

    /// Notifies listeners that child nodes were inserted under `parent`.
    open func nodesWereInserted(_ parent: any javax.swing.tree.TreeNode, at indices: [Int]) {
      guard !indices.isEmpty else { return }
      let path     = pathToNode(parent)
      let children = indices.map { parent.getChildAt($0) as AnyObject }
      fireTreeNodesInserted(path, childIndices: indices, children: children)
    }

    /// Notifies listeners that child nodes were removed from `parent`.
    open func nodesWereRemoved(_ parent: any javax.swing.tree.TreeNode,
                               at indices: [Int],
                               removedChildren: [AnyObject]) {
      guard !indices.isEmpty else { return }
      let path = pathToNode(parent)
      fireTreeNodesRemoved(path, childIndices: indices, children: removedChildren)
    }

    /// Notifies listeners that the entire structure under `node` has changed.
    open func nodeStructureChanged(_ node: any javax.swing.tree.TreeNode) {
      fireTreeStructureChanged(pathToNode(node))
    }

    // -------------------------------------------------------------------------
    // MARK: Path helper
    // -------------------------------------------------------------------------

    private func pathToNode(_ node: any javax.swing.tree.TreeNode) -> javax.swing.tree.TreePath {
      var components: [AnyObject] = [node as AnyObject]
      var current = node.getParent()
      while let parent = current {
        components.insert(parent as AnyObject, at: 0)
        current = parent.getParent()
      }
      return javax.swing.tree.TreePath(components)
    }

    // -------------------------------------------------------------------------
    // MARK: Fire helpers
    // -------------------------------------------------------------------------

    private func fireTreeNodesChanged(_ path: javax.swing.tree.TreePath,
                                      childIndices: [Int],
                                      children: [AnyObject]) {
      guard !listeners.isEmpty else { return }
      let e = javax.swing.event.TreeModelEvent(self, path: path,
                                               childIndices: childIndices,
                                               children: children)
      for l in listeners { l.treeNodesChanged(e) }
    }

    private func fireTreeNodesInserted(_ path: javax.swing.tree.TreePath,
                                       childIndices: [Int],
                                       children: [AnyObject]) {
      guard !listeners.isEmpty else { return }
      let e = javax.swing.event.TreeModelEvent(self, path: path,
                                               childIndices: childIndices,
                                               children: children)
      for l in listeners { l.treeNodesInserted(e) }
    }

    private func fireTreeNodesRemoved(_ path: javax.swing.tree.TreePath,
                                      childIndices: [Int],
                                      children: [AnyObject]) {
      guard !listeners.isEmpty else { return }
      let e = javax.swing.event.TreeModelEvent(self, path: path,
                                               childIndices: childIndices,
                                               children: children)
      for l in listeners { l.treeNodesRemoved(e) }
    }

    private func fireTreeStructureChanged(_ path: javax.swing.tree.TreePath) {
      guard !listeners.isEmpty else { return }
      let e = javax.swing.event.TreeModelEvent(self, path: path)
      for l in listeners { l.treeStructureChanged(e) }
    }
  }
}
