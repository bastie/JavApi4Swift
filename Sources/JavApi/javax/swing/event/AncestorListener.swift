/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.event {

  /// Listener for `AncestorEvent`s.
  ///
  /// Register with a `JComponent` via `addAncestorListener(_:)` to be
  /// notified when the component or one of its ancestors is added to,
  /// removed from, or moved within the component hierarchy.
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol AncestorListener: AnyObject {

    /// Called when the component or an ancestor is added to a visible container.
    func ancestorAdded(_ event: javax.swing.event.AncestorEvent)

    /// Called when the component or an ancestor is removed from a visible container.
    func ancestorRemoved(_ event: javax.swing.event.AncestorEvent)

    /// Called when an ancestor is moved.
    func ancestorMoved(_ event: javax.swing.event.AncestorEvent)
  }
}
