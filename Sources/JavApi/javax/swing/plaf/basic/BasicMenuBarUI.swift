/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.basic {

  /// Default UI delegate for `JMenuBar`.
  ///
  /// Draws a horizontal strip containing the label of each `JMenu`.
  /// Layout mirrors the approach learned from `_X11MenuBar`:
  ///
  /// - A cached array of hit-rectangles (one per menu title) is rebuilt
  ///   whenever `installUI` is called or the bar is invalidated.
  /// - Each title is padded by `titlePadX` pixels on each side.
  /// - The bar has a 1-pixel bottom border in `controlShadow` colour.
  ///
  /// ## Overlay compatibility
  ///
  /// `BasicMenuBarUI` only paints the bar itself.  Drop-down overlays
  /// (`JPopupMenu`) will be rendered in a separate `POPUP_LAYER` — they
  /// are **not** clipped to the menu bar rectangle, avoiding the X11
  /// clipping problem where popups had to be separate native windows.
  ///
  /// ## Colours used
  ///
  /// | Role | Source |
  /// |---|---|
  /// | Bar background | `java.awt.SystemColor.menu` |
  /// | Title text | `java.awt.SystemColor.menuText` |
  /// | Bottom border | `java.awt.SystemColor.controlShadow` |
  ///
  @MainActor
  open class BasicMenuBarUI: javax.swing.plaf.ComponentUI {

    // -------------------------------------------------------------------------
    // MARK: Layout constants
    // -------------------------------------------------------------------------

    /// Horizontal padding on each side of a menu title label.
    public static let titlePadX: Int = 8

    /// Font used to measure and draw menu titles.
    private let font = java.awt.Font("Dialog", java.awt.Font.PLAIN, 12)

    // -------------------------------------------------------------------------
    // MARK: Cached hit rectangles
    // -------------------------------------------------------------------------

    /// One rect per menu — rebuilt in `layoutMenuTitles`.
    private(set) var menuRects: [(menu: javax.swing.JMenu, rect: java.awt.Rectangle)] = []

    // -------------------------------------------------------------------------
    // MARK: ComponentUI lifecycle
    // -------------------------------------------------------------------------

    override open func installUI(_ component: javax.swing.JComponent) {
      // Colours are applied directly from SystemColor in paint() —
      // Component does not expose setBackground/setForeground publicly.
    }

    override open func uninstallUI(_ component: javax.swing.JComponent) {
      menuRects.removeAll()
    }

    // -------------------------------------------------------------------------
    // MARK: Preferred size
    // -------------------------------------------------------------------------

    override open func getPreferredSize(of component: javax.swing.JComponent) -> java.awt.Dimension? {
      guard let bar = component as? javax.swing.JMenuBar else { return nil }
      let fm   = java.awt.FontMetrics.make(for: font)
      let totalWidth = bar.getMenus().reduce(0) { acc, menu in
        acc + fm.stringWidth(menu.getText()) + Self.titlePadX * 2
      }
      return java.awt.Dimension(totalWidth, javax.swing.JMenuBar.defaultHeight)
    }

    // -------------------------------------------------------------------------
    // MARK: Painting
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics, on component: javax.swing.JComponent) {
      guard let bar = component as? javax.swing.JMenuBar else { return }

      // bar.bounds is now set correctly by JRootPane.doLayout() before paint is called.
      // The graphics context origin is already translated to bar's position by paintChildren.
      let w = bar.bounds.width
      let h = javax.swing.JMenuBar.defaultHeight
      let fm = java.awt.FontMetrics.make(for: font)

      // Rebuild hit rects (width may have changed)
      layoutMenuTitles(bar: bar, fontMetrics: fm)

      // Background
      g.setColor(java.awt.SystemColor.menu)
      g.fillRect(0, 0, w, h)

      // Bottom border
      g.setColor(java.awt.SystemColor.controlShadow)
      g.drawLine(0, h - 1, w, h - 1)

      // Menu titles
      let textY = (h - fm.getHeight()) / 2 + fm.getAscent()
      for (menu, rect) in menuRects {
        if menu.isSelected() {
          // Highlight selected menu title
          g.setColor(java.awt.SystemColor.textHighlight)
          g.fillRect(rect.x, 0, rect.width, h - 1)
          g.setColor(java.awt.SystemColor.textHighlightText)
        } else {
          g.setColor(java.awt.SystemColor.menuText)
        }
        g.drawString(menu.getText(), rect.x + Self.titlePadX, textY)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Layout helper
    // -------------------------------------------------------------------------

    /// Recomputes `menuRects` for the current set of menus.
    /// Called from `paint` — stays in sync without needing explicit invalidation.
    private func layoutMenuTitles(bar: javax.swing.JMenuBar,
                                  fontMetrics fm: java.awt.FontMetrics) {
      menuRects.removeAll()
      let h = javax.swing.JMenuBar.defaultHeight
      var x = 0
      for menu in bar.getMenus() {
        let textW = fm.stringWidth(menu.getText())
        let w     = textW + Self.titlePadX * 2
        let rect  = java.awt.Rectangle(x, 0, w, h)
        menuRects.append((menu: menu, rect: rect))
        // Also set bounds on the JMenu component so _AWTHitTest.find() can locate it
        menu.bounds = rect
        x += w
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Hit test (for future mouse handling)
    // -------------------------------------------------------------------------

    /// Returns the `JMenu` whose title rect contains the point `(x, y)`,
    /// or `nil` if no menu is hit.  `y` must be within `[0, defaultHeight)`.
    public func menu(at x: Int, y: Int) -> javax.swing.JMenu? {
      guard y >= 0 && y < javax.swing.JMenuBar.defaultHeight else { return nil }
      return menuRects.first { $0.rect.contains(java.awt.Point(x, y)) }?.menu
    }
  }
}
