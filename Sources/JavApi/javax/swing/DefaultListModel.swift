/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A resizable array implementation of `ListModel`.
  ///
  /// `DefaultListModel` stores its elements in a Swift `Array` and fires the
  /// appropriate `ListDataEvent` on every mutation so that any attached `JList`
  /// (or other `ListDataListener`) stays in sync.
  ///
  /// Listener management and fire methods are inherited from `AbstractListModel`.
  ///
  /// ## Typical usage
  ///
  /// ```swift
  /// let model = javax.swing.DefaultListModel<String>()
  /// model.addElement("Alpha")
  /// model.addElement("Beta")
  /// model.insertElementAt("Gamma", 1)
  /// model.removeElementAt(0)
  /// ```
  ///
  /// - Since: Java 1.2 / JFC 1.0
  @MainActor
  open class DefaultListModel<E>: javax.swing.AbstractListModel<E> {

    // -------------------------------------------------------------------------
    // MARK: Storage
    // -------------------------------------------------------------------------

    fileprivate var elements: [E] = []

    public override init() { super.init() }

    // -------------------------------------------------------------------------
    // MARK: AbstractListModel overrides
    // -------------------------------------------------------------------------

    /// Returns the number of elements.
    override open func getSize() -> Int { elements.count }

    /// Returns the element at `index`.
    override open func getElementAt(_ index: Int) -> E {
      elements[index]
    }

    // -------------------------------------------------------------------------
    // MARK: Mutation — Java API
    // -------------------------------------------------------------------------

    /// Appends `element` to the end of the list.
    open func addElement(_ element: E) {
      let idx = elements.count
      elements.append(element)
      fireIntervalAdded(self, idx, idx)
    }

    /// Inserts `element` at `index`, shifting subsequent elements right.
    open func insertElementAt(_ element: E, _ index: Int) {
      elements.insert(element, at: index)
      fireIntervalAdded(self, index, index)
    }

    /// Replaces the element at `index` with `element`.
    open func setElementAt(_ element: E, _ index: Int) {
      elements[index] = element
      fireContentsChanged(self, index, index)
    }

    /// Removes the element at `index`.
    open func removeElementAt(_ index: Int) {
      elements.remove(at: index)
      fireIntervalRemoved(self, index, index)
    }

    /// Removes the first element that is identical (`===`) to `element`.
    ///
    /// This base implementation is a no-op for non-`AnyObject` element types.
    /// For `Equatable` element types, use the `Equatable`-constrained overload.
    open func removeElement(_ element: E) {
      // Use the Equatable extension overload for value types.
    }

    /// Removes all elements from the list.
    open func removeAllElements() {
      guard !elements.isEmpty else { return }
      let last = elements.count - 1
      elements.removeAll()
      fireIntervalRemoved(self, 0, last)
    }

    /// Returns `true` if the list contains no elements.
    open func isEmpty() -> Bool { elements.isEmpty }

    /// Returns the number of elements (alias for `getSize()`).
    open func size() -> Int { elements.count }

    /// Returns the element at `index` (alias for `getElementAt(_:)`).
    open func get(_ index: Int) -> E { getElementAt(index) }

    /// Returns the index of the first occurrence of `element`, or -1.
    ///
    /// For `Equatable` element types, use the `Equatable`-constrained overload.
    open func indexOf(_ element: E) -> Int { -1 }

    /// Returns `true` if `element` is in the list.
    ///
    /// For `Equatable` element types, use the `Equatable`-constrained overload.
    open func contains(_ element: E) -> Bool { false }

    /// Returns all elements as a Swift Array (copy).
    open func toArray() -> [E] { elements }
  }
}

// -----------------------------------------------------------------------------
// MARK: Equatable overloads
// -----------------------------------------------------------------------------

extension javax.swing.DefaultListModel where E: Equatable {

  /// Returns the index of the first occurrence of `element`, or -1.
  public func indexOf(_ element: E) -> Int {
    elements.firstIndex(of: element) ?? -1
  }

  /// Returns `true` if `element` is in the list.
  public func contains(_ element: E) -> Bool {
    elements.contains(element)
  }

  /// Removes the first occurrence of `element`.
  public func removeElement(_ element: E) {
    if let idx = elements.firstIndex(of: element) {
      removeElementAt(idx)
    }
  }
}
