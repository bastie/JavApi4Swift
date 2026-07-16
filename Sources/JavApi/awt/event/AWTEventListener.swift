/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {

  /// Receives all `AWTEvent`s dispatched anywhere in the application, subject
  /// to an event-mask filter — mirrors `java.awt.event.AWTEventListener`.
  ///
  /// Registered via `Toolkit.addAWTEventListener(_:_:)` with an event mask
  /// built from `AWTEvent`'s `*_EVENT_MASK` constants (e.g.
  /// `AWTEvent.MOUSE_EVENT_MASK | AWTEvent.KEY_EVENT_MASK`). Primarily used
  /// for global event monitoring (accessibility tools, event logging).
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol AWTEventListener: java.util.EventListener {

    /// Invoked for every dispatched event matching the listener's event mask.
    func eventDispatched(_ event: java.awt.AWTEvent)
  }
}
