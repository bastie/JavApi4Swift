/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// MARK: - Helpers

private final class CapturingHandler2: java.util.logging.Handler {
  var published: [java.util.logging.LogRecord] = []
  override func publish(_ record: java.util.logging.LogRecord) {
    published.append(record)
  }
}

private final class AcceptAllFilter: java.util.logging.Filter {
  func isLoggable(_ record: java.util.logging.LogRecord) -> Bool { true }
}

private final class RejectAllFilter: java.util.logging.Filter {
  func isLoggable(_ record: java.util.logging.LogRecord) -> Bool { false }
}

// MARK: - Filter integration in Logger

struct LoggerFilterTests {

  @Test("Logger setFilter / getFilter round-trip")
  func testSetGetFilter() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    #expect(logger.getFilter() == nil)
    let f = AcceptAllFilter()
    logger.setFilter(f)
    #expect(logger.getFilter() != nil)
  }

  @Test("Logger rejects record when filter returns false")
  func testFilterRejectsRecord() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    logger.setLevel(.ALL)
    logger.setFilter(RejectAllFilter())
    let handler = CapturingHandler2()
    logger.addHandler(handler)

    logger.info("should be filtered")
    #expect(handler.published.isEmpty)
  }

  @Test("Logger accepts record when filter returns true")
  func testFilterAcceptsRecord() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    logger.setLevel(.ALL)
    logger.setFilter(AcceptAllFilter())
    let handler = CapturingHandler2()
    logger.addHandler(handler)

    logger.info("should pass filter")
    #expect(handler.published.count == 1)
  }

  @Test("Logger without filter accepts all records")
  func testNoFilterAcceptsAll() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    logger.setLevel(.ALL)
    let handler = CapturingHandler2()
    logger.addHandler(handler)

    logger.fine("no filter set")
    #expect(handler.published.count == 1)
  }
}

// MARK: - Logger global

struct LoggerGlobalTests {

  @Test("Logger.global is not nil")
  func testGlobalNotNil() {
    let g = java.util.logging.Logger.global
    #expect(g.getName() == java.util.logging.Logger.GLOBAL_LOGGER_NAME)
  }

  @Test("Logger.getGlobal() returns same instance as Logger.global")
  func testGetGlobalSameAsGlobal() {
    #expect(java.util.logging.Logger.getGlobal() === java.util.logging.Logger.global)
  }

  @Test("Logger.global name is 'global'")
  func testGlobalName() {
    #expect(java.util.logging.Logger.GLOBAL_LOGGER_NAME == "global")
  }
}

// MARK: - logp variants

struct LoggerLogpTests {

  @Test("logp(level, class, method, msg) sets source info on record")
  func testLogpBasic() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    logger.setLevel(.ALL)
    let handler = CapturingHandler2()
    logger.addHandler(handler)

    logger.logp(.INFO, "MyClass", "myMethod", "message text")

    let record = handler.published.first
    #expect(record?.getLevel() == .INFO)
    #expect(record?.getMessage() == "message text")
    #expect(record?.getSourceClassName() == "MyClass")
    #expect(record?.getSourceMethodName() == "myMethod")
  }

  @Test("logp with supplier evaluates lazily")
  func testLogpSupplierLazy() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    logger.setLevel(.SEVERE)
    let handler = CapturingHandler2()
    logger.addHandler(handler)

    var called = false
    logger.logp(.FINE, "C", "m") { called = true; return "nope" }
    #expect(called == false)
    #expect(handler.published.isEmpty)
  }

  @Test("logp with supplier is called when loggable")
  func testLogpSupplierCalled() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    logger.setLevel(.ALL)
    let handler = CapturingHandler2()
    logger.addHandler(handler)

    logger.logp(.INFO, "C", "m") { "lazy" }
    #expect(handler.published.first?.getMessage() == "lazy")
  }

  @Test("logp with thrown attaches throwable")
  func testLogpWithThrown() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    logger.setLevel(.ALL)
    let handler = CapturingHandler2()
    logger.addHandler(handler)

    let ex = java.lang.Exception("logp error")
    logger.logp(.SEVERE, "C", "m", "crashed", ex)
    #expect(handler.published.first?.getThrown() != nil)
    #expect(handler.published.first?.getSourceClassName() == "C")
  }

  @Test("logp(level, class, method, thrown, supplier) uses supplier message")
  func testLogpThrownSupplier() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    logger.setLevel(.ALL)
    let handler = CapturingHandler2()
    logger.addHandler(handler)

    let ex = java.lang.Exception("oops")
    logger.logp(.SEVERE, "C", "m", ex) { "supplier message" }
    #expect(handler.published.first?.getMessage() == "supplier message")
    #expect(handler.published.first?.getThrown() != nil)
  }
}

// MARK: - logrb

struct LoggerLogrbTests {

  @Test("logrb(level, class, method, bundle, msg) sets source info")
  func testLogrbBasic() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    logger.setLevel(.ALL)
    let handler = CapturingHandler2()
    logger.addHandler(handler)

    logger.logrb(.INFO, "MyClass", "myMethod", "com.example.bundle", "bundled msg")
    let record = handler.published.first
    #expect(record?.getMessage() == "bundled msg")
    #expect(record?.getSourceClassName() == "MyClass")
  }

  @Test("logrb with thrown attaches throwable")
  func testLogrbWithThrown() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    logger.setLevel(.ALL)
    let handler = CapturingHandler2()
    logger.addHandler(handler)

    let ex = java.lang.RuntimeException("logrb error")
    logger.logrb(.SEVERE, "C", "m", "bundle", "msg", ex)
    #expect(handler.published.first?.getThrown() != nil)
  }
}

// MARK: - entering/exiting with params

struct LoggerEnteringExitingParamsTests {

  @Test("entering(class, method, param) includes param in message")
  func testEnteringSingleParam() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    logger.setLevel(.ALL)
    let handler = CapturingHandler2()
    logger.addHandler(handler)

    logger.entering("C", "m", 42)
    let msg = handler.published.first?.getMessage() ?? ""
    #expect(msg.hasPrefix("ENTRY"))
    #expect(msg.contains("42"))
  }

  @Test("entering(class, method, params) includes all params in message")
  func testEnteringMultipleParams() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    logger.setLevel(.ALL)
    let handler = CapturingHandler2()
    logger.addHandler(handler)

    logger.entering("C", "m", ["hello", 99] as [Any])
    let params = handler.published.first?.getParameters() ?? []
    #expect(params.count == 2)
  }

  @Test("exiting(class, method, result) includes result in message")
  func testExitingWithResult() {
    let logger = java.util.logging.Logger.getAnonymousLogger()
    logger.setLevel(.ALL)
    let handler = CapturingHandler2()
    logger.addHandler(handler)

    logger.exiting("C", "m", "ok")
    let msg = handler.published.first?.getMessage() ?? ""
    #expect(msg.hasPrefix("RETURN"))
    #expect(msg.contains("ok"))
  }
}

// MARK: - LogRecord extended

struct LogRecordExtendedTests {

  @Test("LogRecord sequence numbers are increasing")
  func testSequenceNumberIncreasing() {
    let r1 = java.util.logging.LogRecord(.INFO, "first")
    let r2 = java.util.logging.LogRecord(.INFO, "second")
    #expect(r1.getSequenceNumber() < r2.getSequenceNumber())
  }

  @Test("LogRecord getParameters / setParameters round-trip")
  func testParameters() {
    let record = java.util.logging.LogRecord(.INFO, "msg")
    record.setParameters(["a", 1] as [Any])
    let params = record.getParameters()
    #expect(params.count == 2)
  }

  @Test("LogRecord getThreadID returns Int")
  func testGetThreadID() {
    let record = java.util.logging.LogRecord(.INFO, "msg")
    let _ = record.getThreadID() // just verify it compiles and doesn't crash
    #expect(true)
  }

  @Test("LogRecord getLongThreadID returns Int64")
  func testGetLongThreadID() {
    let record = java.util.logging.LogRecord(.INFO, "msg")
    let _ = record.getLongThreadID()
    #expect(true)
  }

  @Test("LogRecord setLoggerName / getLoggerName round-trip")
  func testLoggerName() {
    let record = java.util.logging.LogRecord(.INFO, "msg")
    record.setLoggerName("test.logger")
    #expect(record.getLoggerName() == "test.logger")
  }

  @Test("LogRecord setInstant / getInstant round-trip")
  func testInstant() {
    let record = java.util.logging.LogRecord(.INFO, "msg")
    let instant = java.time.Instant.ofEpochMilli(1_700_000_000_000)
    record.setInstant(instant)
    #expect(record.getMillis() == 1_700_000_000_000)
  }
}

// MARK: - Handler

struct HandlerTests {

  @Test("Handler setLevel / getLevel round-trip")
  func testHandlerSetGetLevel() {
    let handler = CapturingHandler2()
    handler.setLevel(.WARNING)
    #expect(handler.getLevel() == .WARNING)
  }

  @Test("Handler default level is ALL")
  func testHandlerDefaultLevel() {
    let handler = CapturingHandler2()
    #expect(handler.getLevel() == .ALL)
  }

  @Test("Handler setFilter / getFilter round-trip")
  func testHandlerSetGetFilter() {
    let handler = CapturingHandler2()
    #expect(handler.getFilter() == nil)
    handler.setFilter(AcceptAllFilter())
    #expect(handler.getFilter() != nil)
  }

  @Test("Handler setFormatter / getFormatter round-trip")
  func testHandlerSetGetFormatter() {
    let handler = CapturingHandler2()
    #expect(handler.getFormatter() == nil)
    handler.setFormatter(java.util.logging.SimpleFormatter())
    #expect(handler.getFormatter() != nil)
  }

  @Test("Handler.isLoggable returns false for record below level")
  func testHandlerIsLoggable_belowLevel() {
    let handler = CapturingHandler2()
    handler.setLevel(.WARNING)
    let record = java.util.logging.LogRecord(.FINE, "msg")
    #expect(handler.isLoggable(record) == false)
  }

  @Test("Handler.isLoggable returns true for record at level")
  func testHandlerIsLoggable_atLevel() {
    let handler = CapturingHandler2()
    handler.setLevel(.WARNING)
    let record = java.util.logging.LogRecord(.WARNING, "msg")
    #expect(handler.isLoggable(record) == true)
  }

  @Test("Handler.isLoggable returns false when filter rejects")
  func testHandlerIsLoggable_filterRejects() {
    let handler = CapturingHandler2()
    handler.setLevel(.ALL)
    handler.setFilter(RejectAllFilter())
    let record = java.util.logging.LogRecord(.SEVERE, "msg")
    #expect(handler.isLoggable(record) == false)
  }
}

// MARK: - LogManager extended

struct LogManagerExtendedTests {

  @Test("LogManager.getLoggerNames returns at least root logger")
  func testGetLoggerNamesIncludesRoot() {
    let mgr = java.util.logging.LogManager.getLogManager()
    var names: [String] = []
    var enumeration = mgr.getLoggerNames()
    while enumeration.hasMoreElements() {
      names.append(try! enumeration.nextElement())
    }
    #expect(names.contains(java.util.logging.Logger.ROOT_LOGGER_NAME))
  }

  @Test("LogManager.getProperty returns nil")
  func testGetPropertyReturnsNil() {
    let mgr = java.util.logging.LogManager.getLogManager()
    #expect(mgr.getProperty("any.key") == nil)
  }

  @Test("LogManager.readConfiguration does not throw")
  func testReadConfigurationNoThrow() throws {
    let mgr = java.util.logging.LogManager.getLogManager()
    try mgr.readConfiguration()
    #expect(true)
  }
}

// MARK: - SimpleFormatter

struct SimpleFormatterTests {

  @Test("SimpleFormatter.format includes level name")
  func testFormatIncludesLevel() {
    let fmt = java.util.logging.SimpleFormatter()
    let record = java.util.logging.LogRecord(.WARNING, "test warning")
    let output = fmt.format(record)
    #expect(output.contains("WARNING"))
  }

  @Test("SimpleFormatter.format includes message")
  func testFormatIncludesMessage() {
    let fmt = java.util.logging.SimpleFormatter()
    let record = java.util.logging.LogRecord(.INFO, "hello world")
    let output = fmt.format(record)
    #expect(output.contains("hello world"))
  }

  @Test("SimpleFormatter.format includes source class and method")
  func testFormatIncludesSource() {
    let fmt = java.util.logging.SimpleFormatter()
    let record = java.util.logging.LogRecord(.INFO, "msg")
    record.setSourceClassName("com.example.Foo")
    record.setSourceMethodName("doStuff")
    let output = fmt.format(record)
    #expect(output.contains("com.example.Foo"))
    #expect(output.contains("doStuff"))
  }

  @Test("SimpleFormatter.format ends with newline")
  func testFormatEndsWithNewline() {
    let fmt = java.util.logging.SimpleFormatter()
    let record = java.util.logging.LogRecord(.INFO, "msg")
    let output = fmt.format(record)
    #expect(output.hasSuffix("\n"))
  }

  @Test("SimpleFormatter.getHead returns empty string")
  func testGetHead() {
    let fmt = java.util.logging.SimpleFormatter()
    #expect(fmt.getHead(nil) == "")
  }

  @Test("SimpleFormatter.getTail returns empty string")
  func testGetTail() {
    let fmt = java.util.logging.SimpleFormatter()
    #expect(fmt.getTail(nil) == "")
  }
}

// MARK: - XMLFormatter

struct XMLFormatterTests {

  @Test("XMLFormatter.format produces <record> element")
  func testFormatHasRecordElement() {
    let fmt = java.util.logging.XMLFormatter()
    let record = java.util.logging.LogRecord(.INFO, "xml test")
    let output = fmt.format(record)
    #expect(output.contains("<record>"))
    #expect(output.contains("</record>"))
  }

  @Test("XMLFormatter.format includes level")
  func testFormatIncludesLevel() {
    let fmt = java.util.logging.XMLFormatter()
    let record = java.util.logging.LogRecord(.SEVERE, "error")
    let output = fmt.format(record)
    #expect(output.contains("<level>SEVERE</level>"))
  }

  @Test("XMLFormatter.format includes message")
  func testFormatIncludesMessage() {
    let fmt = java.util.logging.XMLFormatter()
    let record = java.util.logging.LogRecord(.INFO, "hello xml")
    let output = fmt.format(record)
    #expect(output.contains("<message>hello xml</message>"))
  }

  @Test("XMLFormatter.format escapes XML special characters")
  func testFormatEscapesXML() {
    let fmt = java.util.logging.XMLFormatter()
    let record = java.util.logging.LogRecord(.INFO, "<tag> & 'quote' \"double\"")
    let output = fmt.format(record)
    #expect(!output.contains("<tag>"))
    #expect(output.contains("&lt;tag&gt;"))
    #expect(output.contains("&amp;"))
  }

  @Test("XMLFormatter.format includes source class")
  func testFormatIncludesSourceClass() {
    let fmt = java.util.logging.XMLFormatter()
    let record = java.util.logging.LogRecord(.INFO, "msg")
    record.setSourceClassName("com.example.Bar")
    let output = fmt.format(record)
    #expect(output.contains("<class>com.example.Bar</class>"))
  }

  @Test("XMLFormatter.getHead returns XML declaration and <log> open tag")
  func testGetHead() {
    let fmt = java.util.logging.XMLFormatter()
    let head = fmt.getHead(nil)
    #expect(head.contains("<?xml"))
    #expect(head.contains("<log>"))
  }

  @Test("XMLFormatter.getTail returns </log>")
  func testGetTail() {
    let fmt = java.util.logging.XMLFormatter()
    #expect(fmt.getTail(nil).contains("</log>"))
  }
}

// MARK: - MemoryHandler

struct MemoryHandlerTests {

  @Test("MemoryHandler buffers records until push level reached")
  func testBuffersUntilPushLevel() {
    let target = CapturingHandler2()
    target.setLevel(.ALL)
    let mem = java.util.logging.MemoryHandler(target, 10, .SEVERE)
    mem.setLevel(.ALL)

    mem.publish(java.util.logging.LogRecord(.INFO, "info 1"))
    mem.publish(java.util.logging.LogRecord(.WARNING, "warn 1"))
    // No push yet — target should not have received anything
    #expect(target.published.isEmpty)
  }

  @Test("MemoryHandler pushes on trigger level")
  func testPushesOnTriggerLevel() {
    let target = CapturingHandler2()
    target.setLevel(.ALL)
    let mem = java.util.logging.MemoryHandler(target, 10, .SEVERE)
    mem.setLevel(.ALL)

    mem.publish(java.util.logging.LogRecord(.INFO, "info 1"))
    mem.publish(java.util.logging.LogRecord(.WARNING, "warn 1"))
    mem.publish(java.util.logging.LogRecord(.SEVERE, "severe!"))
    // SEVERE reached push level → all 3 records pushed
    #expect(target.published.count == 3)
  }

  @Test("MemoryHandler.push() forces flush of buffer")
  func testManualPush() {
    let target = CapturingHandler2()
    target.setLevel(.ALL)
    let mem = java.util.logging.MemoryHandler(target, 10, .SEVERE)
    mem.setLevel(.ALL)

    mem.publish(java.util.logging.LogRecord(.INFO, "buffered"))
    #expect(target.published.isEmpty)
    mem.push()
    #expect(target.published.count == 1)
  }

  @Test("MemoryHandler ring buffer discards oldest when full")
  func testRingBufferOverflow() {
    let target = CapturingHandler2()
    target.setLevel(.ALL)
    let mem = java.util.logging.MemoryHandler(target, 3, .SEVERE)
    mem.setLevel(.ALL)

    for i in 0..<5 {
      mem.publish(java.util.logging.LogRecord(.INFO, "msg \(i)"))
    }
    mem.push()
    // Only last 3 records should be in target
    #expect(target.published.count == 3)
    #expect(target.published[0].getMessage() == "msg 2")
    #expect(target.published[2].getMessage() == "msg 4")
  }

  @Test("MemoryHandler.getPushLevel / setPushLevel round-trip")
  func testSetGetPushLevel() {
    let target = CapturingHandler2()
    let mem = java.util.logging.MemoryHandler(target, 5, .SEVERE)
    mem.setPushLevel(.WARNING)
    #expect(mem.getPushLevel() == .WARNING)
  }

  @Test("MemoryHandler after push buffer is empty")
  func testBufferClearedAfterPush() {
    let target = CapturingHandler2()
    target.setLevel(.ALL)
    let mem = java.util.logging.MemoryHandler(target, 10, .SEVERE)
    mem.setLevel(.ALL)

    mem.publish(java.util.logging.LogRecord(.INFO, "one"))
    mem.push()
    // Push again — target should not receive anything more
    mem.push()
    #expect(target.published.count == 1)
  }
}
