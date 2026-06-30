/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.dnd {

  /// Base event fired by the drag source — mirrors `java.awt.dnd.DragSourceEvent`.
  ///
  /// - Since: Java 1.2
  public class DragSourceEvent {

    /// The `DragSourceContext` that fired this event.
    public private(set) var dragSourceContext: DragSourceContext

    /// Whether the location is specified (headless: always `false`).
    public private(set) var locationSpecified: Bool = false

    /// X coordinate of the cursor in screen space (headless: 0).
    public private(set) var x: Int = 0

    /// Y coordinate of the cursor in screen space (headless: 0).
    public private(set) var y: Int = 0

    /// Creates a `DragSourceEvent` with no location information.
    public init(_ dragSourceContext: DragSourceContext) {
      self.dragSourceContext = dragSourceContext
    }

    /// Creates a `DragSourceEvent` with cursor location.
    public init(_ dragSourceContext: DragSourceContext, _ x: Int, _ y: Int) {
      self.dragSourceContext = dragSourceContext
      self.locationSpecified = true
      self.x = x
      self.y = y
    }

    /// Returns the cursor location, or `nil` if not specified.
    public func getLocation() -> java.awt.Point? {
      guard locationSpecified else { return nil }
      return java.awt.Point(x, y)
    }
  }
}
