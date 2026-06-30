/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.dnd {

  /// Represents the initiator of a drag-and-drop operation —
  /// mirrors `java.awt.dnd.DragSource`.
  ///
  /// In headless mode all drag operations are no-ops; the default instance
  /// is always non-nil.
  ///
  /// - Since: Java 1.2
  open class DragSource {

    // ── Default cursors (headless: all nil) ───────────────────────────────────

    /// Cursor to display when a copy operation is possible.
    public nonisolated(unsafe) static let DefaultCopyDrop:    java.awt.Cursor? = nil
    /// Cursor to display when a move operation is possible.
    public nonisolated(unsafe) static let DefaultMoveDrop:    java.awt.Cursor? = nil
    /// Cursor to display when a link operation is possible.
    public nonisolated(unsafe) static let DefaultLinkDrop:    java.awt.Cursor? = nil
    /// Cursor to display when no drop is possible.
    public nonisolated(unsafe) static let DefaultCopyNoDrop:  java.awt.Cursor? = nil
    /// Cursor to display when no move drop is possible.
    public nonisolated(unsafe) static let DefaultMoveNoDrop:  java.awt.Cursor? = nil
    /// Cursor to display when no link drop is possible.
    public nonisolated(unsafe) static let DefaultLinkNoDrop:  java.awt.Cursor? = nil

    // ── Singleton ─────────────────────────────────────────────────────────────

    private nonisolated(unsafe) static var _defaultDragSource: DragSource?

    /// Returns the default `DragSource` instance.
    public static func getDefaultDragSource() -> DragSource {
      if _defaultDragSource == nil {
        _defaultDragSource = DragSource()
      }
      return _defaultDragSource!
    }

    /// Whether drag-and-drop is supported on this platform (headless: false).
    public static func isDragImageSupported() -> Bool { false }

    // ── Listeners ─────────────────────────────────────────────────────────────

    private var motionListeners: [(any DragSourceMotionListener)] = []
    private var sourceListeners: [(any DragSourceListener)] = []

    // ── Initialisers ──────────────────────────────────────────────────────────

    public init() {}

    // ── API ───────────────────────────────────────────────────────────────────

    /// Creates a `DragGestureRecognizer` for the given component (headless stub).
    ///
    /// - Parameters:
    ///   - recognizerAbstractClass: Ignored; `MouseDragGestureRecognizer` is always returned.
    ///   - component: The component to monitor.
    ///   - actions: The drag actions to recognise.
    ///   - dgl: The listener to notify when a gesture is recognised.
    /// - Returns: A headless `MouseDragGestureRecognizer`.
    public func createDragGestureRecognizer(
      _ recognizerAbstractClass: AnyClass,
      _ component: java.awt.Component,
      _ actions: Int,
      _ dgl: any DragGestureListener
    ) -> DragGestureRecognizer {
      let r = MouseDragGestureRecognizer(dragSource: self, component: component, dragAction: actions)
      r.addDragGestureListener(dgl)
      return r
    }

    /// Starts a drag operation (no-op in headless mode).
    ///
    /// - Parameters:
    ///   - trigger:      The gesture event that triggered the drag.
    ///   - dragCursor:   The cursor to show during drag (ignored headless).
    ///   - transferable: The data to be transferred.
    ///   - dsl:          Optional drag-source listener.
    public func startDrag(
      trigger: DragGestureEvent,
      dragCursor: java.awt.Cursor?,
      transferable: any java.awt.datatransfer.Transferable,
      dsl: (any DragSourceListener)? = nil
    ) {
      // headless no-op
    }

    /// Adds a `DragSourceListener`.
    public func addDragSourceListener(_ dsl: any DragSourceListener) {
      sourceListeners.append(dsl)
    }

    /// Removes a `DragSourceListener`.
    public func removeDragSourceListener(_ dsl: any DragSourceListener) {
      let id = ObjectIdentifier(dsl)
      sourceListeners.removeAll { ObjectIdentifier($0) == id }
    }

    /// Adds a `DragSourceMotionListener`.
    public func addDragSourceMotionListener(_ dsml: any DragSourceMotionListener) {
      motionListeners.append(dsml)
    }

    /// Removes a `DragSourceMotionListener`.
    public func removeDragSourceMotionListener(_ dsml: any DragSourceMotionListener) {
      let id = ObjectIdentifier(dsml)
      motionListeners.removeAll { ObjectIdentifier($0) == id }
    }
  }
}
