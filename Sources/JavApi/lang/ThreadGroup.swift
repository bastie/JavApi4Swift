/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// Thread group that manages a set of threads, Java 1.0 equivalent of `java.lang.ThreadGroup`.
///
/// Implemented as a Swift `actor` so all state is protected by actor isolation —
/// no explicit locks are needed. Instead of raw thread references, the group tracks
/// Swift `Task` handles, mapping Java concepts to Swift Concurrency:
///
/// | Java                        | Swift                              |
/// |-----------------------------|------------------------------------|
/// | `ThreadGroup.interrupt()`   | `task.cancel()` on all tasks       |
/// | `synchronized` methods      | Actor isolation                    |
/// | Parent/child hierarchy      | `weak var parent: ThreadGroup?`    |
/// | `activeCount()`             | Count of non-cancelled tasks       |
///
/// `suspend()` and `resume()` are no-ops — they were deprecated in Java 1.2
/// and have no meaningful equivalent in Swift structured concurrency.
///
/// - Since: JavaApi > 0.19.1 (Java 1.0)
public actor ThreadGroup {

  private let name: String
  private var maxPriority: Int = Thread.MAX_PRIORITY
  private var daemon: Bool = false
  private weak var parent: ThreadGroup?
  private var tasks: [ObjectIdentifier : Task<Swift.Void, any Error>] = [:]
  private var childGroups: [ObjectIdentifier: ThreadGroup] = [:]

  // MARK: - Constructors

  /// Creates a new thread group with the given name.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public init(_ name: String) {
    self.name = name
  }

  /// Creates a new thread group as a child of the given parent group.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public init(_ parent: ThreadGroup, _ name: String) {
    self.parent = parent
    self.name = name
  }

  // MARK: - Name & priority

  /// Returns the name of this thread group.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func getName() -> String {
    return name
  }

  /// Returns the parent of this thread group, or `nil` if it is the root.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func getParent() -> ThreadGroup? {
    return parent
  }

  /// Returns the maximum priority that threads in this group may have.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func getMaxPriority() -> Int {
    return maxPriority
  }

  /// Sets the maximum priority for this group.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func setMaxPriority(_ priority: Int) {
    guard priority >= Thread.MIN_PRIORITY, priority <= Thread.MAX_PRIORITY else { return }
    maxPriority = priority
  }

  // MARK: - Daemon

  /// Returns whether this is a daemon thread group.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func isDaemon() -> Bool {
    return daemon
  }

  /// Sets the daemon status of this thread group.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func setDaemon(_ daemon: Bool) {
    self.daemon = daemon
  }

  // MARK: - Active count

  /// Returns an estimate of the number of active threads in this group.
  /// Cleans up completed tasks as a side effect.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func activeCount() -> Int {
    tasks = tasks.filter { !$0.value.isCancelled }
    return tasks.count
  }

  /// Returns an estimate of the number of active subgroups in this group.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func activeGroupCount() -> Int {
    return childGroups.count
  }

  // MARK: - Interrupt

  /// Interrupts all threads in this group and its subgroups by cancelling
  /// their associated Swift Tasks.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func interrupt() {
    tasks.values.forEach { $0.cancel() }
    // propagate to child groups
    childGroups.values.forEach { group in
      Task { await group.interrupt() }
    }
  }

  // MARK: - Deprecated no-ops (Java 1.2 deprecated)

  /// No-op. `suspend()` was deprecated in Java 1.2 and has no equivalent
  /// in Swift structured concurrency.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  @available(*, deprecated, message: "suspend() was deprecated in Java 1.2 and is a no-op in JavApi4Swift")
  public func suspend() {}

  /// No-op. `resume()` was deprecated in Java 1.2 and has no equivalent
  /// in Swift structured concurrency.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  @available(*, deprecated, message: "resume() was deprecated in Java 1.2 and is a no-op in JavApi4Swift")
  public func resume() {}

  /// No-op. `destroy()` was deprecated in Java 16.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  @available(*, deprecated, message: "destroy() was deprecated in Java 16 and is a no-op in JavApi4Swift")
  public func destroy() {}

  // MARK: - Internal registration (called by Thread)

  internal func register(_ task: Task<Swift.Void, any Error>, id: ObjectIdentifier) {
    tasks[id] = task
  }

  internal func unregister(_ id: ObjectIdentifier) {
    tasks.removeValue(forKey: id)
  }

  internal func registerChildGroup(_ group: ThreadGroup, id: ObjectIdentifier) {
    childGroups[id] = group
  }

  internal func unregisterChildGroup(_ id: ObjectIdentifier) {
    childGroups.removeValue(forKey: id)
  }

  // MARK: - List (debug)

  /// Prints information about this thread group to standard output.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func list() {
    print("java.lang.ThreadGroup[name=\(name),maxpri=\(maxPriority)]")
    print("  active threads: \(tasks.count)")
  }
}
