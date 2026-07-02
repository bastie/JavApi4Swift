/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if os(Windows)
import WinSDK

// =============================================================================
// MARK: - Drag source: mouse-event hooks for DnD gesture recognisers
// =============================================================================

extension _Win32Canvas {

  /// Dispatches mouseDown to all `_Win32MouseDragGestureRecognizer`s on the
  /// hit component. Call at the end of `onMouseDown(x:y:)`.
  func _dndMouseDown(x: Int, y: Int) {
    guard let hit = _SwingHitTest.find(x: x, y: y, in: awtWindow) else { return }
    for r in hit._dragGestureRecognizers {
      if let win32R = r as? java.awt.dnd._Win32MouseDragGestureRecognizer {
        win32R.mousePressedAt(x, y)
      }
    }
  }

  /// Dispatches mouseDragged to all `_Win32MouseDragGestureRecognizer`s across
  /// the entire component tree. Call from `onMouseDrag(x:y:)`.
  ///
  /// Visits all registered recognizers because the hit component may have
  /// changed since `mouseDown` (pointer can leave the component while dragging).
  func _dndMouseDragged(x: Int, y: Int) {
    _dndVisitRecognizers(in: awtWindow) { r in
      r.mouseDraggedAt(x, y)
    }
  }

  /// Dispatches mouseUp to all `_Win32MouseDragGestureRecognizer`s.
  /// Call at the start of `onMouseUp(x:y:)`.
  func _dndMouseUp() {
    _dndVisitRecognizers(in: awtWindow) { r in
      r.mouseReleased()
    }
  }

  /// Recursively visits all `_Win32MouseDragGestureRecognizer`s in the tree.
  private func _dndVisitRecognizers(
    in comp: java.awt.Component,
    block: (java.awt.dnd._Win32MouseDragGestureRecognizer) -> Void
  ) {
    for r in comp._dragGestureRecognizers {
      if let win32R = r as? java.awt.dnd._Win32MouseDragGestureRecognizer {
        block(win32R)
      }
    }
    if let container = comp as? java.awt.Container {
      for child in container.getComponents() {
        _dndVisitRecognizers(in: child, block: block)
      }
    }
  }
}

// =============================================================================
// MARK: - Drop target: registration stub (Step 4b: OLE RegisterDragDrop)
// =============================================================================

extension _Win32Canvas {

  /// Registers this window as a drop target.
  ///
  /// **Step 4a stub** — a full OLE implementation would call
  /// `RegisterDragDrop(hwnd, dropTargetComObject)` here. Until Step 4b is
  /// implemented, this is intentionally a no-op so the rest of the DnD API
  /// (DragGestureListener, DragSourceListener) works for intra-app DnD.
  func _registerDropTarget() {
    // TODO (Step 4b): OleInitialize() + RegisterDragDrop(hwnd, IDropTarget)
  }

  /// Dispatches a simulated "drag entered" event to the `DropTarget` under (x,y).
  ///
  /// Called from the OLE `IDropTarget.DragEnter` implementation (Step 4b).
  func _dndDragEntered(x: Int, y: Int, sourceActions: Int, dropAction: Int) {
    guard let hit = _SwingHitTest.find(x: x, y: y, in: awtWindow),
          let dt  = hit.getDropTarget(),
          dt.isActive() else { return }
    let ctx  = dt.getDropTargetContext()
    let origin = _SwingHitTest.absoluteOrigin(hit)
    let dtde = java.awt.dnd.DropTargetDragEvent(
      ctx,
      cursorLocation: java.awt.Point(x - origin.x, y - origin.y),
      dropAction: dropAction,
      srcActions: sourceActions)
    for l in dt._listenerArray { l.dragEnter(dtde) }
  }

  /// Dispatches a simulated "drag over" event to the `DropTarget` under (x,y).
  func _dndDragOver(x: Int, y: Int, sourceActions: Int, dropAction: Int) {
    guard let hit = _SwingHitTest.find(x: x, y: y, in: awtWindow),
          let dt  = hit.getDropTarget(),
          dt.isActive() else { return }
    let ctx  = dt.getDropTargetContext()
    let origin = _SwingHitTest.absoluteOrigin(hit)
    let dtde = java.awt.dnd.DropTargetDragEvent(
      ctx,
      cursorLocation: java.awt.Point(x - origin.x, y - origin.y),
      dropAction: dropAction,
      srcActions: sourceActions)
    for l in dt._listenerArray { l.dragOver(dtde) }
  }

  /// Dispatches a simulated "drag exited" event to the `DropTarget` under (x,y).
  func _dndDragExited(x: Int, y: Int) {
    guard let hit = _SwingHitTest.find(x: x, y: y, in: awtWindow),
          let dt  = hit.getDropTarget() else { return }
    let ctx = dt.getDropTargetContext()
    let dte = java.awt.dnd.DropTargetEvent(ctx)
    for l in dt._listenerArray { l.dragExit(dte) }
  }

  /// Dispatches a simulated "drop" event to the `DropTarget` under (x,y).
  func _dndDrop(x: Int, y: Int,
                transferable: any java.awt.datatransfer.Transferable,
                sourceActions: Int, dropAction: Int,
                isLocal: Bool) -> Bool {
    guard let hit = _SwingHitTest.find(x: x, y: y, in: awtWindow),
          let dt  = hit.getDropTarget(),
          dt.isActive() else { return false }
    let ctx  = dt.getDropTargetContext()
    let origin = _SwingHitTest.absoluteOrigin(hit)
    let dtde = java.awt.dnd.DropTargetDropEvent(
      ctx,
      cursorLocation: java.awt.Point(x - origin.x, y - origin.y),
      dropAction: dropAction,
      srcActions: sourceActions,
      isLocal: isLocal)
    _ = transferable  // available for DropTargetListener via event
    var accepted = false
    for l in dt._listenerArray { l.drop(dtde); accepted = true }
    return accepted
  }
}

#endif // os(Windows)
