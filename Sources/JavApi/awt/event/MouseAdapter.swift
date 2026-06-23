/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {

  /// Convenience base class for receiving mouse events — override only the methods you need.
  ///
  /// Conforms to ``MouseListener`` only. For motion events subclass ``MouseMotionAdapter``
  /// or implement ``MouseMotionListener`` directly.
  /// - Since: Java 1.1
  @MainActor
  open class MouseAdapter: MouseListener {
    public init() {}
    open func mouseClicked (_ e: java.awt.event.MouseEvent) {}
    open func mousePressed (_ e: java.awt.event.MouseEvent) {}
    open func mouseReleased(_ e: java.awt.event.MouseEvent) {}
    open func mouseEntered (_ e: java.awt.event.MouseEvent) {}
    open func mouseExited  (_ e: java.awt.event.MouseEvent) {}
  }
}
