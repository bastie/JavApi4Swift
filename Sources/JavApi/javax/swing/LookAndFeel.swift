/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// Abstract base class for all Swing Look & Feel implementations.
  ///
  /// A `LookAndFeel` provides a `UIDefaults` table that maps component-class
  /// keys (e.g. `"ButtonUI"`) to `ComponentUI` factory closures.  Subclasses
  /// must implement `getName()`, `getID()`, `getDescription()`,
  /// `isSupportedLookAndFeel()`, `isNativeLookAndFeel()`, and
  /// `getDefaults()`.
  ///
  /// The active L&F is managed by `UIManager`.  Components call
  /// `updateUI()` to pick up the new delegate whenever the L&F changes.
  ///
  /// - Since: Java 1.2
  @MainActor
  open class LookAndFeel {

    public init() {}

    // -------------------------------------------------------------------------
    // MARK: Identity
    // -------------------------------------------------------------------------

    /// Short human-readable name, e.g. `"Basic"`.
    open func getName() -> String { "Unknown" }

    /// Programmer-facing identifier, e.g. `"Basic-1.0.5_017"`.
    open func getID() -> String { "Unknown" }

    /// One-line description shown in UI-chooser dialogs.
    open func getDescription() -> String { "" }

    /// `true` if this L&F wraps or mimics the native OS look.
    open func isNativeLookAndFeel() -> Bool { false }

    /// `true` if this L&F is supported on the current platform.
    open func isSupportedLookAndFeel() -> Bool { true }

    // -------------------------------------------------------------------------
    // MARK: Defaults
    // -------------------------------------------------------------------------

    /// Returns the `UIDefaults` table for this L&F.
    ///
    /// Subclasses override this to register component-UI factories.
    /// `UIManager` merges the result with system defaults.
    open func getDefaults() -> javax.swing.UIDefaults {
      return javax.swing.UIDefaults()
    }

    // -------------------------------------------------------------------------
    // MARK: Initialisation
    // -------------------------------------------------------------------------

    /// Called by `UIManager` when this L&F becomes active.
    /// Override to perform one-time setup (e.g. load fonts, install listeners).
    open func initialize() {}

    /// Called by `UIManager` when this L&F is replaced.
    /// Override to release resources acquired in `initialize()`.
    open func uninitialize() {}
  }
}
