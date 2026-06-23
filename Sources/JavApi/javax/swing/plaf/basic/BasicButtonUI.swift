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
    // MARK: Install / Uninstall
    // -------------------------------------------------------------------------

    override open func installUI(_ component: javax.swing.JComponent) {
      // Install the default button border only if the application has not set
      // a custom one (i.e. the border is still nil or already a ButtonBorder).
      if component.getBorder() == nil
          || component.getBorder() is javax.swing.border.ButtonBorder {
        component.setBorder(javax.swing.border.ButtonBorder())
      }
    }

    override open func uninstallUI(_ component: javax.swing.JComponent) {
      if component.getBorder() is javax.swing.border.ButtonBorder {
        component.setBorder(nil)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Preferred size
    // -------------------------------------------------------------------------

    override open func getPreferredSize(_ component: javax.swing.JComponent) -> java.awt.Dimension? {
      guard let btn = component as? javax.swing.AbstractButton else { return nil }
      let fm = java.awt.FontMetrics.make(for: component.font)
      let w  = fm.stringWidth(btn.getText()) + 20  // 10px padding each side
      let h  = fm.getHeight() + 10                 // 5px padding top/bottom
      return java.awt.Dimension(w, h)
    }

    // -------------------------------------------------------------------------
    // MARK: Painting
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics, _ component: javax.swing.JComponent) {
      guard let btn = component as? javax.swing.AbstractButton else { return }

      let w = component.bounds.width
      let h = component.bounds.height

      // Background — always derived from SystemColor.control so it works in
      // both light and dark mode.  controlShadow maps to .separatorColor on
      // macOS which is near-black in light mode, so we darken/lighten control
      // ourselves instead of relying on the shadow tokens.
      let base = java.awt.SystemColor.control
      let bg: java.awt.Color
      if btn.getModel().isPressed() {
        // Darken by 15 % (clamped to 0)
        bg = java.awt.Color(
          Swift.max(0, base.getRed()   - 38),
          Swift.max(0, base.getGreen() - 38),
          Swift.max(0, base.getBlue()  - 38))
      } else if btn.getModel().isRollover() {
        // Lighten by ~8 % (clamped to 255)
        bg = java.awt.Color(
          Swift.min(255, base.getRed()   + 20),
          Swift.min(255, base.getGreen() + 20),
          Swift.min(255, base.getBlue()  + 20))
      } else {
        bg = base
      }
      g.setColor(bg)
      g.fillRect(0, 0, w, h)

      // Border is painted by JComponent.paint() via getBorder().paintBorder(...)
      // (installed as ButtonBorder in installUI).

      // Icon + Label
      let pressOffset = btn.getModel().isPressed() ? 1 : 0
      let icon = btn.getIcon()
      let text = btn.getText()
      let pad  = 4

      if let icon, text.isEmpty {
        // Icon only — centred
        let ix = (w - icon.getIconWidth())  / 2 + pressOffset
        let iy = (h - icon.getIconHeight()) / 2 + pressOffset
        icon.paintIcon(btn, g, ix, iy)
      } else if let icon {
        // Icon left, text right
        let iw = icon.getIconWidth()
        let ih = icon.getIconHeight()
        let fm = java.awt.FontMetrics.make(for: component.font)
        let tw = fm.stringWidth(text)
        let totalW = iw + pad + tw
        let ix = (w - totalW) / 2 + pressOffset
        let iy = (h - ih) / 2 + pressOffset
        icon.paintIcon(btn, g, ix, iy)
        let tx = ix + iw + pad
        let ty = (h - fm.getHeight()) / 2 + fm.getAscent() + pressOffset
        g.setColor(component.getForeground())
        g.drawString(text, tx, ty)
      } else if !text.isEmpty {
        // Text only
        let fm = java.awt.FontMetrics.make(for: component.font)
        let tw = fm.stringWidth(text)
        let tx = (w - tw) / 2 + pressOffset
        let ty = (h - fm.getHeight()) / 2 + fm.getAscent() + pressOffset
        g.setColor(component.getForeground())
        g.drawString(text, tx, ty)
      }
    }
  }
}
