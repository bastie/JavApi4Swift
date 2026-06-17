/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.event {
 
  /// - Since: Java 1.1
  open class MouseMotionAdapter : java.awt.event.MouseMotionListener {
    public init () {}
    open func mouseDragged(_ e: java.awt.event.MouseEvent){}
    open func mouseMoved  (_ e: java.awt.event.MouseEvent){}
  }
}
