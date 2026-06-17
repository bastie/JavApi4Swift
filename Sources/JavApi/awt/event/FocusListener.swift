/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {
  /// - Since: Java 1.1
  @MainActor
  public protocol FocusListener: java.util.EventListener {
    func focusGained(_ e: java.awt.event.FocusEvent)
    func focusLost  (_ e: java.awt.event.FocusEvent)
  }
}
