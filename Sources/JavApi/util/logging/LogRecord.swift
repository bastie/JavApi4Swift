/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension java.util.logging {
  
  /// - Since: Java 1.4
  open class LogRecord {

    // Global monotonically-increasing sequence counter.
    nonisolated(unsafe) private static var _globalSequence: Int64 = 0
    private static func _nextSequence() -> Int64 {
      // Non-atomic increment is sufficient for single-threaded use; for
      // multi-threaded callers the value may skip but never repeats within
      // a process lifetime.
      _globalSequence &+= 1
      return _globalSequence
    }

    private var instant: java.time.Instant = java.time.Instant()
    private let level: Level
    private var message: String?
    private var loggerName: String?
    private var sourceClassName: String?
    private var sourceMethodName: String?
    private var thrown: Throwable?

    /// Global sequence number assigned at construction.
    private let _sequenceNumber: Int64

    /// Optional array of message-format parameters.
    private var _parameters: [Any] = []

    /// Thread identifier (ObjectIdentifier of the creating thread as a proxy
    /// for Java's thread ID; 0 on platforms where Thread is unavailable).
    private let _threadID: Int

    /// - Parameters:
    ///   - logLevel: level of log information
    ///   - msg: log information
    public init(_ logLevel: Level, _ msg: String?) {
      self.level = logLevel
      self.message = msg
      self._sequenceNumber = LogRecord._nextSequence()
      self._threadID = 0   // Thread.current not reliable cross-platform
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
    
    open func getMessage() -> String? { return self.message }

    open func getLevel() -> Level { return self.level }

    open func getSourceClassName() -> String? { return self.sourceClassName }
    open func setSourceClassName(_ name: String?) { self.sourceClassName = name }

    open func getSourceMethodName() -> String? { return self.sourceMethodName }
    open func setSourceMethodName(_ name: String?) { self.sourceMethodName = name }

    open func getThrown() -> Throwable? { return self.thrown }
    open func setThrown(_ thrown: Throwable?) { self.thrown = thrown }

    // MARK: - Java 1.4: sequenceNumber

    open func getSequenceNumber() -> Int64 { _sequenceNumber }

    // MARK: - Java 1.4: parameters

    open func getParameters() -> [Any] { _parameters }
    open func setParameters(_ params: [Any]) { _parameters = params }

    // MARK: - Java 1.4: threadID / Java 16: longThreadID

    /// Returns a numeric thread identifier.
    ///
    /// This implementation returns 0 on all platforms because Swift does not
    /// expose a portable integer thread ID.  Subclasses may override this.
    open func getThreadID() -> Int { _threadID }

    /// Returns the thread ID as `Int64` (Java 16).
    open func getLongThreadID() -> Int64 { Int64(_threadID) }
  }

}

