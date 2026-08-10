/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - Future<V> protocol

extension java.util.concurrent {

  /// Represents the result of an asynchronous computation.
  ///
  /// Mirrors `java.util.concurrent.Future<V>` (Java 5).
  ///
  /// Methods are provided to check if the computation is complete, to wait for
  /// its completion, and to retrieve its result. The result can only be
  /// retrieved using ``get()`` when the computation has completed, blocking if
  /// necessary until it is ready.
  ///
  /// The concrete implementation provided by JavApi⁴Swift is ``TaskFuture``,
  /// which wraps a Swift `Task`:
  /// ```swift
  /// let future = java.util.concurrent.TaskFuture<Int> {
  ///     try await someAsyncWork()
  /// }
  /// let result = try future.get()
  /// ```
  ///
  /// - Note: `get(timeout:unit:)` is omitted because `java.util.TimeUnit` is
  ///   not yet ported. Use the no-argument ``get()`` instead, or cancel
  ///   proactively from another context.
  ///
  /// - Since: Java 5
  public protocol Future<V> {
    associatedtype V

    /// Attempts to cancel execution of this task.
    ///
    /// Returns `false` if the task has already completed or been cancelled.
    /// If `mayInterruptIfRunning` is `true`, the underlying Swift `Task` is
    /// cancelled; otherwise a cancellation is scheduled cooperatively.
    func cancel(_ mayInterruptIfRunning: Bool) -> Bool

    /// Returns `true` if this task was cancelled before it completed normally.
    func isCancelled() -> Bool

    /// Returns `true` if this task completed (normally, by cancellation,
    /// or by throwing an exception).
    func isDone() -> Bool

    /// Waits if necessary for the computation to complete, then returns its
    /// result.
    ///
    /// - Throws: ``ExecutionException`` if the computation threw an exception
    ///   or was cancelled.
    func get() throws -> V
  }
}

// MARK: - TaskFuture<V> — Swift Task–backed implementation

import Foundation

extension java.util.concurrent {

  /// A ``Future`` implementation that wraps a Swift `async` closure.
  ///
  /// `get()` blocks the calling thread until the task finishes. On WASI
  /// (single-threaded) `get()` throws ``ExecutionException`` when the result
  /// is not yet available.
  ///
  /// ```swift
  /// let future = java.util.concurrent.TaskFuture<Int> {
  ///     try await Task.sleep(for: .milliseconds(100))
  ///     return 42
  /// }
  /// let result = try future.get()   // blocks; returns 42
  /// ```
  ///
  /// Letting a `TaskFuture` deallocate cancels the underlying task.
  ///
  /// - Since: Java 5 (JavApi⁴Swift)
  public final class TaskFuture<V: Sendable>: java.util.concurrent.Future, @unchecked Sendable {

    // MARK: - State
    // All state is protected by _cond on non-WASI platforms.

    private let _task: Task<V, any Error>

    /// Protected by _cond (non-WASI) or accessed single-threadedly (WASI).
    nonisolated(unsafe) private var _result: Result<V, any Error>? = nil
    nonisolated(unsafe) private var _cancelled = false

#if !os(WASI)
    private let _cond = NSCondition()
#endif

    // MARK: - Initialiser

    /// Creates a future that runs `body` in a detached Swift Task.
    public init(_ body: @escaping @Sendable () async throws -> V) {
      _task = Task<V, any Error> { try await body() }

#if !os(WASI)
      let task = _task
      // Use Task (not Task.detached) to inherit priority from the calling context
      // so the monitor is scheduled promptly after _task completes.
      // _signalCompletion is a synchronous helper — NSCondition calls stay
      // outside the async closure, satisfying Swift 6.3 strict concurrency.
      Task { [weak self, task] in
        let r: Result<V, any Error>
        do    { r = try await .success(task.value) }
        catch { r = .failure(error) }
        self?._signalCompletion(r)
      }
#endif
    }

#if !os(WASI)
    /// Synchronous helper: stores the result and wakes blocked `get()` callers.
    ///
    /// Must be called from a **non-async** context so that `NSCondition.lock()`
    /// and `NSCondition.unlock()` are not invoked from within an async closure
    /// (Swift 6.3 strict-concurrency requirement).
    nonisolated private func _signalCompletion(_ r: Result<V, any Error>) {
      _cond.lock()
      _result = r
      _cond.broadcast()
      _cond.unlock()
    }
#endif

    deinit { _task.cancel() }

    // MARK: - Future

    public func cancel(_ mayInterruptIfRunning: Bool) -> Bool {
#if !os(WASI)
      _cond.lock(); defer { _cond.unlock() }
#endif
      guard _result == nil && !_cancelled else { return false }
      _task.cancel()
      _cancelled = true
#if !os(WASI)
      _cond.broadcast()
#endif
      return true
    }

    public func isCancelled() -> Bool {
#if !os(WASI)
      _cond.lock(); defer { _cond.unlock() }
#endif
      return _cancelled
    }

    public func isDone() -> Bool {
#if !os(WASI)
      _cond.lock(); defer { _cond.unlock() }
#endif
      return _result != nil || _cancelled
    }

    public func get() throws -> V {
#if !os(WASI)
      _cond.lock()
      defer { _cond.unlock() }
      while _result == nil && !_cancelled { _cond.wait() }
#else
      guard _result != nil || _cancelled else {
        throw java.util.concurrent.ExecutionException(
          "get() on an incomplete Future is not supported on single-threaded WASI")
      }
#endif
      return try _resolveUnderLock()
    }

    // MARK: - Private

    /// Must be called with _cond held (or on WASI where no lock is needed).
    private func _resolveUnderLock() throws -> V {
      if _cancelled && _result == nil {
        throw java.util.concurrent.ExecutionException("Task was cancelled")
      }
      switch _result! {
      case .success(let v):
        return v
      case .failure(let e):
        if let t = e as? Throwable {
          throw java.util.concurrent.ExecutionException(t)
        }
        throw java.util.concurrent.ExecutionException(
          "Task failed: \(e.localizedDescription)", swiftCause: e)
      }
    }
  }
}
