/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  /// A facility for threads to schedule tasks for future execution in a
  /// background thread — mirrors `java.util.Timer`.
  ///
  /// Unlike `javax.swing.Timer`, callbacks run on a **background actor**, not
  /// on the main actor. If you need to update UI from a task, dispatch
  /// explicitly to the main actor:
  ///
  /// ```swift
  /// class MyTask: java.util.TimerTask {
  ///   func run() {
  ///     Task { @MainActor in label.setText("tick") }
  ///   }
  /// }
  /// let timer = java.util.Timer()
  /// timer.schedule(MyTask(), delay: 0, period: 1000)
  /// ```
  ///
  /// All scheduling methods accept delays and periods in **milliseconds**,
  /// matching the Java API.
  ///
  /// - Since: Java 1.3
  public final class Timer: @unchecked Sendable {

    // -------------------------------------------------------------------------
    // MARK: Internal actor for serial task execution
    // -------------------------------------------------------------------------

    /// Serialises all task executions — equivalent to Java's single
    /// timer-thread model.
    private actor TimerActor {
      func run(_ block: @Sendable () -> Void) { block() }
    }

    private let _actor = TimerActor()

    // -------------------------------------------------------------------------
    // MARK: State (protected by _mutex)
    // -------------------------------------------------------------------------

    private let _mutex = CrossPlatformMutex(0)
    nonisolated(unsafe) private var _cancelled = false
    nonisolated(unsafe) private var _tasks: [Task<Void, Never>] = []

    // -------------------------------------------------------------------------
    // MARK: Initialisers
    // -------------------------------------------------------------------------

    /// Creates a new timer. The associated background actor starts immediately.
    public init() {}

    /// Creates a new timer.
    ///
    /// - Parameter isDaemon: Ignored in the Swift implementation (Swift tasks
    ///   are always daemon-like); present for Java API compatibility.
    public convenience init(isDaemon: Bool) { self.init() }

    /// Creates a new timer with a name (for debugging).
    ///
    /// - Parameter name: A human-readable name; currently unused at runtime.
    public convenience init(_ name: String) { self.init() }

    /// Creates a new timer with a name and daemon flag.
    public convenience init(_ name: String, isDaemon: Bool) { self.init() }

    deinit { cancel() }

    // -------------------------------------------------------------------------
    // MARK: schedule — one-shot, delay in ms
    // -------------------------------------------------------------------------

    /// Schedules *task* to run once after *delay* milliseconds.
    public func schedule(_ task: any java.util.TimerTask, delay: Int64) {
      _enqueue(task: task, delay: delay, period: nil, fixedRate: false)
    }

    /// Schedules *task* to run once at *time* (milliseconds since epoch).
    public func schedule(_ task: any java.util.TimerTask, time: Int64) {
      let now   = java.util.Date().getTime()
      let delay = max(0, time - now)
      _enqueue(task: task, delay: delay, period: nil, fixedRate: false)
    }

    // -------------------------------------------------------------------------
    // MARK: schedule — repeating, fixed delay
    // -------------------------------------------------------------------------

    /// Schedules *task* to repeat with fixed *delay* between executions,
    /// starting after an initial *delay* (both in milliseconds).
    public func schedule(_ task: any java.util.TimerTask, delay: Int64, period: Int64) {
      _enqueue(task: task, delay: delay, period: period, fixedRate: false)
    }

    /// Schedules *task* to repeat with fixed *period*, starting at *time*
    /// (milliseconds since epoch).
    public func schedule(_ task: any java.util.TimerTask, time: Int64, period: Int64) {
      let now   = java.util.Date().getTime()
      let delay = max(0, time - now)
      _enqueue(task: task, delay: delay, period: period, fixedRate: false)
    }

    // -------------------------------------------------------------------------
    // MARK: scheduleAtFixedRate — repeating, fixed rate
    // -------------------------------------------------------------------------

    /// Schedules *task* at a fixed *period* (milliseconds), starting after
    /// *delay* milliseconds. Missed firings are caught up immediately.
    public func scheduleAtFixedRate(_ task: any java.util.TimerTask,
                                    delay: Int64, period: Int64) {
      _enqueue(task: task, delay: delay, period: period, fixedRate: true)
    }

    /// Schedules *task* at a fixed *period* starting at *time* (ms since epoch).
    public func scheduleAtFixedRate(_ task: any java.util.TimerTask,
                                    time: Int64, period: Int64) {
      let now   = java.util.Date().getTime()
      let delay = max(0, time - now)
      _enqueue(task: task, delay: delay, period: period, fixedRate: true)
    }

    // -------------------------------------------------------------------------
    // MARK: cancel / purge
    // -------------------------------------------------------------------------

    /// Cancels this timer and all pending tasks.
    public func cancel() {
      var pending: [Task<Void, Never>] = []
      _mutex.withLock { _ in
        _cancelled = true
        pending = _tasks
        _tasks.removeAll()
      }
      pending.forEach { $0.cancel() }
    }

    /// No-op in this implementation (Swift tasks clean up automatically).
    /// Present for Java API compatibility.
    public func purge() -> Int { 0 }

    // -------------------------------------------------------------------------
    // MARK: Private helper
    // -------------------------------------------------------------------------

    private func _enqueue(task: any java.util.TimerTask,
                          delay: Int64, period: Int64?, fixedRate: Bool) {
      var alreadyCancelled = false
      _mutex.withLock { _ in alreadyCancelled = _cancelled }
      guard !alreadyCancelled else { return }

      let actor = _actor

      let swiftTask = Task<Void, Never> {
        // Initial delay
        if delay > 0 {
          try? await Task.sleep(nanoseconds: UInt64(delay) * 1_000_000)
        }
        guard !Task.isCancelled else { return }

        // First execution
        await actor.run { task.run() }

        guard let period, period > 0 else { return }

        if fixedRate {
          // Fixed-rate: track next scheduled time, catch up if slow
          var next = java.util.Date().getTime() + period
          while !Task.isCancelled {
            let now  = java.util.Date().getTime()
            let wait = max(0, next - now)
            if wait > 0 {
              try? await Task.sleep(nanoseconds: UInt64(wait) * 1_000_000)
            }
            guard !Task.isCancelled else { break }
            await actor.run { task.run() }
            next += period
          }
        } else {
          // Fixed-delay: sleep *after* each execution
          while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: UInt64(period) * 1_000_000)
            guard !Task.isCancelled else { break }
            await actor.run { task.run() }
          }
        }
      }

      var accepted = false
      _mutex.withLock { _ in
        guard !_cancelled else { return }
        _tasks.append(swiftTask)
        accepted = true
      }
      if !accepted { swiftTask.cancel() }
    }
  }
}
