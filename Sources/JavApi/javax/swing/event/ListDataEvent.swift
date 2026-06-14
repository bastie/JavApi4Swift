/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.event {

  /// Defines an event that encapsulates changes to a list.
  ///
  /// `ListDataEvent` is fired by a `ListModel` whenever its contents change.
  /// Three kinds of change are distinguished by `type`:
  ///
  /// | Constant          | Meaning                              |
  /// |-------------------|--------------------------------------|
  /// | `CONTENTS_CHANGED`| One or more elements were modified   |
  /// | `INTERVAL_ADDED`  | Elements were inserted               |
  /// | `INTERVAL_REMOVED`| Elements were removed                |
  ///
  /// The affected range is `[index0, index1]` (both inclusive, `index0 ≤ index1`).
  ///
  /// - Since: Java 1.2
  @MainActor
  public class ListDataEvent: java.util.EventObject, @unchecked Sendable {

    // -------------------------------------------------------------------------
    // MARK: Type constants
    // -------------------------------------------------------------------------

    /// One or more list elements were modified in place.
    public static let CONTENTS_CHANGED: Int = 0
    /// One or more elements were added to the list.
    public static let INTERVAL_ADDED:   Int = 1
    /// One or more elements were removed from the list.
    public static let INTERVAL_REMOVED: Int = 2

    // -------------------------------------------------------------------------
    // MARK: Properties
    // -------------------------------------------------------------------------

    /// The type of change: `CONTENTS_CHANGED`, `INTERVAL_ADDED`, or `INTERVAL_REMOVED`.
    public let type: Int

    /// The lower bound of the changed interval (inclusive).
    public let index0: Int

    /// The upper bound of the changed interval (inclusive).
    public let index1: Int

    // -------------------------------------------------------------------------
    // MARK: Initializer
    // -------------------------------------------------------------------------

    /// Creates a `ListDataEvent`.
    ///
    /// - Parameters:
    ///   - source: The `ListModel` that fired this event.
    ///   - type:   One of `CONTENTS_CHANGED`, `INTERVAL_ADDED`, `INTERVAL_REMOVED`.
    ///   - index0: Lower bound of the affected index range (inclusive).
    ///   - index1: Upper bound of the affected index range (inclusive).
    public init(_ source: AnyObject, type: Int, index0: Int, index1: Int) {
      self.type   = type
      self.index0 = min(index0, index1)
      self.index1 = max(index0, index1)
      super.init(source)
    }
  }
}
