/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.awt {

  /// Manages the AWT event dispatch queue.
  ///
  /// Mirrors `java.awt.EventQueue` (Java 1.1).
  ///
  /// In JavApi⁴Swift the "Event Dispatch Thread" is `@MainActor` — all
  /// runnables submitted via `invokeLater` or `invokeAndWait` execute on the
  /// main actor, matching Java's EDT guarantee.
  ///
  /// ### Typical usage
  /// ```swift
  /// @main
  /// struct MyApp {
  ///   static func main() {
  ///     java.awt.EventQueue.invokeLater {
  ///       let f = java.awt.Frame("Hello")
  ///       f.setSize(400, 300)
  ///       f.setVisible(true)
  ///     }
  ///   }
  /// }
  /// ```
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.1)
  @MainActor
  public final class EventQueue {

    // -------------------------------------------------------------------------
    // MARK: Internal queue — drained by Toolkit.runEventLoop()
    // -------------------------------------------------------------------------

    /// Pending runnables submitted before the event loop has started.
    internal static var pendingRunnables: [@MainActor () -> Void] = []

    /// `true` once the platform event loop is running and runnables are
    /// dispatched immediately rather than queued.
    internal static var isLoopRunning: Bool = false

    // -------------------------------------------------------------------------
    // MARK: Public API
    // -------------------------------------------------------------------------

    /// Causes `runnable` to be executed on the Event Dispatch Thread.
    ///
    /// If the event loop is already running the runnable is dispatched
    /// asynchronously via `Task { @MainActor in … }`.
    /// If the loop has not yet started it is queued and drained as the first
    /// action of `Toolkit.runEventLoop()` — this is the Java 1.0 implicit-start
    /// behaviour: calling `frame.setVisible(true)` in `main()` triggers the loop.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.1)
    public static func invokeLater(_ runnable: @MainActor @escaping () -> Void) {
      if isLoopRunning {
        Task { @MainActor in runnable() }
      } else {
        pendingRunnables.append(runnable)
      }
    }

    /// Causes `runnable` to be executed on the Event Dispatch Thread and waits
    /// for it to finish.
    ///
    /// If called from the EDT itself the runnable is executed synchronously.
    /// Throws `java.lang.InterruptedException` (mapped to a Swift error) if the
    /// calling thread is interrupted while waiting.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.1)
    public static func invokeAndWait(_ runnable: @MainActor () -> Void) throws {
      // On @MainActor we are already on the EDT — run synchronously.
      runnable()
    }

    /// Returns `true` if the calling thread is the Event Dispatch Thread.
    ///
    /// In JavApi⁴Swift this is equivalent to being on `@MainActor`.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.1)
    public static func isDispatchThread() -> Bool {
      // In JavApi⁴Swift the EDT is always @MainActor = the main thread.
      // isLoopRunning is set on @MainActor, so if we can read it without
      // hopping we are on the main actor / main thread.
      // The simplest portable check: compare against the main run loop.
#if canImport(Foundation) && !os(WASI)
      return Foundation.Thread.isMainThread
#else
      // WASM/WASI and other single-threaded environments: always on "main thread"
      return true
#endif
    }

    // -------------------------------------------------------------------------
    // MARK: Internal — drain pending runnables
    // -------------------------------------------------------------------------

    /// Drains all queued runnables and marks the loop as running.
    ///
    /// Called once by `Toolkit.runEventLoop()` before entering the platform
    /// event loop. After this point `invokeLater` dispatches asynchronously.
    internal static func drainAndMarkRunning() {
      isLoopRunning = true
      let pending = pendingRunnables
      pendingRunnables = []
      for runnable in pending {
        runnable()
      }
    }
  }
}
