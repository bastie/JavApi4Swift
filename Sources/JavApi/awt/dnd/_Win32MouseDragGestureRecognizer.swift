/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if os(Windows)

extension java.awt.dnd {

  /// Windows-specific `MouseDragGestureRecognizer` that integrates with
  /// `_Win32Canvas` to detect drag gestures and initiate DnD operations.
  ///
  /// ### How it works
  ///
  /// `_Win32Canvas` calls `mousePressedAt(_:_:)` from `onMouseDown`,
  /// `mouseDraggedAt(_:_:)` from `onMouseDrag`, and `mouseReleased()` from
  /// `onMouseUp`. When the Chebyshev distance from the press origin exceeds
  /// `DragSource.getDragThreshold()`, `fireDragGestureRecognized` is called,
  /// which notifies all `DragGestureListener`s. The listener may then call
  /// `event.startDrag(…)` → `_startDragOperation(…)`, which fires the Java
  /// `DragSourceListener.dragDropEnd` (intra-app DnD).
  ///
  /// ### Step 4b note
  ///
  /// For systemwide DnD (drag to/from Explorer), `_startDragOperation` would
  /// call `DoDragDrop` with COM `IDropSource`/`IDataObject`. That is tracked
  /// as Step 4b and the implementation here intentionally uses the headless
  /// fallback in `DragSource.startDrag`.
  ///
  /// - Since: Java 1.2 (Windows backend, Step 4a)
  @MainActor
  public final class _Win32MouseDragGestureRecognizer: MouseDragGestureRecognizer {

    // ── Initialisers ──────────────────────────────────────────────────────────

    public override init(dragSource: DragSource,
                         component: java.awt.Component,
                         dragAction: Int) {
      super.init(dragSource: dragSource, component: component, dragAction: dragAction)
    }

    // ── Called by _Win32Canvas ────────────────────────────────────────────────

    /// Entry point from `_Win32Canvas.onMouseDown(x:y:)`.
    public func mousePressedAt(_ x: Int, _ y: Int) {
      mousePressed(x, y)
    }

    /// Entry point from `_Win32Canvas.onMouseDrag(x:y:)`.
    ///
    /// Delegates to the platform-independent threshold logic; may synchronously
    /// fire a gesture and call `_startDragOperation` via the listener.
    public func mouseDraggedAt(_ x: Int, _ y: Int) {
      mouseDragged(x, y)
    }

    /// Entry point from `_Win32Canvas.onMouseUp(x:y:)`.
    public override func mouseReleased() {
      super.mouseReleased()
    }

    // ── Called by DragGestureEvent.startDrag (Windows path) ──────────────────

    /// Initiates the DnD operation.
    ///
    /// **Step 4a:** fires `DragSource.startDrag` (headless path — notifies Java
    /// listeners with a failed drop). Full OLE `DoDragDrop` integration is
    /// tracked as Step 4b.
    public func _startDragOperation(
      transferable: any java.awt.datatransfer.Transferable,
      cursor: java.awt.Cursor?,
      dsl: (any DragSourceListener)?
    ) {
      // Build a synthetic DragGestureEvent so DragSource.startDrag has a trigger.
      let origin = java.awt.Point(0, 0)
      let evt    = DragGestureEvent(self,
                                    dragAction: sourceActions,
                                    origin: origin)
      dragSource.startDrag(trigger: evt,
                           dragCursor: cursor,
                           transferable: transferable,
                           dsl: dsl)
    }
  }
}

#endif // os(Windows)
