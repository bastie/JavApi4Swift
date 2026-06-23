/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
@available(*, deprecated)
extension java.security.acl {

  /// An Access Control List (ACL).
  ///
  /// An ACL is a data structure that guards access to a resource. It contains
  /// a list of `AclEntry` objects, each associating a principal with a set of
  /// permissions. Negative entries take precedence over positive ones.
  ///
  /// Mirrors `java.security.acl.Acl` (Java 1.1), which extends `Owner`.
  ///
  /// > Warning: Deprecated since Java 17 for removal; removed in Java 24.
  ///
  /// - Since: JavaApi > 0.x (Java 1.1)
  @available(*, deprecated, message: "java.security.acl.Acl is deprecated since Java 17 for removal and was removed in Java 24.")
  public protocol Acl: Owner {

    /// Sets the name of this ACL.
    ///
    /// - Throws: `NotOwnerException` if `caller` is not an owner.
    mutating func setName(_ caller: java.security.Principal, _ name: String) throws

    /// Returns the name of this ACL.
    func getName() -> String

    /// Adds an entry to this ACL.
    ///
    /// - Returns: `true` if the entry was added; `false` if an entry for
    ///   the same principal already exists.
    /// - Throws: `NotOwnerException` if `caller` is not an owner.
    mutating func addEntry(_ caller: java.security.Principal, _ entry: any AclEntry) throws -> Bool

    /// Removes an entry from this ACL.
    ///
    /// - Returns: `true` if the entry was removed; `false` if not found.
    /// - Throws: `NotOwnerException` if `caller` is not an owner.
    mutating func removeEntry(_ caller: java.security.Principal, _ entry: any AclEntry) throws -> Bool

    /// Returns an enumeration of all permissions granted to the given principal,
    /// taking both positive and negative entries into account.
    func getPermissions(_ user: java.security.Principal) -> any java.util.Enumeration<any Permission>

    /// Returns an enumeration of all entries in this ACL.
    func entries() -> any java.util.Enumeration<any AclEntry>

    /// Returns `true` if the given principal has the specified permission.
    ///
    /// Negative entries are checked first and take precedence.
    func checkPermission(_ principal: java.security.Principal, _ permission: any Permission) -> Bool

    /// Returns a string representation of this ACL.
    func toString() -> String
  }
}
