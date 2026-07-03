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
      withLock { registeredLogger[name] }
    }
  }
}
