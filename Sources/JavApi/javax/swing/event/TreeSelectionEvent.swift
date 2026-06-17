/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.event {

  /// An event that describes a change in the selection of a `JTree`.
  ///
  /// Contains the paths that were added to or removed from the selection.
  ///
  /// - Since: Java 1.2
  @MainActor
  public class TreeSelectionEvent: java.util.EventObject, @unchecked Sendable {

    /// The paths that have changed in the selection.
    public let paths: [javax.swing.tree.TreePath]

    /// For each path: `true` if the path was added to the selection,
    /// `false` if it was removed.
    public let areNew: [Bool]

    /// The path that was the lead selection path before this event.
    public let oldLeadSelectionPath: javax.swing.tree.TreePath?

    /// The current lead selection path after this event.
    public let newLeadSelectionPath: javax.swing.tree.TreePath?

    /// Creates a `TreeSelectionEvent`.
    ///
    /// - Parameters:
    ///   - source:               The `TreeSelectionModel` firing the event.
    ///   - paths:                Paths added/removed from the selection.
    ///   - areNew:               Parallel array: `true` = added, `false` = removed.
    ///   - oldLeadSelectionPath: Previous lead path.
    ///   - newLeadSelectionPath: New lead path.
    public init(_ source: AnyObject,
                paths: [javax.swing.tree.TreePath],
                areNew: [Bool],
                oldLeadSelectionPath: javax.swing.tree.TreePath?,
                newLeadSelectionPath: javax.swing.tree.TreePath?) {
      self.paths                  = paths
      self.areNew                 = areNew
      self.oldLeadSelectionPath   = oldLeadSelectionPath
      self.newLeadSelectionPath   = newLeadSelectionPath
      super.init(source)
    }

    /// Convenience initialiser for a single-path change.
    public convenience init(_ source: AnyObject,
                            path: javax.swing.tree.TreePath,
                            isNew: Bool,
                            oldLeadSelectionPath: javax.swing.tree.TreePath?,
                            newLeadSelectionPath: javax.swing.tree.TreePath?) {
      self.init(source,
                paths: [path],
                areNew: [isNew],
                oldLeadSelectionPath: oldLeadSelectionPath,
                newLeadSelectionPath: newLeadSelectionPath)
    }

    /// Returns the first (or only) changed path.
    public func getPath() -> javax.swing.tree.TreePath? { paths.first }

    /// Returns all changed paths.
    public func getPaths() -> [javax.swing.tree.TreePath] { paths }

    /// Returns `true` if the path at the given index was added to the selection.
    public func isAddedPath(_ index: Int) -> Bool {
      guard index < areNew.count else { return false }
      return areNew[index]
    }

    /// Returns `true` if the first path was added to the selection.
    public func isAddedPath() -> Bool { areNew.first ?? false }
  }
}
