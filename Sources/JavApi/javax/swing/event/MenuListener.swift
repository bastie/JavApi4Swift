/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.event {

  /// Listener for `JMenu` selection state changes.
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol MenuListener: AnyObject, java.util.EventListener {

    /// Invoked when a menu is selected (highlighted).
    func menuSelected(_ e: MenuEvent)

    /// Invoked when a menu is deselected.
    func menuDeselected(_ e: MenuEvent)

    /// Invoked when a menu is cancelled (closed without selection).
    func menuCanceled(_ e: MenuEvent)
  }
}
