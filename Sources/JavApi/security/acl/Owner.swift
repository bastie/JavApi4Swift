/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

@available(*, deprecated)
extension java.security.acl {

  /// Interface for managing owners of an Access Control List (ACL).
  ///
  /// Mirrors `java.security.acl.Owner` (Java 1.1).
  ///
  /// > Warning: Deprecated since Java 17 for removal; removed in Java 24.
  ///
  /// - Since: JavaApi > 0.x (Java 1.1)
  @available(*, deprecated, message: "java.security.acl.Owner is deprecated since Java 17 for removal and was removed in Java 24.")
  public protocol Owner {

    /// Adds an owner to the ACL.
    ///
    /// - Parameters:
    ///   - caller: The principal invoking this method; must already be an owner.
    ///   - owner:  The principal to add as an owner.
    /// - Returns: `true` if the principal was added; `false` if already an owner.
    /// - Throws: `NotOwnerException` if `caller` is not an owner.
    mutating func addOwner(_ caller: java.security.Principal, _ owner: java.security.Principal) throws -> Bool

    /// Removes an owner from the ACL.
    ///
    /// - Parameters:
    ///   - caller: The principal invoking this method; must already be an owner.
    ///   - owner:  The principal to remove.
    /// - Returns: `true` if the principal was removed; `false` if not an owner.
    /// - Throws: `NotOwnerException` if `caller` is not an owner.
    ///           `LastOwnerException` if removing would leave the ACL ownerless.
    mutating func deleteOwner(_ caller: java.security.Principal, _ owner: java.security.Principal) throws -> Bool

    /// Returns `true` if the given principal is an owner of the ACL.
    func isOwner(_ owner: java.security.Principal) -> Bool
  }
}
