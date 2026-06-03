/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - Default implementations for class-based Observers

/// Class-based ``java.util.Observer`` conformers get identity-based
/// `Equatable`, `Hashable`, and `hashCode()` for free via `ObjectIdentifier`.
///
/// ```swift
/// class MyObserver : java.util.Observer {
///     func update(_ observable: java.util.Observable, _ data: Any?) { ... }
///     // ==, hash(into:) and hashCode() are provided automatically
/// }
/// ```
///
/// Value types (`struct`, `enum`) must implement `==`, `hash(into:)` and
/// `hashCode()` manually.
extension java.util.Observer where Self: AnyObject {

  public static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs === rhs
  }
  
}
