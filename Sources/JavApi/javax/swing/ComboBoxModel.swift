/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// The data model for a `JComboBox`.
  ///
  /// `ComboBoxModel` extends `ListModel` by adding the notion of a
  /// *selected item* — the value currently shown in the combo box's
  /// text field or button.
  ///
  /// Whenever the selected item changes, the model should fire a
  /// `ListDataEvent` of type `CONTENTS_CHANGED` with `index0 = -1`
  /// and `index1 = -1` (the Java convention for "selection changed").
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol ComboBoxModel<Element>: javax.swing.ListModel {

    /// Returns the currently selected item, or `nil` if nothing is selected.
    ///
    /// In Java, `getSelectedItem()` returns `Object` — not the generic element
    /// type — so the selection can be set to a value not in the list.
    func getSelectedItem() -> Any?

    /// Sets the currently selected item.
    ///
    /// In Java, `setSelectedItem(Object)` accepts any object.
    /// Implementations should fire a `ListDataEvent(CONTENTS_CHANGED, -1, -1)`
    /// after changing the selection.
    func setSelectedItem(_ item: Any?)
  }
}
