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
  /// Follows the Java API contract: `ToolTipManager` is `final`, extends
  /// `MouseAdapter` (which implements `MouseListener`), and additionally
  /// implements `MouseMotionListener`.
  ///
  /// - Since: JFC 1.0 / Java 1.2
  @MainActor
  public final class ToolTipManager: java.awt.event.MouseAdapter,
                                     java.awt.event.MouseMotionListener {

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
    // MARK: Lightweight popup
    // -------------------------------------------------------------------------

    private var _lightWeightPopupEnabled: Bool = true

    /// Returns whether tooltips use lightweight (non-native) popups.
    ///
    /// When `true` (default), tooltips are rendered inside the component
    /// hierarchy without a native window.  Set to `false` to force a
    /// heavyweight (native) window — required when Swing components are
    /// mixed with heavyweight AWT or native components.
    public func isLightWeightPopupEnabled() -> Bool { _lightWeightPopupEnabled }

    /// Enables or disables lightweight tooltip popups (default: `true`).
    public func setLightWeightPopupEnabled(_ enabled: Bool) {
      _lightWeightPopupEnabled = enabled
    }

    // -------------------------------------------------------------------------
    // MARK: Internal timer state
    // -------------------------------------------------------------------------

    /// The component currently under the mouse cursor (if any).
    private weak var _insideComponent: javax.swing.JComponent?

    /// Whether a tooltip is currently visible.
    private var _tipShowing: Bool = false

    /// Time of the last mouse-exit (used for reshow-delay calculation).
    private var _exitTime: Date?

    // -------------------------------------------------------------------------
    // MARK: MouseListener overrides (from MouseAdapter)
    // -------------------------------------------------------------------------

    /// Called when the mouse enters a component.
    ///
    /// Starts the initial-delay countdown.  If the mouse left a tooltip-bearing
    /// component within `reshowDelay` milliseconds, the initial delay is skipped.
    public override func mouseEntered(_ e: java.awt.event.MouseEvent) {
      guard _enabled else { return }
      guard let component = e.getSource() as? javax.swing.JComponent,
            component.getToolTipText() != nil else { return }
      _insideComponent = component

      // Check reshow: if the mouse left another component recently, skip delay.
      let useReshowDelay: Bool
      if let exitTime = _exitTime {
        let elapsed = Date().timeIntervalSince(exitTime) * 1_000
        useReshowDelay = elapsed < Double(_reshowDelay)
      } else {
        useReshowDelay = false
      }

      let delay = useReshowDelay ? 0 : _initialDelay
      scheduleShow(component: component, afterMilliseconds: delay)
    }

    /// Called when the mouse exits a component.
    ///
    /// Cancels any pending show-timer and hides a visible tooltip.
    public override func mouseExited(_ e: java.awt.event.MouseEvent) {
      _insideComponent = nil
      _exitTime = Date()
      cancelShow()
      if _tipShowing {
        hideToolTip()
      }
    }

    /// Called when a mouse button is pressed.
    ///
    /// Hides any visible tooltip immediately (matches Java Swing behaviour).
    public override func mousePressed(_ e: java.awt.event.MouseEvent) {
      cancelShow()
      if _tipShowing {
        hideToolTip()
      }
    }

    // -------------------------------------------------------------------------
    // MARK: MouseMotionListener
    // -------------------------------------------------------------------------

    /// Called when the mouse is dragged.
    ///
    /// Hides any visible tooltip (dragging dismisses the tooltip in Java Swing).
    public func mouseDragged(_ e: java.awt.event.MouseEvent) {
      cancelShow()
      if _tipShowing {
        hideToolTip()
      }
    }

    /// Called when the mouse moves within a component.
    ///
    /// Resets the show-timer so the tooltip only appears after the mouse
    /// has been stationary for `initialDelay` milliseconds.
    public func mouseMoved(_ e: java.awt.event.MouseEvent) {
      guard _enabled else { return }
      guard let component = e.getSource() as? javax.swing.JComponent,
            component.getToolTipText() != nil else { return }

      if _tipShowing {
        // Already showing: restart dismiss timer.
        scheduleDismiss(component: component)
      } else {
        // Not showing yet: restart the show timer.
        cancelShow()
        scheduleShow(component: component, afterMilliseconds: _initialDelay)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Timer helpers (platform-agnostic stubs)
    // -------------------------------------------------------------------------

    /// Schedules the tooltip to appear after `milliseconds`.
    ///
    /// In JavApi⁴Swift the platform canvas drives actual rendering; this
    /// method stores intent for canvas inspection.
    private func scheduleShow(component: javax.swing.JComponent, afterMilliseconds: Int) {
      // Platform canvas reads _insideComponent and delays from the shared
      // instance to decide when and what to render.
      _insideComponent = component
    }

    /// Cancels a pending show-timer.
    private func cancelShow() {
      // Clearing _insideComponent signals the canvas to stop any pending show.
      _insideComponent = nil
    }

    /// Resets the dismiss timer after the tooltip has been shown.
    private func scheduleDismiss(component: javax.swing.JComponent) {
      // Platform canvas uses dismissDelaySeconds to auto-hide.
    }

    /// Hides the currently visible tooltip.
    private func hideToolTip() {
      _tipShowing = false
      // Platform canvas observes _tipShowing and removes the overlay.
    }

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

    private override init() {
      super.init()
    }
  }
}
