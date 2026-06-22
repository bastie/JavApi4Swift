/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.security.acl {

  /// Represents a group of principals.
  ///
  /// Mirrors `java.security.acl.Group` (Java 1.1), which extends
  /// `java.security.Principal`.
  ///
  /// > Warning: Deprecated since Java 17 for removal; removed in Java 24.
  ///
  /// - Since: JavaApi > 0.x (Java 1.1)
  @available(*, deprecated, message: "java.security.acl.Group is deprecated since Java 17 for removal and was removed in Java 24.")
  public protocol Group: java.security.Principal {

    /// Adds a principal to the group.
    ///
    /// - Parameter user: The principal to add.
    /// - Returns: `true` if the member was added; `false` if already a member.
    mutating func addMember(_ user: java.security.Principal) -> Bool

    /// Removes a principal from the group.
    ///
    /// - Parameter user: The principal to remove.
    /// - Returns: `true` if the member was removed; `false` if not a member.
    mutating func removeMember(_ user: java.security.Principal) -> Bool

    /// Returns `true` if the given principal is a member of the group.
    ///
    /// Membership is evaluated recursively: if the group contains another
    /// group, members of the sub-group are also considered members.
    func isMember(_ member: java.security.Principal) -> Bool

    /// Returns an enumeration of the members in the group.
    func members() -> any java.util.Enumeration<any java.security.Principal>
  }
}
