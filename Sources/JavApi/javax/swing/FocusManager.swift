/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// Public Swing focus-management API — mirrors `javax.swing.FocusManager`
  /// from JFC 1.0 / Java 1.2.
  ///
  /// The heavy lifting is done by the platform-specific focus managers
  /// (`_SwiftUIFocusManager`, `_Win32FocusManager`, `_X11FocusManager`).
  /// This class is a thin, Java-API-compatible façade over the SwiftUI
  /// implementation (the only one available at runtime on Apple platforms).
  ///
  /// ## Usage
  ///
  /// ```swift
  /// // Move focus forward from a component
  /// javax.swing.FocusManager.getCurrentManager().focusNextComponent(button)
  ///
  /// // Replace the manager
  /// javax.swing.FocusManager.setCurrentManager(myCustomManager)
  /// ```
  ///
  /// > Note: In Java 1.4 `FocusManager` was superseded by
  /// > `KeyboardFocusManager`.  This class is retained for JFC 1.0
  /// > source compatibility.
  ///
  /// - Since: JFC 1.0 / Java 1.2
  @MainActor
  open class FocusManager {

    // -------------------------------------------------------------------------
    // MARK: Singleton / current manager
    // -------------------------------------------------------------------------

    private static var _current: javax.swing.FocusManager = javax.swing.FocusManager()

    /// Returns the currently installed focus manager.
    public static func getCurrentManager() -> javax.swing.FocusManager {
      _current
    }

    /// Replaces the current focus manager.
    public static func setCurrentManager(_ manager: javax.swing.FocusManager?) {
      _current = manager ?? javax.swing.FocusManager()
    }

    // -------------------------------------------------------------------------
    // MARK: Focus traversal
    // -------------------------------------------------------------------------

    /// Moves focus to the next focusable component after `aComponent`.
    open func focusNextComponent(_ aComponent: java.awt.Component) {
#if canImport(SwiftUI)
      _SwiftUIFocusManager.shared.transferFocus(forward: true)
#elseif os(Windows)
      _Win32FocusManager.shared.transferFocus(forward: true)
#elseif os(Linux) || os(FreeBSD)
      _X11FocusManager.shared.transferFocus(forward: true)
#endif
    }

    /// Moves focus to the previous focusable component before `aComponent`.
    open func focusPreviousComponent(_ aComponent: java.awt.Component) {
#if canImport(SwiftUI)
      _SwiftUIFocusManager.shared.transferFocus(forward: false)
#elseif os(Windows)
      _Win32FocusManager.shared.transferFocus(forward: false)
#elseif os(Linux) || os(FreeBSD)
      _X11FocusManager.shared.transferFocus(forward: false)
#endif
    }

    // -------------------------------------------------------------------------
    // MARK: Focus owner
    // -------------------------------------------------------------------------

    /// Returns the component that currently owns the keyboard focus, or `nil`.
    open func getFocusOwner() -> java.awt.Component? {
#if canImport(SwiftUI)
      return _SwiftUIFocusManager.shared.focusOwner
#elseif os(Windows)
      return _Win32FocusManager.shared.focusOwner
#elseif os(Linux) || os(FreeBSD)
      return _X11FocusManager.shared.focusOwner
#else
      return nil
#endif
    }

    // -------------------------------------------------------------------------
    // MARK: Key event dispatch hook
    // -------------------------------------------------------------------------

    /// Called by the toolkit before dispatching `e` to `focusedComponent`.
    ///
    /// Override in a subclass to intercept or consume key events globally.
    /// The default implementation does nothing (returns without consuming).
    open func processKeyEvent(_ focusedComponent: java.awt.Component,
                              _ e: java.awt.event.KeyEvent) {
      // Default: do not consume — let normal dispatch proceed.
    }

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    public init() {}
  }
}
