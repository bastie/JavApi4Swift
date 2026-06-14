/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf {

  /// Abstract base class for all Swing UI delegates.
  ///
  /// Every Swing component (`JButton`, `JLabel`, `JPanel`, …) holds a reference
  /// to a `ComponentUI` subclass that is responsible for:
  /// - **Painting** the component (`paint(_:on:)`)
  /// - **Installing** default colours, fonts, borders, and listeners (`installUI(_:)`)
  /// - **Uninstalling** those resources when the L&F changes (`uninstallUI(_:)`)
  /// - Reporting the component's **preferred, minimum, and maximum sizes**
  ///
  /// The active Look & Feel supplies the correct `ComponentUI` subclass for each
  /// component type via `UIManager` / `UIDefaults`.  Components call
  /// `updateUI()` to fetch and install their delegate whenever the L&F changes.
  ///
  /// ## Relationship to LookAndFeel
  ///
  /// ```
  /// UIManager.getLookAndFeel()
  ///   └── getDefaults()["ButtonUI"] → SwiftButtonUI  (a ComponentUI subclass)
  ///
  /// JButton.updateUI()
  ///   └── ui = UIManager.getUI(self)   // fetches SwiftButtonUI
  ///   └── ui.installUI(self)
  /// ```
  ///
  @MainActor
  open class ComponentUI {

    public init() {}

    // -------------------------------------------------------------------------
    // MARK: Lifecycle
    // -------------------------------------------------------------------------

    /// Installs this UI delegate on `component`.
    ///
    /// Called by `JComponent.setUI(_:)`.  Override to set default colours,
    /// fonts, borders, key bindings, and event listeners on the component.
    open func installUI(_ component: javax.swing.JComponent) {}

    /// Uninstalls this UI delegate from `component`.
    ///
    /// Called before a new delegate is installed (L&F change).  Override to
    /// remove listeners and borders that were set in `installUI(_:)`.
    open func uninstallUI(_ component: javax.swing.JComponent) {}

    // -------------------------------------------------------------------------
    // MARK: Painting
    // -------------------------------------------------------------------------

    /// Paints the component.
    ///
    /// Called by `JComponent.paintComponent(_:)`.  The graphics context's
    /// origin is already translated to the component's top-left corner.
    ///
    /// - Parameters:
    ///   - g: The graphics context to paint into.
    ///   - component: The component being painted.
    open func paint(_ g: java.awt.Graphics, on component: javax.swing.JComponent) {}

    /// Paints the component's background before `paint(_:on:)` is called.
    ///
    /// The default implementation fills the component's bounds with
    /// `component.getBackground()` when `component.isOpaque()` returns `true`.
    open func update(_ g: java.awt.Graphics, on component: javax.swing.JComponent) {
      if component.isOpaque() {
        g.setColor(component.getBackground())
        g.fillRect(component.bounds.x, component.bounds.y,
                   component.bounds.width, component.bounds.height)
      }
      paint(g, on: component)
    }

    // -------------------------------------------------------------------------
    // MARK: Size hints
    // -------------------------------------------------------------------------

    /// Returns the preferred size for `component`, or `nil` to let the
    /// component use its own default.
    open func getPreferredSize(of component: javax.swing.JComponent) -> java.awt.Dimension? {
      return nil
    }

    /// Returns the minimum size for `component`, or `nil` to use the default.
    open func getMinimumSize(of component: javax.swing.JComponent) -> java.awt.Dimension? {
      return nil
    }

    /// Returns the maximum size for `component`, or `nil` to use the default.
    open func getMaximumSize(of component: javax.swing.JComponent) -> java.awt.Dimension? {
      return nil
    }

    // -------------------------------------------------------------------------
    // MARK: Hit testing
    // -------------------------------------------------------------------------

    /// Returns `true` if the point `(x, y)` (in the component's coordinate
    /// space) is considered "inside" the component for mouse-event purposes.
    ///
    /// The default implementation delegates to the component's bounds.
    open func contains(_ component: javax.swing.JComponent, x: Int, y: Int) -> Bool {
      return component.bounds.contains(java.awt.Point(x, y))
    }
  }
}
