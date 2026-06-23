/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.event {

  /// An event fired by `JTree` when a node is expanded or collapsed.
  ///
  /// - Since: Java 1.2
  @MainActor
  public class TreeExpansionEvent: java.util.EventObject, @unchecked Sendable {

    /// The path to the node that was expanded or collapsed.
    public let path: javax.swing.tree.TreePath

    /// Creates a `TreeExpansionEvent`.
    ///
    /// - Parameters:
    ///   - source: The `JTree` firing this event.
    ///   - path:   Path to the expanded/collapsed node.
    public init(_ source: AnyObject, path: javax.swing.tree.TreePath) {
      self.path = path
      super.init(source)
    }

    /// Returns the path to the expanded or collapsed node.
    public func getPath() -> javax.swing.tree.TreePath { path }
  }
}
