/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {

  /// Fired when the value of an `Adjustable` component (e.g. `Scrollbar`) changes.
  /// Mirrors `java.awt.event.AdjustmentEvent`.
  public final class AdjustmentEvent: java.awt.AWTEvent, @unchecked Sendable {

    // -------------------------------------------------------------------------
    // MARK: Event id
    // -------------------------------------------------------------------------

    public static let ADJUSTMENT_VALUE_CHANGED = 601

    // -------------------------------------------------------------------------
    // MARK: Adjustment type constants
    // -------------------------------------------------------------------------

    /// The user clicked the unit-decrement button (up/left arrow).
    public static let UNIT_DECREMENT   = 1
    /// The user clicked the unit-increment button (down/right arrow).
    public static let UNIT_INCREMENT   = 2
    /// The user clicked the block-decrement area (track above/left of thumb).
    public static let BLOCK_DECREMENT  = 3
    /// The user clicked the block-increment area (track below/right of thumb).
    public static let BLOCK_INCREMENT  = 4
    /// The user dragged the thumb.
    public static let TRACK            = 5

    // -------------------------------------------------------------------------
    // MARK: Properties
    // -------------------------------------------------------------------------

    /// The current value of the adjustable component.
    public let value: Int
    /// The type of adjustment that triggered this event.
    public let adjustmentType: Int
    /// `true` while the user is still adjusting (e.g. actively dragging).
    public let isAdjusting: Bool

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    public func getValue() -> Int          { value }
    public func getAdjustmentType() -> Int { adjustmentType }

    public init(_ source: AnyObject,
                _ id: Int,
                _ adjustmentType: Int,
                _ value: Int,
                isAdjusting: Bool = false) {
      self.value          = value
      self.adjustmentType = adjustmentType
      self.isAdjusting    = isAdjusting
      super.init(source, id)
    }
  }
}
