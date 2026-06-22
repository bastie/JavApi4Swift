/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.security {

  /// Represents a principal — an entity such as an individual, a corporation,
  /// or a login ID.
  ///
  /// Mirrors `java.security.Principal` (Java 1.1). This interface is **not**
  /// deprecated; it remains in active use in JAAS and elsewhere.
  ///
  /// - Since: JavaApi > 0.x (Java 1.1)
  public protocol Principal {

    /// Returns the name of this principal.
    ///
    /// - Returns: The name of this principal.
    func getName() -> String
  }
}
