/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.event {

  /// Listener for `JPopupMenu` visibility changes.
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol PopupMenuListener: AnyObject, java.util.EventListener {

    /// Invoked before the popup menu becomes visible.
    func popupMenuWillBecomeVisible(_ e: PopupMenuEvent)

    /// Invoked before the popup menu becomes invisible.
    func popupMenuWillBecomeInvisible(_ e: PopupMenuEvent)

    /// Invoked when the popup menu is cancelled (dismissed without selection).
    func popupMenuCanceled(_ e: PopupMenuEvent)
  }
}
