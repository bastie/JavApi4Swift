/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Testing
import JavApi
import SQLiteJDBC

// MARK: – Shared setup

/// Registers the SQLite driver once for the whole test suite and returns
/// an in-memory connection. Every test that needs a connection calls this.
private func openMemoryConnection() throws -> any java.sql.Connection {
  // registerDriver is idempotent for our purposes (duplicates are harmless)
  try java.sql.DriverManager.registerDriver(SQLiteDriver())
  return try java.sql.DriverManager.getConnection("jdbc:sqlite::memory:")
}

// MARK: – SQLiteJDBC (all sub-suites share the global DriverManager registry,
// so the whole group runs serialized to avoid racing java.sql.DriverManager)

@Suite("SQLiteJDBC", .serialized)
struct SQLiteJDBCTests {

  // MARK: – Driver registration

  @Suite("DriverManager")
  struct DriverManagerTests {

    @Test("registerDriver / getDriver accepts jdbc:sqlite: URL")
    func testDriverRegistration() throws {
      try java.sql.DriverManager.registerDriver(SQLiteDriver())
      let driver = try java.sql.DriverManager.getDriver("jdbc:sqlite::memory:")
      #expect(try driver.acceptsURL("jdbc:sqlite::memory:"))
    }

    @Test("getConnection returns open connection")
    func testGetConnection() throws {
      let conn = try openMemoryConnection()
      #expect(try !conn.isClosed())
      try conn.close()
    }

    @Test("getDriver throws for unknown scheme")
    func testUnknownScheme() throws {
      #expect(throws: (any Error).self) {
        _ = try java.sql.DriverManager.getDriver("jdbc:oracle://localhost/xe")
      }
    }
  }

  // MARK: – DDL & DML via Statement

  @Suite("Statement")
  struct StatementTests {

    @Test("CREATE TABLE and INSERT succeed")
    func testCreateAndInsert() throws {
      let conn = try openMemoryConnection()
      defer { try? conn.close() }
      let stmt = try conn.createStatement()
      defer { try? stmt.close() }

      let isResulSet = try stmt.execute("CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT NOT NULL)")
      #expect(!isResulSet)
      let rows = try stmt.executeUpdate("INSERT INTO users VALUES (1, 'Alice')")
      #expect(rows == 1)
    }

    @Test("SELECT returns correct row count")
    func testSelectRowCount() throws {
      let conn = try openMemoryConnection()
      defer { try? conn.close() }
      let stmt = try conn.createStatement()
      defer { try? stmt.close() }

      _ = try stmt.execute("CREATE TABLE t (x INTEGER)")
      _ = try stmt.execute("INSERT INTO t VALUES (10)")
      _ = try stmt.execute("INSERT INTO t VALUES (20)")
      _ = try stmt.execute("INSERT INTO t VALUES (30)")

      let rs = try stmt.executeQuery("SELECT x FROM t ORDER BY x")
      var values: [Int] = []
      while try rs.next() {
        values.append(try rs.getInt("x"))
      }
      #expect(values == [10, 20, 30])
    }

    @Test("getUpdateCount after DELETE")
    func testDeleteUpdateCount() throws {
      let conn = try openMemoryConnection()
      defer { try? conn.close() }
      let stmt = try conn.createStatement()
      defer { try? stmt.close() }

      _ = try stmt.execute("CREATE TABLE t (id INTEGER)")
      _ = try stmt.execute("INSERT INTO t VALUES (1),(2),(3)")
      let deleted = try stmt.executeUpdate("DELETE FROM t WHERE id > 1")
      #expect(deleted == 2)
    }
  }

  // MARK: – PreparedStatement

  @Suite("PreparedStatement")
  struct PreparedStatementTests {

    @Test("bind and query String parameter")
    func testBindString() throws {
      let conn = try openMemoryConnection()
      defer { try? conn.close() }

      let stmt = try conn.createStatement()
      _  = try stmt.execute("CREATE TABLE items (id INTEGER, label TEXT)")
      let ps = try conn.prepareStatement("INSERT INTO items VALUES (?, ?)")
      defer { try? ps.close() }

      try ps.setInt(1, 42)
      try ps.setString(2, "Widget")
      let rows = try ps.executeUpdate()
      #expect(rows == 1)

      let qs = try conn.prepareStatement("SELECT label FROM items WHERE id = ?")
      try qs.setInt(1, 42)
      let rs = try qs.executeQuery()
      #expect(try rs.next())
      #expect(try rs.getString(1) == "Widget")
    }

    @Test("NULL binding produces wasNull == true")
    func testNullBinding() throws {
      let conn = try openMemoryConnection()
      defer { try? conn.close() }

      let stmt = try conn.createStatement()
      _ = try stmt.execute("CREATE TABLE n (val TEXT)")
      let ps = try conn.prepareStatement("INSERT INTO n VALUES (?)")
      try ps.setNull(1, java.sql.Types.VARCHAR)
      _ = try ps.executeUpdate()

      let rs = try conn.createStatement().executeQuery("SELECT val FROM n")
      #expect(try rs.next())
      let v = try rs.getString(1)
      #expect(v == nil)
      #expect(try rs.wasNull())
    }

    @Test("setDouble round-trip")
    func testDoubleRoundTrip() throws {
      let conn = try openMemoryConnection()
      defer { try? conn.close() }

      let stmt = try conn.createStatement()
      _ = try stmt.execute("CREATE TABLE d (v REAL)")
      let ps = try conn.prepareStatement("INSERT INTO d VALUES (?)")
      try ps.setDouble(1, 3.14159)
      _ = try ps.executeUpdate()

      let rs = try conn.createStatement().executeQuery("SELECT v FROM d")
      #expect(try rs.next())
      let v = try rs.getDouble(1)
      #expect(abs(v - 3.14159) < 1e-10)
    }
  }

  // MARK: – ResultSetMetaData

  @Suite("ResultSetMetaData")
  struct ResultSetMetaDataTests {

    @Test("column count and names")
    func testColumnNamesAndCount() throws {
      let conn = try openMemoryConnection()
      defer { try? conn.close() }

      _ = try conn.createStatement().execute("CREATE TABLE p (id INTEGER, name TEXT, score REAL)")
      _ = try conn.createStatement().execute("INSERT INTO p VALUES (1,'Alice',9.5)")
      let rs = try conn.createStatement().executeQuery("SELECT id, name, score FROM p")
      let meta = try rs.getMetaData()

      #expect(try meta.getColumnCount() == 3)
      #expect(try meta.getColumnName(1) == "id")
      #expect(try meta.getColumnName(2) == "name")
      #expect(try meta.getColumnName(3) == "score")
    }
  }

  // MARK: – Transactions

  @Suite("Transactions")
  struct TransactionTests {

    @Test("rollback discards rows")
    func testRollback() throws {
      let conn = try openMemoryConnection()
      defer { try? conn.close() }

      _ = try conn.createStatement().execute("CREATE TABLE tx (v INTEGER)")
      try conn.setAutoCommit(false)

      _ = try conn.createStatement().execute("INSERT INTO tx VALUES (99)")
      try conn.rollback()
      try conn.setAutoCommit(true)

      let rs = try conn.createStatement().executeQuery("SELECT COUNT(*) FROM tx")
      #expect(try rs.next())
      #expect(try rs.getInt(1) == 0)
    }

    @Test("commit makes rows visible")
    func testCommit() throws {
      let conn = try openMemoryConnection()
      defer { try? conn.close() }

      _ = try conn.createStatement().execute("CREATE TABLE tx2 (v INTEGER)")
      try conn.setAutoCommit(false)
      _ = try conn.createStatement().execute("INSERT INTO tx2 VALUES (7)")
      try conn.commit()
      try conn.setAutoCommit(true)

      let rs = try conn.createStatement().executeQuery("SELECT v FROM tx2")
      #expect(try rs.next())
      #expect(try rs.getInt(1) == 7)
    }
  }

  // MARK: – DatabaseMetaData

  @Suite("DatabaseMetaData")
  struct DatabaseMetaDataTests {

    @Test("product name is SQLite")
    func testProductName() throws {
      let conn = try openMemoryConnection()
      defer { try? conn.close() }
      let meta = try conn.getMetaData()
      #expect(try meta.getDatabaseProductName() == "SQLite")
    }

    @Test("getTables returns created table")
    func testGetTables() throws {
      let conn = try openMemoryConnection()
      defer { try? conn.close() }
      let stmt = try conn.createStatement()
      _ = try stmt.execute("CREATE TABLE myTable (id INTEGER)")
      let rs = try conn.getMetaData().getTables(nil, nil, "myTable", nil)
      #expect(try rs.next())
      #expect(try rs.getString("TABLE_NAME") == "myTable")
    }
  }
}
