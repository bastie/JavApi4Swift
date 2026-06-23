/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.security {
  /// The namespace for the legacy Access Control List (ACL) API.
  ///
  /// Mirrors the `java.security.acl` package (Java 1.1).
  ///
  /// > Warning: This entire package was deprecated in Java 17 for removal
  /// > and **removed in Java 24**. Use `java.security.Policy` /
  /// > `java.security.Principal` for new code.
  /// > Set the system property `java.expected.version` to a value < 17
  /// > to suppress deprecation warnings in legacy code.
  @available(*, deprecated, message: "java.security.acl is deprecated since Java 17 for removal and was removed in Java 24. Use java.security.Policy / java.security.Principal instead. Set java.expected.version < 17 to suppress.")
  public enum acl {}
}

