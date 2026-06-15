/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {

  /// Fired when the state of a selectable item (Checkbox, Choice, List) changes.
  /// Mirrors `java.awt.event.ItemEvent`.
  public final class ItemEvent: java.awt.AWTEvent, @unchecked Sendable {

    public static let ITEM_STATE_CHANGED = 701

    /// The item whose state changed (typically the label string).
    public static let SELECTED   = 1
    public static let DESELECTED = 2

    public let item: AnyObject?
    public let stateChange: Int

    public override init(_ source: AnyObject, _ id: Int) {
      self.item        = source
      self.stateChange = ItemEvent.SELECTED
      super.init(source, id)
    }

    public init(_ source: AnyObject, _ id: Int, _ item: AnyObject?, _ stateChange: Int) {
      self.item        = item
      self.stateChange = stateChange
      super.init(source, id)
    }

    public func getItem() -> AnyObject?  { item }
    public func getStateChange() -> Int  { stateChange }
  }
}
