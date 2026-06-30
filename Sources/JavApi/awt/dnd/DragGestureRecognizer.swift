/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.dnd {

  /// Abstract base for gesture recognisers — mirrors `java.awt.dnd.DragGestureRecognizer`.
  ///
  /// Subclasses register platform-specific input listeners on `component` and call
  /// `fireDragGestureRecognized(_:origin:)` when a drag gesture is detected.
  /// In headless mode the recogniser is always idle.
  ///
  /// - Since: Java 1.2
  open class DragGestureRecognizer {

    /// The `DragSource` associated with this recogniser.
    public private(set) var dragSource: DragSource

    /// The component being monitored for drag gestures.
    public private(set) var component: java.awt.Component

    /// The drag action(s) this recogniser should report.
    public var sourceActions: Int

    private var listeners: [(any DragGestureListener)] = []

    // ── Initialisers ──────────────────────────────────────────────────────────

    public init(dragSource: DragSource,
                component: java.awt.Component,
                dragAction: Int) {
      self.dragSource = dragSource
      self.component = component
      self.sourceActions = dragAction
    }

    // ── Listener management ───────────────────────────────────────────────────

    /// Adds a `DragGestureListener`.
    public func addDragGestureListener(_ dgl: any DragGestureListener) {
      listeners.append(dgl)
    }

    /// Removes a `DragGestureListener`.
    public func removeDragGestureListener(_ dgl: any DragGestureListener) {
      let id = ObjectIdentifier(dgl)
      listeners.removeAll { ObjectIdentifier($0) == id }
    }

    // ── For subclasses ────────────────────────────────────────────────────────

    /// Registers the platform input listener on `component`.
    /// Subclasses override this to hook into native events.
    open func registerListeners() {}

    /// Unregisters the platform input listener from `component`.
    open func unregisterListeners() {}

    /// Resets the recogniser state (no-op in base implementation).
    open func resetRecognizer() {}

    /// Called by subclasses when a gesture is detected.
    public func fireDragGestureRecognized(action: Int, origin: java.awt.Point) {
      let evt = DragGestureEvent(self, dragAction: action, origin: origin)
      for listener in listeners {
        listener.dragGestureRecognized(evt)
      }
    }
  }
}
