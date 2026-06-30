/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.knight {

  /// UI delegate for `JRadioButton` in the Knight Look & Feel.
  ///
  /// Renders a knight's shield shape instead of the standard radio circle.
  /// The shield is outlined when unselected and filled when selected.
  ///
  /// - Since: JavApi4Swift / Knight L&F
  @MainActor
  open class KnightRadioButtonUI: javax.swing.plaf.basic.BasicRadioButtonUI {

    private let shieldSize: Int = 13
    private let gap: Int = 4

    override open class func createUI(_ c: javax.swing.JComponent) -> javax.swing.plaf.ComponentUI {
      return KnightRadioButtonUI()
    }

    override open func getPreferredSize(_ component: javax.swing.JComponent) -> java.awt.Dimension? {
      guard let btn = component as? javax.swing.AbstractButton else { return nil }
      let fm = java.awt.FontMetrics.make(for: component.font)
      let w  = shieldSize + gap + fm.stringWidth(btn.getText()) + 4
      let h  = Swift.max(shieldSize, fm.getHeight()) + 4
      return java.awt.Dimension(w, h)
    }

    override open func paint(_ g: java.awt.Graphics, _ component: javax.swing.JComponent) {
      guard let btn = component as? javax.swing.AbstractButton else { return }

      let h  = component.bounds.height
      let sy = (h - shieldSize) / 2   // shield top-y
      let w  = shieldSize

      // Background
      g.setColor(component.getBackground())
      g.fillRect(0, 0, component.bounds.width, h)

      // Shield polygon (5 points):
      //   top-left, top-right, right-waist, bottom-tip, left-waist
      let waistY = sy + w * 2 / 3
      let tipX   = w / 2
      let tipY   = sy + w - 1

      let xs = [0,      w - 1,  w - 1,  tipX,  0     ]
      let ys = [sy,     sy,     waistY, tipY,  waistY]
      let n  = 5

      // Fill background
      g.setColor(java.awt.SystemColor.window)
      g.fillPolygon(xs, ys, n)

      if btn.isSelected() {
        g.setColor(java.awt.SystemColor.controlText)
        g.fillPolygon(xs, ys, n)
      }

      // Outline
      g.setColor(java.awt.SystemColor.controlDkShadow)
      g.drawPolygon(xs, ys, n)

      // Label
      let text = btn.getText()
      if !text.isEmpty {
        let fm  = java.awt.FontMetrics.make(for: component.font)
        let tx  = shieldSize + gap
        let ty  = (h - fm.getHeight()) / 2 + fm.getAscent()
        g.setColor(component.getForeground())
        g.drawString(text, tx, ty)
      }
    }
  }
}
