/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// The interface for objects which contain a set of items for which zero or
  /// more can be selected.
  ///
  /// Mirrors `java.awt.ItemSelectable` (Java 1.1). Implemented for example by
  /// `Checkbox`, `CheckboxMenuItem`, `Choice` and `List`.
  ///
  /// - Since: JavaApi > 0.20.0 (Java 1.1)
  @MainActor
  public protocol ItemSelectable {

    /// Returns the selected items or `nil` if no items are selected.
    func getSelectedObjects() -> [AnyObject]?

    /// Adds a listener to receive item events when the state of an item is
    /// changed by the user.
    func addItemListener(_ l: java.awt.event.ItemListener)

    /// Removes an item listener.
    func removeItemListener(_ l: java.awt.event.ItemListener)
  }
}
