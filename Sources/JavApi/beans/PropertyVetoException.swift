/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.beans {

  /// Thrown when a proposed change to a constrained property is rejected by a listener.
  ///
  /// - Since: Java 1.1
  public class PropertyVetoException: Exception, @unchecked Sendable {

    private let evt: java.beans.PropertyChangeEvent

    /// - Parameters:
    ///   - message: Why the change was vetoed.
    ///   - evt: The rejected event.
    public init(_ message: String, _ evt: java.beans.PropertyChangeEvent) {
      self.evt = evt
      super.init(message)
    }

    /// - Returns: The event that was vetoed.
    public func getPropertyChangeEvent() -> java.beans.PropertyChangeEvent { evt }
  }
}
