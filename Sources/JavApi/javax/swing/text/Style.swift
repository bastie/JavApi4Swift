/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.text {

  /// A named, mutable attribute set — mirrors `javax.swing.text.Style`
  /// from Java 1.2 / JFC 1.0.
  ///
  /// A `Style` is a `MutableAttributeSet` with a name and change listeners.
  /// Named styles are stored in a `StyledDocument` and can be applied to
  /// character runs or paragraphs by name.
  ///
  /// ## Hierarchy
  ///
  /// ```
  /// AttributeSet
  ///   └── MutableAttributeSet
  ///         └── Style              ← this protocol
  /// ```
  ///
  /// - Since: Java 1.2 / JFC 1.0
  @MainActor
  public protocol Style: javax.swing.text.MutableAttributeSet {

    // -------------------------------------------------------------------------
    // MARK: Identity
    // -------------------------------------------------------------------------

    /// Returns the name of this style.
    func getName() -> String

    // -------------------------------------------------------------------------
    // MARK: Change listeners
    // -------------------------------------------------------------------------

    /// Registers `l` to be notified when this style's attributes change.
    func addChangeListener(_ l: javax.swing.event.ChangeListener)

    /// Removes a previously registered change listener.
    func removeChangeListener(_ l: javax.swing.event.ChangeListener)
  }
}
