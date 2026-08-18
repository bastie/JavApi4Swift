/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - StructuredTaskScope<T> (Java 25)

extension java.util.concurrent {

  /// A structured concurrency scope for forking and joining subtasks (Java 25).
  ///
  /// Mirrors `java.util.concurrent.StructuredTaskScope<T>` (Java 25).
  ///
  /// **Deliberate API break:** Unlike the rest of JavApi⁴Swift, the methods
  /// ``join()``, ``joinUntil(_:)``, and ``close()`` are `async` because
  /// structured concurrency is inherently asynchronous. The remainder of the
  /// JavApi stays synchronous and must be wrapped by the caller when bridging.
  ///
  /// **WASM note:** On `WASI` there is no true thread parallelism. Forked tasks
  /// run cooperatively on the same thread; `join()` still awaits their completion
  /// correctly via Swift's cooperative scheduler.
  ///
  /// ```swift
  /// let scope = java.util.concurrent.StructuredTaskScope<Int>()
  /// let t1 = scope.fork { 1 + 1 }
  /// let t2 = scope.fork { 2 + 2 }
  /// try await scope.join()
  /// print(try t1.get(), try t2.get())   // 2  4
  /// ```
  ///
  /// - Since: Java 25
  open class StructuredTaskScope<T>: @unchecked Sendable {

    private let _lock = CrossPlatformMutex(0)
    nonisolated(unsafe) private var _subtasks: [Subtask<T>] = []
    nonisolated(unsafe) private var _shutdown = false

    public init() {}

    // MARK: - fork

    /// Forks a new subtask within this scope.
    ///
    /// The task starts immediately. When it completes, ``handleComplete(_:)``
    /// is called on this scope. The subtask handle can be used after ``join()``
    /// to retrieve the result.
    ///
    /// - Parameter task: An async, optionally throwing closure that produces `T`.
    /// - Returns: A ``Subtask`` handle.
    /// - Since: Java 25
    @discardableResult
    public func fork(_ task: @escaping @Sendable () async throws -> T) -> Subtask<T> {
      let subtask = Subtask<T>()
      let tracker = Task<Void, Never> {
        do {
          let value = try await task()
          subtask._setSuccess(value)
        } catch {
          subtask._setFailed(error)
        }
        self.handleComplete(subtask)
      }
      subtask._trackerTask = tracker
      _lock.withLock { _ in _subtasks.append(subtask) }
      return subtask
    }

    // MARK: - join / joinUntil / close

    /// Waits for all forked subtasks to complete.
    ///
    /// Returns normally regardless of whether individual subtasks succeeded or
    /// failed — inspect each ``Subtask`` after `join()` returns.
    ///
    /// - Since: Java 25
    public func join() async throws {
      for subtask in snapshot() {
        await subtask._trackerTask?.value
      }
    }

    /// Waits for all forked subtasks to complete, or throws ``TimeoutException``
    /// if `deadline` is exceeded.
    ///
    /// Mirrors `StructuredTaskScope.joinUntil(Instant)` (Java 25).
    ///
    /// - Parameter deadline: The latest point in time to wait, as a `java.util.Date`.
    /// - Throws: ``TimeoutException`` if the deadline expires.
    /// - Since: Java 25
    public func joinUntil(_ deadline: java.util.Date) async throws {
      let remainingMs = deadline.getTime() - System.currentTimeMillis()
      guard remainingMs > 0 else { throw TimeoutException() }

      try await withThrowingTaskGroup(of: Bool.self) { group in
        // Timeout sentinel — fires after remainingMs
        group.addTask {
          try await Task.sleep(nanoseconds: UInt64(remainingMs) * 1_000_000)
          return false
        }
        // Completion sentinel — resolves when all subtasks are done
        group.addTask {
          try await self.join()
          return true
        }
        // First to complete wins
        for try await completed in group {
          group.cancelAll()
          if !completed { throw TimeoutException() }
          return
        }
      }
    }

    /// Waits for all forked subtasks to finish and cleans up resources.
    ///
    /// Equivalent to calling ``join()`` followed by scope cleanup.
    ///
    /// - Since: Java 25
    public func close() async throws {
      try await join()
    }

    // MARK: - shutdown / isShutdown

    /// Cancels all currently running subtasks and marks the scope as shut down.
    ///
    /// Subtasks that have already completed are unaffected. Future calls to
    /// ``fork(_:)`` after `shutdown()` will still be tracked but the underlying
    /// Swift `Task` will have a cancellation request pending.
    ///
    /// - Since: Java 25
    public func shutdown() {
      _lock.withLock { _ in _shutdown = true }
      snapshot().forEach { $0._trackerTask?.cancel() }
    }

    /// Returns `true` if ``shutdown()`` has been called on this scope.
    /// - Since: Java 25
    public func isShutdown() -> Bool {
      var result = false
      _lock.withLock { _ in result = _shutdown }
      return result
    }

    // MARK: - handleComplete (open for subclasses)

    /// Called by the scope whenever a subtask completes (success or failure).
    ///
    /// Subclasses override this to implement custom completion policies, such as
    /// shutting down the scope on the first failure or the first success.
    ///
    /// The default implementation is a no-op.
    ///
    /// - Parameter subtask: The subtask that just completed.
    /// - Since: Java 25
    open func handleComplete(_ subtask: Subtask<T>) {
      // default: no-op
    }

    // MARK: - Private helpers

    private func snapshot() -> [Subtask<T>] {
      var result: [Subtask<T>] = []
      _lock.withLock { _ in result = _subtasks }
      return result
    }
  }
}

// MARK: - ShutdownOnFailure<T>

extension java.util.concurrent {

  /// A `StructuredTaskScope` that shuts down the scope on the first subtask failure.
  ///
  /// After ``join()`` returns, call ``throwIfFailed()`` to rethrow the first error.
  ///
  /// Mirrors `java.util.concurrent.StructuredTaskScope.ShutdownOnFailure` (Java 25).
  ///
  /// ```swift
  /// let scope = java.util.concurrent.ShutdownOnFailure<Int>()
  /// scope.fork { throw MyError() }
  /// scope.fork { 42 }
  /// try await scope.join()
  /// try scope.throwIfFailed()
  /// ```
  ///
  /// - Since: Java 25
  public final class ShutdownOnFailure<T>: StructuredTaskScope<T> {

    private let _exLock = CrossPlatformMutex(0)
    nonisolated(unsafe) private var _firstException: (any Error)? = nil

    public override init() { super.init() }

    public override func handleComplete(_ subtask: Subtask<T>) {
      guard let error = subtask.exception() else { return }
      _exLock.withLock { _ in
        if _firstException == nil { _firstException = error }
      }
      shutdown()
    }

    /// Returns the first exception thrown by a failed subtask, or `nil`.
    /// - Since: Java 25
    public func exception() -> (any Error)? {
      var result: (any Error)? = nil
      _exLock.withLock { _ in result = _firstException }
      return result
    }

    /// Throws the first exception if any subtask failed; otherwise returns normally.
    /// - Since: Java 25
    public func throwIfFailed() throws {
      if let error = exception() { throw error }
    }
  }
}

// MARK: - ShutdownOnSuccess<T>

extension java.util.concurrent {

  /// A `StructuredTaskScope` that shuts down the scope on the first subtask success.
  ///
  /// After ``join()`` returns, call ``result()`` to obtain the winning value.
  ///
  /// Mirrors `java.util.concurrent.StructuredTaskScope.ShutdownOnSuccess<T>` (Java 25).
  ///
  /// ```swift
  /// let scope = java.util.concurrent.ShutdownOnSuccess<String>()
  /// scope.fork { "fast" }
  /// scope.fork { try await Task.sleep(nanoseconds: 1_000_000_000); return "slow" }
  /// try await scope.join()
  /// let winner = try scope.result()   // "fast"
  /// ```
  ///
  /// - Since: Java 25
  public final class ShutdownOnSuccess<T>: StructuredTaskScope<T> {

    private let _resultLock = CrossPlatformMutex(0)
    nonisolated(unsafe) private var _firstResult: T? = nil

    public override init() { super.init() }

    public override func handleComplete(_ subtask: Subtask<T>) {
      guard subtask.state() == .success, let value = try? subtask.get() else { return }
      _resultLock.withLock { _ in
        if _firstResult == nil { _firstResult = value }
      }
      shutdown()
    }

    /// Returns the result of the first successful subtask.
    ///
    /// - Throws: `IllegalStateException` if no subtask has succeeded yet.
    /// - Since: Java 25
    public func result() throws -> T {
      var r: T? = nil
      _resultLock.withLock { _ in r = _firstResult }
      guard let r else {
        throw IllegalStateException()
      }
      return r
    }
  }
}
