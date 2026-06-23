/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import SQLite3
import JavApi

/// `ResultSetMetaData` backed by `sqlite3_column_*` metadata functions.
public final class SQLiteResultSetMetaData: java.sql.ResultSetMetaData {

  private let stmt: OpaquePointer?

  init(stmt: OpaquePointer?) {
    self.stmt = stmt
  }

  public func getColumnCount() throws -> Int {
    return Int(sqlite3_column_count(stmt))
  }

  public func getColumnName(_ column: Int) throws -> String {
    guard let ptr = sqlite3_column_name(stmt, Int32(column - 1)) else {
      throw java.sql.SQLException("Column index \(column) out of range")
    }
    return String(cString: ptr)
  }

  public func getColumnLabel(_ column: Int) throws -> String {
    return try getColumnName(column)
  }

  public func getColumnType(_ column: Int) throws -> Int {
    guard let typeName = sqlite3_column_decltype(stmt, Int32(column - 1)).map({ String(cString: $0) }) else {
      // Use storage class of current row value as fallback
      switch sqlite3_column_type(stmt, Int32(column - 1)) {
      case SQLITE_INTEGER: return java.sql.Types.INTEGER
      case SQLITE_FLOAT:   return java.sql.Types.DOUBLE
      case SQLITE_TEXT:    return java.sql.Types.VARCHAR
      case SQLITE_BLOB:    return java.sql.Types.VARBINARY
      default:             return java.sql.Types.NULL
      }
    }
    return sqliteTypeToJDBC(typeName.uppercased())
  }

  public func getColumnTypeName(_ column: Int) throws -> String {
    guard let ptr = sqlite3_column_decltype(stmt, Int32(column - 1)) else {
      return "UNKNOWN"
    }
    return String(cString: ptr)
  }

  public func isNullable(_ column: Int) throws -> Int {
    return columnNullableUnknown
  }

  public func getColumnDisplaySize(_ column: Int) throws -> Int {
    return 255
  }

  // MARK: – Type mapping

  private func sqliteTypeToJDBC(_ typeName: String) -> Int {
    if typeName.contains("INT")              { return java.sql.Types.INTEGER }
    if typeName.contains("REAL") ||
       typeName.contains("FLOA") ||
       typeName.contains("DOUB")            { return java.sql.Types.DOUBLE }
    if typeName.contains("TEXT") ||
       typeName.contains("CHAR") ||
       typeName.contains("CLOB")            { return java.sql.Types.VARCHAR }
    if typeName.contains("BLOB") ||
       typeName.isEmpty                      { return java.sql.Types.VARBINARY }
    if typeName.contains("DATE")            { return java.sql.Types.DATE }
    if typeName.contains("TIME")            { return java.sql.Types.TIMESTAMP }
    if typeName.contains("BOOL")            { return java.sql.Types.BIT }
    if typeName.contains("NUM") ||
       typeName.contains("DEC")             { return java.sql.Types.DECIMAL }
    return java.sql.Types.OTHER
  }
}
