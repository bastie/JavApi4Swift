/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// The model that provides the data for a `JList`.
  ///
  /// `ListModel` is the data-provider interface for list components.
  /// It exposes a sequence of elements by index and lets listeners register
  /// for `ListDataEvent` notifications whenever the contents change.
  ///
  /// The generic parameter `E` is the element type stored in the list.
  ///
  /// ## Implementing a custom model
  ///
  /// ```swift
  /// class MyModel: javax.swing.ListModel {
  ///   typealias Element = String
  ///   private var items: [String] = []
  ///   func getSize() -> Int { items.count }
  ///   func getElementAt(_ index: Int) -> String { items[index] }
  ///   // listener management …
  /// }
  /// ```
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol ListModel<Element>: AnyObject {

    /// The type of the elements stored in this model.
    associatedtype Element

    /// Returns the number of elements in this list.
    func getSize() -> Int

    /// Returns the element at the given index.
    ///
    /// - Note: Like Java, this method does not guard against out-of-bounds
    ///   access — callers must ensure `0 ≤ index < getSize()`.
    func getElementAt(_ index: Int) -> Element

    /// Registers `l` to receive `ListDataEvent` notifications.
    func addListDataListener(_ l: javax.swing.event.ListDataListener)

    /// Removes `l` from the list of registered listeners.
    func removeListDataListener(_ l: javax.swing.event.ListDataListener)
  }
}
