/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// Stub for `java.lang.SecurityManager` (Java 1.0).
///
/// In Java, `SecurityManager` allowed applications to implement a security
/// policy by overriding `check*` methods. It was deprecated in Java 17 and
/// removed in Java 18. All `check*` methods in this implementation are no-ops
/// (i.e. they always allow the requested operation).
///
/// Subclass and override individual `check*` methods to enforce custom policies.
///
/// - Since: JavaApi > 0.19.1 (Java 1.0)
open class SecurityManager {

  public init() {}

  // MARK: - Thread / class-loader checks

  /// Checks whether the calling thread is allowed to create a new class loader.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  open func checkCreateClassLoader() {}

  /// Checks whether the calling thread is allowed to modify the thread `t`.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  open func checkAccess(_ t: Thread) {}

  // MARK: - File checks

  /// Checks whether the calling thread is allowed to read the file at `file`.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  open func checkRead(_ file: String) {}

  /// Checks whether the calling thread is allowed to write the file at `file`.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  open func checkWrite(_ file: String) {}

  /// Checks whether the calling thread is allowed to delete the file at `file`.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  open func checkDelete(_ file: String) {}

  // MARK: - Network checks

  /// Checks whether the calling thread is allowed to open a socket connection
  /// to `host`:`port`.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  open func checkConnect(_ host: String, _ port: Int) {}

  /// Checks whether the calling thread is allowed to listen on `port`.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  open func checkListen(_ port: Int) {}

  /// Checks whether the calling thread is allowed to accept a socket
  /// connection from `host`:`port`.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  open func checkAccept(_ host: String, _ port: Int) {}

  // MARK: - System checks

  /// Checks whether the calling thread is allowed to read or write the
  /// system property named `key`.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  open func checkPropertyAccess(_ key: String) {}

  /// Checks whether the calling thread is allowed to cause the JVM to halt
  /// with the given `status`.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  open func checkExit(_ status: Int) {}

  /// Checks whether the calling thread is allowed to execute the command `cmd`.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  open func checkExec(_ cmd: String) {}

  /// Checks whether the calling thread is allowed to link the dynamic library
  /// named `lib`.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  open func checkLink(_ lib: String) {}

  // MARK: - Permission check (Java 2+ convenience, kept for API completeness)

  /// Generic permission check. No-op in this implementation.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  open func checkPermission(_ permissionName: String) {}
}
