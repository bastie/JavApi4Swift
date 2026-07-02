/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(AppKit) && os(macOS)
import AppKit

extension java.awt.dnd {

  /// macOS-specific `MouseDragGestureRecognizer` that integrates with
  /// `_SwiftUINativeCanvas` to initiate native AppKit drag sessions.
  ///
  /// ### How it works
  ///
  /// `_SwiftUINativeCanvas` calls `mouseDraggedWithNSEvent(_:x:y:)` from its
  /// `mouseDragged(with:)` override whenever the recognised drag threshold is
  /// not yet handled by other components (scrollbars, split panes, …).
  ///
  /// If the Chebyshev distance from the press origin exceeds
  /// `DragSource.getDragThreshold()`, `fireDragGestureRecognized` is called
  /// synchronously. The `DragGestureListener` then calls `event.startDrag(…)`,
  /// which delegates to `_beginDraggingSession(…)` below — still inside the
  /// same synchronous call stack, so `beginDraggingSession(with:event:source:)`
  /// receives the original `NSEvent` as required by AppKit.
  ///
  /// - Since: Java 1.2 (macOS backend, Step 2)
  @MainActor
  public final class _AppKitMouseDragGestureRecognizer: MouseDragGestureRecognizer {

    /// Weak back-reference to the canvas that dispatches mouse events.
    internal weak var canvas: AnyObject? // typed as AnyObject to avoid import cycle;
    // cast to _SwiftUINativeCanvas at call sites

    /// The NSEvent that arrived with the most recent mouseDragged call.
    /// Only valid inside the synchronous gesture→startDrag call stack.
    private var _pendingNSEvent: NSEvent? = nil

    /// Active helper kept alive for the duration of the drag session.
    private var _activeHelper: _AppKitDraggingSourceHelper? = nil

    // ── Initialiser ───────────────────────────────────────────────────────────

    public override init(dragSource: DragSource,
                         component: java.awt.Component,
                         dragAction: Int) {
      super.init(dragSource: dragSource, component: component, dragAction: dragAction)
    }

    // ── Called by _SwiftUINativeCanvas ────────────────────────────────────────

    /// Entry point from `_SwiftUINativeCanvas.mouseDown(with:)`.
    public func mousePressedWithNSEvent(_ event: NSEvent, x: Int, y: Int) {
      mousePressed(x, y)
    }

    /// Entry point from `_SwiftUINativeCanvas.mouseDragged(with:)`.
    ///
    /// Stores the NSEvent so `_beginDraggingSession` can use it, then
    /// delegates to the platform-independent threshold logic.
    public func mouseDraggedWithNSEvent(_ event: NSEvent, x: Int, y: Int) {
      _pendingNSEvent = event
      mouseDragged(x, y)   // may synchronously fire gesture → startDrag
      _pendingNSEvent = nil
    }

    /// Entry point from `_SwiftUINativeCanvas.mouseUp(with:)`.
    public func mouseUpWithNSEvent(_ event: NSEvent) {
      mouseReleased()
    }

    // ── Called by DragGestureEvent.startDrag (macOS path) ────────────────────

    /// Initiates a native AppKit drag session.
    ///
    /// Must be called synchronously from within `mouseDraggedWithNSEvent` so
    /// that `_pendingNSEvent` is still set (AppKit requires the original event).
    public func _beginDraggingSession(
      transferable: any java.awt.datatransfer.Transferable,
      cursor: java.awt.Cursor?,
      dsl: (any DragSourceListener)?
    ) {
      guard let nsEvent   = _pendingNSEvent,
            let nsCanvas  = canvas as? _SwiftUINativeCanvas else { return }

      let ctx = DragSourceContext(component: component, transferable: transferable)
      if let dsl { ctx.addDragSourceListener(dsl) }

      var listeners: [any DragSourceListener] = []
      if let dsl { listeners.append(dsl) }

      let helper = _AppKitDraggingSourceHelper(
        context: ctx,
        sourceActions: sourceActions,
        listeners: listeners
      )
      _activeHelper = helper   // keep alive for the session

      let item = helper.makeDraggingItem()
      nsCanvas.beginDraggingSession(with: [item], event: nsEvent, source: helper)
    }
  }
}

#endif
