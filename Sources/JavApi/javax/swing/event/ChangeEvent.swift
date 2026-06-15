/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.event {

  /// An event that indicates a state change in the source component.
  ///
  /// `ChangeEvent` is fired by `ButtonModel` whenever `isPressed`,
  /// `isArmed`, `isRollover`, `isSelected`, or `isEnabled` changes.
  /// Unlike `java.util.EventObject` it carries no additional payload —
  /// listeners query the source directly for the new state.
  ///
  /// - Since: Java 1.2
  @MainActor
  public class ChangeEvent: java.util.EventObject, @unchecked Sendable {

    /// Creates a `ChangeEvent` with the given source.
    public override init(_ source: AnyObject) {
      super.init(source)
    }
  }
}
