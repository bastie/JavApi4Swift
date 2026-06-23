/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {

  /// - Since: Java 1.0
  @MainActor
  public protocol MouseListener: java.util.EventListener {
    func mouseClicked (_ e: java.awt.event.MouseEvent)
    func mousePressed (_ e: java.awt.event.MouseEvent)
    func mouseReleased(_ e: java.awt.event.MouseEvent)
    func mouseEntered (_ e: java.awt.event.MouseEvent)
    func mouseExited  (_ e: java.awt.event.MouseEvent)
  }

}
