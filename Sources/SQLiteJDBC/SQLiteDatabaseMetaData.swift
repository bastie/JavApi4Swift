/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import SQLite3
import JavApi

/// Minimal `DatabaseMetaData` implementation for SQLite.
public final class SQLiteDatabaseMetaData: java.sql.DatabaseMetaData {

  private let connection: SQLiteConnection

  init(connection: SQLiteConnection) {
    self.connection = connection
  }

  public func getDatabaseProductName() throws -> String  { "SQLite" }
  public func getDatabaseProductVersion() throws -> String {
    return String(cString: sqlite3_libversion())
  }
  public func getDriverName() throws -> String          { "SQLiteJDBC (JavApi4Swift)" }
  public func getDriverVersion() throws -> String       { "1.0" }
  public var driverMajorVersion: Int                    { 1 }
  public var driverMinorVersion: Int                    { 0 }

  public func getURL() throws -> String?                { nil }
  public func getUserName() throws -> String?           { nil }
  public func isReadOnly() throws -> Bool               { false }

  public func getTables(
    _ catalog: String?,
    _ schemaPattern: String?,
    _ tableNamePattern: String?,
    _ types: [String]?
  ) throws -> any java.sql.ResultSet {
    let pattern = tableNamePattern ?? "%"
    let sql = """
      SELECT name AS TABLE_NAME, type AS TABLE_TYPE
      FROM sqlite_master
      WHERE type IN ('table','view')
        AND name LIKE '\(pattern)'
      ORDER BY name
      """
    return try SQLiteResultSet(connection: connection, sql: sql, maxRows: 0)
  }

  public func getColumns(
    _ catalog: String?,
    _ schemaPattern: String?,
    _ tableNamePattern: String?,
    _ columnNamePattern: String?
  ) throws -> any java.sql.ResultSet {
    // SQLite has no cross-table column catalog in pure SQL; return empty result
    let sql = "SELECT '' AS TABLE_NAME, '' AS COLUMN_NAME, 0 AS DATA_TYPE WHERE 0=1"
    return try SQLiteResultSet(connection: connection, sql: sql, maxRows: 0)
  }

  public func supportsTransactions() throws -> Bool     { true }
  public func getDefaultTransactionIsolation() throws -> Int {
    return SQLiteConnection.TRANSACTION_SERIALIZABLE_DEFAULT
  }

  public func storesLowerCaseIdentifiers() throws -> Bool { false }
  public func storesUpperCaseIdentifiers() throws -> Bool { false }
  public func storesMixedCaseIdentifiers() throws -> Bool { true }
}

// Convenience constant reachable without a Connection instance
private extension java.sql.Connection {
  static var TRANSACTION_SERIALIZABLE_DEFAULT: Int { 8 }
}
