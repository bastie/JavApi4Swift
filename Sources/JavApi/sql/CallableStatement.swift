/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.sql {

  /// An interface used to execute SQL stored procedures.
  ///
  /// Mirrors `java.sql.CallableStatement` (Java 1.1).
  ///
  /// > Note: SQLiteJDBC does not implement this protocol because SQLite has
  /// > no stored-procedure support. The protocol is provided for API
  /// > completeness only.
  ///
  /// - Since: JavaApi (Java 1.1)
  public protocol CallableStatement: PreparedStatement {

    func registerOutParameter(_ parameterIndex: Int, _ sqlType: Int) throws
    func wasNull() throws -> Bool

    func getString(_ parameterIndex: Int) throws -> String?
    func getBoolean(_ parameterIndex: Int) throws -> Bool
    func getInt(_ parameterIndex: Int) throws -> Int
    func getLong(_ parameterIndex: Int) throws -> Int64
    func getDouble(_ parameterIndex: Int) throws -> Double
    func getDate(_ parameterIndex: Int) throws -> java.sql.Date?
    func getTime(_ parameterIndex: Int) throws -> java.sql.Time?
    func getTimestamp(_ parameterIndex: Int) throws -> java.sql.Timestamp?
  }
}
