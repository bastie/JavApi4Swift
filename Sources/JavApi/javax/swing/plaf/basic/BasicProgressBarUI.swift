/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.basic {

  /// The Basic look-and-feel UI delegate for `JProgressBar`.
  ///
  /// Renders the progress bar as a filled rectangle.  In determinate mode the
  /// fill fraction is `(value - min) / (max - min)`.  In indeterminate mode a
  /// striped pattern is drawn to signal ongoing work.
  ///
  /// The preferred size is font-driven; no hard-coded pixel values are used.
  ///
  /// - Since: Java 1.2
  @MainActor
  open class BasicProgressBarUI: javax.swing.plaf.ComponentUI {

    // -------------------------------------------------------------------------
    // MARK: Preferred size
    // -------------------------------------------------------------------------

    override open func getPreferredSize(_ component: javax.swing.JComponent) -> java.awt.Dimension? {
      guard let bar = component as? javax.swing.JProgressBar else { return nil }
      let fm = java.awt.FontMetrics.make(for: component.font)
      let thick  = fm.getHeight() + 8   // perpendicular dimension
      let length = fm.charWidth("m") * 15   // ~15 character widths
      if bar.getOrientation() == javax.swing.JProgressBar.HORIZONTAL {
        return java.awt.Dimension(length, thick)
      } else {
        return java.awt.Dimension(thick, length)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Paint
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics, _ component: javax.swing.JComponent) {
      guard let bar = component as? javax.swing.JProgressBar else { return }

      let w = component.bounds.width
      let h = component.bounds.height
      let horizontal = bar.getOrientation() == javax.swing.JProgressBar.HORIZONTAL

      // ── Background ─────────────────────────────────────────────────────────
      g.setColor(java.awt.SystemColor.control)
      g.fillRect(0, 0, w, h)

      // ── Progress fill ───────────────────────────────────────────────────────
      if bar.isIndeterminate() {
        // Striped indeterminate pattern
        g.setColor(java.awt.Color(100, 149, 237))   // cornflower blue
        let stripeW = 12
        if horizontal {
          var x = 0
          var toggle = false
          while x < w {
            if toggle { g.fillRect(x, 1, min(stripeW, w - x), h - 2) }
            x += stripeW
            toggle = !toggle
          }
        } else {
          var y = 0
          var toggle = false
          while y < h {
            if toggle { g.fillRect(1, y, w - 2, min(stripeW, h - y)) }
            y += stripeW
            toggle = !toggle
          }
        }
      } else {
        let pct = bar.percentComplete()
        g.setColor(java.awt.Color(52, 152, 219))    // Swing-blue
        if horizontal {
          let fillW = Int(Double(w - 2) * pct)
          if fillW > 0 { g.fillRect(1, 1, fillW, h - 2) }
        } else {
          let fillH = Int(Double(h - 2) * pct)
          if fillH > 0 { g.fillRect(1, h - 1 - fillH, w - 2, fillH) }
        }
      }

      // ── Border ──────────────────────────────────────────────────────────────
      if bar.isBorderPainted() {
        g.setColor(java.awt.SystemColor.controlShadow)
        g.drawLine(0,   0,   w-1, 0)
        g.drawLine(0,   0,   0,   h-1)
        g.drawLine(w-1, 0,   w-1, h-1)
        g.drawLine(0,   h-1, w-1, h-1)
      }

      // ── String overlay ──────────────────────────────────────────────────────
      if bar.isStringPainted() {
        let fm  = java.awt.FontMetrics.make(for: component.font)
        let str = bar.getString()
        let tw  = fm.stringWidth(str)
        let tx  = (w - tw) / 2
        let ty  = fm.getAscent() + (h - fm.getHeight()) / 2
        g.setColor(java.awt.Color.black)
        g.drawString(str, tx, ty)
      }
    }
  }
}
