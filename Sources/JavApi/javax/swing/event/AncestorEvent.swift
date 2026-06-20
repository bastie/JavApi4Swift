/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.event {

  /// Event fired when a component or one of its ancestors is added to or
  /// removed from the component hierarchy, or when an ancestor moves.
  ///
  /// The source is the `JComponent` that added the listener.
  ///
  /// - Since: Java 1.2
  @MainActor
  public class AncestorEvent: java.util.EventObject, @unchecked Sendable {

    // -------------------------------------------------------------------------
    // MARK: Event-ID constants
    // -------------------------------------------------------------------------

    /// The component or an ancestor was added to a visible container.
    public static let ANCESTOR_ADDED:   Int = 1
    /// The component or an ancestor was removed from a visible container.
    public static let ANCESTOR_REMOVED: Int = 2
    /// An ancestor was moved.
    public static let ANCESTOR_MOVED:   Int = 3

    // -------------------------------------------------------------------------
    // MARK: Properties
    // -------------------------------------------------------------------------

    private let id:       Int
    private let ancestor: java.awt.Container?
    private let ancestorParent: java.awt.Container?

    // -------------------------------------------------------------------------
    // MARK: Initializer
    // -------------------------------------------------------------------------

    /// Creates an `AncestorEvent`.
    ///
    /// - Parameters:
    ///   - source:         The `JComponent` that added the listener.
    ///   - id:             One of `ANCESTOR_ADDED`, `ANCESTOR_REMOVED`, `ANCESTOR_MOVED`.
    ///   - ancestor:       The ancestor `Container` involved.
    ///   - ancestorParent: The parent of the ancestor.
    public init(_ source: AnyObject,
                _ id: Int,
                _ ancestor: java.awt.Container?,
                _ ancestorParent: java.awt.Container?) {
      self.id             = id
      self.ancestor       = ancestor
      self.ancestorParent = ancestorParent
      super.init(source)
    }

    // -------------------------------------------------------------------------
    // MARK: Accessors
    // -------------------------------------------------------------------------

    public func getID()             -> Int                  { id }
    public func getAncestor()       -> java.awt.Container?  { ancestor }
    public func getAncestorParent() -> java.awt.Container?  { ancestorParent }

    /// Convenience: returns the `JComponent` that fired this event.
    public func getComponent() -> javax.swing.JComponent? {
      getSource() as? javax.swing.JComponent
    }
  }
}
