/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {
  /// - Since: Java 1.1
  @MainActor
  public protocol ContainerListener: java.util.EventListener {
    func componentAdded (_ e: java.awt.event.ContainerEvent)
    func componentRemoved  (_ e: java.awt.event.ContainerEvent)
  }
}
