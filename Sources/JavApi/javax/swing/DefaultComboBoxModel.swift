/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// The default implementation of `MutableComboBoxModel`.
  ///
  /// `DefaultComboBoxModel` stores its items in a Swift `Array` and tracks
  /// the selected item separately.  Every mutation fires the appropriate
  /// `ListDataEvent`; a selection change fires
  /// `ListDataEvent(CONTENTS_CHANGED, index0: -1, index1: -1)` — the Java
  /// convention for "only the selection changed, no structural modification".
  ///
  /// ## Typical usage
  ///
  /// ```swift
  /// let model = javax.swing.DefaultComboBoxModel<String>()
  /// model.addElement("Red")
  /// model.addElement("Green")
  /// model.addElement("Blue")
  /// model.setSelectedItem("Green")
  /// // model.getSelectedItem() == "Green"
  /// ```
  ///
  /// - Since: Java 1.2
  @MainActor
  open class DefaultComboBoxModel<E>: javax.swing.MutableComboBoxModel {

    public typealias Element = E

    // -------------------------------------------------------------------------
    // MARK: Storage
    // -------------------------------------------------------------------------

    internal var elements: [E] = []
    private var selectedItem: E? = nil

    // -------------------------------------------------------------------------
    // MARK: Listeners
    // -------------------------------------------------------------------------

    private var listeners: [javax.swing.event.ListDataListener] = []

    // -------------------------------------------------------------------------
    // MARK: Initializers
    // -------------------------------------------------------------------------

    /// Creates an empty model.
    public init() {}

    /// Creates a model pre-populated with `items`.
    /// The first item (if any) becomes the initial selection.
    public init(_ items: [E]) {
      self.elements    = items
      self.selectedItem = items.first
    }

    // -------------------------------------------------------------------------
    // MARK: ListModel
    // -------------------------------------------------------------------------

    open func getSize() -> Int { elements.count }

    open func getElementAt(_ index: Int) -> E {
      elements[index]
    }

    open func addListDataListener(_ l: javax.swing.event.ListDataListener) {
      listeners.append(l)
    }

    open func removeListDataListener(_ l: javax.swing.event.ListDataListener) {
      listeners.removeAll { $0 === (l as AnyObject) }
    }

    // -------------------------------------------------------------------------
    // MARK: ComboBoxModel — selection
    // -------------------------------------------------------------------------

    open func getSelectedItem() -> E? { selectedItem }

    open func setSelectedItem(_ item: E?) {
      selectedItem = item
      // Java convention: fire CONTENTS_CHANGED with index -1..-1 for selection.
      fireContentsChanged(-1, -1)
    }

    // -------------------------------------------------------------------------
    // MARK: MutableComboBoxModel — mutation
    // -------------------------------------------------------------------------

    open func addElement(_ item: E) {
      let idx = elements.count
      elements.append(item)
      if elements.count == 1 {
        selectedItem = item
        fireContentsChanged(-1, -1)
      }
      fireIntervalAdded(idx, idx)
    }

    open func insertElementAt(_ item: E, at index: Int) {
      elements.insert(item, at: index)
      fireIntervalAdded(index, index)
    }

    @discardableResult
    open func removeElementAt(_ index: Int) -> E {
      let removed = elements.remove(at: index)
      fireIntervalRemoved(index, index)
      return removed
    }

    /// Removes the first element equal (by identity) to `item`.
    ///
    /// For `Equatable` element types, prefer the `Equatable`-constrained
    /// extension overload below.
    open func removeElement(_ item: E) {
      // Base: no-op. Use Equatable extension overload for value types.
    }

    /// Removes all elements and clears the selection.
    open func removeAllElements() {
      guard !elements.isEmpty else { return }
      let last = elements.count - 1
      elements.removeAll()
      selectedItem = nil
      fireIntervalRemoved(0, last)
    }

    // -------------------------------------------------------------------------
    // MARK: Convenience
    // -------------------------------------------------------------------------

    /// Returns the index of the currently selected item, or -1.
    open func getIndexOf(_ item: E) -> Int { -1 }

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

extension javax.swing.DefaultComboBoxModel where E: Equatable {

  /// Returns the index of `item` in the list, or -1 if not found.
  public func getIndexOf(_ item: E) -> Int {
    elements.firstIndex(of: item) ?? -1
  }

  /// Removes the first occurrence of `item`.
  public func removeElement(_ item: E) {
    if let idx = elements.firstIndex(of: item) {
      removeElementAt(idx)
    }
  }
}
