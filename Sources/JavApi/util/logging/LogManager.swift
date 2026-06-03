/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension java.util.logging {
  
  /// - Since: Java 1.4
  open class LogManager {
    
    nonisolated(unsafe) private static let _instance = java.util.logging.LogManager ()
    
    internal init() { // FIXME: maybe public visibility
    }
    
    private var registeredLogger : [String: Logger] = [:]
    
    public static func getLogManager() -> LogManager {
      return _instance
    }
    
    open func addLogger(_ logger: Logger) -> Bool {
      guard logger.getName() != nil else { return false }
      if let _ = registeredLogger[logger.getName()!] {
        return false
      }
      self.registeredLogger[logger.getName()!] = logger
      return true
    }
  }
}
