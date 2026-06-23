/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

@available(*, deprecated)
extension java.security.acl {

  /// Represents one entry in an Access Control List (ACL).
  ///
  /// Each entry associates a principal with a set of permissions. An entry
  /// can be either *positive* (grants permissions) or *negative* (denies
  /// permissions). Negative entries take precedence over positive ones.
  ///
  /// Mirrors `java.security.acl.AclEntry` (Java 1.1).
  ///
  /// > Warning: Deprecated since Java 17 for removal; removed in Java 24.
  ///
  /// - Since: JavaApi > 0.x (Java 1.1)
  @available(*, deprecated, message: "java.security.acl.AclEntry is deprecated since Java 17 for removal and was removed in Java 24.")
  public protocol AclEntry {

    /// Sets the principal this entry controls access for.
    ///
    /// - Returns: `true` if the principal was set; `false` if already set.
    mutating func setPrincipal(_ user: java.security.Principal) -> Bool

    /// Returns the principal associated with this entry.
    func getPrincipal() -> java.security.Principal?

    /// Marks this entry as a *negative* (deny) entry.
    ///
    /// By default entries are positive (grant). Once set to negative,
    /// the entry cannot be changed back.
    mutating func setNegativePermissions()

    /// Returns `true` if this is a negative (deny) entry.
    func isNegative() -> Bool

    /// Adds a permission to this entry.
    ///
    /// - Returns: `true` if the permission was added; `false` if already present.
    mutating func addPermission(_ permission: any Permission) -> Bool

    /// Removes a permission from this entry.
    ///
    /// - Returns: `true` if the permission was removed; `false` if not present.
    mutating func removePermission(_ permission: any Permission) -> Bool

    /// Returns `true` if the given permission is part of this entry.
    func checkPermission(_ permission: any Permission) -> Bool

    /// Returns an enumeration of all permissions in this entry.
    func permissions() -> any java.util.Enumeration<any Permission>

    /// Returns a string representation of this entry.
    func toString() -> String

    /// Creates and returns a copy of this entry.
    func clone() -> AclEntry
  }
}
