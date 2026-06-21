/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.sql {

  /// A precompiled SQL statement object.
  ///
  /// Mirrors `java.sql.PreparedStatement` (Java 1.1). Parameter markers (`?`)
  /// are set via the `set*` methods; indices are 1-based.
  ///
  /// - Since: JavaApi (Java 1.1)
  public protocol PreparedStatement: Statement {

    /// Executes the prepared query and returns a result set.
    @discardableResult
    func executeQuery() throws -> any ResultSet

    /// Executes the prepared DML statement; returns the row count.
    func executeUpdate() throws -> Int

    /// Executes the prepared statement.
    func execute() throws -> Bool

    func clearParameters() throws

    // --- Bind methods (1-based parameter index) ---
    func setNull(_ parameterIndex: Int, _ sqlType: Int) throws
    func setBoolean(_ parameterIndex: Int, _ x: Bool) throws
    func setInt(_ parameterIndex: Int, _ x: Int) throws
    func setLong(_ parameterIndex: Int, _ x: Int64) throws
    func setDouble(_ parameterIndex: Int, _ x: Double) throws
    func setString(_ parameterIndex: Int, _ x: String?) throws
    func setDate(_ parameterIndex: Int, _ x: java.sql.Date?) throws
    func setTime(_ parameterIndex: Int, _ x: java.sql.Time?) throws
    func setTimestamp(_ parameterIndex: Int, _ x: java.sql.Timestamp?) throws
    func setBytes(_ parameterIndex: Int, _ x: [UInt8]?) throws
  }
}
