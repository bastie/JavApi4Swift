/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - Subtask<T> (Java 25)

extension java.util.concurrent {

  /// A handle to a subtask forked within a `StructuredTaskScope`.
  ///
  /// Mirrors `java.util.concurrent.StructuredTaskScope.Subtask<T>` (Java 25).
  ///
  /// A `Subtask` is created by ``StructuredTaskScope/fork(_:)`` and transitions
  /// through the states ``State/running`` → ``State/success`` or ``State/failed``.
  ///
  /// - Since: Java 25
  public final class Subtask<T>: @unchecked Sendable {

    // MARK: - State enum

    /// The lifecycle state of a `Subtask`.
    public enum State: Equatable {
      /// The task has been forked but has not yet completed.
      case running
      /// The task completed successfully.
      case success
      /// The task completed by throwing an error.
      case failed
    }

    // MARK: - Internal storage

    private enum _Internal {
      case running
      case success(T)
      case failed(any Error)
    }

    private let _lock = CrossPlatformMutex(0)
    nonisolated(unsafe) private var _internal: _Internal = .running

    /// The underlying Swift `Task` wrapper; set by `StructuredTaskScope.fork`.
    internal var _trackerTask: Task<Void, Never>?

    internal init() {}

    // MARK: - Internal state transition

    internal func _setSuccess(_ value: T) {
      _lock.withLock { _ in _internal = .success(value) }
    }

    internal func _setFailed(_ error: any Error) {
      _lock.withLock { _ in _internal = .failed(error) }
    }

    // MARK: - Public API

    /// Returns the current state of the subtask.
    public func state() -> State {
      var s = State.running
      _lock.withLock { _ in
        switch _internal {
        case .running:  s = .running
        case .success:  s = .success
        case .failed:   s = .failed
        }
      }
      return s
    }

    /// Returns the result of the subtask.
    ///
    /// - Throws: The error thrown by the task if it failed.
    /// - Precondition: The task must have completed (``state()`` ≠ ``.running``).
    public func get() throws -> T {
      var captured: _Internal = .running
      _lock.withLock { _ in captured = _internal }
      switch captured {
      case .running:
        preconditionFailure("\(type(of: self)).get() called before task completed")
      case .success(let value):
        return value
      case .failed(let error):
        throw error
      }
    }

    /// Returns the error thrown by the subtask, or `nil` if it succeeded or is still running.
    public func exception() -> (any Error)? {
      var result: (any Error)? = nil
      _lock.withLock { _ in
        if case .failed(let error) = _internal { result = error }
      }
      return result
    }
  }
}
