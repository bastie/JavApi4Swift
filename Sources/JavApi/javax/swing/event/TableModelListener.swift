/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.event {

  /// Listener interface for changes in a `TableModel`.
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol TableModelListener: java.util.EventListener {

    /// Called whenever the table model changes.
    func tableChanged(_ e: javax.swing.event.TableModelEvent)
  }
}
