/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.dnd {

  /// Listener for drag-source motion events — mirrors `java.awt.dnd.DragSourceMotionListener`.
  ///
  /// - Since: Java 1.4
  public protocol DragSourceMotionListener: AnyObject {

    /// Called when the mouse is moved during a drag operation.
    func dragMouseMoved(_ dsde: DragSourceDragEvent)
  }
}
