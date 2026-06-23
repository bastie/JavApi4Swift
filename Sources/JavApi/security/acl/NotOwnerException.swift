/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

@available(*, deprecated)
extension java.security.acl {

  /// Thrown when a non-owner attempts an operation that requires ownership.
  ///
  /// Only the owner(s) of an ACL may modify it. This exception is thrown
  /// when a caller without ownership rights tries to do so.
  ///
  /// Mirrors `java.security.acl.NotOwnerException` (Java 1.1).
  ///
  /// > Warning: Deprecated since Java 17 for removal; removed in Java 24.
  ///
  /// - Since: JavaApi > 0.x (Java 1.1)
  @available(*, deprecated, message: "java.security.acl.NotOwnerException is deprecated since Java 17 for removal and was removed in Java 24.")
  public class NotOwnerException: Exception, @unchecked Sendable {

    public override init() {
      super.init()
    }

    public override init(_ message: String) {
      super.init(message)
    }
  }
}
