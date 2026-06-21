/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.sql {

  /// A table of data representing a database result set.
  ///
  /// Mirrors `java.sql.ResultSet` (Java 1.1). The cursor is initially
  /// positioned before the first row; call ``next()`` to advance.
  ///
  /// - Since: JavaApi (Java 1.1)
  public protocol ResultSet: AnyObject {

    /// Moves the cursor to the next row.
    /// - Returns: `true` if the new current row is valid; `false` if there are no more rows.
    func next() throws -> Bool

    func close() throws

    func wasNull() throws -> Bool

    // --- String ---
    func getString(_ columnIndex: Int) throws -> String?
    func getString(_ columnLabel: String) throws -> String?

    // --- Boolean ---
    func getBoolean(_ columnIndex: Int) throws -> Bool
    func getBoolean(_ columnLabel: String) throws -> Bool

    // --- Int ---
    func getInt(_ columnIndex: Int) throws -> Int
    func getInt(_ columnLabel: String) throws -> Int

    // --- Long ---
    func getLong(_ columnIndex: Int) throws -> Int64
    func getLong(_ columnLabel: String) throws -> Int64

    // --- Double ---
    func getDouble(_ columnIndex: Int) throws -> Double
    func getDouble(_ columnLabel: String) throws -> Double

    // --- Date / Time / Timestamp ---
    func getDate(_ columnIndex: Int) throws -> java.sql.Date?
    func getDate(_ columnLabel: String) throws -> java.sql.Date?

    func getTime(_ columnIndex: Int) throws -> java.sql.Time?
    func getTime(_ columnLabel: String) throws -> java.sql.Time?

    func getTimestamp(_ columnIndex: Int) throws -> java.sql.Timestamp?
    func getTimestamp(_ columnLabel: String) throws -> java.sql.Timestamp?

    // --- Metadata ---
    func getMetaData() throws -> any ResultSetMetaData

    /// Returns the 1-based column index for the given label.
    func findColumn(_ columnLabel: String) throws -> Int

    var warnings: SQLWarning? { get throws }
  }
}
