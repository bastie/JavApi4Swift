/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.event {

  /// An event fired by `JMenu` when it is selected, deselected, or cancelled.
  ///
  /// - Since: Java 1.2
  @MainActor
  public class MenuEvent: java.util.EventObject, @unchecked Sendable {

    /// Creates a `MenuEvent` with the given source.
    public override init(_ source: AnyObject) {
      super.init(source)
    }
  }
}
