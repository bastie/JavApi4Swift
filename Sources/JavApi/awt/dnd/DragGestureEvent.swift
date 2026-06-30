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

    /// Starts the drag operation (no-op in headless mode).
    ///
    /// - Parameters:
    ///   - dragCursor: Ignored in headless mode.
    ///   - transferable: The data to be transferred.
    ///   - dsl: Optional drag source listener.
    public func startDrag(dragCursor: java.awt.Cursor?,
                          transferable: any java.awt.datatransfer.Transferable,
                          dsl: (any DragSourceListener)? = nil) {
      // headless no-op
    }
  }
}
