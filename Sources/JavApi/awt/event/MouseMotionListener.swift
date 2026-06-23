/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {

  /// - Since: Java 1.1
  @MainActor
  public protocol MouseMotionListener: java.util.EventListener {
    func mouseDragged(_ e: java.awt.event.MouseEvent)
    func mouseMoved  (_ e: java.awt.event.MouseEvent)
  }
}
