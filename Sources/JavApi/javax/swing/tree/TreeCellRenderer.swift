/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.tree {

  /// Defines the interface for an object that renders a single tree node.
  ///
  /// `JTree` calls `getTreeCellRendererComponent` for each visible node.
  /// The returned `Component` is painted by the UI delegate at the node's
  /// position — it is a *stamp* (never added to the component hierarchy).
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol TreeCellRenderer: AnyObject {

    /// Returns a component configured to render the given tree node.
    ///
    /// - Parameters:
    ///   - tree:     The `JTree` being painted.
    ///   - value:    The node value (typically a `DefaultMutableTreeNode`).
    ///   - selected: Whether the node is currently selected.
    ///   - expanded: Whether the node is expanded.
    ///   - leaf:     Whether the node is a leaf.
    ///   - row:      The row index (0-based, visible rows only).
    ///   - hasFocus: Whether the node has keyboard focus.
    /// - Returns: A fully configured `Component` ready for painting.
    func getTreeCellRendererComponent(
      _ tree:     javax.swing.JTree,
      _ value:    AnyObject,
      _ selected: Bool,
      _ expanded: Bool,
      _ leaf:     Bool,
      _ row:      Int,
      _ hasFocus: Bool
    ) -> java.awt.Component
  }
}
