/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.sql {

  /// An object that provides information about the types and properties of
  /// the columns in a `ResultSet`.
  ///
  /// Mirrors `java.sql.ResultSetMetaData` (Java 1.1).
  ///
  /// - Since: JavaApi (Java 1.1)
  public protocol ResultSetMetaData: AnyObject {

    /// Returns the number of columns in this result set.
    func getColumnCount() throws -> Int

    /// Returns the designated column's name (1-based index).
    func getColumnName(_ column: Int) throws -> String

    /// Returns the designated column's label (alias), or the column name if
    /// no alias was specified.
    func getColumnLabel(_ column: Int) throws -> String

    /// Returns the designated column's SQL type from ``Types``.
    func getColumnType(_ column: Int) throws -> Int

    /// Returns the designated column's type name as reported by the database.
    func getColumnTypeName(_ column: Int) throws -> String

    /// Returns `true` if `NULL` values are allowed in the column.
    func isNullable(_ column: Int) throws -> Int

    /// Returns the column's display size.
    func getColumnDisplaySize(_ column: Int) throws -> Int
  }
}

extension java.sql.ResultSetMetaData {
  /// Constant: column does not allow NULL.
  public var columnNoNulls: Int { 0 }
  /// Constant: column allows NULL.
  public var columnNullable: Int { 1 }
  /// Constant: nullability unknown.
  public var columnNullableUnknown: Int { 2 }
}
