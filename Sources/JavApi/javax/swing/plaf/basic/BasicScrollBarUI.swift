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
    // MARK: Paint
    // -------------------------------------------------------------------------

    open func paint(_ g: java.awt.Graphics, _ c: javax.swing.JComponent) {
      guard let bar = c as? javax.swing.JScrollBar else { return }

      let x = bar.bounds.x, y = bar.bounds.y, w = bar.bounds.width, h = bar.bounds.height

      // Track
      g.setColor(java.awt.SystemColor.scrollbar)
      g.fillRect(x, y, w, h)

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

      // Outer border
      g.setColor(java.awt.SystemColor.controlDkShadow)
      g.drawLine(x,     y,     x+w-1, y)
      g.drawLine(x,     y,     x,     y+h-1)
      g.drawLine(x+w-1, y,     x+w-1, y+h-1)
      g.drawLine(x,     y+h-1, x+w-1, y+h-1)
    }

    // -------------------------------------------------------------------------
    // MARK: Preferred size
    // -------------------------------------------------------------------------

    override open func getPreferredSize(_ c: javax.swing.JComponent) -> java.awt.Dimension {
      guard let bar = c as? javax.swing.JScrollBar else {
        return java.awt.Dimension(16, 100)
      }
      return bar.getOrientation() == javax.swing.JScrollBar.VERTICAL
        ? java.awt.Dimension(16, 100)
        : java.awt.Dimension(100, 16)
    }
  }
}
