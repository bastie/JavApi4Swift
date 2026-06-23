/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension javax.swing {

  /// Manages the display of tooltips for all Swing components — mirrors
  /// `javax.swing.ToolTipManager` from JFC 1.0 / Java 1.2.
  ///
  /// The manager is a singleton accessed via `sharedInstance()`.  It controls
  /// three delays (all in milliseconds, matching Java Swing defaults):
  ///
  /// | Property | Default | Meaning |
  /// |---|---|---|
  /// | `initialDelay` | 750 ms | Time the mouse must hover before the tooltip appears |
  /// | `dismissDelay` | 4 000 ms | Time the tooltip stays visible before auto-hiding |
  /// | `reshowDelay`  | 500 ms | Suppressed initial delay when moving between components quickly |
  ///
  /// ## Usage
  ///
  /// ```swift
  /// // Change delays globally
  /// javax.swing.ToolTipManager.sharedInstance().setInitialDelay(500)
  /// javax.swing.ToolTipManager.sharedInstance().setDismissDelay(8_000)
  ///
  /// // Disable tooltips globally
  /// javax.swing.ToolTipManager.sharedInstance().setEnabled(false)
  /// ```
  ///
  /// The actual rendering is handled by the platform canvas
  /// (`_SwiftUINativeCanvas` on Apple, equivalent on other platforms).
  /// Components do not need to call `registerComponent` manually —
  /// `JComponent.setToolTipText(_:)` is sufficient.
  ///
  /// - Since: JFC 1.0 / Java 1.2
  @MainActor
  open class ToolTipManager {

    // -------------------------------------------------------------------------
    // MARK: Singleton
    // -------------------------------------------------------------------------

    private static let _shared = ToolTipManager()

    /// Returns the shared tooltip manager.
    public static func sharedInstance() -> ToolTipManager {
      _shared
    }

    // -------------------------------------------------------------------------
    // MARK: Delays (stored in milliseconds, matching Java API)
    // -------------------------------------------------------------------------

    private var _initialDelay: Int = 750
    private var _dismissDelay: Int = 4_000
    private var _reshowDelay:  Int = 500

    /// Returns the delay in milliseconds before a tooltip appears.
    public func getInitialDelay() -> Int { _initialDelay }

    /// Sets the delay in milliseconds before a tooltip appears.
    ///
    /// - Parameter delay: Delay in milliseconds (default: 750).
    public func setInitialDelay(_ delay: Int) { _initialDelay = max(0, delay) }

    /// Returns the time in milliseconds a tooltip stays visible.
    public func getDismissDelay() -> Int { _dismissDelay }

    /// Sets the time in milliseconds a tooltip stays visible before auto-hiding.
    ///
    /// - Parameter delay: Duration in milliseconds (default: 4 000).
    public func setDismissDelay(_ delay: Int) { _dismissDelay = max(0, delay) }

    /// Returns the reshow delay in milliseconds.
    ///
    /// When the mouse moves quickly from one tooltip-bearing component to
    /// another within this time window, the initial delay is skipped and
    /// the new tooltip appears immediately.
    public func getReshowDelay() -> Int { _reshowDelay }

    /// Sets the reshow delay in milliseconds (default: 500).
    public func setReshowDelay(_ delay: Int) { _reshowDelay = max(0, delay) }

    // -------------------------------------------------------------------------
    // MARK: Convenience: delays as TimeInterval (seconds) — used by the canvas
    // -------------------------------------------------------------------------

    /// `initialDelay` as `TimeInterval` (seconds) for use with `Timer`.
    public var initialDelaySeconds: TimeInterval { TimeInterval(_initialDelay) / 1_000 }

    /// `dismissDelay` as `TimeInterval` (seconds) for use with `Timer`.
    public var dismissDelaySeconds: TimeInterval { TimeInterval(_dismissDelay) / 1_000 }

    /// `reshowDelay` as `TimeInterval` (seconds) for use with `Timer`.
    public var reshowDelaySeconds: TimeInterval { TimeInterval(_reshowDelay) / 1_000 }

    // -------------------------------------------------------------------------
    // MARK: Enable / disable
    // -------------------------------------------------------------------------

    private var _enabled: Bool = true

    /// Returns whether tooltips are enabled globally.
    public func isEnabled() -> Bool { _enabled }

    /// Enables or disables tooltips globally.
    ///
    /// When set to `false` no tooltip will appear for any component,
    /// regardless of whether `setToolTipText(_:)` has been called on it.
    public func setEnabled(_ enabled: Bool) { _enabled = enabled }

    // -------------------------------------------------------------------------
    // MARK: Component registration (Java API compatibility)
    // -------------------------------------------------------------------------

    /// Registers `component` with this manager.
    ///
    /// In JavApi⁴Swift, `JComponent.setToolTipText(_:)` is sufficient to
    /// enable tooltips — explicit registration is not required.  This method
    /// exists for source compatibility with Java code that calls it manually.
    public func registerComponent(_ component: javax.swing.JComponent) {
      // No-op: tooltip text on JComponent is checked directly by the canvas.
    }

    /// Unregisters `component`, preventing it from showing tooltips even if
    /// `setToolTipText(_:)` has been called.
    ///
    /// In JavApi⁴Swift this clears the component's tooltip text as a
    /// best-effort equivalent to Java's behaviour.
    public func unregisterComponent(_ component: javax.swing.JComponent) {
      component.setToolTipText(nil)
    }

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    private init() {}
  }
}
