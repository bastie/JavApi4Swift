/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {
  @MainActor
  public protocol ComponentListener: java.util.EventListener {
    func componentResized(_ e: java.awt.event.ComponentEvent)
    func componentMoved  (_ e: java.awt.event.ComponentEvent)
    func componentShown  (_ e: java.awt.event.ComponentEvent)
    func componentHidden (_ e: java.awt.event.ComponentEvent)
  }

  @MainActor
  public protocol FocusListener: java.util.EventListener {
    func focusGained(_ e: java.awt.event.FocusEvent)
    func focusLost  (_ e: java.awt.event.FocusEvent)
  }
}
