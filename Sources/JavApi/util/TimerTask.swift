/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  /// Abstract base for tasks submitted to `java.util.Timer`.
  ///
  /// Mirrors `java.util.TimerTask`. Implement `run()` with the work to
  /// perform; the owning `Timer` calls it on a background actor.
  ///
  /// ```swift
  /// class MyTask: java.util.TimerTask {
  ///   func run() { print("tick") }
  /// }
  /// ```
  ///
  /// - Since: Java 1.3
  public protocol TimerTask: AnyObject, Sendable {
    /// The action to perform. Called by the owning `Timer` on a background actor.
    func run()

    /// Returns the time at which this task is scheduled for its most recent
    /// actual execution, or `-1` if not yet scheduled.
    func scheduledExecutionTime() -> Int64
  }
}

// MARK: - Default implementation

public extension java.util.TimerTask {
  func scheduledExecutionTime() -> Int64 { -1 }
}
