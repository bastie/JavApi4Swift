/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.knight {

  /// UI delegate for `JRadioButtonMenuItem` in the Knight Look & Feel.
  ///
  /// Instead of the standard radio circle, a knight's **shield** shape is
  /// drawn as the selection indicator.  The shield is outlined when the item
  /// is unselected and filled when selected.
  ///
  /// ## Shield shape (normalised, 6 points)
  ///
  /// ```
  ///   0---1        top-left, top-right  (flat top edge)
  ///   |   |
  ///   2   3        left & right waist
  ///    \ /
  ///     4          bottom tip (point)
  /// ```
  ///
  /// ## Layout
  ///
  /// ```
  /// |<-- padX -->|[shield]<-- indicatorGap -->|  Label text  |<-- padX -->|
  /// ```
  ///
  /// - Since: JavApi4Swift / Knight L&F
  @MainActor
  open class KnightRadioButtonMenuItemUI: javax.swing.plaf.basic.BasicMenuItemUI {

    /// Width/height of the shield bounding box (derived from font cap-height).
    private var _shieldSize: Int = 13

    override open class func createUI(_ c: javax.swing.JComponent) -> javax.swing.plaf.ComponentUI {
      return KnightRadioButtonMenuItemUI()
    }

    // -------------------------------------------------------------------------
    // MARK: Indicator geometry
    // -------------------------------------------------------------------------

    override open func indicatorWidth() -> Int { _shieldSize }

    private func updateShieldSize(for component: javax.swing.JComponent) {
      let fm = java.awt.FontMetrics.make(for: component.font)
      _shieldSize = fm.getAscent()
    }

    // -------------------------------------------------------------------------
    // MARK: Preferred size
    // -------------------------------------------------------------------------

    override open func getPreferredSize(_ component: javax.swing.JComponent) -> java.awt.Dimension? {
      updateShieldSize(for: component)
      return super.getPreferredSize(component)
    }

    // -------------------------------------------------------------------------
    // MARK: Paint
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics, _ component: javax.swing.JComponent) {
      updateShieldSize(for: component)
      super.paint(g, component)
    }

    /// Draws a knight's shield.  Outlined when unselected, filled when selected.
    ///
    /// Shield polygon (6 points, within `rect`):
    /// - Top edge: full width, flat
    /// - Sides taper inward at ~2/3 height
    /// - Bottom: single point at horizontal centre
    override open func paintIndicator(_ g: java.awt.Graphics,
                                      in rect: java.awt.Rectangle,
                                      selected: Bool) {
      let x = rect.x
      let y = rect.y
      let w = rect.width
      let h = rect.height

      // Shield outline polygon — 5 points:
      //   top-left (x, y)
      //   top-right (x+w-1, y)
      //   right-waist (x+w-1, y + h*2/3)
      //   bottom-tip (x + w/2, y + h - 1)
      //   left-waist (x, y + h*2/3)
      let waistY = y + h * 2 / 3
      let tipX   = x + w / 2
      let tipY   = y + h - 1

      let xs = [x,       x + w - 1, x + w - 1, tipX,  x      ]
      let ys = [y,       y,          waistY,    tipY,  waistY ]
      let n  = 5

      // Fill background (always light so selected dot is visible)
      g.setColor(java.awt.SystemColor.window)
      g.fillPolygon(xs, ys, n)

      if selected {
        // Fill with accent colour when selected
        g.setColor(java.awt.SystemColor.controlText)
        g.fillPolygon(xs, ys, n)
      }

      // Outline
      g.setColor(java.awt.SystemColor.controlDkShadow)
      g.drawPolygon(xs, ys, n)
    }
  }
}
