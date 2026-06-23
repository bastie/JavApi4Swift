/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// Manages the active Look & Feel and provides `ComponentUI` instances.
  ///
  /// `UIManager` is the central point for L&F management in Swing:
  ///
  /// - It holds the currently active `LookAndFeel`.
  /// - `getUI(_:)` looks up the correct `ComponentUI` for a `JComponent`
  ///   by deriving a key from the component's class name (e.g. `JButton` →
  ///   `"ButtonUI"`) and asking the active L&F's `UIDefaults` table.
  /// - `setLookAndFeel(_:)` installs a new L&F; `getLookAndFeel()` returns it.
  ///
  /// ## Default L&F
  ///
  /// The default is `BasicLookAndFeel`, installed lazily on first access.
  ///
  /// ## Usage
  ///
  /// ```swift
  /// // Install a different L&F:
  /// try UIManager.setLookAndFeel(MyCustomLookAndFeel())
  ///
  /// // Fetch a UI delegate (called internally by JButton.updateUI()):
  /// if let ui = UIManager.getUI(self) { setUI(ui) }
  /// ```
  ///
  /// - Since: Java 1.2
  @MainActor
  public final class UIManager {

    // -------------------------------------------------------------------------
    // MARK: Singleton state
    // -------------------------------------------------------------------------

    private static var _laf: javax.swing.LookAndFeel = javax.swing.plaf.basic.BasicLookAndFeel()
    private static var _defaults: javax.swing.UIDefaults = javax.swing.plaf.basic.BasicLookAndFeel().getDefaults()

    private init() {}

    // -------------------------------------------------------------------------
    // MARK: L&F access
    // -------------------------------------------------------------------------

    /// Returns the currently active Look & Feel.
    public static func getLookAndFeel() -> javax.swing.LookAndFeel {
      return _laf
    }

    /// Installs `laf` as the active Look & Feel.
    ///
    /// Calls `uninitialize()` on the old L&F and `initialize()` on the new one,
    /// then rebuilds the defaults table.
    ///
    /// - Throws: `UnsupportedLookAndFeelException` if `laf.isSupportedLookAndFeel()` is `false`.
    public static func setLookAndFeel(_ laf: javax.swing.LookAndFeel) throws {
      guard laf.isSupportedLookAndFeel() else {
        throw javax.swing.UnsupportedLookAndFeelException(
          "LookAndFeel \(laf.getName()) is not supported on this platform")
      }
      _laf.uninitialize()
      _laf = laf
      _defaults = laf.getDefaults()
      laf.initialize()
    }

    /// Convenience: install a L&F by fully-qualified class name (no-op stub).
    ///
    /// In Java this loads the class dynamically.  In JavApi⁴Swift, pass the
    /// instance directly to `setLookAndFeel(_:)` instead.
    public static func setLookAndFeel(_ className: String) throws {
      // Dynamic class loading is not supported in Swift.
      // Use setLookAndFeel(_ laf: LookAndFeel) with a concrete instance.
    }

    // -------------------------------------------------------------------------
    // MARK: UI lookup
    // -------------------------------------------------------------------------

    /// Returns a new `ComponentUI` for `component` from the active L&F, or `nil`.
    ///
    /// The key is derived by stripping the leading `J` from the last component
    /// of the class name and appending `"UI"`:
    /// `javax.swing.JButton` → `"ButtonUI"`.
    public static func getUI(_ component: javax.swing.JComponent) -> javax.swing.plaf.ComponentUI? {
      let key = component.getUIClassID()
      return _defaults.getUI(for: key)
    }

    // -------------------------------------------------------------------------
    // MARK: Defaults table
    // -------------------------------------------------------------------------

    /// Returns the merged `UIDefaults` of the active L&F.
    public static func getDefaults() -> javax.swing.UIDefaults {
      return _defaults
    }
  }
}
