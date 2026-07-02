/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(AppKit) && os(macOS)
import AppKit

extension java.awt.dnd {

  /// AppKit-side drag-source object — implements `NSDraggingSource` so AppKit
  /// can call us back during a live drag session.
  ///
  /// Created transiently by `_AppKitMouseDragGestureRecognizer._beginDraggingSession`
  /// and kept alive for the duration of the drag session via a strong reference
  /// stored in `_SwiftUINativeCanvas`.
  @MainActor
  final class _AppKitDraggingSourceHelper: NSObject, NSDraggingSource {

    /// The source context that carries the transferable and listeners.
    let dragSourceContext: DragSourceContext

    /// The registered drag-source listeners (Java side).
    private let sourceListeners: [any DragSourceListener]

    /// The allowed actions (converted from `DnDConstants`).
    private let allowedActions: Int

    init(context: DragSourceContext,
         sourceActions: Int,
         listeners: [any DragSourceListener] = []) {
      self.dragSourceContext = context
      self.allowedActions    = sourceActions
      self.sourceListeners   = listeners
    }

    // ── NSDraggingSource ─────────────────────────────────────────────────────

    nonisolated func draggingSession(
      _ session: NSDraggingSession,
      sourceOperationMaskFor context: NSDraggingContext
    ) -> NSDragOperation {
      MainActor.assumeIsolated {
        _AppKitPasteboardBridge.dragOperation(from: allowedActions)
      }
    }

    nonisolated func draggingSession(
      _ session: NSDraggingSession,
      willBeginAt screenPoint: NSPoint
    ) {
      // Could notify DragSourceMotionListeners here in a future step
    }

    nonisolated func draggingSession(
      _ session: NSDraggingSession,
      movedTo screenPoint: NSPoint
    ) {
      // Mouse-moved notifications for DragSourceMotionListeners (future step)
    }

    nonisolated func draggingSession(
      _ session: NSDraggingSession,
      endedAt screenPoint: NSPoint,
      operation: NSDragOperation
    ) {
      MainActor.assumeIsolated {
        let action  = _AppKitPasteboardBridge.dndAction(from: operation)
        let success = operation != []
        let endEvt  = DragSourceDropEvent(
          dragSourceContext,
          dropAction: action,
          success: success
        )
        for l in sourceListeners { l.dragDropEnd(endEvt) }
      }
    }

    // ── NSDraggingItem factory ────────────────────────────────────────────────

    /// Builds an `NSDraggingItem` from the stored transferable.
    func makeDraggingItem() -> NSDraggingItem {
      let pbItems = _AppKitPasteboardBridge.pasteboardItems(
        for: dragSourceContext.transferable
      )
      let item = NSDraggingItem(pasteboardWriter: pbItems.first ?? NSPasteboardItem())
      return item
    }
  }
}

#endif
