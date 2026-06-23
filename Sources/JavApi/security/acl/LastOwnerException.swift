/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

@available(*, deprecated)
extension java.security.acl {

  /// Thrown when an attempt is made to remove the last owner of an ACL.
  ///
  /// Every ACL must have at least one owner; this exception prevents
  /// leaving an ACL without an owner.
  ///
  /// Mirrors `java.security.acl.LastOwnerException` (Java 1.1).
  ///
  /// > Warning: Deprecated since Java 17 for removal; removed in Java 24.
  ///
  /// - Since: JavaApi > 0.x (Java 1.1)
  @available(*, deprecated, message: "java.security.acl.LastOwnerException is deprecated since Java 17 for removal and was removed in Java 24.")
  public class LastOwnerException: Exception, @unchecked Sendable {

    public override init() {
      super.init()
    }

    public override init(_ message: String) {
      super.init(message)
    }
  }
}
