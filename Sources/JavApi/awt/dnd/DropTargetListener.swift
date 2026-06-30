/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.dnd {

  /// Listener for drop-target events — mirrors `java.awt.dnd.DropTargetListener`.
  ///
  /// - Since: Java 1.2
  public protocol DropTargetListener: AnyObject {

    /// Called when a drag enters the drop target.
    func dragEnter(_ dtde: DropTargetDragEvent)

    /// Called when a drag moves over the drop target.
    func dragOver(_ dtde: DropTargetDragEvent)

    /// Called when the drop action changes over the drop target.
    func dropActionChanged(_ dtde: DropTargetDragEvent)

    /// Called when the drag exits the drop target.
    func dragExit(_ dte: DropTargetEvent)

    /// Called when a drop occurs on the drop target.
    func drop(_ dtde: DropTargetDropEvent)
  }
}
