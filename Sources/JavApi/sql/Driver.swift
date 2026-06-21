/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.sql {

  /// The interface every JDBC driver class must implement.
  ///
  /// Mirrors `java.sql.Driver` (Java 1.1). Register an implementation via
  /// ``DriverManager/registerDriver(_:)``.
  ///
  /// - Since: JavaApi (Java 1.1)
  public protocol Driver: AnyObject {

    /// Returns `true` if the driver can open a connection to the given URL.
    func acceptsURL(_ url: String) throws -> Bool

    /// Attempts to open a connection to the given URL.
    ///
    /// Returns `nil` if the driver does not handle this URL scheme.
    func connect(_ url: String, _ info: [String: String]?) throws -> (any Connection)?

    /// Returns metadata about the driver.
    func getPropertyInfo(_ url: String, _ info: [String: String]?) throws -> [DriverPropertyInfo]

    /// The driver's major version number.
    var majorVersion: Int { get }

    /// The driver's minor version number.
    var minorVersion: Int { get }

    /// Returns `true` if the driver is a JDBC-compliant driver.
    var jdbcCompliant: Bool { get }
  }
}
