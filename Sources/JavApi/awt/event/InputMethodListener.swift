/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {

  /// Receives notifications when input-method (IME) composed text changes —
  /// mirrors `java.awt.event.InputMethodListener`.
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol InputMethodListener: java.util.EventListener {

    /// Invoked when the text being composed by an input method changes.
    func inputMethodTextChanged(_ event: java.awt.event.InputMethodEvent)

    /// Invoked when the caret within composed text changes,
    /// without any text change.
    func caretPositionChanged(_ event: java.awt.event.InputMethodEvent)
  }
}
