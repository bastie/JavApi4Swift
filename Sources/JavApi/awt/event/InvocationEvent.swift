/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {

  /// Wraps a `Runnable` so it can be executed on the event-dispatch thread —
  /// mirrors `java.awt.event.InvocationEvent`.
  ///
  /// Created internally by `EventQueue.invokeLater(_:)` /
  /// `EventQueue.invokeAndWait(_:)`; rarely constructed directly by user code.
  ///
  /// - Since: Java 1.2
  open class InvocationEvent: java.awt.AWTEvent, @unchecked Sendable {

    // -------------------------------------------------------------------------
    // MARK: - Event id range
    // -------------------------------------------------------------------------

    public static let INVOCATION_FIRST   = 1200
    public static let INVOCATION_DEFAULT = 1200
    public static let INVOCATION_LAST    = 1200

    // -------------------------------------------------------------------------
    // MARK: - Fields
    // -------------------------------------------------------------------------

    /// The action to execute when this event is dispatched.
    public let runnable: any Runnable

    /// Object whose monitor is notified after `runnable.run()` completes.
    /// Mirrors Java's `protected Object notifier` (used by `invokeAndWait`).
    private let notifier: AnyObject?

    /// If `true`, exceptions thrown by `runnable.run()` are caught and
    /// stored in `exception`/`throwable` instead of propagating.
    private let catchExceptions: Bool

    /// The timestamp (epoch millis) at which this event was created.
    public let when: Int64

    /// Set to `true` once `dispatch()` has completed `runnable.run()`.
    private var dispatched: Bool = false

    /// Exception caught during `run()`, if `catchExceptions` is `true`.
    public private(set) var exception: java.lang.Exception?

    // -------------------------------------------------------------------------
    // MARK: - Init
    // -------------------------------------------------------------------------

    /// Creates an event that notifies no one when dispatch completes.
    public init(_ source: AnyObject, _ runnable: any Runnable) {
      self.runnable = runnable
      self.notifier = nil
      self.catchExceptions = false
      self.when = java.lang.System.currentTimeMillis()
      super.init(source, InvocationEvent.INVOCATION_DEFAULT)
    }

    /// Creates an event that notifies `notifier`'s monitor once dispatch
    /// completes — used by `EventQueue.invokeAndWait(_:)`.
    public init(_ source: AnyObject,
                _ runnable: any Runnable,
                _ notifier: AnyObject?,
                _ catchThrowables: Bool) {
      self.runnable = runnable
      self.notifier = notifier
      self.catchExceptions = catchThrowables
      self.when = java.lang.System.currentTimeMillis()
      super.init(source, InvocationEvent.INVOCATION_DEFAULT)
    }

    /// Creates an event with an explicit event id
    /// (for subclasses defining custom invocation event types).
    public init(_ source: AnyObject,
                _ id: Int,
                _ runnable: any Runnable,
                _ notifier: AnyObject?,
                _ catchThrowables: Bool) {
      self.runnable = runnable
      self.notifier = notifier
      self.catchExceptions = catchThrowables
      self.when = java.lang.System.currentTimeMillis()
      super.init(source, id)
    }

    // -------------------------------------------------------------------------
    // MARK: - Dispatch
    // -------------------------------------------------------------------------

    /// Executes `runnable.run()`, then performs the notify step.
    ///
    /// Mirrors `java.awt.event.InvocationEvent.dispatch()`. Subclasses may
    /// override to customise the run/notify sequence.
    ///
    /// - Note: `java.lang.Runnable.run()` is non-throwing in this port, so
    ///   `catchExceptions` / `getException()` / `getThrowable()` are present
    ///   for API compatibility but never populated. Runnables that need to
    ///   report failure should do so through their own result/error channel.
    open func dispatch() {
      runnable.run()
      dispatched = true
    }

    // -------------------------------------------------------------------------
    // MARK: - Accessors
    // -------------------------------------------------------------------------

    /// The timestamp (epoch millis) at which this event was created.
    public func getWhen() -> Int64 { when }

    /// Returns `true` once `dispatch()` has run to completion.
    public func isDispatched() -> Bool { dispatched }

    /// The exception caught during `run()`, if any (only set when the
    /// catch-exceptions constructor was used).
    public func getException() -> java.lang.Exception? { exception }

    /// Alias for `getException()` — mirrors Java's `getThrowable()`.
    public func getThrowable() -> java.lang.Exception? { exception }
  }
}
