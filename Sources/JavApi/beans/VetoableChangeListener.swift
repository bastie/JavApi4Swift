/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.beans {

  /// Listener interface for receiving vetoed property-change events.
  ///
  /// - Since: Java 1.1
  public protocol VetoableChangeListener: java.util.EventListener {
    /// Called when a constrained property is about to change.
    /// - Parameter evt: The pending change event.
    /// - Throws: ``PropertyVetoException`` to reject the change.
    func vetoableChange(_ evt: java.beans.PropertyChangeEvent) throws
  }
}
