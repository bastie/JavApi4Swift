/*
 * SPDX-FileCopyrightText: 2023-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation
#if canImport(WASILibc)
import WASILibc
#endif

open class Thread: @unchecked Sendable {

  // MARK: - Priority constants

  /// The minimum priority a thread can have (Java Thread.MIN_PRIORITY = 1)
  public static let MIN_PRIORITY: Int = 1
  /// The default priority assigned to a thread (Java Thread.NORM_PRIORITY = 5)
  public static let NORM_PRIORITY: Int = 5
  /// The maximum priority a thread can have (Java Thread.MAX_PRIORITY = 10)
  public static let MAX_PRIORITY: Int = 10

  // MARK: - Properties

  private var name: String
  private var priority: Int = Thread.NORM_PRIORITY
  private var daemon: Bool = false
  private var runnable: (any Runnable)?
  private var group: ThreadGroup?

  /// The underlying Swift Task, set when `start()` is called.
  private var task: Task<Swift.Void, any Error>?

  // MARK: - Constructors

  /// Creates a new Thread with a default name.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public init() {
    self.name = "Thread-\(UUID().uuidString.prefix(8))"
  }

  /// Creates a new Thread that will execute the given Runnable.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public init(_ runnable: any Runnable) {
    self.name = "Thread-\(UUID().uuidString.prefix(8))"
    self.runnable = runnable
  }

  /// Creates a new Thread with the given name.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public init(_ name: String) {
    self.name = name
  }

  /// Creates a new Thread with the given name that will execute the given Runnable.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public init(_ runnable: any Runnable, _ name: String) {
    self.name = name
    self.runnable = runnable
  }

  /// Creates a new Thread in the given group.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public init(_ group: ThreadGroup, _ name: String) {
    self.group = group
    self.name = name
  }

  /// Creates a new Thread in the given group that will execute the given Runnable.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public init(_ group: ThreadGroup, _ runnable: any Runnable, _ name: String) {
    self.group = group
    self.name = name
    self.runnable = runnable
  }

  // MARK: - run / start

  /// Override in subclasses to define the thread's work. The default
  /// implementation calls the `Runnable` passed to the constructor, if any.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  open func run() {
    runnable?.run()
  }

  /// Causes this thread to begin execution. Creates a Swift `Task` that
  /// calls `run()` and registers it with the `ThreadGroup` if one was set.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func start() {
    let t = Task<Swift.Void, any Error> { [weak self] in
      guard let self else { return }
      self.run()
      // unregister when done
      if let g = self.group {
        await g.unregister(ObjectIdentifier(self))
      }
    }
    self.task = t
    if let g = group {
      Task { await g.register(t, id: ObjectIdentifier(self)) }
    }
  }

  // MARK: - Interrupt / status

  /// Interrupts this thread by cancelling its underlying Swift Task.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func interrupt() {
    task?.cancel()
  }

  /// Returns `true` if this thread's Task has been cancelled.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func isInterrupted() -> Bool {
    return task?.isCancelled ?? false
  }

  /// Returns `true` if the thread has been started and has not yet finished.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func isAlive() -> Bool {
    guard let task else { return false }
    return !task.isCancelled
  }

  // MARK: - Name / priority / daemon

  /// Returns the name of this thread.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func getName() -> String { return name }

  /// Sets the name of this thread.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func setName(_ name: String) { self.name = name }

  /// Returns the priority of this thread.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func getPriority() -> Int { return priority }

  /// Sets the priority of this thread. Clamped to [MIN_PRIORITY, MAX_PRIORITY].
  ///
  /// Note: Swift Tasks do not expose priority mapping to Java's 1–10 scale;
  /// this value is stored but has no effect on scheduling.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func setPriority(_ priority: Int) {
    self.priority = max(Thread.MIN_PRIORITY, min(Thread.MAX_PRIORITY, priority))
  }

  /// Returns whether this is a daemon thread.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func isDaemon() -> Bool { return daemon }

  /// Sets the daemon status of this thread. Must be called before `start()`.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func setDaemon(_ daemon: Bool) { self.daemon = daemon }

  /// Returns the thread group this thread belongs to, or `nil`.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func getThreadGroup() -> ThreadGroup? { return group }

  // MARK: - Static helpers

  /// Let the current thread sleep for the given number of milliseconds.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  @available(*, renamed: "sleep", message: "with Swift 5.5 or higher use await/async with sleep(nanoseconds) instead")
  public static func sleep(_ milliseconds: Int64) {
#if os(WASI)
    // DispatchGroup is unavailable on WASI; use POSIX usleep instead.
    usleep(UInt32(milliseconds * 1_000))
#else
    let group = DispatchGroup()
    group.enter()
    _ = group.wait(timeout: .now() + DispatchTimeInterval.milliseconds(Int(milliseconds)))
#endif
  }
}
