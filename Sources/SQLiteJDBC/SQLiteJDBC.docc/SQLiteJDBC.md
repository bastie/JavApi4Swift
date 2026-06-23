# SQLiteJDBC

<!--
* SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
* SPDX-License-Identifier: 0BSD
-->

A JDBC 1.x driver for SQLite, serving as the reference implementation for the `java.sql` API in JavApi⁴Swift.

## Overview

SQLiteJDBC demonstrates how to implement the `java.sql` Service Provider Interface (SPI) defined in JavApi⁴Swift. It connects to SQLite databases via the system `libsqlite3` C library and exposes the connection through the standard JDBC 1.x protocol layer.

This driver is intentionally kept close to the original Java JDBC 1.x specification (Java 1.1, 1997). Features introduced in JDBC 2.0 and later — such as `javax.sql`, scrollable result sets, batch updates, `Blob`/`Clob`, and connection pooling — are out of scope.

## Architecture

### SPI Registration

SQLiteJDBC uses the static registry pattern defined in `java.sql.DriverManager` (see Java2Swift.md). There are no `META-INF/services` files and no runtime reflection. The driver must be registered explicitly before use:

```swift
import SQLiteJDBC

try java.sql.DriverManager.registerDriver(SQLiteDriver())
```

This replaces the Java idiom `Class.forName("org.sqlite.JDBC")`, which relied on a static initializer as a side effect of class loading.

### Layer Structure

```
java.sql (JavApi — protocols only, no implementation)
    ↑ implements
SQLiteJDBC (this library)
    ↑ wraps
CSQLite (system library target — libsqlite3)
```

`JavApi` defines the contracts (`java.sql.Driver`, `java.sql.Connection`, etc.) as Swift protocols. `SQLiteJDBC` provides concrete Swift classes that implement those protocols by calling into the C SQLite API through the `CSQLite` module.

### URL Scheme

The driver accepts connection URLs of the form:

```
jdbc:sqlite:<path>
jdbc:sqlite::memory:
```

The path is passed directly to `sqlite3_open_v2`. Use `:memory:` for an in-process, non-persistent database — useful in unit tests.

## Implemented JDBC 1.x Surface

| java.sql type | SQLiteJDBC class | Notes |
|---|---|---|
| `Driver` | `SQLiteDriver` | URL prefix `jdbc:sqlite:` |
| `Connection` | `SQLiteConnection` | Wraps `sqlite3*` handle |
| `Statement` | `SQLiteStatement` | `sqlite3_exec` / `sqlite3_prepare_v2` |
| `PreparedStatement` | `SQLitePreparedStatement` | `sqlite3_bind_*` |
| `ResultSet` | `SQLiteResultSet` | `sqlite3_step` / `sqlite3_column_*` |
| `ResultSetMetaData` | `SQLiteResultSetMetaData` | Column names and types |
| `DatabaseMetaData` | `SQLiteDatabaseMetaData` | Minimal implementation |

`CallableStatement` is not implemented — SQLite has no stored procedures.

## Platform Support

| Platform | Supported | Notes |
|---|---|---|
| macOS | ✅ | `libsqlite3` is a system framework |
| Linux | ✅ | Requires `libsqlite3-dev` (`apt`) or `sqlite` (`brew`) |
| Windows | ⚠️ | SQLite DLL must be present; untested |
| iOS / tvOS / watchOS | ⚠️ | `libsqlite3` available but sandboxing limits file paths |
| WASI | ❌ | No filesystem, no C library support |

The core `java.sql` protocols in JavApi remain platform-independent. Only this driver target carries the platform restriction.

## Testing

Tests live in `Tests/SQLiteJDBCTests` and use an in-memory SQLite database (`jdbc:sqlite::memory:`) so no external setup is required. Run with:

```bash
swift test --filter SQLiteJDBCTests
```

## Writing Your Own Driver

To implement a JDBC driver for a different database (PostgreSQL, MySQL, …):

1. Create a new Swift package or target that depends on `JavApi`.
2. Implement `java.sql.Driver`, `java.sql.Connection`, `java.sql.Statement`, and `java.sql.ResultSet`.
3. At startup, call `try java.sql.DriverManager.registerDriver(YourDriver())`.

Use `SQLiteJDBC` as the reference — the class structure and SPI wiring apply unchanged.
