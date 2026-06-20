/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.basic {

  /// The Basic Look-and-Feel UI delegate for `JDesktopPane`.
  ///
  /// Fills the desktop background with `SystemColor.desktop` and then
  /// delegates painting of all child `JInternalFrame`s to their own
  /// `paint(_:)` methods via `JComponent.paintChildren(_:)`.
  ///
  /// `JDesktopPane` has no `getUIClassID()` override in the current
  /// implementation, so this delegate must be installed manually or by
  /// registering `"DesktopPaneUI"` in `UIDefaults` / `BasicLookAndFeel`.
  ///
  /// - Since: Java 1.2
  @MainActor
  open class BasicDesktopPaneUI: javax.swing.plaf.ComponentUI {

    // -------------------------------------------------------------------------
    // MARK: ComponentUI factory
    // -------------------------------------------------------------------------

    open class func createUI(_ c: javax.swing.JComponent) -> javax.swing.plaf.ComponentUI {
      return BasicDesktopPaneUI()
    }

    // -------------------------------------------------------------------------
    // MARK: Install / uninstall
    // -------------------------------------------------------------------------

    override open func installUI(_ c: javax.swing.JComponent) {
      // Ensure the desktop has a background colour so it is painted opaque.
      c.setBackground(java.awt.SystemColor.desktop)
      c.setOpaque(true)
    }

    override open func uninstallUI(_ c: javax.swing.JComponent) {
      // Nothing to uninstall — no listeners or resources were registered.
    }

    // -------------------------------------------------------------------------
    // MARK: Paint
    // -------------------------------------------------------------------------

    /// Fills the desktop background.
    ///
    /// Child internal frames are painted by `JComponent.paintChildren(_:)`,
    /// which is called by `JComponent.paint(_:)` after this method returns.
    override open func paint(_ g: java.awt.Graphics, _ c: javax.swing.JComponent) {
      g.setColor(c.getBackground())
      g.fillRect(0, 0, c.bounds.width, c.bounds.height)
    }

    // -------------------------------------------------------------------------
    // MARK: Preferred size
    // -------------------------------------------------------------------------

    /// Returns `nil` — the desktop pane adapts to its parent container.
    override open func getPreferredSize(_ c: javax.swing.JComponent) -> java.awt.Dimension? {
      return nil
    }
  }
}
