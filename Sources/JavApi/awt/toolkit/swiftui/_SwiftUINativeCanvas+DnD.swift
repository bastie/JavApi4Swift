/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(AppKit) && os(macOS)
import AppKit

// =============================================================================
// MARK: - Drag source: mouse-event hooks for DnD gesture recognisers
// =============================================================================

extension _SwiftUINativeCanvas {

  /// Dispatches mouseDown to all `_AppKitMouseDragGestureRecognizer`s on the
  /// hit component. Call at the end of `mouseDown(with:)`.
  func _dndMouseDown(event: NSEvent, pt: CGPoint) {
    guard let root = component,
          let hit  = _SwiftUIHitTest.find(at: pt, in: root) else { return }
    for r in hit._dragGestureRecognizers {
      if let appKitR = r as? java.awt.dnd._AppKitMouseDragGestureRecognizer {
        appKitR.canvas = self
        appKitR.mousePressedWithNSEvent(event, x: Int(pt.x), y: Int(pt.y))
      }
    }
  }

  /// Dispatches mouseDragged to all `_AppKitMouseDragGestureRecognizer`s on the
  /// hit component. Call from the generic fallback in `mouseDragged(with:)`.
  ///
  /// Returns `true` if a native drag session was initiated (caller should return
  /// early and not process further drag semantics).
  @discardableResult
  func _dndMouseDragged(event: NSEvent, pt: CGPoint) -> Bool {
    guard let root = component,
          let hit  = _SwiftUIHitTest.find(at: pt, in: root) else { return false }
    var initiated = false
    for r in hit._dragGestureRecognizers {
      if let appKitR = r as? java.awt.dnd._AppKitMouseDragGestureRecognizer {
        appKitR.canvas = self
        // mouseDraggedWithNSEvent may synchronously call beginDraggingSession
        appKitR.mouseDraggedWithNSEvent(event, x: Int(pt.x), y: Int(pt.y))
        initiated = true
      }
    }
    return initiated
  }

  /// Dispatches mouseUp to all recognisers across all components.
  /// Call at the start of `mouseUp(with:)` (before other handling).
  func _dndMouseUp(event: NSEvent) {
    guard let root = component else { return }
    _dndVisitRecognizers(in: root) { r in
      r.mouseUpWithNSEvent(event)
    }
  }

  /// Recursively visits all `_AppKitMouseDragGestureRecognizer`s in the tree.
  private func _dndVisitRecognizers(
    in comp: java.awt.Component,
    block: (java.awt.dnd._AppKitMouseDragGestureRecognizer) -> Void
  ) {
    for r in comp._dragGestureRecognizers {
      if let appKitR = r as? java.awt.dnd._AppKitMouseDragGestureRecognizer {
        block(appKitR)
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
// MARK: - Drop target: NSDraggingDestination
// =============================================================================

extension _SwiftUINativeCanvas {

  // ── Registration ─────────────────────────────────────────────────────────────

  /// Registers this view to receive all drag types we can bridge.
  ///
  /// Call once after the view is set up (e.g., in `subscribeNotifications`).
  func _registerForDnDTypes() {
    registerForDraggedTypes([
      .string,
      .fileURL,
      .tiff,
      .png,
    ])
  }

  // ── Hit testing helper ────────────────────────────────────────────────────

  private func _dropTargetAndListeners(
    at pt: CGPoint
  ) -> (java.awt.dnd.DropTarget, [any java.awt.dnd.DropTargetListener])? {
    guard let root = component,
          let hit  = _SwiftUIHitTest.find(at: pt, in: root),
          let dt   = hit.getDropTarget(),
          dt.isActive() else { return nil }
    // Collect listeners registered on the DropTarget
    // (We expose them via the context to keep the API surface minimal)
    let ctx = dt.getDropTargetContext()
    _ = ctx  // used below for events
    return (dt, [])   // listeners accessed through DropTargetListener stored on DropTarget
  }

  // ── NSDraggingDestination ─────────────────────────────────────────────────

  public override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
    let pt  = convert(sender.draggingLocation, from: nil)
    let awt = CGPoint(x: pt.x, y: pt.y)
    guard let root = component,
          let hit  = _SwiftUIHitTest.find(at: awt, in: root),
          let dt   = hit.getDropTarget(),
          dt.isActive() else { return [] }

    let ctx    = dt.getDropTargetContext()
    let origin = _SwingHitTest.absoluteOrigin(hit)
    let lx = Int(awt.x) - origin.x
    let ly = Int(awt.y) - origin.y
    let srcActions = java.awt.dnd.DnDConstants.ACTION_COPY_OR_MOVE
    let dropAction = java.awt.dnd._AppKitPasteboardBridge.dndAction(
      from: sender.draggingSourceOperationMask)
    let dtde = java.awt.dnd.DropTargetDragEvent(
      ctx,
      cursorLocation: java.awt.Point(lx, ly),
      dropAction: dropAction,
      srcActions: srcActions)

    for l in dt._listenerArray { l.dragEnter(dtde) }
    return sender.draggingSourceOperationMask
  }

  public override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
    let pt  = convert(sender.draggingLocation, from: nil)
    let awt = CGPoint(x: pt.x, y: pt.y)
    guard let root = component,
          let hit  = _SwiftUIHitTest.find(at: awt, in: root),
          let dt   = hit.getDropTarget(),
          dt.isActive() else { return [] }

    let ctx    = dt.getDropTargetContext()
    let origin = _SwingHitTest.absoluteOrigin(hit)
    let lx = Int(awt.x) - origin.x
    let ly = Int(awt.y) - origin.y
    let dropAction = java.awt.dnd._AppKitPasteboardBridge.dndAction(
      from: sender.draggingSourceOperationMask)
    let dtde = java.awt.dnd.DropTargetDragEvent(
      ctx,
      cursorLocation: java.awt.Point(lx, ly),
      dropAction: dropAction,
      srcActions: java.awt.dnd.DnDConstants.ACTION_COPY_OR_MOVE)

    for l in dt._listenerArray { l.dragOver(dtde) }
    return sender.draggingSourceOperationMask
  }

  public override func draggingExited(_ sender: NSDraggingInfo?) {
    guard let sender else { return }
    let pt  = convert(sender.draggingLocation, from: nil)
    let awt = CGPoint(x: pt.x, y: pt.y)
    guard let root = component,
          let hit  = _SwiftUIHitTest.find(at: awt, in: root),
          let dt   = hit.getDropTarget() else { return }

    let ctx  = dt.getDropTargetContext()
    let dte  = java.awt.dnd.DropTargetEvent(ctx)
    for l in dt._listenerArray { l.dragExit(dte) }
  }

  public override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
    let pt  = convert(sender.draggingLocation, from: nil)
    let awt = CGPoint(x: pt.x, y: pt.y)
    guard let root = component,
          let hit  = _SwiftUIHitTest.find(at: awt, in: root),
          let dt   = hit.getDropTarget(),
          dt.isActive() else { return false }

    let ctx    = dt.getDropTargetContext()
    let origin = _SwingHitTest.absoluteOrigin(hit)
    let lx = Int(awt.x) - origin.x
    let ly = Int(awt.y) - origin.y
    let dropAction = java.awt.dnd._AppKitPasteboardBridge.dndAction(
      from: sender.draggingSourceOperationMask)
    let isLocal = sender.draggingSource is java.awt.dnd._AppKitDraggingSourceHelper

    let dtde = java.awt.dnd.DropTargetDropEvent(
      ctx,
      cursorLocation: java.awt.Point(lx, ly),
      dropAction: dropAction,
      srcActions: java.awt.dnd.DnDConstants.ACTION_COPY_OR_MOVE,
      isLocal: isLocal)

    // Attach the transferable from the pasteboard
    let transferable = java.awt.dnd._AppKitPasteboardBridge.transferable(from: sender)
    _ = transferable  // available for DropTargetListener via NSDraggingInfo

    var accepted = false
    for l in dt._listenerArray {
      l.drop(dtde)
      accepted = true
    }
    return accepted
  }

  public override func concludeDragOperation(_ sender: NSDraggingInfo?) {
    needsDisplay = true
  }
}

#endif
