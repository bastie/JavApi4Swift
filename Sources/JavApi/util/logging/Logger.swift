/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension java.util.logging {
  
  /// - Since: Java 1.4
  open class Logger {
    
    public static let GLOBAL_LOGGER_NAME = "JavApi global logger"
    
    private var name : String?
    private var resourceBundleName : String?
    private var handlers : [Handler] = []
    
    internal init (_ theName : String?, _ theResourceBundleName: String? = nil) {
      self.name = theName
      self.resourceBundleName = theResourceBundleName
    }
    
    public static func getLogger(_ name: String) -> Logger {
      let newLogger = Logger(name)
      _ = LogManager.getLogManager().addLogger(newLogger)
      return newLogger
    }
    
    public static func getAnonymousLogger() -> Logger {
      // TODO: Javadoc tells something over root Logger
      return Logger(nil)
    }
    
    open func getName() -> String? {
      return name
    }
    
    open func addHandler (_ handler: Handler) {
      self.handlers.append(handler)
    }
    
    open func removeHandler (_ handler: Handler) {
      self.handlers.removeAll(where: { $0 === handler })
    }
    
    open func getHandlers() -> [Handler] {
      return handlers
    }
    
    open func log (_ record: LogRecord) {
      
    }
  }
}
