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
  final public class KnightRadioButtonUI: javax.swing.plaf.basic.BasicRadioButtonUI {

    private let shieldSize: Int = 13
    private let gap: Int = 4

    override public class func createUI(_ c: javax.swing.JComponent) -> javax.swing.plaf.ComponentUI {
      return KnightRadioButtonUI()
    }

    override public func getPreferredSize(_ component: javax.swing.JComponent) -> java.awt.Dimension? {
      guard let btn = component as? javax.swing.AbstractButton else { return nil }
      let fm = java.awt.FontMetrics.make(for: component.font)
      let w  = shieldSize + gap + fm.stringWidth(btn.getText()) + 4
      let h  = Swift.max(shieldSize, fm.getHeight()) + 4
      return java.awt.Dimension(w, h)
    }

    override public func paint(_ g: java.awt.Graphics, _ component: javax.swing.JComponent) {
      guard let btn = component as? javax.swing.AbstractButton else { return }

      let h  = component.bounds.height
      let sy = (h - shieldSize) / 2   // shield top-y
      let w  = shieldSize

      // Background
      g.setColor(component.getBackground())
      g.fillRect(0, 0, component.bounds.width, h)
      // FIXME: nur nötig bis alle Komponenten umgestellt sind
      if true {
        g.setColor(KnightColor.DARK_BLACK)
        g.fillRect(0, 0, component.bounds.width, h)
      }

      // Shield polygon (5 points):
      //   top-left, top-right, right-waist, bottom-tip, left-waist
      let waistY = sy + w * 2 / 3
      let tipX   = w / 2
      let tipY   = sy + w - 1

      let xs = [0,      w - 1,  w - 1,  tipX,  0     ]
      let ys = [sy,     sy,     waistY, tipY,  waistY]
      let n  = 5

      // Fill background
      g.setColor(KnightColor.DARK_BLACK)
      if btn.isSelected() {
        g.setColor(KnightColor.DARK_RED)
        g.fillPolygon(xs, ys, n)
      }

      // Outline
      g.setColor(KnightColor.DARK_RED)
      if btn.isSelected() {
        g.setColor(KnightColor.DARK_BLACK)
      }
      g.drawPolygon(xs, ys, n)

      // Label
      let text = btn.getText()
      if !text.isEmpty {
        let fm  = java.awt.FontMetrics.make(for: component.font)
        let tx  = shieldSize + gap
        let ty  = (h - fm.getHeight()) / 2 + fm.getAscent()
        if btn.isSelected() {
          g.setColor(KnightColor.ALL_WHITE)
        }
        else {
          g.setColor(KnightColor.MOSTLY_WHITE)
        }
        g.drawString(text, tx, ty)
      }
    }
  }
}
