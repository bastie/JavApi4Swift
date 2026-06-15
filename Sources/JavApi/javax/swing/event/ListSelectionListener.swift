/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.event {

  /// Listener interface for `ListSelectionModel` changes.
  ///
  /// Implement this protocol to be notified whenever the selection in a
  /// `ListSelectionModel` (or a `JList`) changes.
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol ListSelectionListener: java.util.EventListener {

    /// Called when the selection changes.
    ///
    /// - Parameter e: The event describing the changed index range and
    ///   whether the change is still in progress (`valueIsAdjusting`).
    func valueChanged(_ e: javax.swing.event.ListSelectionEvent)
  }
}
