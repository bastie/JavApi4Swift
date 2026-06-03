/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension java.util.logging {
  
  /// - Since: Java 1.4
  open class Formatter {
    
    public init() {}
    
    open func format(_ record: LogRecord) -> String {
      fatalError("not yet implemented")
    }
    
    open func getTail (_ handler : Handler?) -> String {
      return ""
    }
    
    open func getHead(_ handler: Handler?) -> String {
      return ""
    }
  }
}
