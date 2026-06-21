/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import SQLite3
import JavApi

/// A simple (non-prepared) JDBC `Statement` backed by SQLite.
public final class SQLiteStatement: java.sql.Statement {

  private let connection: SQLiteConnection
  private var currentResultSet: SQLiteResultSet?
  private var updateCount: Int = -1
  private var maxRows: Int = 0
  private var queryTimeout: Int = 0

  init(connection: SQLiteConnection) {
    self.connection = connection
  }

  // MARK: – Execute

  public func executeQuery(_ sql: String) throws -> any java.sql.ResultSet {
    try connection.checkOpen()
    let rs = try SQLiteResultSet(connection: connection, sql: sql, maxRows: maxRows)
    currentResultSet = rs
    updateCount = -1
    return rs
  }

  public func executeUpdate(_ sql: String) throws -> Int {
    try connection.checkOpen()
    try connection.execSQL(sql)
    let count = Int(sqlite3_changes(connection.db))
    updateCount = count
    currentResultSet = nil
    return count
  }

  public func execute(_ sql: String) throws -> Bool {
    let trimmed = sql.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    if trimmed.hasPrefix("SELECT") || trimmed.hasPrefix("PRAGMA") || trimmed.hasPrefix("WITH") {
      _ = try executeQuery(sql)
      return true
    } else {
      _ = try executeUpdate(sql)
      return false
    }
  }

  public func getResultSet() throws -> (any java.sql.ResultSet)? { return currentResultSet }
  public func getUpdateCount() throws -> Int { return updateCount }

  public func close() throws { currentResultSet = nil }

  public var warnings: java.sql.SQLWarning? { get throws { return nil } }
  public func clearWarnings() throws {}

  public func setMaxRows(_ max: Int) throws { maxRows = max }
  public func getMaxRows() throws -> Int { return maxRows }

  public func setQueryTimeout(_ seconds: Int) throws { queryTimeout = seconds }
  public func getQueryTimeout() throws -> Int { return queryTimeout }
}
