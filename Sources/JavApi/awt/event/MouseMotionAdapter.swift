/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {

  /// Convenience base class for receiving mouse-motion events — override only the methods you need.
  ///
  /// Conforms to ``MouseMotionListener``. For click/press/release events subclass ``MouseAdapter``
  /// or implement ``MouseListener`` directly.
  /// - Since: Java 1.1
  @MainActor
  open class MouseMotionAdapter: MouseMotionListener {
    public init() {}
    open func mouseMoved  (_ e: java.awt.event.MouseEvent) {}
    open func mouseDragged(_ e: java.awt.event.MouseEvent) {}
  }
}
