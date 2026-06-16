/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {

  /// Convenience base class — override only the methods you need.
  /// - Since: Java 1.1
  @MainActor
  open class MouseAdapter: MouseListener, MouseMotionListener {
    public init() {}
    open func mouseClicked (_ e: java.awt.event.MouseEvent) {}
    open func mousePressed (_ e: java.awt.event.MouseEvent) {}
    open func mouseReleased(_ e: java.awt.event.MouseEvent) {}
    open func mouseEntered (_ e: java.awt.event.MouseEvent) {}
    open func mouseExited  (_ e: java.awt.event.MouseEvent) {}
    open func mouseMoved   (_ e: java.awt.event.MouseEvent) {}
    open func mouseDragged (_ e: java.awt.event.MouseEvent) {}
  }
}
