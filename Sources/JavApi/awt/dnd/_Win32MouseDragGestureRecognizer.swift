/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if os(Windows)
import WinSDK

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
  /// ### Step 4b — OLE DnD
  ///
  /// `_startDragOperation` calls `DoDragDrop` with COM `IDropSource` /
  /// `IDataObject` so that drags work across application boundaries
  /// (e.g. dragging text into Windows Explorer or other Win32 apps).
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

    /// Initiates the DnD operation via OLE `DoDragDrop`.
    ///
    /// Lazily initialises OLE, wraps the `Transferable` in an `IDataObject`,
    /// creates an `IDropSource`, and calls `DoDragDrop` — which blocks and
    /// pumps Win32 messages until the drag ends.  On return, fires
    /// `DragSourceDropEvent` on the registered listener.
    public func _startDragOperation(
      transferable: any java.awt.datatransfer.Transferable,
      cursor: java.awt.Cursor?,
      dsl: (any DragSourceListener)?
    ) {
      // ── OLE DoDragDrop ──────────────────────────────────────────────────────
      _Win32OLE.ensureInitialized()

      let dataObject = _Win32OLEDataObject(transferable: transferable)
      let dropSource = _Win32OLEDropSource()

      // Allow copy + move + link; the drop target picks the effective action.
      let allowed: DWORD = _DROPEFFECT_COPY | _DROPEFFECT_MOVE | _DROPEFFECT_LINK
      var actual:  DWORD = _DROPEFFECT_NONE

      // Blocks until the drag ends (pumps its own Win32 message loop).
      let hr = DoDragDrop(dataObject.asIDataObject,
                          dropSource.asIDropSource,
                          allowed,
                          &actual)

      // ── Notify DragSourceListener ────────────────────────────────────────
      let success = hr == _DRAGDROP_S_DROP
      let action  = _dropEffectToJavaAction(actual)
      let ctx     = DragSourceContext(component: component,
                                      transferable: transferable)
      if let dsl { ctx.addDragSourceListener(dsl) }
      let endEvt  = DragSourceDropEvent(ctx, dropAction: action, success: success)
      dsl?.dragDropEnd(endEvt)
    }
  }
}

// =============================================================================
// MARK: - Helper
// =============================================================================

/// Maps a Win32 `DROPEFFECT` bitmask to a Java DnD action constant.
private func _dropEffectToJavaAction(_ effect: DWORD) -> Int {
  if effect & _DROPEFFECT_MOVE != 0 { return java.awt.dnd.DnDConstants.ACTION_MOVE }
  if effect & _DROPEFFECT_COPY != 0 { return java.awt.dnd.DnDConstants.ACTION_COPY }
  if effect & _DROPEFFECT_LINK != 0 { return java.awt.dnd.DnDConstants.ACTION_LINK }
  return java.awt.dnd.DnDConstants.ACTION_NONE
}

#endif // os(Windows)
