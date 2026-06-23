/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// The `java.sql` package — JDBC 1.x (Java 1.1) API.
///
/// Concrete driver implementations are provided by separate library targets
/// (e.g. `SQLiteJDBC`). Register a driver before use:
///
/// ```swift
/// try java.sql.DriverManager.registerDriver(MyDriver())
/// let conn = try java.sql.DriverManager.getConnection("jdbc:mydb://host/db")
/// ```
extension java {
  public enum sql {}
}
