/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
import Foundation
@testable import JavApi

// MARK: - Hilfstask-Typen

/// Einfacher Task der jeden Aufruf zählt.
///
/// Verwendet NSLock damit Schreibzugriffe vom Timer-Task für den Test-Task
/// sichtbar sind (Speicher-Ordnungsgarantie über Task-Grenzen).
final class CountingTask: java.util.TimerTask, @unchecked Sendable {
  private let _lock = NSLock()
  private var _count = 0
  var callCount: Int { _lock.withLock { _count } }
  func run() { _lock.withLock { _count += 1 } }
}

/// Task der einen Wert in eine Continuation liefert (für async-Synchronisation).
final class SignalTask: java.util.TimerTask, @unchecked Sendable {
  private let continuation: CheckedContinuation<Void, Never>
  init(_ continuation: CheckedContinuation<Void, Never>) {
    self.continuation = continuation
  }
  func run() { continuation.resume() }
}

/// Task der sich selbst (und den Timer) nach dem ersten Aufruf abbricht.
final class SelfCancellingTask: java.util.TimerTask, @unchecked Sendable {
  nonisolated(unsafe) var callCount = 0
  private let timer: java.util.Timer
  init(timer: java.util.Timer) { self.timer = timer }
  func run() {
    callCount += 1
    timer.cancel()
  }
}

// MARK: - One-shot scheduling

@Suite("java.util.Timer — einmaliges Scheduling")
struct TimerOneShotTests {

  @Test("schedule(task:delay:) ruft run() genau einmal auf")
  func testOneShotRunsOnce() async {
    let task = CountingTask()
    let timer = java.util.Timer()
    await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
      let signal = SignalTask(cont)
      timer.schedule(signal, delay: 10)
    }
    // Der CountingTask wurde NICHT scheduliert — wir prüfen nur dass kein Absturz passiert
    timer.schedule(task, delay: 10)
    try? await Task.sleep(nanoseconds: 50_000_000)  // 50 ms warten
    #expect(task.callCount == 1)
    timer.cancel()
  }

  @Test("schedule(task:delay:) mit delay 0 läuft sofort")
  func testOneShotDelay0() async {
    let timer = java.util.Timer()
    // Über Continuation sicherstellen dass run() vor der Assertion aufgerufen wurde
    await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
      class SignallingCountTask: java.util.TimerTask, @unchecked Sendable {
        nonisolated(unsafe) var callCount = 0
        let cont: CheckedContinuation<Void, Never>
        init(_ cont: CheckedContinuation<Void, Never>) { self.cont = cont }
        func run() { callCount += 1; cont.resume() }
      }
      let t = SignallingCountTask(cont)
      timer.schedule(t, delay: 0)
    }
    timer.cancel()
  }

  @Test("cancel() verhindert Ausführung eines noch ausstehenden Tasks")
  func testCancelBeforeExecution() async {
    let task = CountingTask()
    let timer = java.util.Timer()
    timer.schedule(task, delay: 200)  // 200 ms in der Zukunft
    timer.cancel()                    // sofort abbrechen
    try? await Task.sleep(nanoseconds: 300_000_000)  // 300 ms warten
    #expect(task.callCount == 0)
  }

  @Test("Timer nach cancel() ignoriert neue schedule-Aufrufe")
  func testScheduleAfterCancel() async {
    let task = CountingTask()
    let timer = java.util.Timer()
    timer.cancel()
    timer.schedule(task, delay: 10)
    try? await Task.sleep(nanoseconds: 100_000_000)  // 100 ms warten
    #expect(task.callCount == 0)
  }
}

// MARK: - Repeating scheduling

@Suite("java.util.Timer — wiederholendes Scheduling")
struct TimerRepeatingTests {

  @Test("schedule(delay:period:) ruft run() mehrfach auf")
  func testFixedDelayRepeats() async {
    let task = CountingTask()
    let timer = java.util.Timer()
    // 50 ms Periode, 500 ms Wartezeit → erwartet ≥ 3 (ca. 10 Aufrufe möglich).
    // Großzügige Toleranz damit parallele Tests den kooperativen Thread-Pool
    // nicht zu sehr belasten.
    timer.schedule(task, delay: 0, period: 50)
    try? await Task.sleep(nanoseconds: 500_000_000)  // 500 ms
    timer.cancel()
    #expect(task.callCount >= 3)
  }

  @Test("scheduleAtFixedRate(delay:period:) ruft run() mehrfach auf")
  func testFixedRateRepeats() async {
    let task = CountingTask()
    let timer = java.util.Timer()
    timer.scheduleAtFixedRate(task, delay: 0, period: 50)
    try? await Task.sleep(nanoseconds: 500_000_000)  // 500 ms
    timer.cancel()
    #expect(task.callCount >= 3)
  }

  @Test("cancel() stoppt wiederholenden Task")
  func testCancelStopsRepeating() async {
    let task = CountingTask()
    let timer = java.util.Timer()
    timer.schedule(task, delay: 0, period: 50)
    try? await Task.sleep(nanoseconds: 300_000_000)  // 300 ms laufen lassen
    timer.cancel()
    let countAtCancel = task.callCount
    try? await Task.sleep(nanoseconds: 200_000_000)  // weitere 200 ms warten
    #expect(task.callCount == countAtCancel)         // kein weiterer Aufruf
  }

  @Test("selbst abbrechender Task stoppt weiteres Scheduling")
  func testSelfCancelling() async {
    let timer = java.util.Timer()
    let task = SelfCancellingTask(timer: timer)
    timer.schedule(task, delay: 0, period: 20)
    try? await Task.sleep(nanoseconds: 150_000_000)  // 150 ms warten
    #expect(task.callCount == 1)  // genau einmal ausgeführt, dann abgebrochen
  }
}

// MARK: - Konstruktoren

@Suite("java.util.Timer — Konstruktoren")
struct TimerConstructorTests {

  @Test("init() erzeugt funktionsfähigen Timer")
  func testDefaultInit() async {
    let task = CountingTask()
    let timer = java.util.Timer()
    await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
      let s = SignalTask(cont)
      timer.schedule(s, delay: 0)
    }
    timer.schedule(task, delay: 0)
    try? await Task.sleep(nanoseconds: 50_000_000)
    timer.cancel()
  }

  @Test("init(isDaemon:) ist funktionsfähig")
  func testDaemonInit() async {
    let timer = java.util.Timer(isDaemon: true)
    let task = CountingTask()
    await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
      let s = SignalTask(cont)
      timer.schedule(s, delay: 0)
    }
    timer.schedule(task, delay: 0)
    try? await Task.sleep(nanoseconds: 50_000_000)
    timer.cancel()
  }

  @Test("init(_:) mit Name ist funktionsfähig")
  func testNamedInit() async {
    let timer = java.util.Timer("test-timer")
    let task = CountingTask()
    await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
      let s = SignalTask(cont)
      timer.schedule(s, delay: 0)
    }
    timer.schedule(task, delay: 0)
    try? await Task.sleep(nanoseconds: 50_000_000)
    timer.cancel()
  }

  @Test("purge() gibt 0 zurück (Swift-Tasks räumen sich selbst auf)")
  func testPurgeReturnsZero() {
    let timer = java.util.Timer()
    #expect(timer.purge() == 0)
    timer.cancel()
  }
}

// MARK: - TimerTask protocol

@Suite("java.util.TimerTask — Protocol")
struct TimerTaskTests {

  @Test("scheduledExecutionTime() gibt -1 zurück wenn nicht explizit implementiert")
  func testScheduledExecutionTimeDefault() {
    let task = CountingTask()
    #expect(task.scheduledExecutionTime() == -1)
  }

  @Test("TimerTask ist Sendable")
  func testTimerTaskSendable() async {
    // Compiler-Test: CountingTask muss als Sendable über Task-Grenzen hinweg nutzbar sein
    let task = CountingTask()
    let timer = java.util.Timer()
    await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
      class Bridge: java.util.TimerTask, @unchecked Sendable {
        let inner: CountingTask
        let cont: CheckedContinuation<Void, Never>
        init(_ inner: CountingTask, _ cont: CheckedContinuation<Void, Never>) {
          self.inner = inner; self.cont = cont
        }
        func run() { inner.run(); cont.resume() }
      }
      timer.schedule(Bridge(task, cont), delay: 0)
    }
    #expect(task.callCount == 1)
    timer.cancel()
  }
}
