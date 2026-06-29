/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension java.util.logging {

  /// - Since: Java 1.4
  open class Logger {

    public static let GLOBAL_LOGGER_NAME = "global"

    // Root logger: parent of all named loggers that have no explicit parent.
    // Java's spec says getAnonymousLogger() returns a logger whose parent is
    // the root logger. We model this as a module-level singleton.
    nonisolated(unsafe) private static let _rootLogger: Logger = {
      let root = Logger(nil, nil)
      root._level = Level.INFO
      return root
    }()

    private var name: String?
    private var resourceBundleName: String?
    private var handlers: [Handler] = []
    private var _level: Level? = nil

    internal init(_ theName: String?, _ theResourceBundleName: String? = nil) {
      self.name = theName
      self.resourceBundleName = theResourceBundleName
    }

    // -------------------------------------------------------------------------
    // MARK: - Factory methods
    // -------------------------------------------------------------------------

    /// Returns a named logger, registering it with the LogManager if needed.
    public static func getLogger(_ name: String) -> Logger {
      let mgr = LogManager.getLogManager()
      if let existing = mgr.getLogger(name) { return existing }
      let logger = Logger(name)
      _ = mgr.addLogger(logger)
      return logger
    }

    /// Returns a named logger with an associated resource bundle.
    public static func getLogger(_ name: String, _ resourceBundleName: String) -> Logger {
      let mgr = LogManager.getLogManager()
      if let existing = mgr.getLogger(name) { return existing }
      let logger = Logger(name, resourceBundleName)
      _ = mgr.addLogger(logger)
      return logger
    }

    /// Returns an anonymous logger whose parent is the root logger.
    /// Anonymous loggers are NOT registered with LogManager.
    public static func getAnonymousLogger() -> Logger {
      let anon = Logger(nil, nil)
      anon._level = Logger._rootLogger._level
      return anon
    }

    // -------------------------------------------------------------------------
    // MARK: - Properties
    // -------------------------------------------------------------------------

    open func getName() -> String? { return name }

    open func getLevel() -> Level? { return _level }

    open func setLevel(_ level: Level) { self._level = level }

    /// Effective level: walk up to root if own level is nil.
    private func effectiveLevel() -> Level {
      return _level ?? Logger._rootLogger._level ?? Level.INFO
    }

    private func isLoggable(_ level: Level) -> Bool {
      return level.intValue() >= effectiveLevel().intValue()
    }

    // -------------------------------------------------------------------------
    // MARK: - Handlers
    // -------------------------------------------------------------------------

    open func addHandler(_ handler: Handler) {
      self.handlers.append(handler)
    }

    open func removeHandler(_ handler: Handler) {
      self.handlers.removeAll(where: { $0 === handler })
    }

    open func getHandlers() -> [Handler] { return handlers }

    // -------------------------------------------------------------------------
    // MARK: - Core log method
    // -------------------------------------------------------------------------

    /// Logs a `LogRecord`. All convenience methods delegate here.
    open func log(_ record: LogRecord) {
      guard isLoggable(record.getLevel()) else { return }
      for h in handlers { h.publish(record) }
      // propagate to root if no own handlers
      if handlers.isEmpty && self !== Logger._rootLogger {
        for h in Logger._rootLogger.handlers { h.publish(record) }
      }
    }

    // -------------------------------------------------------------------------
    // MARK: - Convenience log methods
    // -------------------------------------------------------------------------

    open func severe(_ msg: String) {
      log(LogRecord(Level.SEVERE, msg))
    }

    open func warning(_ msg: String) {
      log(LogRecord(Level.WARNING, msg))
    }

    open func info(_ msg: String) {
      log(LogRecord(Level.INFO, msg))
    }

    open func config(_ msg: String) {
      log(LogRecord(Level.CONFIG, msg))
    }

    open func fine(_ msg: String) {
      log(LogRecord(Level.FINE, msg))
    }

    open func finer(_ msg: String) {
      log(LogRecord(Level.FINER, msg))
    }

    open func finest(_ msg: String) {
      log(LogRecord(Level.FINEST, msg))
    }

    /// Logs at an arbitrary level with a message.
    open func log(_ level: Level, _ msg: String) {
      log(LogRecord(level, msg))
    }

    /// Logs at an arbitrary level with a message supplier (lazy evaluation).
    open func log(_ level: Level, _ msgSupplier: () -> String) {
      guard isLoggable(level) else { return }
      log(LogRecord(level, msgSupplier()))
    }

    /// Logs at an arbitrary level with a throwable.
    open func log(_ level: Level, _ msg: String, _ thrown: Throwable) {
      let record = LogRecord(level, msg)
      record.setThrown(thrown)
      log(record)
    }

    open func entering(_ sourceClass: String, _ sourceMethod: String) {
      guard isLoggable(Level.FINER) else { return }
      let record = LogRecord(Level.FINER, "ENTRY")
      record.setSourceClassName(sourceClass)
      record.setSourceMethodName(sourceMethod)
      log(record)
    }

    open func exiting(_ sourceClass: String, _ sourceMethod: String) {
      guard isLoggable(Level.FINER) else { return }
      let record = LogRecord(Level.FINER, "RETURN")
      record.setSourceClassName(sourceClass)
      record.setSourceMethodName(sourceMethod)
      log(record)
    }

    open func throwing(_ sourceClass: String, _ sourceMethod: String, _ thrown: Throwable) {
      guard isLoggable(Level.FINER) else { return }
      let record = LogRecord(Level.FINER, "THROW")
      record.setSourceClassName(sourceClass)
      record.setSourceMethodName(sourceMethod)
      record.setThrown(thrown)
      log(record)
    }
  }
}
