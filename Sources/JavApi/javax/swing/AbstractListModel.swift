/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// Abstract base class for `ListModel` implementations.
  ///
  /// `AbstractListModel` handles listener registration and the three fire
  /// methods (`fireContentsChanged`, `fireIntervalAdded`, `fireIntervalRemoved`)
  /// so that concrete subclasses only need to implement the data-access methods
  /// `getSize()` and `getElementAt(_:)`.
  ///
  /// ## Subclassing
  ///
  /// Override `getSize()` and `getElementAt(_:)`, then call the appropriate
  /// `fire*` method after every mutation:
  ///
  /// ```swift
  /// class MyModel<E>: javax.swing.AbstractListModel<E> {
  ///   private var items: [E] = []
  ///   override func getSize() -> Int { items.count }
  ///   override func getElementAt(_ index: Int) -> E { items[index] }
  ///   func append(_ item: E) {
  ///     let i = items.count
  ///     items.append(item)
  ///     fireIntervalAdded(self, i, i)
  ///   }
  /// }
  /// ```
  ///
  /// - Since: Java 1.2 / JFC 1.0
  @MainActor
  open class AbstractListModel<E>: javax.swing.ListModel {

    public typealias Element = E

    // -------------------------------------------------------------------------
    // MARK: Listener management
    // -------------------------------------------------------------------------

    private var listDataListeners: [javax.swing.event.ListDataListener] = []

    public init() {}

    /// Registers `l` to receive `ListDataEvent` notifications.
    open func addListDataListener(_ l: javax.swing.event.ListDataListener) {
      listDataListeners.append(l)
    }

    /// Removes `l` from the list of registered listeners.
    open func removeListDataListener(_ l: javax.swing.event.ListDataListener) {
      listDataListeners.removeAll { $0 === (l as AnyObject) }
    }

    /// Returns all currently registered `ListDataListener`s.
    open func getListDataListeners() -> [javax.swing.event.ListDataListener] {
      listDataListeners
    }

    // -------------------------------------------------------------------------
    // MARK: Abstract data-access — must be overridden
    // -------------------------------------------------------------------------

    /// Returns the number of elements in the list.
    ///
    /// Subclasses **must** override this method.
    open func getSize() -> Int {
      fatalError("AbstractListModel.getSize() must be overridden by \(type(of: self))")
    }

    /// Returns the element at `index`.
    ///
    /// Subclasses **must** override this method.
    open func getElementAt(_ index: Int) -> E {
      fatalError("AbstractListModel.getElementAt(_:) must be overridden by \(type(of: self))")
    }

    // -------------------------------------------------------------------------
    // MARK: Fire helpers
    // -------------------------------------------------------------------------

    /// Notifies listeners that elements in `[index0, index1]` have changed.
    open func fireContentsChanged(_ source: AnyObject, _ index0: Int, _ index1: Int) {
      guard !listDataListeners.isEmpty else { return }
      let e = javax.swing.event.ListDataEvent(
        source,
        javax.swing.event.ListDataEvent.CONTENTS_CHANGED,
        index0, index1)
      for l in listDataListeners { l.contentsChanged(e) }
    }

    /// Notifies listeners that elements `[index0, index1]` have been added.
    open func fireIntervalAdded(_ source: AnyObject, _ index0: Int, _ index1: Int) {
      guard !listDataListeners.isEmpty else { return }
      let e = javax.swing.event.ListDataEvent(
        source,
        javax.swing.event.ListDataEvent.INTERVAL_ADDED,
        index0, index1)
      for l in listDataListeners { l.intervalAdded(e) }
    }

    /// Notifies listeners that elements `[index0, index1]` have been removed.
    open func fireIntervalRemoved(_ source: AnyObject, _ index0: Int, _ index1: Int) {
      guard !listDataListeners.isEmpty else { return }
      let e = javax.swing.event.ListDataEvent(
        source,
        javax.swing.event.ListDataEvent.INTERVAL_REMOVED,
        index0, index1)
      for l in listDataListeners { l.intervalRemoved(e) }
    }
  }
}
