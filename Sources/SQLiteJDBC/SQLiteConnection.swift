/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import SQLite3
import JavApi

/// A JDBC `Connection` backed by a single SQLite database handle.
public final class SQLiteConnection: java.sql.Connection {

  internal var db: OpaquePointer?
  private var closed = false
  private var autoCommit = true

  init(path: String) throws {
    let flags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE
    let rc = sqlite3_open_v2(path, &db, flags, nil)
    guard rc == SQLITE_OK else {
      let msg = String(cString: sqlite3_errmsg(db))
      sqlite3_close(db)
      throw java.sql.SQLException("Cannot open SQLite database at '\(path)': \(msg)", "08001", Int(rc))
    }
  }

  deinit {
    try? close()
  }

  // MARK: – Statement factory

  public func createStatement() throws -> any java.sql.Statement {
    try checkOpen()
    return SQLiteStatement(connection: self)
  }

  public func prepareStatement(_ sql: String) throws -> any java.sql.PreparedStatement {
    try checkOpen()
    return try SQLitePreparedStatement(connection: self, sql: sql)
  }

  public func prepareCall(_ sql: String) throws -> any java.sql.CallableStatement {
    throw java.sql.SQLException("SQLite does not support stored procedures (CallableStatement)")
  }

  // MARK: – Transaction control

  public func getAutoCommit() throws -> Bool { return autoCommit }

  public func setAutoCommit(_ autoCommit: Bool) throws {
    try checkOpen()
    if self.autoCommit == autoCommit { return }
    self.autoCommit = autoCommit
    if autoCommit {
      try execSQL("COMMIT")
    } else {
      try execSQL("BEGIN")
    }
  }

  public func commit() throws {
    try checkOpen()
    try execSQL("COMMIT")
    if !autoCommit { try execSQL("BEGIN") }
  }

  public func rollback() throws {
    try checkOpen()
    try execSQL("ROLLBACK")
    if !autoCommit { try execSQL("BEGIN") }
  }

  // MARK: – Isolation

  public var TRANSACTION_NONE            : Int { 0 }
  public var TRANSACTION_READ_UNCOMMITTED: Int { 1 }
  public var TRANSACTION_READ_COMMITTED  : Int { 2 }
  public var TRANSACTION_REPEATABLE_READ : Int { 4 }
  public var TRANSACTION_SERIALIZABLE    : Int { 8 }

  public func getTransactionIsolation() throws -> Int { return TRANSACTION_SERIALIZABLE }
  public func setTransactionIsolation(_ level: Int) throws {
    // SQLite supports SERIALIZABLE only; accept silently for API compat
  }

  // MARK: – Lifecycle

  public func close() throws {
    guard !closed else { return }
    closed = true
    sqlite3_close(db)
    db = nil
  }

  public func isClosed() throws -> Bool { return closed }

  // MARK: – Metadata & warnings

  public func getMetaData() throws -> any java.sql.DatabaseMetaData {
    try checkOpen()
    return SQLiteDatabaseMetaData(connection: self)
  }

  public var warnings: java.sql.SQLWarning? {
    get throws { return nil }
  }

  public func clearWarnings() throws {}

  // MARK: – Catalog

  public func getCatalog() throws -> String? { return nil }
  public func setCatalog(_ catalog: String?) throws {}

  // MARK: – Utility

  public func nativeSQL(_ sql: String) throws -> String { return sql }

  // MARK: – Internal helpers

  internal func checkOpen() throws {
    if closed { throw java.sql.SQLException("Connection is closed") }
  }

  internal func execSQL(_ sql: String) throws {
    var errMsg: UnsafeMutablePointer<CChar>? = nil
    let rc = sqlite3_exec(db, sql, nil, nil, &errMsg)
    if rc != SQLITE_OK {
      let msg = errMsg.map { String(cString: $0) } ?? "unknown error"
      sqlite3_free(errMsg)
      throw java.sql.SQLException(msg, sql, Int(rc))
    }
  }

  internal func sqliteError() -> java.sql.SQLException {
    let msg = db.map { String(cString: sqlite3_errmsg($0)) } ?? "unknown error"
    let code = db.map { Int(sqlite3_errcode($0)) } ?? -1
    return java.sql.SQLException(msg, "HY000", code)
  }
}
