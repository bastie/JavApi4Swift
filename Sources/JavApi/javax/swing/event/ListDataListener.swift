/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.event {

  /// Listener interface for changes in a `ListModel`.
  ///
  /// Implement this protocol to be notified when elements are added to,
  /// removed from, or modified in a `ListModel`.
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol ListDataListener: java.util.EventListener {

    /// Called when the contents of one or more list elements changed.
    func contentsChanged(_ e: javax.swing.event.ListDataEvent)

    /// Called when one or more elements were inserted into the list.
    func intervalAdded(_ e: javax.swing.event.ListDataEvent)

    /// Called when one or more elements were removed from the list.
    func intervalRemoved(_ e: javax.swing.event.ListDataEvent)
  }
}
