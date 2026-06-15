/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A model that supports at most one selected index.
  ///
  /// Used by `JTabbedPane` (selected tab) and `JMenuBar` (selected menu).
  /// When `selectedIndex` is -1, nothing is selected.
  ///
  /// Implementations fire a `ChangeEvent` whenever the selection changes.
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol SingleSelectionModel: AnyObject {

    /// Returns the currently selected index, or -1 if nothing is selected.
    func getSelectedIndex() -> Int

    /// Sets the selected index; use -1 to clear the selection.
    func setSelectedIndex(_ index: Int)

    /// Returns `true` if any index is selected (`getSelectedIndex() != -1`).
    func isSelected() -> Bool

    /// Clears the selection (sets selected index to -1).
    func clearSelection()

    func addChangeListener(_ l: javax.swing.event.ChangeListener)
    func removeChangeListener(_ l: javax.swing.event.ChangeListener)
  }
}
