/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {

  /// - Since: Java 1.4
  @MainActor
  public protocol MouseWheelListener: java.util.EventListener {
    func mouseWheelMoved(_ e: MouseWheelEvent)
  }
}
