/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.event {

  /// Convenience base class for receiving both mouse and mouse-motion events.
  ///
  /// Implements ``MouseInputListener`` (= ``MouseListener`` + ``MouseMotionListener``)
  /// with empty default methods — override only those you need.
  ///
  /// - Since: Swing 1.0 / Java 1.1 era (JFC add-on)
  @MainActor
  open class MouseInputAdapter: java.awt.event.MouseAdapter, java.awt.event.MouseMotionListener {
    public override init() {}
    open func mouseMoved  (_ e: java.awt.event.MouseEvent) {}
    open func mouseDragged(_ e: java.awt.event.MouseEvent) {}
  }
}
