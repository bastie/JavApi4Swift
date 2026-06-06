/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {
  @MainActor
  public protocol MouseListener: java.util.EventListener {
    func mouseClicked (_ e: java.awt.event.MouseEvent)
    func mousePressed (_ e: java.awt.event.MouseEvent)
    func mouseReleased(_ e: java.awt.event.MouseEvent)
    func mouseEntered (_ e: java.awt.event.MouseEvent)
    func mouseExited  (_ e: java.awt.event.MouseEvent)
  }

  @MainActor
  public protocol MouseMotionListener: java.util.EventListener {
    func mouseDragged(_ e: java.awt.event.MouseEvent)
    func mouseMoved  (_ e: java.awt.event.MouseEvent)
  }
}
