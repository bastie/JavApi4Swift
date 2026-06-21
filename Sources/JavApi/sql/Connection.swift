/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.sql {

  /// A connection (session) with a specific database.
  ///
  /// Mirrors `java.sql.Connection` (Java 1.1).
  ///
  /// - Since: JavaApi (Java 1.1)
  public protocol Connection: AnyObject {

    // --- Statement factory ---
    func createStatement() throws -> any Statement
    func prepareStatement(_ sql: String) throws -> any PreparedStatement
    func prepareCall(_ sql: String) throws -> any CallableStatement

    // --- Transaction control ---
    func getAutoCommit() throws -> Bool
    func setAutoCommit(_ autoCommit: Bool) throws
    func commit() throws
    func rollback() throws

    // --- Isolation level ---
    /// Transaction isolation constants (mirrors `java.sql.Connection` constants).
    var TRANSACTION_NONE            : Int { get }
    var TRANSACTION_READ_UNCOMMITTED: Int { get }
    var TRANSACTION_READ_COMMITTED  : Int { get }
    var TRANSACTION_REPEATABLE_READ : Int { get }
    var TRANSACTION_SERIALIZABLE    : Int { get }

    func getTransactionIsolation() throws -> Int
    func setTransactionIsolation(_ level: Int) throws

    // --- Lifecycle ---
    func close() throws
    func isClosed() throws -> Bool

    // --- Metadata & warnings ---
    func getMetaData() throws -> any DatabaseMetaData
    var warnings: SQLWarning? { get throws }
    func clearWarnings() throws

    // --- Catalog ---
    func getCatalog() throws -> String?
    func setCatalog(_ catalog: String?) throws

    // --- Utility ---
    func nativeSQL(_ sql: String) throws -> String
  }
}

extension java.sql.Connection {
  public var TRANSACTION_NONE             : Int { 0 }
  public var TRANSACTION_READ_UNCOMMITTED : Int { 1 }
  public var TRANSACTION_READ_COMMITTED   : Int { 2 }
  public var TRANSACTION_REPEATABLE_READ  : Int { 4 }
  public var TRANSACTION_SERIALIZABLE     : Int { 8 }
}
