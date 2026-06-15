/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.beans {

  /// Listener interface for receiving property-change events.
  ///
  /// - Since: Java 1.1
  public protocol PropertyChangeListener: java.util.EventListener {
    /// Called when a bound property has changed.
    /// - Parameter evt: PropertyChangeEvent
    func propertyChange(_ evt: java.beans.PropertyChangeEvent)
  }
}
