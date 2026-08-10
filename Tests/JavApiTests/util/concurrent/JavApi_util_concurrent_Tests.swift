/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
import Foundation
@testable import JavApi

// MARK: - Callable<V>

@Suite("java.util.concurrent.Callable")
struct CallableTests {

  @Test("AnyCallable.call() gibt Ergebnis zurück")
  func testCallReturnsValue() throws {
    let c = java.util.concurrent.AnyCallable<Int> { 42 }
    #expect(try c.call() == 42)
  }

  @Test("AnyCallable.call() wirft Exception weiter")
  func testCallThrows() {
    let c = java.util.concurrent.AnyCallable<Int> {
      throw java.lang.RuntimeException("boom")
    }
    #expect(throws: (any Error).self) { try c.call() }
  }

  @Test("Callable als Protokoll verwendbar")
  func testCallableProtocol() throws {
    let c: any java.util.concurrent.Callable<String> =
      java.util.concurrent.AnyCallable { "hello" }
    #expect(try c.call() == "hello")
  }

  @Test("Callable mit Nebeneffekt")
  func testCallableSideEffect() throws {
    var counter = 0
    let c = java.util.concurrent.AnyCallable<Void> { counter += 1 }
    try c.call()
    try c.call()
    #expect(counter == 2)
  }

  @Test("Callable gibt komplexen Rückgabetyp zurück")
  func testCallableComplexReturn() throws {
    let c = java.util.concurrent.AnyCallable<[Int]> { [1, 2, 3] }
    #expect(try c.call() == [1, 2, 3])
  }
}

// MARK: - ExecutionException

@Suite("java.util.concurrent.ExecutionException")
struct ExecutionExceptionTests {

  @Test("init() erzeugt Exception ohne Nachricht")
  func testDefaultInit() {
    let e = java.util.concurrent.ExecutionException()
    #expect(e.getMessage() == nil)
  }

  @Test("init(_ message:) setzt Nachricht")
  func testMessageInit() {
    let e = java.util.concurrent.ExecutionException("task failed")
    #expect(e.getMessage() == "task failed")
  }

  @Test("init(_ cause:) setzt Ursache")
  func testCauseInit() {
    let cause = java.lang.RuntimeException("root cause")
    let e = java.util.concurrent.ExecutionException(cause)
    #expect(e.getCause() === cause)
  }

  @Test("init(_ message: _ cause:) setzt Nachricht und Ursache")
  func testMessageAndCauseInit() {
    let cause = java.lang.RuntimeException("root")
    let e = java.util.concurrent.ExecutionException("wrapper", cause)
    #expect(e.getMessage() == "wrapper")
    #expect(e.getCause() === cause)
  }

  @Test("ExecutionException ist Throwable")
  func testIsThrowable() {
    let e = java.util.concurrent.ExecutionException("test")
    #expect(e is Throwable)
    #expect(e is Exception)
  }

  @Test("ExecutionException ist als Error verwendbar")
  func testAsError() {
    let e: any Error = java.util.concurrent.ExecutionException("as error")
    #expect(e is java.util.concurrent.ExecutionException)
  }
}

// MARK: - TaskFuture<V>

@Suite("java.util.concurrent.TaskFuture")
struct TaskFutureTests {

  @Test("get() gibt Ergebnis eines synchron abgeschlossenen Tasks zurück")
  func testGetCompletedTask() async throws {
    let future = java.util.concurrent.TaskFuture<Int> { 99 }
    // Kurz warten damit der Task abschließt
    try await Task.sleep(nanoseconds: 20_000_000)
    #expect(try future.get() == 99)
  }

  @Test("get() blockiert bis Task fertig ist")
  func testGetBlocks() async throws {
    let future = java.util.concurrent.TaskFuture<String> {
      try await Task.sleep(nanoseconds: 30_000_000)
      return "done"
    }
    // get() soll blockieren — wir rufen es in einem Thread auf
    let result = try await Task.detached { try future.get() }.value
    #expect(result == "done")
  }

  @Test("get() wirft ExecutionException wenn Task fehlschlägt")
  func testGetThrowsOnFailure() async throws {
    let future = java.util.concurrent.TaskFuture<Int> {
      throw java.lang.RuntimeException("task boom")
    }
    try await Task.sleep(nanoseconds: 20_000_000)
    #expect(throws: java.util.concurrent.ExecutionException.self) {
      try future.get()
    }
  }

  @Test("isDone() ist false vor Abschluss und true danach")
  func testIsDone() async throws {
    let future = java.util.concurrent.TaskFuture<Int> {
      try await Task.sleep(nanoseconds: 50_000_000)   // 50 ms
      return 1
    }
    #expect(future.isDone() == false)
    // 300 ms Wartezeit (6× der Task-Laufzeit) damit der Monitor-Task auch
    // bei hoher paralleler Test-Last rechtzeitig gescheduled wird.
    try await Task.sleep(nanoseconds: 300_000_000)
    #expect(future.isDone() == true)
  }

  @Test("isCancelled() ist false für nicht abgebrochenen Task")
  func testIsNotCancelled() async throws {
    let future = java.util.concurrent.TaskFuture<Int> { 7 }
    try await Task.sleep(nanoseconds: 20_000_000)
    #expect(future.isCancelled() == false)
  }

  @Test("cancel() gibt true zurück und setzt isCancelled()")
  func testCancel() async throws {
    let future = java.util.concurrent.TaskFuture<Int> {
      try await Task.sleep(nanoseconds: 500_000_000)
      return 0
    }
    try await Task.sleep(nanoseconds: 10_000_000)
    let cancelled = future.cancel(true)
    #expect(cancelled == true)
    #expect(future.isCancelled() == true)
  }

  @Test("cancel() gibt false zurück wenn Task schon fertig")
  func testCancelAfterDone() async throws {
    let future = java.util.concurrent.TaskFuture<Int> { 5 }
    try await Task.sleep(nanoseconds: 50_000_000)
    #expect(future.isDone() == true)
    #expect(future.cancel(true) == false)
  }

  @Test("get() wirft ExecutionException nach cancel()")
  func testGetAfterCancel() async throws {
    let future = java.util.concurrent.TaskFuture<Int> {
      try await Task.sleep(nanoseconds: 500_000_000)
      return 0
    }
    try await Task.sleep(nanoseconds: 10_000_000)
    _ = future.cancel(true)
    // In einem detachten Thread aufrufen damit get() nicht deadlockt
    let thrown = await Task.detached {
      do {
        _ = try future.get()
        return false
      } catch {
        return true
      }
    }.value
    #expect(thrown == true)
  }
}
