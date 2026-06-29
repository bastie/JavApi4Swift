/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// MARK: - Test Handler

/// Captures published LogRecords so tests can inspect them.
private final class CapturingHandler: java.util.logging.Handler {
  var published: [java.util.logging.LogRecord] = []

  override func publish(_ record: java.util.logging.LogRecord) {
    published.append(record)
  }
}

// MARK: - Logger Tests

struct JavApi_util_logging_Tests {

  // MARK: - getLogger caching

  @Test("getLogger() returns same instance for same name")
  func testGetLoggerCaching() {
    let a = java.util.logging.Logger.getLogger("com.example.test.cache")
    let b = java.util.logging.Logger.getLogger("com.example.test.cache")
    #expect(a === b)
  }

  @Test("getLogger() returns different instances for different names")
  func testGetLoggerDifferentNames() {
    let a = java.util.logging.Logger.getLogger("com.example.test.alpha")
    let b = java.util.logging.Logger.getLogger("com.example.test.beta")
    #expect(a !== b)
  }

  @Test("getLogger() name is accessible via getName()")
  func testGetLoggerName() {
    let logger = java.util.logging.Logger.getLogger("com.example.test.named")
    #expect(logger.getName() == "com.example.test.named")
  }

  // MARK: - getAnonymousLogger

  @Test("getAnonymousLogger() returns a logger with no name")
  func testGetAnonymousLoggerNoName() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    #expect(logger.getName() == nil)
  }

  @Test("getAnonymousLogger() returns different instances each call")
  func testGetAnonymousLoggerUnique() {
    let a = java.util.logging.Logger.getAnonymousLogger()
    let b = java.util.logging.Logger.getAnonymousLogger()
    #expect(a !== b)
  }

  // MARK: - Level / isLoggable

  @Test("setLevel and getLevel round-trip")
  func testSetGetLevel() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    logger.setLevel(.WARNING)
    #expect(logger.getLevel() == .WARNING)
  }

  @Test("messages below level are not published")
  func testLevelFiltering() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    logger.setLevel(.WARNING)
    let handler = CapturingHandler()
    logger.addHandler(handler)

    logger.fine("below threshold")
    logger.info("also below")
    #expect(handler.published.isEmpty)
  }

  @Test("messages at or above level are published")
  func testLevelFilteringAbove() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    logger.setLevel(.WARNING)
    let handler = CapturingHandler()
    logger.addHandler(handler)

    logger.warning("at threshold")
    logger.severe("above threshold")
    #expect(handler.published.count == 2)
  }

  // MARK: - Convenience methods

  @Test("severe() publishes SEVERE record")
  func testSevere() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    logger.setLevel(.ALL)
    let handler = CapturingHandler()
    logger.addHandler(handler)

    logger.severe("critical error")
    #expect(handler.published.count == 1)
    #expect(handler.published[0].getLevel() == .SEVERE)
    #expect(handler.published[0].getMessage() == "critical error")
  }

  @Test("warning() publishes WARNING record")
  func testWarning() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    logger.setLevel(.ALL)
    let handler = CapturingHandler()
    logger.addHandler(handler)

    logger.warning("heads up")
    #expect(handler.published[0].getLevel() == .WARNING)
  }

  @Test("info() publishes INFO record")
  func testInfo() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    logger.setLevel(.ALL)
    let handler = CapturingHandler()
    logger.addHandler(handler)

    logger.info("informational")
    #expect(handler.published[0].getLevel() == .INFO)
  }

  @Test("config() publishes CONFIG record")
  func testConfig() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    logger.setLevel(.ALL)
    let handler = CapturingHandler()
    logger.addHandler(handler)

    logger.config("config msg")
    #expect(handler.published[0].getLevel() == .CONFIG)
  }

  @Test("fine() publishes FINE record")
  func testFine() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    logger.setLevel(.ALL)
    let handler = CapturingHandler()
    logger.addHandler(handler)

    logger.fine("fine detail")
    #expect(handler.published[0].getLevel() == .FINE)
  }

  @Test("finer() publishes FINER record")
  func testFiner() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    logger.setLevel(.ALL)
    let handler = CapturingHandler()
    logger.addHandler(handler)

    logger.finer("finer detail")
    #expect(handler.published[0].getLevel() == .FINER)
  }

  @Test("finest() publishes FINEST record")
  func testFinest() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    logger.setLevel(.ALL)
    let handler = CapturingHandler()
    logger.addHandler(handler)

    logger.finest("finest detail")
    #expect(handler.published[0].getLevel() == .FINEST)
  }

  // MARK: - log(Level, String)

  @Test("log(level, msg) publishes record at given level")
  func testLogLevelMsg() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    logger.setLevel(.ALL)
    let handler = CapturingHandler()
    logger.addHandler(handler)

    logger.log(.WARNING, "explicit level")
    #expect(handler.published[0].getLevel() == .WARNING)
    #expect(handler.published[0].getMessage() == "explicit level")
  }

  // MARK: - log(Level, supplier)

  @Test("log(level, supplier) evaluates supplier only when loggable")
  func testLogSupplierNotCalledBelowLevel() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    logger.setLevel(.SEVERE)
    let handler = CapturingHandler()
    logger.addHandler(handler)

    var supplierCalled = false
    logger.log(.FINE) {
      supplierCalled = true
      return "expensive message"
    }
    #expect(supplierCalled == false)
    #expect(handler.published.isEmpty)
  }

  @Test("log(level, supplier) calls supplier when loggable")
  func testLogSupplierCalledWhenLoggable() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    logger.setLevel(.ALL)
    let handler = CapturingHandler()
    logger.addHandler(handler)

    logger.log(.INFO) { "lazy message" }
    #expect(handler.published.count == 1)
    #expect(handler.published[0].getMessage() == "lazy message")
  }

  // MARK: - log(Level, String, Throwable)

  @Test("log(level, msg, thrown) attaches throwable to record")
  func testLogWithThrown() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    logger.setLevel(.ALL)
    let handler = CapturingHandler()
    logger.addHandler(handler)

    let ex = java.lang.Exception("boom")
    logger.log(.SEVERE, "error occurred", ex)

    #expect(handler.published.count == 1)
    #expect(handler.published[0].getThrown() != nil)
  }

  // MARK: - entering / exiting / throwing

  @Test("entering() publishes FINER record with ENTRY message")
  func testEntering() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    logger.setLevel(.ALL)
    let handler = CapturingHandler()
    logger.addHandler(handler)

    logger.entering("MyClass", "myMethod")
    #expect(handler.published.count == 1)
    #expect(handler.published[0].getLevel() == .FINER)
    #expect(handler.published[0].getMessage() == "ENTRY")
    #expect(handler.published[0].getSourceClassName() == "MyClass")
    #expect(handler.published[0].getSourceMethodName() == "myMethod")
  }

  @Test("exiting() publishes FINER record with RETURN message")
  func testExiting() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    logger.setLevel(.ALL)
    let handler = CapturingHandler()
    logger.addHandler(handler)

    logger.exiting("MyClass", "myMethod")
    #expect(handler.published[0].getMessage() == "RETURN")
    #expect(handler.published[0].getSourceClassName() == "MyClass")
  }

  @Test("throwing() publishes FINER record with throwable")
  func testThrowing() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    logger.setLevel(.ALL)
    let handler = CapturingHandler()
    logger.addHandler(handler)

    let ex = java.lang.IllegalArgumentException("bad arg")
    logger.throwing("MyClass", "myMethod", ex)
    #expect(handler.published[0].getMessage() == "THROW")
    #expect(handler.published[0].getThrown() != nil)
    #expect(handler.published[0].getSourceClassName() == "MyClass")
    #expect(handler.published[0].getSourceMethodName() == "myMethod")
  }

  @Test("entering() not called when level below FINER")
  func testEnteringFilteredOut() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    logger.setLevel(.WARNING)
    let handler = CapturingHandler()
    logger.addHandler(handler)

    logger.entering("MyClass", "myMethod")
    #expect(handler.published.isEmpty)
  }

  // MARK: - Handlers

  @Test("addHandler / getHandlers round-trip")
  func testAddHandler() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    let handler = CapturingHandler()
    logger.addHandler(handler)
    #expect(logger.getHandlers().count == 1)
  }

  @Test("removeHandler removes the handler")
  func testRemoveHandler() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    let handler = CapturingHandler()
    logger.addHandler(handler)
    logger.removeHandler(handler)
    #expect(logger.getHandlers().isEmpty)
  }

  // MARK: - LogRecord accessors

  @Test("LogRecord stores level and message")
  func testLogRecordBasic() {
    let record = java.util.logging.LogRecord(.INFO, "test message")
    #expect(record.getLevel() == .INFO)
    #expect(record.getMessage() == "test message")
  }

  @Test("LogRecord sourceClassName round-trip")
  func testLogRecordSourceClass() {
    let record = java.util.logging.LogRecord(.INFO, "msg")
    record.setSourceClassName("com.example.Foo")
    #expect(record.getSourceClassName() == "com.example.Foo")
  }

  @Test("LogRecord sourceMethodName round-trip")
  func testLogRecordSourceMethod() {
    let record = java.util.logging.LogRecord(.INFO, "msg")
    record.setSourceMethodName("doSomething")
    #expect(record.getSourceMethodName() == "doSomething")
  }

  @Test("LogRecord thrown round-trip")
  func testLogRecordThrown() {
    let record = java.util.logging.LogRecord(.SEVERE, "fail")
    let ex = java.lang.RuntimeException("oops")
    record.setThrown(ex)
    #expect(record.getThrown() != nil)
  }

  // MARK: - LogManager

  @Test("LogManager.getLogManager() returns same singleton")
  func testLogManagerSingleton() {
    let a = java.util.logging.LogManager.getLogManager()
    let b = java.util.logging.LogManager.getLogManager()
    #expect(a === b)
  }

  @Test("LogManager.getLogger returns nil for unknown name")
  func testLogManagerGetLoggerUnknown() {
    let mgr = java.util.logging.LogManager.getLogManager()
    #expect(mgr.getLogger("com.example.test.nonexistent.xyz") == nil)
  }

  @Test("LogManager.getLogger returns registered logger")
  func testLogManagerGetLoggerRegistered() {
    let name = "com.example.test.registered"
    let logger = java.util.logging.Logger.getLogger(name)
    let mgr = java.util.logging.LogManager.getLogManager()
    #expect(mgr.getLogger(name) === logger)
  }

  // MARK: - log(LogRecord) direkt

  @Test("log(LogRecord) dispatches to handler")
  func testLogRecord_direct() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    logger.setLevel(.ALL)
    let handler = CapturingHandler()
    logger.addHandler(handler)

    let record = java.util.logging.LogRecord(.WARNING, "direct record")
    logger.log(record)

    #expect(handler.published.count == 1)
    #expect(handler.published[0].getMessage() == "direct record")
    #expect(handler.published[0].getLevel() == .WARNING)
  }

  @Test("log(LogRecord) below level is suppressed")
  func testLogRecord_belowLevel_suppressed() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    logger.setLevel(.SEVERE)
    let handler = CapturingHandler()
    logger.addHandler(handler)

    let record = java.util.logging.LogRecord(.INFO, "suppressed")
    logger.log(record)

    #expect(handler.published.isEmpty)
  }

  // MARK: - Parent / Propagation

  @Test("getParent() of anonymous logger is root logger")
  func testAnonymousLoggerParentIsRoot() {
    let anon = java.util.logging.Logger.getAnonymousLogger()
    #expect(anon.getParent() === java.util.logging.Logger.rootLogger)
  }

  @Test("getParent() of named logger is root logger")
  func testNamedLoggerParentIsRoot() {
    let logger = java.util.logging.Logger.getLogger("com.example.test.parent")
    #expect(logger.getParent() === java.util.logging.Logger.rootLogger)
  }

  @Test("root logger has name \"\"")
  func testRootLoggerName() {
    #expect(java.util.logging.Logger.rootLogger.getName() == "")
  }

  @Test("root logger has no parent")
  func testRootLoggerHasNoParent() {
    #expect(java.util.logging.Logger.rootLogger.getParent() == nil)
  }

  @Test("root logger is registered in LogManager under \"\"")
  func testRootLoggerRegistered() {
    let mgr = java.util.logging.LogManager.getLogManager()
    #expect(mgr.getLogger("") === java.util.logging.Logger.rootLogger)
  }

  @Test("record propagates to root logger handler when child has none")
  func testPropagationToRoot() {
    let root = java.util.logging.Logger.rootLogger
    let rootHandler = CapturingHandler()
    root.addHandler(rootHandler)
    root.setLevel(.ALL)

    let child = java.util.logging.Logger.getAnonymousLogger()
    child.setLevel(.ALL)
    // child has no own handlers → propagates to root
    child.info("propagated")

    root.removeHandler(rootHandler)
    #expect(rootHandler.published.count >= 1)
  }

  @Test("setUseParentHandlers(false) stops propagation")
  func testUseParentHandlersFalse() {
    let root = java.util.logging.Logger.rootLogger
    let rootHandler = CapturingHandler()
    root.addHandler(rootHandler)
    root.setLevel(.ALL)

    let child = java.util.logging.Logger.getAnonymousLogger()
    child.setLevel(.ALL)
    child.setUseParentHandlers(false)
    child.info("not propagated")

    root.removeHandler(rootHandler)
    #expect(rootHandler.published.isEmpty)
  }

  @Test("setParent() changes propagation target")
  func testSetParent() {
    let intermediate = java.util.logging.Logger.getAnonymousLogger()
    intermediate.setLevel(.ALL)
    let handler = CapturingHandler()
    intermediate.addHandler(handler)
    intermediate.setUseParentHandlers(false)

    let child = java.util.logging.Logger.getAnonymousLogger()
    child.setLevel(.ALL)
    child.setParent(intermediate)

    child.info("via intermediate")
    #expect(handler.published.count == 1)
  }

  @Test("effectiveLevel inherits from parent when own level is nil")
  func testEffectiveLevelInheritance() {
    let parent = java.util.logging.Logger.getAnonymousLogger()
    parent.setLevel(.WARNING)

    let child = java.util.logging.Logger.getAnonymousLogger()
    child.setParent(parent)
    // child has no own level — should inherit WARNING from parent
    let handler = CapturingHandler()
    child.addHandler(handler)
    child.setUseParentHandlers(false)

    child.info("below inherited WARNING — suppressed")
    child.warning("at WARNING — passes")

    #expect(handler.published.count == 1)
    #expect(handler.published[0].getLevel() == .WARNING)
  }

  @Test("logger with own handler also propagates unless disabled")
  func testOwnHandlerAndPropagation() {
    let root = java.util.logging.Logger.rootLogger
    let rootHandler = CapturingHandler()
    root.addHandler(rootHandler)
    root.setLevel(.ALL)

    let child = java.util.logging.Logger.getAnonymousLogger()
    child.setLevel(.ALL)
    let childHandler = CapturingHandler()
    child.addHandler(childHandler)
    // useParentHandlers defaults to true → both handlers receive record

    child.info("both")

    root.removeHandler(rootHandler)
    #expect(childHandler.published.count == 1)
    #expect(rootHandler.published.count >= 1)
  }

  // MARK: - Level edge cases

  @Test("OFF level suppresses all messages")
  func testLevel_OFF_suppressesAll() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    logger.setLevel(.OFF)
    let handler = CapturingHandler()
    logger.addHandler(handler)

    logger.severe("should be suppressed")
    #expect(handler.published.isEmpty)
  }

  @Test("ALL level passes everything including FINEST")
  func testLevel_ALL_passesFinest() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    logger.setLevel(.ALL)
    let handler = CapturingHandler()
    logger.addHandler(handler)

    logger.finest("very verbose")
    #expect(handler.published.count == 1)
  }

  @Test("multiple handlers all receive the record")
  func testMultipleHandlers() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    logger.setLevel(.ALL)
    let h1 = CapturingHandler()
    let h2 = CapturingHandler()
    logger.addHandler(h1)
    logger.addHandler(h2)

    logger.info("broadcast")

    #expect(h1.published.count == 1)
    #expect(h2.published.count == 1)
  }

  // MARK: - Level

  @Test("Level.getName() returns correct name")
  func testLevel_getName() {
    #expect(java.util.logging.Level.SEVERE.getName() == "SEVERE")
    #expect(java.util.logging.Level.WARNING.getName() == "WARNING")
    #expect(java.util.logging.Level.INFO.getName() == "INFO")
    #expect(java.util.logging.Level.CONFIG.getName() == "CONFIG")
    #expect(java.util.logging.Level.FINE.getName() == "FINE")
    #expect(java.util.logging.Level.FINER.getName() == "FINER")
    #expect(java.util.logging.Level.FINEST.getName() == "FINEST")
    #expect(java.util.logging.Level.ALL.getName() == "ALL")
    #expect(java.util.logging.Level.OFF.getName() == "OFF")
  }

  @Test("Level.intValue() reflects correct ordering")
  func testLevel_intValue_ordering() {
    let levels: [java.util.logging.Level] = [
      .ALL, .FINEST, .FINER, .FINE, .CONFIG, .INFO, .WARNING, .SEVERE, .OFF
    ]
    for i in 0..<levels.count - 1 {
      #expect(levels[i].intValue() < levels[i + 1].intValue(),
              "Expected \(levels[i].getName()) < \(levels[i+1].getName())")
    }
  }

  @Test("Level.OFF has highest intValue")
  func testLevel_OFF_isHighest() {
    #expect(java.util.logging.Level.OFF.intValue() == Int.max)
  }

  @Test("Level.ALL has lowest intValue")
  func testLevel_ALL_isLowest() {
    #expect(java.util.logging.Level.ALL.intValue() == Int.min)
  }

  @Test("Level Equatable: same level compares equal")
  func testLevel_equatable() {
    #expect(java.util.logging.Level.INFO == java.util.logging.Level.INFO)
    #expect(java.util.logging.Level.SEVERE != java.util.logging.Level.WARNING)
  }

  @Test("Level custom init sets name and intValue")
  func testLevel_customInit() {
    let custom = java.util.logging.Level("CUSTOM", 850)
    #expect(custom.getName() == "CUSTOM")
    #expect(custom.intValue() == 850)
  }

  @Test("Level.getResourceBundleName() returns nil for built-in levels")
  func testLevel_getResourceBundleName_nil() {
    #expect(java.util.logging.Level.INFO.getResourceBundleName() == nil)
    #expect(java.util.logging.Level.SEVERE.getResourceBundleName() == nil)
  }

  @Test("Level.parse() returns correct level for name")
  @MainActor
  func testLevel_parse() throws {
    let info = try java.util.logging.Level.parse("INFO")
    #expect(info == .INFO)
    let severe = try java.util.logging.Level.parse("SEVERE")
    #expect(severe == .SEVERE)
  }

  @Test("Level.parse() returns correct level for intValue string")
  @MainActor
  func testLevel_parse_intValue() throws {
    let info = try java.util.logging.Level.parse("800")
    #expect(info == .INFO)
    let warning = try java.util.logging.Level.parse("900")
    #expect(warning == .WARNING)
  }

  @Test("Level.parse() throws for unknown name")
  @MainActor
  func testLevel_parse_unknownThrows() {
    #expect(throws: (any Error).self) {
      _ = try java.util.logging.Level.parse("UNKNOWN_LEVEL")
    }
  }
}
