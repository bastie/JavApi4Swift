/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A mutable `ComboBoxModel` that supports adding and removing elements.
  ///
  /// `MutableComboBoxModel` refines `ComboBoxModel` with mutation methods.
  /// `DefaultComboBoxModel` is the standard implementation.
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol MutableComboBoxModel: javax.swing.ComboBoxModel {

    /// Appends `item` to the end of the model.
    func addElement(_ item: Element)

    /// Inserts `item` at the given `index`.
    func insertElementAt(_ item: Element, at index: Int)

    /// Removes the element at `index`.
    @discardableResult
    func removeElementAt(_ index: Int) -> Element

    /// Removes `item` from the model (first occurrence).
    func removeElement(_ item: Element)
  }
}
