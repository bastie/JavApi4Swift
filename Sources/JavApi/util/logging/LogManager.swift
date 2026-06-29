/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension java.util.logging {
  
  /// - Since: Java 1.4
  open class LogManager {
    
    nonisolated(unsafe) private static let _instance = java.util.logging.LogManager ()
    
    // init is intentionally internal: LogManager is a singleton accessed via
    // getLogManager(). Java's constructor is also protected — internal matches
    // the intent (subclassable within the module, not publicly instantiable).
    internal init() {
    }
    
    private var registeredLogger : [String: Logger] = [:]
    
    public static func getLogManager() -> LogManager {
      return _instance
    }
    
    open func addLogger(_ logger: Logger) -> Bool {
      guard let name = logger.getName() else { return false }
      if registeredLogger[name] != nil { return false }
      registeredLogger[name] = logger
      return true
    }

    open func getLogger(_ name: String) -> Logger? {
      return registeredLogger[name]
    }
  }
}
