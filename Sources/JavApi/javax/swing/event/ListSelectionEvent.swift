/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.event {

  /// An event that characterises a change in the current selection.
  ///
  /// Fired by `ListSelectionModel` whenever the selection changes.
  /// The affected index range is `[firstIndex, lastIndex]` (both inclusive);
  /// listeners should query the model for the exact new selection state rather
  /// than relying solely on the event's range.
  ///
  /// `valueIsAdjusting` is `true` while the user is still in the middle of a
  /// gesture (e.g. dragging through a list); it becomes `false` on the final
  /// event of the gesture.
  ///
  /// - Since: Java 1.2
  @MainActor
  public class ListSelectionEvent: java.util.EventObject, @unchecked Sendable {

    /// The first index in the changed range (inclusive).
    public let firstIndex: Int

    /// The last index in the changed range (inclusive).
    public let lastIndex: Int

    /// `true` if this event is one of a rapid series (e.g. mouse drag).
    public let valueIsAdjusting: Bool

    /// Creates a `ListSelectionEvent`.
    ///
    /// - Parameters:
    ///   - source:           The `ListSelectionModel` that fired this event.
    ///   - firstIndex:       Lower bound of the affected index range.
    ///   - lastIndex:        Upper bound of the affected index range.
    ///   - valueIsAdjusting: `true` during a rapid gesture, `false` on the final event.
    public init(_ source: AnyObject,
                _ firstIndex: Int,
                _ lastIndex: Int,
                _ valueIsAdjusting: Bool) {
      self.firstIndex        = min(firstIndex, lastIndex)
      self.lastIndex         = max(firstIndex, lastIndex)
      self.valueIsAdjusting  = valueIsAdjusting
      super.init(source)
    }
  }
}
