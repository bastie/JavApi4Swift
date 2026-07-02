/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.dnd {

  /// Event fired when a drag gesture is recognised —
  /// mirrors `java.awt.dnd.DragGestureEvent`.
  ///
  /// - Since: Java 1.2
  public final class DragGestureEvent {

    /// The recogniser that fired this event.
    public private(set) var dragGestureRecognizer: DragGestureRecognizer

    /// The drag action.
    public private(set) var dragAction: Int

    /// The origin of the drag (screen-relative, headless: 0,0).
    public private(set) var dragOrigin: java.awt.Point

    /// The component that initiated the drag.
    public var component: java.awt.Component {
      dragGestureRecognizer.component
    }

    /// The `DragSource` that created the recogniser.
    public var dragSource: DragSource {
      dragGestureRecognizer.dragSource
    }

    /// Creates a `DragGestureEvent`.
    public init(_ recognizer: DragGestureRecognizer,
                dragAction: Int,
                origin: java.awt.Point) {
      self.dragGestureRecognizer = recognizer
      self.dragAction = dragAction
      self.dragOrigin = origin
    }

    /// Returns the origin of the drag gesture.
    public func getDragOrigin() -> java.awt.Point { dragOrigin }

    /// Returns the drag action.
    public func getDragAction() -> Int { dragAction }

    /// Starts the drag operation.
    ///
    /// On macOS, initiates a native AppKit drag session via
    /// `_AppKitMouseDragGestureRecognizer._beginDraggingSession`.
    /// On other platforms / headless, this is a no-op.
    ///
    /// - Parameters:
    ///   - dragCursor: The cursor to show during the drag (ignored headless / macOS uses system cursors).
    ///   - transferable: The data to be transferred.
    ///   - dsl: Optional drag source listener.
    @MainActor public func startDrag(dragCursor: java.awt.Cursor?,
                          transferable: any java.awt.datatransfer.Transferable,
                          dsl: (any DragSourceListener)? = nil) {
#if canImport(AppKit) && os(macOS)
      if let appKitRec = dragGestureRecognizer as? _AppKitMouseDragGestureRecognizer {
        appKitRec._beginDraggingSession(transferable: transferable,
                                        cursor: dragCursor,
                                        dsl: dsl)
        return
      }
#endif
#if os(Windows)
      if let win32Rec = dragGestureRecognizer as? _Win32MouseDragGestureRecognizer {
        win32Rec._startDragOperation(transferable: transferable,
                                     cursor: dragCursor,
                                     dsl: dsl)
        return
      }
#endif
      // headless no-op
    }
  }
}
