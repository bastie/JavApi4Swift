/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {

  /// Event representing a paint or update request on a component.
  ///
  /// `PaintEvent` is delivered when the windowing system requests that a
  /// component repaint itself (`PAINT`) or when `Component.repaint()` is
  /// called (`UPDATE`).  It carries an *update rectangle* that identifies
  /// the dirty region.
  ///
  /// Mirrors `java.awt.event.PaintEvent` (Java 1.1).
  ///
  /// - Since: Java 1.1
  public class PaintEvent: ComponentEvent, @unchecked Sendable {

    // MARK: - Event-id constants

    /// Marks the first integer in the paint-event id range.
    public static let PAINT_FIRST: Int = 800

    /// Marks the last integer in the paint-event id range.
    public static let PAINT_LAST: Int  = 801

    /// Event id for a paint request (windowing system repaint).
    public static let PAINT: Int  = 800

    /// Event id for an update request (`Component.repaint()`).
    public static let UPDATE: Int = 801

    // MARK: - State

    /// The rectangle that should be repainted.
    private var updateRect: java.awt.Rectangle

    // MARK: - Constructor

    /// Creates a `PaintEvent` for the given component.
    ///
    /// - Parameters:
    ///   - source: the component that needs repainting
    ///   - id: either ``PAINT`` or ``UPDATE``
    ///   - updateRect: the dirty region within the component
    public init(_ source: java.awt.Component, _ id: Int,
                _ updateRect: java.awt.Rectangle) {
      self.updateRect = updateRect
      super.init(source, id)
    }

    // MARK: - Accessors

    /// Returns the rectangle to be repainted.
    public func getUpdateRect() -> java.awt.Rectangle {
      return updateRect
    }

    /// Sets the rectangle to be repainted.
    public func setUpdateRect(_ updateRect: java.awt.Rectangle) {
      self.updateRect = updateRect
    }

    // MARK: - paramString

    /// Returns a string representation of this event for debugging.
    public func paramString() -> String {
      let idStr = id == PaintEvent.PAINT ? "PAINT" : "UPDATE"
      return "\(idStr),updateRect=\(updateRect)"
    }
  }
}
