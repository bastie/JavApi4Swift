/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {
  /// Convenience class for `FocusListener`
  /// - Since: Java 1.1
  @MainActor
  open class FocusAdapter: FocusListener {
    open func focusGained(_ e: java.awt.event.FocusEvent){}
    open func focusLost  (_ e: java.awt.event.FocusEvent){}
  }
}
