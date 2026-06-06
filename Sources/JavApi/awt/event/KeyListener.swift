/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {
  @MainActor
  public protocol KeyListener: java.util.EventListener {
    func keyTyped   (_ e: java.awt.event.KeyEvent)
    func keyPressed (_ e: java.awt.event.KeyEvent)
    func keyReleased(_ e: java.awt.event.KeyEvent)
  }
}
