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

      // Derive the available width from the CGContext clip path — this is always
      // correct even on the first paint before layout has propagated bar.bounds.
      // Fall back to the parent's width, then bar's own bounds as last resort.
      let clipW: Int
      #if canImport(CoreGraphics)
      if let g2d = g as? java.awt.Graphics2D {
        let box = g2d.cgContext.boundingBoxOfClipPath
        if box.width > 0 {
          clipW = Int(box.width)
        } else {
          clipW = bar.parent?.bounds.width ?? bar.bounds.width
        }
      } else {
        clipW = bar.parent?.bounds.width ?? bar.bounds.width
      }
      #else
      clipW = bar.parent?.bounds.width ?? bar.bounds.width
      #endif
      let w = clipW
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
      g.setColor(java.awt.SystemColor.menuText)
      let textY = (h - fm.getHeight()) / 2 + fm.getAscent()
      for (menu, rect) in menuRects {
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
        menuRects.append((menu: menu,
                          rect: java.awt.Rectangle(x, 0, w, h)))
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
