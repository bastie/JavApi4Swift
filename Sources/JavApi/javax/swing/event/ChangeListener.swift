/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.event {

  /// Listener notified when the state of a model changes.
  ///
  /// Implement this protocol and register via
  /// `ButtonModel.addChangeListener(_:)` to be notified whenever
  /// the button model's state (pressed, armed, rollover, …) changes.
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol ChangeListener: java.util.EventListener {
    func stateChanged(_ e: javax.swing.event.ChangeEvent)
  }
}
