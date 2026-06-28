/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension java.util.logging {
  
  /// - Since: Java 1.4
  open class LogRecord {
    
    private var instant : java.time.Instant = java.time.Instant()
    
    private let level : Level
    private var message : String?
    
    private var loggerName : String?
    
    /// - Parameters:
    ///    - logLevel: level of log information
    ///    - msg: log information
    public init (_ logLevel : Level, _ msg : String?) {
      self.level = logLevel
      self.message = msg
    }
    
    open func setLoggerName (_ loggerName : String?) {
      self.loggerName = loggerName
    }
    
    open func getLoggerName () -> String? {
      return self.loggerName
    }
    
    @available(*, deprecated, renamed: "setInstant", message: "it is same as use java.time.Instant.ofEpochMilli(milliseconds)")
    open func setMillis (_ millis : Int64) {
      self.setInstant(java.time.Instant.ofEpochMilli(millis))
    }
    
    open func getMillis () -> Int64 {
      return self.instant.epochMilli
    }
    
    open func setInstant (_ instant : java.time.Instant) {
      self.instant = instant
    }
    
    open func getInstant () -> java.time.Instant {
      return self.instant
    }
    
    open func setMessage (_ msg : String?) {
      self.message = msg
    }
    
    open func getMessage () -> String? {
      return self.message
    }
  }
  
}
