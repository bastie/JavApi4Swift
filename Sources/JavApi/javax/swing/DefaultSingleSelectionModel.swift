/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// The default implementation of `SingleSelectionModel`.
  ///
  /// Stores a single integer index; fires a `ChangeEvent` whenever
  /// `selectedIndex` changes.  The initial selection is -1 (nothing selected).
  ///
  /// - Since: Java 1.2
  @MainActor
  open class DefaultSingleSelectionModel: javax.swing.SingleSelectionModel {

    // -------------------------------------------------------------------------
    // MARK: Storage
    // -------------------------------------------------------------------------

    private var _selectedIndex: Int = -1
    private var listeners: [javax.swing.event.ChangeListener] = []

    public init() {}

    // -------------------------------------------------------------------------
    // MARK: SingleSelectionModel
    // -------------------------------------------------------------------------

    open func getSelectedIndex() -> Int { _selectedIndex }

    open func setSelectedIndex(_ index: Int) {
      guard index != _selectedIndex else { return }
      _selectedIndex = index
      fireStateChanged()
    }

    open func isSelected() -> Bool { _selectedIndex != -1 }

    open func clearSelection() { setSelectedIndex(-1) }

    open func addChangeListener(_ l: javax.swing.event.ChangeListener) {
      listeners.append(l)
    }

    open func removeChangeListener(_ l: javax.swing.event.ChangeListener) {
      listeners.removeAll { $0 === (l as AnyObject) }
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
