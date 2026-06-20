/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.tree {

  /// The default implementation of `TreeSelectionModel`.
  ///
  /// Supports all three selection modes.  The default mode is
  /// `DISCONTIGUOUS_TREE_SELECTION`.
  ///
  /// - Since: Java 1.2
  @MainActor
  open class DefaultTreeSelectionModel: javax.swing.tree.TreeSelectionModel {

    // -------------------------------------------------------------------------
    // MARK: Storage
    // -------------------------------------------------------------------------

    private var selectionMode_: Int = 4   // DISCONTIGUOUS_TREE_SELECTION
    private var selectedPaths_: [javax.swing.tree.TreePath] = []
    private var leadPath_:       javax.swing.tree.TreePath? = nil
    private var listeners_:      [javax.swing.event.TreeSelectionListener] = []

    public init() {}

    // -------------------------------------------------------------------------
    // MARK: TreeSelectionModel — mode
    // -------------------------------------------------------------------------

    open func getSelectionMode() -> Int { selectionMode_ }

    open func setSelectionMode(_ mode: Int) {
      selectionMode_ = mode
      // Enforce mode constraints on existing selection
      if mode == Self.SINGLE_TREE_SELECTION, selectedPaths_.count > 1 {
        let first = selectedPaths_[0]
        clearSelection()
        setSelectionPath(first)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: TreeSelectionModel — mutation
    // -------------------------------------------------------------------------

    open func setSelectionPath(_ path: javax.swing.tree.TreePath?) {
      let old = selectedPaths_
      selectedPaths_ = path.map { [$0] } ?? []
      leadPath_ = path
      fireValueChanged(old: old)
    }

    open func setSelectionPaths(_ paths: [javax.swing.tree.TreePath]?) {
      let old = selectedPaths_
      selectedPaths_ = enforcedPaths(paths ?? [])
      leadPath_ = selectedPaths_.last
      fireValueChanged(old: old)
    }

    open func addSelectionPath(_ path: javax.swing.tree.TreePath) {
      addSelectionPaths([path])
    }

    open func addSelectionPaths(_ paths: [javax.swing.tree.TreePath]) {
      let old = selectedPaths_
      for p in paths where !isPathSelected(p) {
        selectedPaths_.append(p)
      }
      selectedPaths_ = enforcedPaths(selectedPaths_)
      leadPath_ = paths.last
      fireValueChanged(old: old)
    }

    open func removeSelectionPath(_ path: javax.swing.tree.TreePath) {
      removeSelectionPaths([path])
    }

    open func removeSelectionPaths(_ paths: [javax.swing.tree.TreePath]) {
      let old = selectedPaths_
      selectedPaths_.removeAll { p in paths.contains { $0 == p } }
      if let lead = leadPath_, paths.contains(where: { $0 == lead }) {
        leadPath_ = selectedPaths_.last
      }
      fireValueChanged(old: old)
    }

    open func clearSelection() {
      let old = selectedPaths_
      selectedPaths_ = []
      leadPath_ = nil
      fireValueChanged(old: old)
    }

    // -------------------------------------------------------------------------
    // MARK: TreeSelectionModel — query
    // -------------------------------------------------------------------------

    open func getSelectionPath() -> javax.swing.tree.TreePath? { selectedPaths_.first }
    open func getSelectionPaths() -> [javax.swing.tree.TreePath]? {
      selectedPaths_.isEmpty ? nil : selectedPaths_
    }
    open func getSelectionCount() -> Int  { selectedPaths_.count }
    open func isPathSelected(_ path: javax.swing.tree.TreePath) -> Bool {
      selectedPaths_.contains { $0 == path }
    }
    open func isSelectionEmpty() -> Bool  { selectedPaths_.isEmpty }

    open func getLeadSelectionPath() -> javax.swing.tree.TreePath? { leadPath_ }
    open func getLeadSelectionRow()  -> Int {
      guard let lead = leadPath_ else { return -1 }
      return selectedPaths_.firstIndex { $0 == lead } ?? -1
    }

    // -------------------------------------------------------------------------
    // MARK: TreeSelectionModel — listeners
    // -------------------------------------------------------------------------

    open func addTreeSelectionListener(_ l: javax.swing.event.TreeSelectionListener) {
      listeners_.append(l)
    }
    open func removeTreeSelectionListener(_ l: javax.swing.event.TreeSelectionListener) {
      listeners_.removeAll { $0 === (l as AnyObject) }
    }

    // -------------------------------------------------------------------------
    // MARK: Private helpers
    // -------------------------------------------------------------------------

    private func enforcedPaths(_ paths: [javax.swing.tree.TreePath]) -> [javax.swing.tree.TreePath] {
      if selectionMode_ == Self.SINGLE_TREE_SELECTION {
        return paths.isEmpty ? [] : [paths[0]]
      }
      return paths
    }

    private func fireValueChanged(old: [javax.swing.tree.TreePath]) {
      guard !old.isEmpty || !selectedPaths_.isEmpty else { return }
      let changedPaths = (old + selectedPaths_).filter { p in
        old.contains { $0 == p } != selectedPaths_.contains { $0 == p }
      }
      guard !changedPaths.isEmpty else { return }
      let areNew = changedPaths.map { p in selectedPaths_.contains { $0 == p } }
      let e = javax.swing.event.TreeSelectionEvent(
        self,
        paths: changedPaths,
        areNew: areNew,
        oldLeadSelectionPath: nil,
        newLeadSelectionPath: leadPath_)
      for l in listeners_ { l.valueChanged(e) }
    }
  }
}
