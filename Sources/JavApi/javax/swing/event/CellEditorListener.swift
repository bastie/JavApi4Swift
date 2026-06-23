/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.event {

  /// Listener notified when a `CellEditor` stops or cancels editing.
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol CellEditorListener: AnyObject, java.util.EventListener {

    /// Invoked when the cell editor has stopped editing (value accepted).
    func editingStopped(_ e: ChangeEvent)

    /// Invoked when the cell editor has cancelled editing (value discarded).
    func editingCanceled(_ e: ChangeEvent)
  }
}
