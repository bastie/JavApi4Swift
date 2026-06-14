/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.basic {

  /// Default UI delegate for `JButton`.
  ///
  /// Paints a simple raised/pressed rectangle with the button label centred
  /// inside.  Uses `SystemColor` values so the look adapts to light/dark mode.
  ///
  /// ## Visual states
  ///
  /// | State | Background |
  /// |---|---|
  /// | Normal | `SystemColor.control` |
  /// | Rollover | `SystemColor.control` lightened |
  /// | Pressed | `SystemColor.controlShadow` |
  ///
  @MainActor
  open class BasicButtonUI: javax.swing.plaf.ComponentUI {

    // -------------------------------------------------------------------------
    // MARK: Preferred size
    // -------------------------------------------------------------------------

    override open func getPreferredSize(of component: javax.swing.JComponent) -> java.awt.Dimension? {
      guard let btn = component as? javax.swing.JButton else { return nil }
      let fm = java.awt.FontMetrics.make(for: component.font)
      let w  = fm.stringWidth(btn.getText()) + 20  // 10px padding each side
      let h  = fm.getHeight() + 10                 // 5px padding top/bottom
      return java.awt.Dimension(w, h)
    }

    // -------------------------------------------------------------------------
    // MARK: Painting
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics, on component: javax.swing.JComponent) {
      guard let btn = component as? javax.swing.JButton else { return }

      let w = component.bounds.width
      let h = component.bounds.height

      // Background
      let bg: java.awt.Color
      if btn.isPressed {
        bg = java.awt.SystemColor.controlShadow
      } else if btn.isRollover {
        // Slightly lighter than normal control colour
        let c = java.awt.SystemColor.control
        bg = java.awt.Color(
          min(255, c.getRed()   + 20),
          min(255, c.getGreen() + 20),
          min(255, c.getBlue()  + 20))
      } else {
        bg = java.awt.SystemColor.control
      }
      g.setColor(bg)
      g.fillRect(0, 0, w, h)

      // Border — simple 3-D effect
      if btn.isPressed {
        // Inset shadow
        g.setColor(java.awt.SystemColor.controlDkShadow)
        g.drawLine(0, 0, w - 1, 0)
        g.drawLine(0, 0, 0, h - 1)
        g.setColor(java.awt.SystemColor.controlHighlight)
        g.drawLine(w - 1, 0, w - 1, h - 1)
        g.drawLine(0, h - 1, w - 1, h - 1)
      } else {
        // Raised border
        g.setColor(java.awt.SystemColor.controlHighlight)
        g.drawLine(0, 0, w - 2, 0)
        g.drawLine(0, 0, 0, h - 2)
        g.setColor(java.awt.SystemColor.controlDkShadow)
        g.drawLine(w - 1, 0, w - 1, h - 1)
        g.drawLine(0, h - 1, w - 1, h - 1)
        g.setColor(java.awt.SystemColor.controlShadow)
        g.drawLine(w - 2, 1, w - 2, h - 2)
        g.drawLine(1, h - 2, w - 2, h - 2)
      }

      // Label
      let text = btn.getText()
      guard !text.isEmpty else { return }
      let fm  = java.awt.FontMetrics.make(for: component.font)
      let tw  = fm.stringWidth(text)
      let th  = fm.getHeight()
      let tx  = (w - tw) / 2 + (btn.isPressed ? 1 : 0)
      let ty  = (h - th) / 2 + fm.getAscent() + (btn.isPressed ? 1 : 0)
      g.setColor(component.getForeground())
      g.drawString(text, tx, ty)
    }
  }
}
