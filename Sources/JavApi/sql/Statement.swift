/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.sql {

  /// An object used for executing a static SQL statement and returning the
  /// results it produces.
  ///
  /// Mirrors `java.sql.Statement` (Java 1.1).
  ///
  /// - Since: JavaApi (Java 1.1)
  public protocol Statement: AnyObject {

    /// Executes a SQL query and returns the result set.
    @discardableResult
    func executeQuery(_ sql: String) throws -> any ResultSet

    /// Executes a SQL DML statement; returns the row count.
    func executeUpdate(_ sql: String) throws -> Int

    /// Executes a SQL statement that may return multiple results.
    /// - Returns: `true` if the result is a `ResultSet`.
    func execute(_ sql: String) throws -> Bool

    /// Returns the current result as a `ResultSet`, or `nil`.
    func getResultSet() throws -> (any ResultSet)?

    /// Returns the current result as an update count, or -1.
    func getUpdateCount() throws -> Int

    func close() throws

    var warnings: SQLWarning? { get throws }
    func clearWarnings() throws

    func setMaxRows(_ max: Int) throws
    func getMaxRows() throws -> Int

    func setQueryTimeout(_ seconds: Int) throws
    func getQueryTimeout() throws -> Int
  }
}
