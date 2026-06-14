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
  /// ## Typical usage
  ///
  /// ```swift
  /// let model = javax.swing.DefaultListModel<String>()
  /// model.addElement("Alpha")
  /// model.addElement("Beta")
  /// model.insertElementAt("Gamma", at: 1)
  /// model.removeElementAt(0)
  /// ```
  ///
  /// - Since: Java 1.2
  @MainActor
  open class DefaultListModel<E>: javax.swing.ListModel {

    public typealias Element = E

    // -------------------------------------------------------------------------
    // MARK: Storage
    // -------------------------------------------------------------------------

    private var elements: [E] = []

    // -------------------------------------------------------------------------
    // MARK: Listeners
    // -------------------------------------------------------------------------

    private var listeners: [javax.swing.event.ListDataListener] = []

    public init() {}

    // -------------------------------------------------------------------------
    // MARK: ListModel protocol
    // -------------------------------------------------------------------------

    /// Returns the number of elements.
    open func getSize() -> Int { elements.count }

    /// Returns the element at `index`, or `nil` if out of range.
    open func getElementAt(_ index: Int) -> E? {
      guard index >= 0, index < elements.count else { return nil }
      return elements[index]
    }

    open func addListDataListener(_ l: javax.swing.event.ListDataListener) {
      listeners.append(l)
    }

    open func removeListDataListener(_ l: javax.swing.event.ListDataListener) {
      listeners.removeAll { $0 === (l as AnyObject) }
    }

    // -------------------------------------------------------------------------
    // MARK: Mutation — Java API
    // -------------------------------------------------------------------------

    /// Appends `element` to the end of the list.
    open func addElement(_ element: E) {
      let idx = elements.count
      elements.append(element)
      fireIntervalAdded(idx, idx)
    }

    /// Inserts `element` at `index`, shifting subsequent elements right.
    open func insertElementAt(_ element: E, at index: Int) {
      elements.insert(element, at: index)
      fireIntervalAdded(index, index)
    }

    /// Replaces the element at `index` with `element`.
    open func setElementAt(_ element: E, at index: Int) {
      elements[index] = element
      fireContentsChanged(index, index)
    }

    /// Removes and returns the element at `index`.
    @discardableResult
    open func removeElementAt(_ index: Int) -> E {
      let removed = elements.remove(at: index)
      fireIntervalRemoved(index, index)
      return removed
    }

    /// Removes the first element that is identical (`===`) to `element`.
    ///
    /// This base implementation requires `E: AnyObject`.
    /// For `Equatable` element types, use the `Equatable`-constrained overload
    /// on `DefaultListModel` instead.
    open func removeElement(_ element: E) {
      // Base implementation: no-op for non-AnyObject element types.
      // Use the Equatable extension overload for value types.
    }

    /// Removes all elements from the list.
    open func removeAllElements() {
      guard !elements.isEmpty else { return }
      let last = elements.count - 1
      elements.removeAll()
      fireIntervalRemoved(0, last)
    }

    /// Returns `true` if the list contains no elements.
    open func isEmpty() -> Bool { elements.isEmpty }

    /// Returns the number of elements (alias for `getSize()`).
    open func size() -> Int { elements.count }

    /// Returns the element at `index` (alias for `getElementAt(_:)`).
    open func get(_ index: Int) -> E? { getElementAt(index) }

    /// Returns the index of the first occurrence of `element`, or -1.
    ///
    /// This base implementation always returns -1.
    /// For `Equatable` element types, use the `Equatable`-constrained overload.
    open func indexOf(_ element: E) -> Int { -1 }

    /// Returns `true` if `element` is in the list.
    ///
    /// This base implementation always returns `false`.
    /// For `Equatable` element types, use the `Equatable`-constrained overload.
    open func contains(_ element: E) -> Bool { false }

    /// Returns all elements as a Swift Array (copy).
    open func toArray() -> [E] { elements }

    // -------------------------------------------------------------------------
    // MARK: Fire helpers
    // -------------------------------------------------------------------------

    private func fireIntervalAdded(_ index0: Int, _ index1: Int) {
      guard !listeners.isEmpty else { return }
      let e = javax.swing.event.ListDataEvent(
        self, type: javax.swing.event.ListDataEvent.INTERVAL_ADDED,
        index0: index0, index1: index1)
      for l in listeners { l.intervalAdded(e) }
    }

    private func fireIntervalRemoved(_ index0: Int, _ index1: Int) {
      guard !listeners.isEmpty else { return }
      let e = javax.swing.event.ListDataEvent(
        self, type: javax.swing.event.ListDataEvent.INTERVAL_REMOVED,
        index0: index0, index1: index1)
      for l in listeners { l.intervalRemoved(e) }
    }

    private func fireContentsChanged(_ index0: Int, _ index1: Int) {
      guard !listeners.isEmpty else { return }
      let e = javax.swing.event.ListDataEvent(
        self, type: javax.swing.event.ListDataEvent.CONTENTS_CHANGED,
        index0: index0, index1: index1)
      for l in listeners { l.contentsChanged(e) }
    }
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
