/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import SQLite3
import JavApi
import Foundation

/// A forward-only JDBC `ResultSet` that iterates over SQLite rows.
public final class SQLiteResultSet: java.sql.ResultSet {

  private var stmt: OpaquePointer?
  private let connection: SQLiteConnection
  private var ownStatement: Bool          // true when we compiled the stmt ourselves
  private var lastWasNull: Bool = false
  private var exhausted: Bool = false
  private var maxRows: Int
  private var rowCount: Int = 0

  /// Init from a raw SQL string (used by `SQLiteStatement`).
  init(connection: SQLiteConnection, sql: String, maxRows: Int) throws {
    self.connection = connection
    self.maxRows = maxRows
    self.ownStatement = true
    let rc = sqlite3_prepare_v2(connection.db, sql, -1, &stmt, nil)
    guard rc == SQLITE_OK else { throw connection.sqliteError() }
  }

  /// Init from an already-prepared stmt (used by `SQLitePreparedStatement`).
  init(stmt: OpaquePointer?, connection: SQLiteConnection, maxRows: Int) throws {
    self.stmt = stmt
    self.connection = connection
    self.maxRows = maxRows
    self.ownStatement = false
  }

  deinit {
    if ownStatement { sqlite3_finalize(stmt) }
  }

  // MARK: – Cursor

  public func next() throws -> Bool {
    guard !exhausted else { return false }
    if maxRows > 0 && rowCount >= maxRows {
      exhausted = true
      return false
    }
    let rc = sqlite3_step(stmt)
    switch rc {
    case SQLITE_ROW:
      rowCount += 1
      return true
    case SQLITE_DONE:
      exhausted = true
      return false
    default:
      throw connection.sqliteError()
    }
  }

  public func close() throws {
    if ownStatement { sqlite3_finalize(stmt); stmt = nil }
    exhausted = true
  }

  public func wasNull() throws -> Bool { return lastWasNull }

  // MARK: – Column accessors (1-based index)

  public func getString(_ columnIndex: Int) throws -> String? {
    let col = Int32(columnIndex - 1)
    if sqlite3_column_type(stmt, col) == SQLITE_NULL { lastWasNull = true; return nil }
    lastWasNull = false
    guard let ptr = sqlite3_column_text(stmt, col) else { return nil }
    return String(cString: ptr)
  }

  public func getString(_ columnLabel: String) throws -> String? {
    return try getString(try findColumn(columnLabel))
  }

  public func getBoolean(_ columnIndex: Int) throws -> Bool {
    let col = Int32(columnIndex - 1)
    lastWasNull = sqlite3_column_type(stmt, col) == SQLITE_NULL
    return sqlite3_column_int(stmt, col) != 0
  }

  public func getBoolean(_ columnLabel: String) throws -> Bool {
    return try getBoolean(try findColumn(columnLabel))
  }

  public func getInt(_ columnIndex: Int) throws -> Int {
    let col = Int32(columnIndex - 1)
    lastWasNull = sqlite3_column_type(stmt, col) == SQLITE_NULL
    return Int(sqlite3_column_int64(stmt, col))
  }

  public func getInt(_ columnLabel: String) throws -> Int {
    return try getInt(try findColumn(columnLabel))
  }

  public func getLong(_ columnIndex: Int) throws -> Int64 {
    let col = Int32(columnIndex - 1)
    lastWasNull = sqlite3_column_type(stmt, col) == SQLITE_NULL
    return sqlite3_column_int64(stmt, col)
  }

  public func getLong(_ columnLabel: String) throws -> Int64 {
    return try getLong(try findColumn(columnLabel))
  }

  public func getDouble(_ columnIndex: Int) throws -> Double {
    let col = Int32(columnIndex - 1)
    lastWasNull = sqlite3_column_type(stmt, col) == SQLITE_NULL
    return sqlite3_column_double(stmt, col)
  }

  public func getDouble(_ columnLabel: String) throws -> Double {
    return try getDouble(try findColumn(columnLabel))
  }

  public func getDate(_ columnIndex: Int) throws -> java.sql.Date? {
    guard let s = try getString(columnIndex) else { return nil }
    let ms = parseISODate(s)
    return java.sql.Date(ms)
  }

  public func getDate(_ columnLabel: String) throws -> java.sql.Date? {
    return try getDate(try findColumn(columnLabel))
  }

  public func getTime(_ columnIndex: Int) throws -> java.sql.Time? {
    guard let s = try getString(columnIndex) else { return nil }
    return java.sql.Time(parseISODate(s))
  }

  public func getTime(_ columnLabel: String) throws -> java.sql.Time? {
    return try getTime(try findColumn(columnLabel))
  }

  public func getTimestamp(_ columnIndex: Int) throws -> java.sql.Timestamp? {
    guard let s = try getString(columnIndex) else { return nil }
    return java.sql.Timestamp(parseISODate(s))
  }

  public func getTimestamp(_ columnLabel: String) throws -> java.sql.Timestamp? {
    return try getTimestamp(try findColumn(columnLabel))
  }

  // MARK: – Metadata

  public func getMetaData() throws -> any java.sql.ResultSetMetaData {
    return SQLiteResultSetMetaData(stmt: stmt)
  }

  public func findColumn(_ columnLabel: String) throws -> Int {
    let count = sqlite3_column_count(stmt)
    for i in 0..<count {
      if let ptr = sqlite3_column_name(stmt, i), String(cString: ptr) == columnLabel {
        return Int(i + 1)
      }
    }
    throw java.sql.SQLException("Column '\(columnLabel)' not found")
  }

  public var warnings: java.sql.SQLWarning? { get throws { return nil } }

  // MARK: – Helpers

  private func parseISODate(_ s: String) -> Int64 {
    // Simple ISO-8601 parser for yyyy-MM-dd or yyyy-MM-dd HH:mm:ss
    var cal = Foundation.Calendar(identifier: .gregorian)
    cal.timeZone = Foundation.TimeZone(secondsFromGMT: 0)!
    let fmt = Foundation.DateFormatter()
    fmt.calendar = cal
    fmt.timeZone = Foundation.TimeZone(secondsFromGMT: 0)
    for pattern in ["yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd", "HH:mm:ss"] {
      fmt.dateFormat = pattern
      if let d = fmt.date(from: s) {
        return Int64(d.timeIntervalSince1970 * 1000)
      }
    }
    return 0
  }
}
