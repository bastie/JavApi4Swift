/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension javax.swing {

  /// The default implementation of `ListSelectionModel`.
  ///
  /// Uses an `IndexSet` internally to track arbitrary sets of selected indices.
  /// All three selection modes are enforced on every mutation:
  ///
  /// - `SINGLE_SELECTION` — only the most recently touched index is kept.
  /// - `SINGLE_INTERVAL_SELECTION` — the selection is always one contiguous range.
  /// - `MULTIPLE_INTERVAL_SELECTION` — any combination is allowed (default).
  ///
  /// A single `ListSelectionEvent` is fired after each mutation, covering the
  /// affected `[firstIndex, lastIndex]` range.
  ///
  /// - Since: Java 1.2
  @MainActor
  open class DefaultListSelectionModel: javax.swing.ListSelectionModel {

    // -------------------------------------------------------------------------
    // MARK: Mode constants
    // -------------------------------------------------------------------------

    /// Only one index may be selected at a time.
    public static let SINGLE_SELECTION            = 0
    /// One contiguous interval may be selected.
    public static let SINGLE_INTERVAL_SELECTION   = 1
    /// Any number of indices / intervals may be selected (default).
    public static let MULTIPLE_INTERVAL_SELECTION = 2

    // -------------------------------------------------------------------------
    // MARK: Storage
    // -------------------------------------------------------------------------

    private var selectedIndices: IndexSet = IndexSet()
    private var listeners: [javax.swing.event.ListSelectionListener] = []

    public init() {}

    // -------------------------------------------------------------------------
    // MARK: ListSelectionModel — mode
    // -------------------------------------------------------------------------

    private var _selectionMode: Int = DefaultListSelectionModel.MULTIPLE_INTERVAL_SELECTION

    open func getSelectionMode() -> Int { _selectionMode }
    open func setSelectionMode(_ selectionMode: Int) { _selectionMode = selectionMode }

    // -------------------------------------------------------------------------
    // MARK: Anchor / lead
    // -------------------------------------------------------------------------

    private var _anchorSelectionIndex: Int = -1
    private var _leadSelectionIndex:   Int = -1

    open func getAnchorSelectionIndex() -> Int { _anchorSelectionIndex }
    open func setAnchorSelectionIndex(_ index: Int) { _anchorSelectionIndex = index }

    open func getLeadSelectionIndex() -> Int { _leadSelectionIndex }
    open func setLeadSelectionIndex(_ index: Int) { _leadSelectionIndex = index }

    // -------------------------------------------------------------------------
    // MARK: Adjusting
    // -------------------------------------------------------------------------

    private var _valueIsAdjusting: Bool = false

    open func getValueIsAdjusting() -> Bool { _valueIsAdjusting }
    open func setValueIsAdjusting(_ b: Bool) { _valueIsAdjusting = b }

    // -------------------------------------------------------------------------
    // MARK: Mutation
    // -------------------------------------------------------------------------

    open func setSelectionInterval(_ index0: Int, _ index1: Int) {
      let lo = min(index0, index1)
      let hi = max(index0, index1)
      _anchorSelectionIndex = index0
      _leadSelectionIndex   = index1
      selectedIndices.removeAll()
      switch _selectionMode {
      case DefaultListSelectionModel.SINGLE_SELECTION:
        selectedIndices.insert(hi)
      default:
        selectedIndices.insert(integersIn: lo...hi)
      }
      fireValueChanged(lo, hi)
    }

    open func addSelectionInterval(_ index0: Int, _ index1: Int) {
      let lo = min(index0, index1)
      let hi = max(index0, index1)
      _anchorSelectionIndex = index0
      _leadSelectionIndex   = index1
      switch _selectionMode {
      case DefaultListSelectionModel.SINGLE_SELECTION:
        selectedIndices.removeAll()
        selectedIndices.insert(hi)
      case DefaultListSelectionModel.SINGLE_INTERVAL_SELECTION:
        // Merge into one contiguous range
        let newLo = min(lo, selectedIndices.min() ?? lo)
        let newHi = max(hi, selectedIndices.max() ?? hi)
        selectedIndices.removeAll()
        selectedIndices.insert(integersIn: newLo...newHi)
      default:
        selectedIndices.insert(integersIn: lo...hi)
      }
      fireValueChanged(lo, hi)
    }

    open func removeSelectionInterval(_ index0: Int, _ index1: Int) {
      let lo = min(index0, index1)
      let hi = max(index0, index1)
      selectedIndices.remove(integersIn: lo...hi)
      fireValueChanged(lo, hi)
    }

    open func clearSelection() {
      guard !selectedIndices.isEmpty else { return }
      let lo = selectedIndices.min() ?? 0
      let hi = selectedIndices.max() ?? 0
      selectedIndices.removeAll()
      fireValueChanged(lo, hi)
    }

    // -------------------------------------------------------------------------
    // MARK: Query
    // -------------------------------------------------------------------------

    open func isSelectionEmpty() -> Bool { selectedIndices.isEmpty }

    open func isSelectedIndex(_ index: Int) -> Bool { selectedIndices.contains(index) }

    open func getMinSelectionIndex() -> Int { selectedIndices.min() ?? -1 }

    open func getMaxSelectionIndex() -> Int { selectedIndices.max() ?? -1 }

    /// Returns all selected indices as a sorted Swift Array.
    open func getSelectedIndices() -> [Int] { Array(selectedIndices) }

    // -------------------------------------------------------------------------
    // MARK: Listeners
    // -------------------------------------------------------------------------

    open func addListSelectionListener(_ l: javax.swing.event.ListSelectionListener) {
      listeners.append(l)
    }

    open func removeListSelectionListener(_ l: javax.swing.event.ListSelectionListener) {
      listeners.removeAll { $0 === (l as AnyObject) }
    }

    // -------------------------------------------------------------------------
    // MARK: Fire
    // -------------------------------------------------------------------------

    open func fireValueChanged(_ firstIndex: Int, _ lastIndex: Int) {
      guard !listeners.isEmpty else { return }
      let e = javax.swing.event.ListSelectionEvent(
        self, firstIndex, lastIndex, _valueIsAdjusting)
      for l in listeners { l.valueChanged(e) }
    }
  }
}
