/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.tree {

  /// An immutable sequence of objects that together describe a path from
  /// the root of a tree to a specific node.
  ///
  /// `TreePath` is used by `JTree` and `TreeModel` to identify nodes.
  /// The first element is the root; the last element is the target node.
  ///
  /// - Since: Java 1.2
  @MainActor
  public final class TreePath {

    private let components: [AnyObject]

    // -------------------------------------------------------------------------
    // MARK: Initializers
    // -------------------------------------------------------------------------

    /// Creates a `TreePath` from an array of node objects.
    public init(_ path: [AnyObject]) {
      precondition(!path.isEmpty, "TreePath must contain at least one element")
      self.components = path
    }

    /// Creates a single-element `TreePath` (root only).
    public init(_ root: AnyObject) {
      self.components = [root]
    }

    // -------------------------------------------------------------------------
    // MARK: Access
    // -------------------------------------------------------------------------

    /// Returns the last component (the target node).
    public func getLastPathComponent() -> AnyObject { components.last! }

    /// Returns the first component (the root).
    public func getFirstPathComponent() -> AnyObject { components.first! }

    /// Returns the number of elements in this path.
    public func getPathCount() -> Int { components.count }

    /// Returns the component at `index`.
    public func getPathComponent(_ index: Int) -> AnyObject { components[index] }

    /// Returns all components as an array.
    public func getPath() -> [AnyObject] { components }

    // -------------------------------------------------------------------------
    // MARK: Derived paths
    // -------------------------------------------------------------------------

    /// Returns the parent path (all but the last component), or `nil` if
    /// this path has only one component.
    public func getParentPath() -> javax.swing.tree.TreePath? {
      guard components.count > 1 else { return nil }
      return TreePath(Array(components.dropLast()))
    }

    /// Returns a new `TreePath` by appending `child` to this path.
    public func pathByAddingChild(_ child: AnyObject) -> javax.swing.tree.TreePath {
      TreePath(components + [child])
    }

    // -------------------------------------------------------------------------
    // MARK: Equality
    // -------------------------------------------------------------------------

    /// Returns `true` if both paths have the same components (by identity).
    public func isDescendant(of path: javax.swing.tree.TreePath) -> Bool {
      guard path.getPathCount() <= getPathCount() else { return false }
      for i in 0..<path.getPathCount() {
        if components[i] !== path.components[i] { return false }
      }
      return true
    }
  }
}
