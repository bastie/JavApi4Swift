/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.basic {

  /// The Basic Look-and-Feel UI delegate for `JScrollBar`.
  ///
  /// Paints a track, thumb, and two arrow buttons.  The same geometry helpers
  /// (`thumbRect`, `decrementButtonRect`, `incrementButtonRect`) defined on
  /// `JScrollBar` are reused here so that hit-testing and painting stay in sync.
  ///
  /// The outer border is a `LineBorder(controlDkShadow)` installed in
  /// `installUI()` and removed in `uninstallUI()`.
  ///
  /// - Since: Java 1.2
  @MainActor
  open class BasicScrollBarUI: javax.swing.plaf.ComponentUI {

    // -------------------------------------------------------------------------
    // MARK: ComponentUI factory
    // -------------------------------------------------------------------------

    open class func createUI(_ c: javax.swing.JComponent) -> javax.swing.plaf.ComponentUI {
      return BasicScrollBarUI()
    }

    // -------------------------------------------------------------------------
    // MARK: ComponentUI lifecycle
    // -------------------------------------------------------------------------

    override open func installUI(_ component: javax.swing.JComponent) {
      component.setBorder(javax.swing.border.LineBorder(java.awt.SystemColor.controlDkShadow))
    }

    override open func uninstallUI(_ component: javax.swing.JComponent) {
      if component.getBorder() is javax.swing.border.LineBorder {
        component.setBorder(nil)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Paint
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics, _ c: javax.swing.JComponent) {
      guard let bar = c as? javax.swing.JScrollBar else { return }

      // g is already translated to (0,0) of bar — use local coordinates
      let w = bar.bounds.width, h = bar.bounds.height

      // Track
      g.setColor(java.awt.SystemColor.scrollbar)
      g.fillRect(0, 0, w, h)

      // Thumb
      let tr = bar.thumbRect()
      g.setColor(java.awt.SystemColor.control)
      g.fillRect(tr.x, tr.y, tr.width, tr.height)
      g.setColor(java.awt.SystemColor.controlShadow)
      g.drawLine(tr.x,              tr.y,               tr.x + tr.width - 1, tr.y)
      g.drawLine(tr.x,              tr.y,               tr.x,                tr.y + tr.height - 1)
      g.drawLine(tr.x + tr.width-1, tr.y,               tr.x + tr.width - 1, tr.y + tr.height - 1)
      g.drawLine(tr.x,              tr.y + tr.height-1,  tr.x + tr.width - 1, tr.y + tr.height - 1)

      // Arrow buttons
      bar._drawArrow(g, rect: bar.decrementButtonRect(), decrement: true)
      bar._drawArrow(g, rect: bar.incrementButtonRect(), decrement: false)
    }

    // -------------------------------------------------------------------------
    // MARK: Preferred size
    // -------------------------------------------------------------------------

    override open func getPreferredSize(_ c: javax.swing.JComponent) -> java.awt.Dimension {
      // Scrollbar thickness: roughly one font line height; length unconstrained (0).
      let fm    = java.awt.FontMetrics.make(for: c.font)
      let thick = fm.getHeight()
      guard let bar = c as? javax.swing.JScrollBar else {
        return java.awt.Dimension(thick, thick)
      }
      return bar.getOrientation() == javax.swing.JScrollBar.VERTICAL
        ? java.awt.Dimension(thick, 0)
        : java.awt.Dimension(0, thick)
    }
  }
}
