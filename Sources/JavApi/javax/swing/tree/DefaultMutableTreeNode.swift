/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.tree {

  /// A general-purpose node in a tree data structure.
  ///
  /// `DefaultMutableTreeNode` stores an optional *user object* (any value)
  /// and maintains parent/child relationships.  It is the standard node class
  /// used with `DefaultTreeModel`.
  ///
  /// ## Example
  ///
  /// ```swift
  /// let root  = javax.swing.tree.DefaultMutableTreeNode("Root")
  /// let child = javax.swing.tree.DefaultMutableTreeNode("Child")
  /// root.add(child)
  /// root.getChildCount() // 1
  /// ```
  ///
  /// - Since: Java 1.2
  @MainActor
  open class DefaultMutableTreeNode: javax.swing.tree.MutableTreeNode {

    // -------------------------------------------------------------------------
    // MARK: Storage
    // -------------------------------------------------------------------------

    private var _userObject:     Any?
    private var _parent:         (any javax.swing.tree.MutableTreeNode)?
    private var _children:       [any javax.swing.tree.MutableTreeNode] = []
    private var _allowsChildren: Bool

    // -------------------------------------------------------------------------
    // MARK: Initializers
    // -------------------------------------------------------------------------

    /// Creates a node with the given user object.
    public init(_ userObject: Any? = nil, allowsChildren: Bool = true) {
      _userObject     = userObject
      _allowsChildren = allowsChildren
    }

    // -------------------------------------------------------------------------
    // MARK: TreeNode
    // -------------------------------------------------------------------------

    open func getParent() -> (any javax.swing.tree.TreeNode)? { _parent }

    open func getChildAt(_ index: Int) -> any javax.swing.tree.TreeNode {
      _children[index]
    }

    open func getChildCount() -> Int { _children.count }

    open func getIndex(_ node: any javax.swing.tree.TreeNode) -> Int {
      _children.firstIndex { $0 === node } ?? -1
    }

    open func isLeaf() -> Bool { _children.isEmpty }

    open func getAllowsChildren() -> Bool { _allowsChildren }

    // -------------------------------------------------------------------------
    // MARK: MutableTreeNode
    // -------------------------------------------------------------------------

    open func insert(_ child: any javax.swing.tree.MutableTreeNode, _ index: Int) {
      guard _allowsChildren else { return }
      (child as? DefaultMutableTreeNode)?._parent = self
      _children.insert(child, at: index)
    }

    open func remove(_ index: Int) {
      (_children[index] as? DefaultMutableTreeNode)?._parent = nil
      _children.remove(at: index)
    }

    open func remove(_ node: any javax.swing.tree.MutableTreeNode) {
      if let idx = _children.firstIndex(where: { $0 === node }) {
        remove(idx)
      }
    }

    open func removeFromParent() {
      _parent?.remove(self)
      _parent = nil
    }

    open func setParent(_ parent: (any javax.swing.tree.MutableTreeNode)?) {
      _parent = parent
    }

    open func setUserObject(_ object: Any?) { _userObject = object }

    // -------------------------------------------------------------------------
    // MARK: Convenience (beyond MutableTreeNode protocol)
    // -------------------------------------------------------------------------

    /// Returns the user object associated with this node.
    open func getUserObject() -> Any? { _userObject }

    /// Appends `child` as the last child of this node.
    open func add(_ child: any javax.swing.tree.MutableTreeNode) {
      insert(child, _children.count)
    }

    /// Returns `true` if this node is the root (no parent).
    open func isRoot() -> Bool { _parent == nil }

    /// Returns the depth of the subtree rooted at this node
    /// (0 for a leaf, 1 if all children are leaves, etc.).
    open func getDepth() -> Int {
      guard !_children.isEmpty else { return 0 }
      return 1 + (_children.map { ($0 as? DefaultMutableTreeNode)?.getDepth() ?? 0 }.max() ?? 0)
    }

    /// Returns the path from the root to this node as an array.
    open func getPath() -> [any javax.swing.tree.TreeNode] {
      var path: [any javax.swing.tree.TreeNode] = [self]
      var current: (any javax.swing.tree.TreeNode)? = _parent
      while let node = current {
        path.insert(node, at: 0)
        current = node.getParent()
      }
      return path
    }

    /// Returns a string representation using the user object's description.
    open func toString() -> String {
      if let obj = _userObject { return "\(obj)" }
      return "DefaultMutableTreeNode"
    }
  }
}
