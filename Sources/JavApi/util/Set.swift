/*
 * SPDX-FileCopyrightText: 2026 Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */


extension java.util {
  
  /// Protocol mirroring `java.util.Set<E>`.
  ///
  /// A collection that contains no duplicate elements. At most one `nil` element
  /// is allowed (matching Java's nullable-element contract).
  ///
  /// `java.util.Set` extends `java.util.Collection`, adding only the constraint
  /// that `add(_:)` must return `false` when the element is already present.
  ///
  /// - Note: This is distinct from Swift's built-in `Set` type. Use the fully-
  ///   qualified name `java.util.Set` to avoid ambiguity at call sites.
  ///
  /// - Since: Java 1.2
  public protocol Set<E>: java.util.Collection where E: Equatable {
    // No additional requirements beyond Collection — the uniqueness contract is
    // enforced by the semantics of add(_:), not by extra protocol members.
    // Concrete types (HashSet, TreeSet) provide the backing guarantee.
  }
}
