/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {
  /// Convencience class for `ComponentListener`
  /// - Since: Java 1.1
  @MainActor
  open class ComponentAdapter : ComponentListener {
    open func componentResized(_ e: java.awt.event.ComponentEvent){}
    open func componentMoved  (_ e: java.awt.event.ComponentEvent){}
    open func componentShown  (_ e: java.awt.event.ComponentEvent){}
    open func componentHidden (_ e: java.awt.event.ComponentEvent){}
  }
}
