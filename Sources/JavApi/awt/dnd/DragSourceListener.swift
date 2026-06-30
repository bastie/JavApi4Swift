/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.dnd {

  /// Listener for drag-source events — mirrors `java.awt.dnd.DragSourceListener`.
  ///
  /// - Since: Java 1.2
  public protocol DragSourceListener: AnyObject {

    /// Called when the cursor's hot-spot enters a drop target.
    func dragEnter(_ dsde: DragSourceDragEvent)

    /// Called when the cursor's hot-spot moves over a drop target.
    func dragOver(_ dsde: DragSourceDragEvent)

    /// Called when the drop action changes.
    func dropActionChanged(_ dsde: DragSourceDragEvent)

    /// Called when the cursor's hot-spot exits a drop target.
    func dragExit(_ dse: DragSourceEvent)

    /// Called when the drop has completed.
    func dragDropEnd(_ dsde: DragSourceDropEvent)
  }
}
