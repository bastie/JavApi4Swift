/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// Extends all Swift `CaseIterable` enums with a Java-style `values()` method,
/// so Java developers can use the familiar pattern without explicit `java.lang.Enum` conformance.
extension CaseIterable {
  /// Returns all cases of this enumeration — mirrors Java's `Enum.values()`.
  /// - Note: Prefer Swift's `allCases` in new Swift-first code.
  public func values() -> [Self] {
    Array(Self.allCases)
  }
}
