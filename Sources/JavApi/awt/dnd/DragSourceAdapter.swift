/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.dnd {

  /// Abstract adapter class for drag-source events —
  /// mirrors `java.awt.dnd.DragSourceAdapter`.
  ///
  /// Implements both `DragSourceListener` and `DragSourceMotionListener` with
  /// empty default methods so that subclasses only need to override the methods
  /// they care about.
  ///
  /// ```swift
  /// class MyDSL: java.awt.dnd.DragSourceAdapter {
  ///   override func dragDropEnd(_ e: java.awt.dnd.DragSourceDropEvent) {
  ///     print("drop finished, success=\(e.getDropSuccess())")
  ///   }
  /// }
  /// ```
  ///
  /// - Since: Java 1.4
  open class DragSourceAdapter: DragSourceListener, DragSourceMotionListener {

    public init() {}

    // ── DragSourceListener ────────────────────────────────────────────────────

    /// Called when the cursor enters a drop target. Default: no-op.
    open func dragEnter(_ dsde: DragSourceDragEvent) {}

    /// Called when the cursor moves over a drop target. Default: no-op.
    open func dragOver(_ dsde: DragSourceDragEvent) {}

    /// Called when the drop action changes. Default: no-op.
    open func dropActionChanged(_ dsde: DragSourceDragEvent) {}

    /// Called when the cursor exits a drop target. Default: no-op.
    open func dragExit(_ dse: DragSourceEvent) {}

    /// Called when the drag-and-drop operation has ended. Default: no-op.
    open func dragDropEnd(_ dsde: DragSourceDropEvent) {}

    // ── DragSourceMotionListener ──────────────────────────────────────────────

    /// Called when the mouse moves during a drag. Default: no-op.
    open func dragMouseMoved(_ dsde: DragSourceDragEvent) {}
  }
}
