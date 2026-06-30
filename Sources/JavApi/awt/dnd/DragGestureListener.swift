/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.dnd {

  /// Listener that is notified when a drag gesture is recognised —
  /// mirrors `java.awt.dnd.DragGestureListener`.
  ///
  /// - Since: Java 1.2
  public protocol DragGestureListener: AnyObject {

    /// Called when a drag gesture has been initiated.
    func dragGestureRecognized(_ dge: DragGestureEvent)
  }
}
