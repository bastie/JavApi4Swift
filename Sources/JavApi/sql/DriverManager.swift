/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.sql {

  /// The basic service for managing a set of JDBC drivers.
  ///
  /// Mirrors `java.sql.DriverManager` (Java 1.1). Because Swift has no
  /// runtime reflection or classpath scanning, drivers must be registered
  /// explicitly via ``registerDriver(_:)`` before use. This replaces the
  /// Java idiom of `Class.forName("org.example.Driver")`.
  ///
  /// ```swift
  /// try java.sql.DriverManager.registerDriver(SQLiteDriver())
  /// let conn = try java.sql.DriverManager.getConnection("jdbc:sqlite::memory:")
  /// ```
  ///
  /// - Since: JavaApi (Java 1.1)
  ///
  /// `registeredDrivers` is process-global mutable state. Swift Testing runs
  /// tests concurrently (especially under Xcode), so all access is funneled
  /// through an `NSLock` to avoid the same kind of data race that caused
  /// `EXC_BAD_ACCESS`/`EXC_BREAKPOINT` crashes in ``java/util/logging/LogManager``.
  public enum DriverManager {

    /// Registered driver instances (SPI registry — replaces META-INF/services).
    nonisolated(unsafe) private static var registeredDrivers: [any Driver] = []
    private static let lock = NSLock()

    private static func withLock<T>(_ body: () throws -> T) rethrows -> T {
      lock.lock()
      defer { lock.unlock() }
      return try body()
    }

    // MARK: – Driver registration

    /// Registers a driver with the manager.
    public static func registerDriver(_ driver: any Driver) throws {
      withLock { registeredDrivers.append(driver) }
    }

    /// Deregisters a driver. Drivers are matched by identity (`===`).
    public static func deregisterDriver(_ driver: any Driver) throws {
      withLock { registeredDrivers.removeAll { $0 === driver } }
    }

    /// Returns all registered drivers.
    public static func getDrivers() -> [any Driver] {
      withLock { registeredDrivers }
    }

    // MARK: – Connection factory

    /// Attempts to establish a connection to the given database URL.
    ///
    /// Iterates registered drivers in registration order and returns the
    /// first connection successfully established.
    ///
    /// - Throws: ``SQLException`` if no driver accepts the URL or the
    ///   connection attempt fails.
    public static func getConnection(_ url: String) throws -> any Connection {
      return try getConnection(url, nil)
    }

    /// Attempts to establish a connection using the given URL and properties.
    public static func getConnection(_ url: String, _ info: [String: String]?) throws -> any Connection {
      let drivers = withLock { registeredDrivers }
      for driver in drivers {
        if let conn = try driver.connect(url, info) {
          return conn
        }
      }
      throw SQLException("No suitable driver found for \(url)")
    }

    // MARK: – Driver lookup

    /// Returns the first registered driver that accepts the given URL.
    public static func getDriver(_ url: String) throws -> any Driver {
      let drivers = withLock { registeredDrivers }
      for driver in drivers {
        if try driver.acceptsURL(url) { return driver }
      }
      throw SQLException("No suitable driver found for \(url)")
    }
  }
}
