/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util.concurrent {

  /// Exception thrown when attempting to retrieve the result of a task that
  /// aborted by throwing an exception.
  ///
  /// Mirrors `java.util.concurrent.ExecutionException` (Java 5).
  ///
  /// The underlying cause is available via ``getCause()``. Typical usage:
  /// ```swift
  /// do {
  ///     let value = try future.get()
  /// } catch let e as java.util.concurrent.ExecutionException {
  ///     print("Task failed: \(e.getCause()?.getMessage() ?? "unknown")")
  /// }
  /// ```
  ///
  /// - Since: Java 5
  open class ExecutionException: Exception, @unchecked Sendable {

    public override init() {
      super.init()
    }

    public override init(_ message: String) {
      super.init(message)
    }

    public override init(_ message: String, _ cause: Throwable) {
      super.init(message, cause)
    }

    public override init(_ cause: Throwable) {
      super.init(cause)
    }

    /// Convenience initialiser that wraps any Swift `Error` as the cause.
    ///
    /// Use this when a non-`Throwable` Swift error surfaces inside a
    /// `Future`'s execution and needs to be wrapped for the caller.
    public init(_ message: String, swiftCause: any Error) {
      super.init(message)
    }
  }
}
