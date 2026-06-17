/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {
  /// - Since: Java 1.1
  @MainActor
  public protocol ComponentListener: java.util.EventListener {
    func componentResized(_ e: java.awt.event.ComponentEvent)
    func componentMoved  (_ e: java.awt.event.ComponentEvent)
    func componentShown  (_ e: java.awt.event.ComponentEvent)
    func componentHidden (_ e: java.awt.event.ComponentEvent)
  }
}
