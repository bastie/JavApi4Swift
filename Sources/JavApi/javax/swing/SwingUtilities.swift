/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// Utility methods for Swing components.
  ///
  /// The most commonly used method is `invokeLater(_:)`, which schedules a
  /// `Runnable` to be executed on the **Event Dispatch Thread** (EDT).
  /// This is the correct way to create and show Swing windows:
  ///
  /// ```swift
  /// javax.swing.SwingUtilities.invokeLater {
  ///   let frame = javax.swing.JFrame("My App")
  ///   frame.setVisible(true)
  /// }
  /// java.awt.Toolkit.getDefaultToolkit().runEventLoop()
  /// ```
  ///
  /// In JavApi4Swift the EDT is the main thread (`@MainActor`).
  /// `invokeLater` therefore delegates to `java.awt.EventQueue.invokeLater`.
  ///
  @MainActor
  public class SwingUtilities {

    // -------------------------------------------------------------------------
    // MARK: EDT scheduling
    // -------------------------------------------------------------------------

    /// Schedules `runnable` to be executed on the Event Dispatch Thread.
    /// Equivalent to `java.awt.EventQueue.invokeLater(runnable)`.
    public static func invokeLater(_ runnable: any java.lang.Runnable) {
      java.awt.EventQueue.invokeLater { runnable.run() }
    }

    /// Swift-closure convenience overload.
    public static func invokeLater(_ block: @escaping @MainActor () -> Void) {
      java.awt.EventQueue.invokeLater(block)
    }

    /// Executes `runnable` on the Event Dispatch Thread and waits for
    /// completion.  If the calling thread already is the EDT, `runnable`
    /// is executed directly.
    ///
    /// > **Note:** In JavApi4Swift this is equivalent to `invokeLater` because
    /// > the runtime is single-threaded on `@MainActor`.
    public static func invokeAndWait(_ runnable: any java.lang.Runnable) {
      java.awt.EventQueue.invokeLater { runnable.run() }
    }

    /// Returns `true` if the current thread is the Event Dispatch Thread.
    /// In JavApi4Swift this always returns `true` (everything runs on the
    /// main actor).
    public static func isEventDispatchThread() -> Bool {
      return true
    }
  }
}
