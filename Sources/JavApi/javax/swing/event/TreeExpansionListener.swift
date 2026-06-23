/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.event {

  /// Listener notified when a `JTree` node is expanded or collapsed.
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol TreeExpansionListener: AnyObject, java.util.EventListener {

    /// Invoked when a tree node has been expanded.
    func treeExpanded(_ e: TreeExpansionEvent)

    /// Invoked when a tree node has been collapsed.
    func treeCollapsed(_ e: TreeExpansionEvent)
  }
}
