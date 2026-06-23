/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.sql {

  /// Comprehensive information about the database as a whole.
  ///
  /// Mirrors the subset of `java.sql.DatabaseMetaData` relevant to JDBC 1.x
  /// (Java 1.1).
  ///
  /// - Since: JavaApi (Java 1.1)
  public protocol DatabaseMetaData: AnyObject {

    func getDatabaseProductName() throws -> String
    func getDatabaseProductVersion() throws -> String
    func getDriverName() throws -> String
    func getDriverVersion() throws -> String
    var driverMajorVersion: Int { get }
    var driverMinorVersion: Int { get }

    func getURL() throws -> String?
    func getUserName() throws -> String?

    func isReadOnly() throws -> Bool

    func getTables(
      _ catalog: String?,
      _ schemaPattern: String?,
      _ tableNamePattern: String?,
      _ types: [String]?
    ) throws -> any ResultSet

    func getColumns(
      _ catalog: String?,
      _ schemaPattern: String?,
      _ tableNamePattern: String?,
      _ columnNamePattern: String?
    ) throws -> any ResultSet

    func supportsTransactions() throws -> Bool
    func getDefaultTransactionIsolation() throws -> Int

    func storesLowerCaseIdentifiers() throws -> Bool
    func storesUpperCaseIdentifiers() throws -> Bool
    func storesMixedCaseIdentifiers() throws -> Bool
  }
}
