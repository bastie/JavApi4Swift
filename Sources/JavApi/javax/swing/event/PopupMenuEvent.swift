/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.event {

  /// An event fired by `JPopupMenu` when it becomes visible, invisible, or cancelled.
  ///
  /// - Since: Java 1.2
  @MainActor
  public class PopupMenuEvent: java.util.EventObject, @unchecked Sendable {

    /// Creates a `PopupMenuEvent` with the given source.
    public override init(_ source: AnyObject) {
      super.init(source)
    }
  }
}
