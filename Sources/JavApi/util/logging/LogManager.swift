/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

import Foundation

extension java.util.logging {

  /// - Since: Java 1.4
  ///
  /// `LogManager` is a global singleton whose `registeredLogger` map is
  /// mutated from `addLogger` and read from `getLogger`. Swift Testing runs
  /// tests concurrently (especially under Xcode's parallel test execution),
  /// so unsynchronized access to that dictionary is a data race that can
  /// corrupt memory (`EXC_BAD_ACCESS`). All access is therefore funneled
  /// through an `NSLock`, mirroring the pattern used by
  /// ``java/util/Hashtable``.
  open class LogManager {

    nonisolated(unsafe) private static let _instance = java.util.logging.LogManager ()

    // init is intentionally internal: LogManager is a singleton accessed via
    // getLogManager(). Java's constructor is also protected — internal matches
    // the intent (subclassable within the module, not publicly instantiable).
    internal init() {
    }

    private var registeredLogger : [String: Logger] = [:]
    private let lock = NSLock()

    private func withLock<T>(_ body: () throws -> T) rethrows -> T {
      lock.lock()
      defer { lock.unlock() }
      return try body()
    }

    public static func getLogManager() -> LogManager {
      return _instance
    }

    open func addLogger(_ logger: Logger) -> Bool {
      guard let name = logger.getName() else { return false }
      return withLock {
        if registeredLogger[name] != nil { return false }
        registeredLogger[name] = logger
        return true
      }
    }

    open func getLogger(_ name: String) -> Logger? {
      if name == Logger.ROOT_LOGGER_NAME {
        return Logger.rootLogger
      }
      return withLock { registeredLogger[name] }
    }

    /// Returns an `Enumeration` of all registered logger names.
    ///
    /// - Since: Java 1.4
    open func getLoggerNames() -> any java.util.Enumeration<String> {
      let names : [String] = withLock { Array(registeredLogger.keys) }
      
      return java.util.Collections.enumeration(java.util.ArrayList(from: names))
    }

    /// Returns a logging property from the manager's property set.
    ///
    /// This implementation has no persistent property store and always
    /// returns `nil`.
    ///
    /// - Since: Java 1.4
    open func getProperty(_ name: String) -> String? { nil }

    /// Re-initialises the logging configuration from the default location.
    ///
    /// This implementation is a no-op: no properties file system is supported.
    ///
    /// - Since: Java 1.4
    open func readConfiguration() throws {}

    /// Resets the logging configuration.
    ///
    /// Closes all handlers on all registered loggers and removes all loggers
    /// except the root logger.
    ///
    /// - Since: Java 1.4
    open func reset() {
      withLock {
        for logger in registeredLogger.values {
          for handler in logger.getHandlers() {
            try? handler.close()
          }
        }
        // Keep only the root logger.
        let root = registeredLogger[Logger.ROOT_LOGGER_NAME]
        registeredLogger = [:]
        if let root { registeredLogger[Logger.ROOT_LOGGER_NAME] = root }
      }
    }
  }
}
