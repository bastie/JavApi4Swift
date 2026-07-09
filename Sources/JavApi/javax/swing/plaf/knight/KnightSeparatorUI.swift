/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.knight {

  /// Default UI delegate for `JSeparator`.
  ///
  /// Paints a single line using `SystemColor.controlShadow` (horizontal or
  /// vertical depending on the separator's orientation).  The L&F can replace
  /// this delegate by installing a different `SeparatorUI`.
  ///
  @MainActor
  final public class KnightSeparatorUI: javax.swing.plaf.ComponentUI {
    
    private let SEPARATOR_WIDTH : Int = 2

    override public func getPreferredSize(_ component: javax.swing.JComponent) -> java.awt.Dimension? {
      guard let sep = component as? javax.swing.JSeparator else { return nil }
      if sep.getOrientation() == javax.swing.JSeparator.VERTICAL {
        return java.awt.Dimension(SEPARATOR_WIDTH, 0)
      }
      else {
        return java.awt.Dimension(0, SEPARATOR_WIDTH)
      }
    }

    override public func paint(_ g: java.awt.Graphics, _ component: javax.swing.JComponent) {
      guard let sep = component as? javax.swing.JSeparator else { return }
      let width = sep.bounds.width
      let height = sep.bounds.height

      // FIXME: nur nötig bis alle Komponenten umgestellt sind
      if true {
        g.setColor(KnightColor.DARK_BLACK)
        g.fillRect(0, 0, width, height)
      }
      
      g.setColor(KnightColor.DARK_RED)
      if sep.getOrientation() == javax.swing.JSeparator.VERTICAL {
        let cx = width / SEPARATOR_WIDTH
        g.drawLine(cx, SEPARATOR_WIDTH, cx, height - SEPARATOR_WIDTH)
      }
      else {
        let cy = height / SEPARATOR_WIDTH
        g.drawLine(SEPARATOR_WIDTH, cy, width - SEPARATOR_WIDTH, cy)
      }
    }
  }
}
