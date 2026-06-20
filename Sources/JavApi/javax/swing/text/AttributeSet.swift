/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.text {

  /// A read-only collection of unique text attributes.
  ///
  /// `AttributeSet` maps attribute name keys (typically type-erased `AnyHashable`)
  /// to values.  It is the foundation for all styled-text formatting in Swing.
  ///
  /// The standard attribute keys are defined as static constants on
  /// `StyleConstants` (e.g. `StyleConstants.Bold`, `StyleConstants.FontSize`).
  ///
  /// ## Hierarchy
  ///
  /// ```
  /// AttributeSet          ← this protocol (read-only)
  ///   └── MutableAttributeSet  (not yet implemented)
  ///         └── SimpleAttributeSet
  /// ```
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol AttributeSet: AnyObject {

    /// Returns the number of attributes in this set.
    func getAttributeCount() -> Int

    /// Returns `true` if the attribute with `name` is defined in this set
    /// (not searched in a resolve parent).
    func isDefined(_ name: AnyHashable) -> Bool

    /// Returns `true` if this set contains all attributes defined in `attrs`.
    func containsAttributes(_ attrs: javax.swing.text.AttributeSet) -> Bool

    /// Returns the value for attribute `name`, or `nil` if not present.
    func getAttribute(_ name: AnyHashable) -> Any?

    /// Returns all attribute names as an array of `AnyHashable`.
    func getAttributeNames() -> [AnyHashable]

    /// Returns the resolving parent, or `nil` if none.
    func getResolveParent() -> javax.swing.text.AttributeSet?
  }
}
