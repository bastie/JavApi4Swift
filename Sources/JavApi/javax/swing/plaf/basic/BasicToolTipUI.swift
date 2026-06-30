/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.basic {

  /// Default UI delegate for `JToolTip`.
  ///
  /// Paints a filled rectangle with the tooltip text.  The border is a
  /// `LineBorder(infoText)` installed via `installUI()`.
  ///
  /// ## Colours
  ///
  /// | Role | Source |
  /// |---|---|
  /// | Background | `SystemColor.info` (light yellow) |
  /// | Border | `SystemColor.infoText` (via `LineBorder`) |
  /// | Text | `SystemColor.infoText` |
  ///
  /// - Since: Java 1.2 / JFC 1.0
  @MainActor
  open class BasicToolTipUI: javax.swing.plaf.ComponentUI {

    // -------------------------------------------------------------------------
    // MARK: ComponentUI lifecycle
    // -------------------------------------------------------------------------

    override open func installUI(_ component: javax.swing.JComponent) {
      component.setBorder(javax.swing.border.LineBorder(java.awt.SystemColor.infoText))
    }

    override open func uninstallUI(_ component: javax.swing.JComponent) {
      if component.getBorder() is javax.swing.border.LineBorder {
        component.setBorder(nil)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Preferred size
    // -------------------------------------------------------------------------

    override open func getPreferredSize(_ component: javax.swing.JComponent) -> java.awt.Dimension? {
      guard let tip = component as? javax.swing.JToolTip else { return nil }
      let text = tip.getTipText() ?? ""
      guard !text.isEmpty else { return java.awt.Dimension(4, 4) }
      let fm = java.awt.FontMetrics.make(for: component.font)
      let w = fm.stringWidth(text) + 8   // 4px padding each side
      let h = fm.getHeight() + 6         // 3px top + 3px bottom
      return java.awt.Dimension(w, h)
    }

    // -------------------------------------------------------------------------
    // MARK: Painting
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics, _ component: javax.swing.JComponent) {
      guard let tip = component as? javax.swing.JToolTip else { return }
      let text = tip.getTipText() ?? ""
      let w = component.bounds.width
      let h = component.bounds.height

      // Background
      g.setColor(java.awt.SystemColor.info)
      g.fillRect(0, 0, w, h)

      // Text
      guard !text.isEmpty else { return }
      g.setColor(java.awt.SystemColor.infoText)
      let fm = java.awt.FontMetrics.make(for: component.font)
      let textY = (h - fm.getHeight()) / 2 + fm.getAscent()
      g.drawString(text, 4, textY)
    }
  }
}
