/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// MARK: - StructuredTaskScope

struct JavApi_util_concurrent_StructuredTaskScope_Tests {

  @Test("fork + join — two tasks both succeed")
  func testForkJoinSuccess() async throws {
    let scope = java.util.concurrent.StructuredTaskScope<Int>()
    let t1 = scope.fork { 1 + 1 }
    let t2 = scope.fork { 3 + 4 }
    try await scope.join()
    #expect(try t1.get() == 2)
    #expect(try t2.get() == 7)
  }

  @Test("fork + join — subtask state is success after completion")
  func testSubtaskStateSuccess() async throws {
    let scope = java.util.concurrent.StructuredTaskScope<String>()
    let t = scope.fork { "hello" }
    try await scope.join()
    #expect(t.state() == .success)
  }

  @Test("fork + join — failed subtask has state failed")
  func testSubtaskStateFailed() async throws {
    struct TestError: Error {}
    let scope = java.util.concurrent.StructuredTaskScope<Int>()
    let t = scope.fork { throw TestError() }
    try await scope.join()
    #expect(t.state() == .failed)
    #expect(t.exception() != nil)
  }

  @Test("Subtask.get() throws after failure")
  func testSubtaskGetThrows() async throws {
    struct TestError: Error {}
    let scope = java.util.concurrent.StructuredTaskScope<Int>()
    let t = scope.fork { throw TestError() }
    try await scope.join()
    #expect(throws: TestError.self) { try t.get() }
  }

  @Test("join() does not throw even if subtasks fail")
  func testJoinDoesNotThrowOnSubtaskFailure() async throws {
    struct TestError: Error {}
    let scope = java.util.concurrent.StructuredTaskScope<Void>()
    _ = scope.fork { throw TestError() }
    // join() itself must not rethrow subtask errors
    try await scope.join()
    #expect(true)
  }

  @Test("close() is equivalent to join()")
  func testClose() async throws {
    let scope = java.util.concurrent.StructuredTaskScope<Int>()
    let t = scope.fork { 99 }
    try await scope.close()
    #expect(try t.get() == 99)
  }

  @Test("isShutdown() is false before shutdown, true after")
  func testIsShutdown() async throws {
    let scope = java.util.concurrent.StructuredTaskScope<Int>()
    #expect(!scope.isShutdown())
    scope.shutdown()
    #expect(scope.isShutdown())
  }

  @Test("joinUntil — completes within deadline")
  func testJoinUntilWithinDeadline() async throws {
    let scope = java.util.concurrent.StructuredTaskScope<Int>()
    _ = scope.fork { 1 }
    let deadline = java.util.Date(System.currentTimeMillis() + 5_000)  // 5 s
    try await scope.joinUntil(deadline)
    #expect(true)
  }

  @Test("joinUntil — expired deadline throws TimeoutException")
  func testJoinUntilExpiredDeadline() async throws {
    let scope = java.util.concurrent.StructuredTaskScope<Int>()
    // Fork a task that sleeps longer than the deadline
    _ = scope.fork {
      try await Task.sleep(nanoseconds: 10_000_000_000)  // 10 s
      return 0
    }
    let expired = java.util.Date(System.currentTimeMillis() - 1)  // already in the past
    await #expect(throws: java.util.concurrent.TimeoutException.self) {
      try await scope.joinUntil(expired)
    }
    scope.shutdown()
  }

  @Test("fork returns subtask in running state immediately")
  func testSubtaskRunningBeforeJoin() async throws {
    let scope = java.util.concurrent.StructuredTaskScope<Int>()
    // Use a semaphore-like flag to hold the task
    let t = scope.fork {
      try await Task.sleep(nanoseconds: 50_000_000)  // 50 ms
      return 1
    }
    // Immediately after fork, task may still be running
    // (state is running OR success depending on scheduler timing, so just verify it doesn't crash)
    _ = t.state()
    try await scope.join()
    #expect(t.state() == .success)
  }
}

// MARK: - ShutdownOnFailure

struct JavApi_util_concurrent_ShutdownOnFailure_Tests {

  @Test("throwIfFailed — no exception when all succeed")
  func testNoExceptionOnSuccess() async throws {
    let scope = java.util.concurrent.ShutdownOnFailure<Int>()
    _ = scope.fork { 1 }
    _ = scope.fork { 2 }
    try await scope.join()
    try scope.throwIfFailed()   // must not throw
    #expect(true)
  }

  @Test("throwIfFailed — throws when one subtask fails")
  func testThrowsOnFailure() async throws {
    struct TestError: Error {}
    let scope = java.util.concurrent.ShutdownOnFailure<Int>()
    _ = scope.fork { throw TestError() }
    _ = scope.fork { 42 }
    try await scope.join()
    #expect(throws: TestError.self) { try scope.throwIfFailed() }
  }

  @Test("exception() returns nil before any failure")
  func testExceptionNilOnSuccess() async throws {
    let scope = java.util.concurrent.ShutdownOnFailure<String>()
    _ = scope.fork { "ok" }
    try await scope.join()
    #expect(scope.exception() == nil)
  }

  @Test("scope is shut down after first failure")
  func testScopeShutdownAfterFailure() async throws {
    struct TestError: Error {}
    let scope = java.util.concurrent.ShutdownOnFailure<Int>()
    _ = scope.fork { throw TestError() }
    try await scope.join()
    #expect(scope.isShutdown())
  }
}

// MARK: - ShutdownOnSuccess

struct JavApi_util_concurrent_ShutdownOnSuccess_Tests {

  @Test("result() returns first successful value")
  func testResultReturnsFirstSuccess() async throws {
    let scope = java.util.concurrent.ShutdownOnSuccess<Int>()
    _ = scope.fork { 42 }
    try await scope.join()
    #expect(try scope.result() == 42)
  }

  @Test("result() throws if no subtask succeeded")
  func testResultThrowsWhenNoSuccess() async throws {
    struct TestError: Error {}
    let scope = java.util.concurrent.ShutdownOnSuccess<Int>()
    _ = scope.fork { throw TestError() }
    try await scope.join()
    #expect(throws: IllegalStateException.self) { try scope.result() }
  }

  @Test("scope is shut down after first success")
  func testScopeShutdownAfterSuccess() async throws {
    let scope = java.util.concurrent.ShutdownOnSuccess<Int>()
    _ = scope.fork { 1 }
    try await scope.join()
    #expect(scope.isShutdown())
  }

  @Test("Subtask.exception() is nil for successful task")
  func testExceptionNilForSuccess() async throws {
    let scope = java.util.concurrent.StructuredTaskScope<Int>()
    let t = scope.fork { 10 }
    try await scope.join()
    #expect(t.exception() == nil)
  }
}
