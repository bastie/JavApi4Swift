/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {
  /// - Since: Java 1.1
  @MainActor
  open class ContainerAdapter : ContainerListener {
    open func componentAdded (_ e: java.awt.event.ContainerEvent){}
    open func componentRemoved  (_ e: java.awt.event.ContainerEvent){}
  }
}
