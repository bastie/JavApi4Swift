/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {
  @MainActor
  open class KeyAdapter : KeyListener {
    open func keyTyped   (_ e: java.awt.event.KeyEvent){}
    open func keyPressed (_ e: java.awt.event.KeyEvent){}
    open func keyReleased(_ e: java.awt.event.KeyEvent){}
  }
}
