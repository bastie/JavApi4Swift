/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.text {

  /// A mutable extension of `AttributeSet` — mirrors
  /// `javax.swing.text.MutableAttributeSet` from Java 1.2 / JFC 1.0.
  ///
  /// Adds write operations (add, remove, set resolve parent) to the
  /// read-only `AttributeSet` protocol.
  ///
  /// ## Hierarchy
  ///
  /// ```
  /// AttributeSet            (read-only)
  ///   └── MutableAttributeSet   ← this protocol
  ///         ├── SimpleAttributeSet
  ///         └── Style
  /// ```
  ///
  /// - Since: Java 1.2 / JFC 1.0
  @MainActor
  public protocol MutableAttributeSet: javax.swing.text.AttributeSet {

    // -------------------------------------------------------------------------
    // MARK: Mutation
    // -------------------------------------------------------------------------

    /// Adds a single attribute: stores `value` under `name`.
    func addAttribute(_ name: AnyHashable, _ value: Any)

    /// Merges all attributes from `attrs` into this set.
    func addAttributes(_ attrs: javax.swing.text.AttributeSet)

    /// Removes the attribute stored under `name`.
    func removeAttribute(_ name: AnyHashable)

    /// Removes all attributes whose names appear in `names`.
    func removeAttributes(_ names: [AnyHashable])

    /// Removes all attributes that are present in `attrs`.
    func removeAttributes(_ attrs: javax.swing.text.AttributeSet)

    // -------------------------------------------------------------------------
    // MARK: Resolve parent
    // -------------------------------------------------------------------------

    /// Sets the parent `AttributeSet` used to resolve missing attributes.
    ///
    /// When `getAttribute(_:)` does not find a name in this set, it falls
    /// back to the resolve parent (if any).
    func setResolveParent(_ parent: javax.swing.text.AttributeSet?)
  }
}
