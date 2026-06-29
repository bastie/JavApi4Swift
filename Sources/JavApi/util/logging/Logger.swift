/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension java.util.logging {

  /// A named logging channel, mirroring `java.util.logging.Logger` (Java 1.4).
  ///
  /// **Hierarchy**
  /// Every logger has a parent (default: the root logger `""`).  Level
  /// resolution and handler propagation walk the parent chain exactly as
  /// specified by Java:
  /// - `effectiveLevel()` returns the first non-nil level found walking up.
  /// - `log(_:)` publishes to own handlers; if `useParentHandlers` is `true`
  ///   (the default) it then propagates to the parent, and so on up to root.
  ///
  /// **Root logger**
  /// The root logger has the name `""` and is registered in `LogManager`.
  /// Its default level is `INFO`.
  ///
  /// - Since: Java 1.4
  open class Logger {

    public static let GLOBAL_LOGGER_NAME = "global"
    public static let ROOT_LOGGER_NAME   = ""

    // -------------------------------------------------------------------------
    // MARK: - Root logger singleton
    // -------------------------------------------------------------------------

    /// The root logger (`""`).  Registered in LogManager on first access.
    nonisolated(unsafe) public static let rootLogger: Logger = {
      let root = Logger(ROOT_LOGGER_NAME, nil)
      root._level = Level.INFO
      root._parent = nil
      root._useParentHandlers = false
      _ = LogManager.getLogManager().addLogger(root)
      return root
    }()

    // -------------------------------------------------------------------------
    // MARK: - Storage
    // -------------------------------------------------------------------------

    private var name: String?
    private var resourceBundleName: String?
    private var handlers: [Handler] = []
    private var _level: Level? = nil
    private var _parent: Logger? = nil
    private var _useParentHandlers: Bool = true

    internal init(_ theName: String?, _ theResourceBundleName: String? = nil) {
      self.name = theName
      self.resourceBundleName = theResourceBundleName
    }

    // -------------------------------------------------------------------------
    // MARK: - Factory methods
    // -------------------------------------------------------------------------

    /// Returns a named logger, registering it with LogManager if needed.
    public static func getLogger(_ name: String) -> Logger {
      let mgr = LogManager.getLogManager()
      if let existing = mgr.getLogger(name) { return existing }
      let logger = Logger(name)
      logger._parent = rootLogger
      _ = mgr.addLogger(logger)
      return logger
    }

    /// Returns a named logger with an associated resource bundle.
    public static func getLogger(_ name: String, _ resourceBundleName: String) -> Logger {
      let mgr = LogManager.getLogManager()
      if let existing = mgr.getLogger(name) { return existing }
      let logger = Logger(name, resourceBundleName)
      logger._parent = rootLogger
      _ = mgr.addLogger(logger)
      return logger
    }

    /// Returns an anonymous logger whose parent is the root logger.
    /// Anonymous loggers are NOT registered with LogManager.
    public static func getAnonymousLogger() -> Logger {
      let anon = Logger(nil, nil)
      anon._parent = rootLogger
      return anon
    }

    // -------------------------------------------------------------------------
    // MARK: - Properties
    // -------------------------------------------------------------------------

    open func getName() -> String? { return name }

    open func getLevel() -> Level? { return _level }

    open func setLevel(_ level: Level) { self._level = level }

    /// The parent logger in the namespace hierarchy.
    open func getParent() -> Logger? { return _parent }

    /// Sets the parent logger (normally managed by LogManager).
    open func setParent(_ parent: Logger) { self._parent = parent }

    /// Whether this logger passes records to its parent's handlers.
    open func getUseParentHandlers() -> Bool { return _useParentHandlers }

    open func setUseParentHandlers(_ useParentHandlers: Bool) {
      self._useParentHandlers = useParentHandlers
    }

    /// Effective level: walk parent chain until a non-nil level is found.
    private func effectiveLevel() -> Level {
      var current: Logger? = self
      while let logger = current {
        if let lvl = logger._level { return lvl }
        current = logger._parent
      }
      return Level.INFO
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

    /// Logs a `LogRecord`, propagating up the parent chain.
    open func log(_ record: LogRecord) {
      guard isLoggable(record.getLevel()) else { return }
      _publish(record)
    }

    /// Internal: publish to own handlers, then propagate to parent if enabled.
    private func _publish(_ record: LogRecord) {
      for h in handlers { h.publish(record) }
      if _useParentHandlers, let parent = _parent {
        parent._publish(record)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: - Convenience log methods
    // -------------------------------------------------------------------------

    open func severe(_ msg: String) { log(LogRecord(Level.SEVERE, msg)) }
    open func warning(_ msg: String) { log(LogRecord(Level.WARNING, msg)) }
    open func info(_ msg: String) { log(LogRecord(Level.INFO, msg)) }
    open func config(_ msg: String) { log(LogRecord(Level.CONFIG, msg)) }
    open func fine(_ msg: String) { log(LogRecord(Level.FINE, msg)) }
    open func finer(_ msg: String) { log(LogRecord(Level.FINER, msg)) }
    open func finest(_ msg: String) { log(LogRecord(Level.FINEST, msg)) }

    open func log(_ level: Level, _ msg: String) {
      log(LogRecord(level, msg))
    }

    open func log(_ level: Level, _ msgSupplier: () -> String) {
      guard isLoggable(level) else { return }
      log(LogRecord(level, msgSupplier()))
    }

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
