/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import SQLite3
import JavApi

/// A precompiled JDBC `PreparedStatement` backed by SQLite.
public final class SQLitePreparedStatement: java.sql.PreparedStatement {

  private let connection: SQLiteConnection
  private var stmt: OpaquePointer?
  private let sql: String
  private var currentResultSet: SQLiteResultSet?
  private var updateCount: Int = -1
  private var maxRows: Int = 0
  private var queryTimeout: Int = 0

  init(connection: SQLiteConnection, sql: String) throws {
    self.connection = connection
    self.sql = sql
    let rc = sqlite3_prepare_v2(connection.db, sql, -1, &stmt, nil)
    guard rc == SQLITE_OK else {
      throw connection.sqliteError()
    }
  }

  deinit {
    sqlite3_finalize(stmt)
  }

  // MARK: – Execute

  public func executeQuery() throws -> any java.sql.ResultSet {
    try connection.checkOpen()
    sqlite3_reset(stmt)
    let rs = try SQLiteResultSet(stmt: stmt, connection: connection, maxRows: maxRows)
    currentResultSet = rs
    updateCount = -1
    return rs
  }

  public func executeUpdate() throws -> Int {
    try connection.checkOpen()
    sqlite3_reset(stmt)
    let rc = sqlite3_step(stmt)
    guard rc == SQLITE_DONE else { throw connection.sqliteError() }
    let count = Int(sqlite3_changes(connection.db))
    updateCount = count
    currentResultSet = nil
    return count
  }

  public func execute() throws -> Bool {
    let trimmed = sql.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    if trimmed.hasPrefix("SELECT") || trimmed.hasPrefix("PRAGMA") || trimmed.hasPrefix("WITH") {
      _ = try executeQuery()
      return true
    } else {
      _ = try executeUpdate()
      return false
    }
  }

  public func clearParameters() throws {
    sqlite3_clear_bindings(stmt)
  }

  // MARK: – Bind methods (1-based index)

  public func setNull(_ parameterIndex: Int, _ sqlType: Int) throws {
    sqlite3_bind_null(stmt, Int32(parameterIndex))
  }

  public func setBoolean(_ parameterIndex: Int, _ x: Bool) throws {
    sqlite3_bind_int(stmt, Int32(parameterIndex), x ? 1 : 0)
  }

  public func setInt(_ parameterIndex: Int, _ x: Int) throws {
    sqlite3_bind_int64(stmt, Int32(parameterIndex), Int64(x))
  }

  public func setLong(_ parameterIndex: Int, _ x: Int64) throws {
    sqlite3_bind_int64(stmt, Int32(parameterIndex), x)
  }

  public func setDouble(_ parameterIndex: Int, _ x: Double) throws {
    sqlite3_bind_double(stmt, Int32(parameterIndex), x)
  }

  public func setString(_ parameterIndex: Int, _ x: String?) throws {
    if let x {
      sqlite3_bind_text(stmt, Int32(parameterIndex), x, -1, SQLITE_TRANSIENT)
    } else {
      sqlite3_bind_null(stmt, Int32(parameterIndex))
    }
  }

  public func setDate(_ parameterIndex: Int, _ x: java.sql.Date?) throws {
    try setString(parameterIndex, x?.toString())
  }

  public func setTime(_ parameterIndex: Int, _ x: java.sql.Time?) throws {
    try setString(parameterIndex, x?.toString())
  }

  public func setTimestamp(_ parameterIndex: Int, _ x: java.sql.Timestamp?) throws {
    try setString(parameterIndex, x?.toString())
  }

  public func setBytes(_ parameterIndex: Int, _ x: [UInt8]?) throws {
    if let x {
      sqlite3_bind_blob(stmt, Int32(parameterIndex), x, Int32(x.count), SQLITE_TRANSIENT)
    } else {
      sqlite3_bind_null(stmt, Int32(parameterIndex))
    }
  }

  // MARK: – Statement pass-through

  public func executeQuery(_ sql: String) throws -> any java.sql.ResultSet {
    throw java.sql.SQLException("Use executeQuery() without SQL on a PreparedStatement")
  }

  public func executeUpdate(_ sql: String) throws -> Int {
    throw java.sql.SQLException("Use executeUpdate() without SQL on a PreparedStatement")
  }

  public func execute(_ sql: String) throws -> Bool {
    throw java.sql.SQLException("Use execute() without SQL on a PreparedStatement")
  }

  public func getResultSet() throws -> (any java.sql.ResultSet)? { return currentResultSet }
  public func getUpdateCount() throws -> Int { return updateCount }
  public func close() throws { sqlite3_finalize(stmt); stmt = nil }

  public var warnings: java.sql.SQLWarning? { get throws { return nil } }
  public func clearWarnings() throws {}

  public func setMaxRows(_ max: Int) throws { maxRows = max }
  public func getMaxRows() throws -> Int { return maxRows }
  public func setQueryTimeout(_ seconds: Int) throws { queryTimeout = seconds }
  public func getQueryTimeout() throws -> Int { return queryTimeout }
}

// SQLITE_TRANSIENT tells SQLite to copy the data immediately
private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
