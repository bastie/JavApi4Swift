/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.basic {

  /// Default UI delegate for `JSeparator`.
  ///
  /// Paints a single line using `SystemColor.controlShadow` (horizontal or
  /// vertical depending on the separator's orientation).  The L&F can replace
  /// this delegate by installing a different `SeparatorUI`.
  ///
  @MainActor
  open class BasicSeparatorUI: javax.swing.plaf.ComponentUI {

    override open func getPreferredSize(_ component: javax.swing.JComponent) -> java.awt.Dimension? {
      guard let sep = component as? javax.swing.JSeparator else { return nil }
      if sep.getOrientation() == javax.swing.JSeparator.VERTICAL {
        return java.awt.Dimension(2, 0)
      } else {
        return java.awt.Dimension(0, 2)
      }
    }

    override open func paint(_ g: java.awt.Graphics, on component: javax.swing.JComponent) {
      guard let sep = component as? javax.swing.JSeparator else { return }
      let w = component.bounds.width
      let h = component.bounds.height

      g.setColor(java.awt.SystemColor.controlShadow)
      if sep.getOrientation() == javax.swing.JSeparator.VERTICAL {
        let cx = w / 2
        g.drawLine(cx, 2, cx, h - 2)
      } else {
        let cy = h / 2
        g.drawLine(2, cy, w - 2, cy)
      }
    }
  }
}
