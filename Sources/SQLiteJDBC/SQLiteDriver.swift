/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import SQLite3
import JavApi

/// A JDBC 1.x driver backed by the system SQLite library.
///
/// Register once before use:
/// ```swift
/// try java.sql.DriverManager.registerDriver(SQLiteDriver())
/// ```
///
/// Accepted URL scheme: `jdbc:sqlite:<path>` or `jdbc:sqlite::memory:`
///
/// - Since: JavApi4Swift (Java 1.1 / JDBC 1.x)
public final class SQLiteDriver: java.sql.Driver {

  public init() {}

  public func acceptsURL(_ url: String) throws -> Bool {
    return url.hasPrefix("jdbc:sqlite:")
  }

  public func connect(_ url: String, _ info: [String: String]?) throws -> (any java.sql.Connection)? {
    guard try acceptsURL(url) else { return nil }
    let path = String(url.dropFirst("jdbc:sqlite:".count))
    return try SQLiteConnection(path: path)
  }

  public func getPropertyInfo(_ url: String, _ info: [String: String]?) throws -> [java.sql.DriverPropertyInfo] {
    return []
  }

  public var majorVersion: Int { 1 }
  public var minorVersion: Int { 0 }
  public var jdbcCompliant: Bool { false }
}
