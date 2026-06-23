/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

@available(*, deprecated)
extension java.security.acl {

  /// Represents a permission, such as the ability to read or write a file.
  ///
  /// Mirrors `java.security.acl.Permission` (Java 1.1).
  ///
  /// > Warning: Deprecated since Java 17 for removal; removed in Java 24.
  ///
  /// - Since: JavaApi > 0.x (Java 1.1)
  @available(*, deprecated, message: "java.security.acl.Permission is deprecated since Java 17 for removal and was removed in Java 24.")
  public protocol Permission {

    /// Returns `true` if the given object is the same permission as this one.
    func equals(_ another: Any?) -> Bool

    /// Returns a string representation of this permission.
    func toString() -> String
  }
}
