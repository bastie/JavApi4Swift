/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.dnd {

  /// Mouse-based drag gesture recogniser — mirrors `java.awt.dnd.MouseDragGestureRecognizer`.
  ///
  /// ### Gesture detection (platform-independent, Step 1)
  ///
  /// The recogniser tracks mouse-press and mouse-drag coordinates internally.
  /// Platform-specific subclasses (Step 2+) call `mousePressed(_:_:)` and
  /// `mouseDragged(_:_:)` from their native event handlers. When the cumulative
  /// drag distance exceeds `DragSource.getDragThreshold()` pixels, the recogniser
  /// fires `fireDragGestureRecognized(action:origin:)`.
  ///
  /// For headless / test use, `simulateMousePress(_:_:)` and
  /// `simulateMouseDrag(_:_:)` are provided as public entry points.
  ///
  /// - Since: Java 1.2
  open class MouseDragGestureRecognizer: DragGestureRecognizer {

    // ── Threshold state ───────────────────────────────────────────────────────

    /// Coordinates of the most recent mouse-press (component-relative).
    private var pressX: Int = 0
    private var pressY: Int = 0

    /// Whether we are currently tracking a potential drag (button held down).
    private var tracking: Bool = false

    /// Whether a gesture has already been fired for the current press–drag sequence.
    private var gestureFired: Bool = false

    // ── Initialisers ──────────────────────────────────────────────────────────

    @MainActor
    public override init(dragSource: DragSource,
                         component: java.awt.Component,
                         dragAction: Int) {
      super.init(dragSource: dragSource, component: component, dragAction: dragAction)
    }

    // ── Platform-independent gesture API ─────────────────────────────────────

    /// Called (by platform subclasses or tests) when a mouse button is pressed.
    ///
    /// Records the press origin and starts tracking.
    ///
    /// - Parameters:
    ///   - x: Horizontal position relative to the component.
    ///   - y: Vertical position relative to the component.
    public func mousePressed(_ x: Int, _ y: Int) {
      pressX = x
      pressY = y
      tracking = true
      gestureFired = false
    }

    /// Called (by platform subclasses or tests) when the mouse is dragged.
    ///
    /// Computes the Chebyshev distance from the press origin and fires a
    /// drag-gesture event once the threshold is exceeded.
    ///
    /// - Parameters:
    ///   - x: Current horizontal position relative to the component.
    ///   - y: Current vertical position relative to the component.
    public func mouseDragged(_ x: Int, _ y: Int) {
      guard tracking, !gestureFired else { return }
      let dx = abs(x - pressX)
      let dy = abs(y - pressY)
      if dx > DragSource.getDragThreshold() || dy > DragSource.getDragThreshold() {
        gestureFired = true
        fireDragGestureRecognized(action: sourceActions,
                                  origin: java.awt.Point(pressX, pressY))
      }
    }

    /// Called (by platform subclasses or tests) when the mouse button is released.
    ///
    /// Ends the current tracking sequence without firing a gesture.
    public func mouseReleased() {
      tracking = false
      gestureFired = false
    }

    // ── Convenience entry points for headless / test use ─────────────────────

    /// Simulates a mouse-press event at the given component-relative coordinates.
    public func simulateMousePress(_ x: Int, _ y: Int) {
      mousePressed(x, y)
    }

    /// Simulates a mouse-drag event at the given component-relative coordinates.
    ///
    /// Fires a drag-gesture event if the threshold is exceeded.
    public func simulateMouseDrag(_ x: Int, _ y: Int) {
      mouseDragged(x, y)
    }

    /// Simulates a mouse-release event, resetting the tracking state.
    public func simulateMouseRelease() {
      mouseReleased()
    }

    // ── Subclass hooks ────────────────────────────────────────────────────────

    /// Installs native mouse listeners on `component`.
    ///
    /// Override in platform-specific subclasses (Step 2+). Headless: no-op.
    open override func registerListeners() {}

    /// Removes native mouse listeners from `component`.
    ///
    /// Override in platform-specific subclasses (Step 2+). Headless: no-op.
    open override func unregisterListeners() {}
  }
}
