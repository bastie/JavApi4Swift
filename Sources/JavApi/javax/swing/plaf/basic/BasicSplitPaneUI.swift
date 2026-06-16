/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.basic {

  /// Default UI delegate for `JSplitPane`.
  ///
  /// Paints the divider bar between the two child components and clips each
  /// child to its allocated bounds.  Mouse dragging is handled by `JSplitPane`
  /// itself.
  ///
  /// - Since: Java 1.1
  @MainActor
  open class BasicSplitPaneUI: javax.swing.plaf.ComponentUI {

    // -------------------------------------------------------------------------
    // MARK: Factory
    // -------------------------------------------------------------------------

    open class func createUI(_ c: javax.swing.JComponent) -> javax.swing.plaf.ComponentUI {
      return BasicSplitPaneUI()
    }

    // -------------------------------------------------------------------------
    // MARK: Preferred size
    // -------------------------------------------------------------------------

    override open func getPreferredSize(_ component: javax.swing.JComponent) -> java.awt.Dimension? {
      guard let sp = component as? javax.swing.JSplitPane else { return nil }
      let ls = sp.getLeftComponent()?.getPreferredSize()  ?? java.awt.Dimension(100, 100)
      let rs = sp.getRightComponent()?.getPreferredSize() ?? java.awt.Dimension(100, 100)
      let d  = sp.getDividerSize()
      if sp.isHorizontal {
        return java.awt.Dimension(ls.width + d + rs.width, max(ls.height, rs.height))
      } else {
        return java.awt.Dimension(max(ls.width, rs.width), ls.height + d + rs.height)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Paint
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics, on component: javax.swing.JComponent) {
      guard let sp = component as? javax.swing.JSplitPane else { return }

      sp.doLayout()

      let w   = sp.bounds.width
      let h   = sp.bounds.height
      let pos = sp.effectiveDividerLocation()
      let d   = sp.getDividerSize()

      // ── Background ────────────────────────────────────────────────────────
      g.setColor(java.awt.Color.lightGray)
      g.fillRect(0, 0, w, h)

      // ── Left / top child ──────────────────────────────────────────────────
      if let left = sp.getLeftComponent() {
        g.save()
        g.clipRect(left.bounds.x, left.bounds.y,
                   left.bounds.width, left.bounds.height)
        g.translate(left.bounds.x, left.bounds.y)
        left.paint(g)
        g.restore()
      }

      // ── Right / bottom child ──────────────────────────────────────────────
      if let right = sp.getRightComponent() {
        g.save()
        g.clipRect(right.bounds.x, right.bounds.y,
                   right.bounds.width, right.bounds.height)
        g.translate(right.bounds.x, right.bounds.y)
        right.paint(g)
        g.restore()
      }

      // ── Divider bar ───────────────────────────────────────────────────────
      let dividerColor = java.awt.Color(180, 180, 180)
      g.setColor(dividerColor)
      if sp.isHorizontal {
        g.fillRect(pos, 0, d, h)
        // Subtle 3-D edge lines
        g.setColor(java.awt.Color(220, 220, 220))
        g.drawLine(pos, 0, pos, h - 1)
        g.setColor(java.awt.Color(140, 140, 140))
        g.drawLine(pos + d - 1, 0, pos + d - 1, h - 1)
        // Grip dots in the centre
        _drawGrip(g, x: pos + d / 2 - 1, y: h / 2, vertical: true)
      } else {
        g.fillRect(0, pos, w, d)
        g.setColor(java.awt.Color(220, 220, 220))
        g.drawLine(0, pos, w - 1, pos)
        g.setColor(java.awt.Color(140, 140, 140))
        g.drawLine(0, pos + d - 1, w - 1, pos + d - 1)
        _drawGrip(g, x: w / 2, y: pos + d / 2 - 1, vertical: false)
      }
    }

    /// Draws three small grip dots centred around `(x, y)`.
    private func _drawGrip(_ g: java.awt.Graphics, x: Int, y: Int, vertical: Bool) {
      g.setColor(java.awt.Color(100, 100, 100))
      let offsets = [-4, 0, 4]
      for off in offsets {
        let px = vertical ? x : x + off
        let py = vertical ? y + off : y
        g.fillRect(px, py, 2, 2)
      }
    }
  }
}
