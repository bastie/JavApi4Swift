/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.event {

  /// Listener notified whenever the selection in a `JTree` changes.
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol TreeSelectionListener: AnyObject, java.util.EventListener {

    /// Invoked whenever the selection changes in the tree being listened to.
    func valueChanged(_ e: TreeSelectionEvent)
  }
}
