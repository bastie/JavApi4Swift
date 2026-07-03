/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.dnd {

  /// Abstract adapter class for drop-target events —
  /// mirrors `java.awt.dnd.DropTargetAdapter`.
  ///
  /// Implements `DropTargetListener` with empty default methods so that
  /// subclasses only need to override the methods they care about.
  /// In practice `drop(_:)` must always be overridden to accept or reject
  /// the drop and call `dropComplete(_:)`.
  ///
  /// ```swift
  /// class MyDTL: java.awt.dnd.DropTargetAdapter {
  ///   override func dragEnter(_ e: java.awt.dnd.DropTargetDragEvent) {
  ///     e.acceptDrag(java.awt.dnd.DnDConstants.ACTION_COPY)
  ///   }
  ///   override func drop(_ e: java.awt.dnd.DropTargetDropEvent) {
  ///     e.acceptDrop(java.awt.dnd.DnDConstants.ACTION_COPY)
  ///     // … read transferable …
  ///     e.dropComplete(true)
  ///   }
  /// }
  /// ```
  ///
  /// - Since: Java 1.4
  open class DropTargetAdapter: DropTargetListener {

    public init() {}

    // ── DropTargetListener ────────────────────────────────────────────────────

    /// Called when a drag enters the drop target. Default: no-op.
    open func dragEnter(_ dtde: DropTargetDragEvent) {}

    /// Called when a drag moves over the drop target. Default: no-op.
    open func dragOver(_ dtde: DropTargetDragEvent) {}

    /// Called when the drop action changes over the drop target. Default: no-op.
    open func dropActionChanged(_ dtde: DropTargetDragEvent) {}

    /// Called when the drag exits the drop target. Default: no-op.
    open func dragExit(_ dte: DropTargetEvent) {}

    /// Called when a drop occurs on the drop target. Default: no-op.
    ///
    /// - Important: Override this method and call `e.acceptDrop(_:)` followed
    ///   by `e.dropComplete(_:)`, otherwise the drop will not be completed.
    open func drop(_ dtde: DropTargetDropEvent) {}
  }
}
