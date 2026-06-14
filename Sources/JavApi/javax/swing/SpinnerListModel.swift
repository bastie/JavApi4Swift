/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A `SpinnerModel` backed by a fixed list of values.
  ///
  /// The spinner cycles through the provided array; `getNextValue()` returns
  /// `nil` when the current value is the last element, and `getPreviousValue()`
  /// returns `nil` when it is the first.
  ///
  /// ## Example
  ///
  /// ```swift
  /// let model = javax.swing.SpinnerListModel(["Mon", "Tue", "Wed", "Thu", "Fri"])
  /// model.getValue()         // "Mon"
  /// model.getNextValue()     // "Tue"
  /// ```
  ///
  /// - Since: Java 1.4
  @MainActor
  open class SpinnerListModel: javax.swing.SpinnerModel {

    // -------------------------------------------------------------------------
    // MARK: Storage
    // -------------------------------------------------------------------------

    private var list:         [Any]
    private var currentIndex: Int

    private var listeners: [javax.swing.event.ChangeListener] = []

    // -------------------------------------------------------------------------
    // MARK: Initializers
    // -------------------------------------------------------------------------

    /// Creates a model from an array of arbitrary values.
    /// The initial selection is the first element.
    public init(_ list: [Any]) {
      precondition(!list.isEmpty, "SpinnerListModel requires a non-empty list")
      self.list         = list
      self.currentIndex = 0
    }

    // -------------------------------------------------------------------------
    // MARK: SpinnerModel
    // -------------------------------------------------------------------------

    open func getValue() -> Any? { list[currentIndex] }

    open func setValue(_ value: Any?) {
      guard let v = value else { return }
      // Find by string description (mirrors Java's equals-based lookup)
      if let idx = list.firstIndex(where: { "\($0)" == "\(v)" }) {
        guard idx != currentIndex else { return }
        currentIndex = idx
        fireStateChanged()
      }
    }

    open func getNextValue() -> Any? {
      currentIndex < list.count - 1 ? list[currentIndex + 1] : nil
    }

    open func getPreviousValue() -> Any? {
      currentIndex > 0 ? list[currentIndex - 1] : nil
    }

    open func addChangeListener(_ l: javax.swing.event.ChangeListener) {
      listeners.append(l)
    }

    open func removeChangeListener(_ l: javax.swing.event.ChangeListener) {
      listeners.removeAll { $0 === (l as AnyObject) }
    }

    // -------------------------------------------------------------------------
    // MARK: Typed accessors
    // -------------------------------------------------------------------------

    /// Returns a copy of the backing list.
    open func getList() -> [Any] { list }

    /// Replaces the backing list; resets selection to index 0.
    open func setList(_ newList: [Any]) {
      precondition(!newList.isEmpty, "SpinnerListModel requires a non-empty list")
      list         = newList
      currentIndex = 0
      fireStateChanged()
    }

    // -------------------------------------------------------------------------
    // MARK: Fire
    // -------------------------------------------------------------------------

    open func fireStateChanged() {
      let e = javax.swing.event.ChangeEvent(self)
      for l in listeners { l.stateChanged(e) }
    }
  }
}
