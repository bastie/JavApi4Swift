/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.basic {

  /// UI delegate for `JRadioButton`.
  ///
  /// Renders a circle to the left of the label, with a filled inner dot when
  /// the button is selected.
  ///
  /// - Since: Java 1.2
  @MainActor
  open class BasicRadioButtonUI: javax.swing.plaf.basic.BasicToggleButtonUI {

    /// Diameter of the radio circle in pixels.
    private let circleSize: Int = 13
    /// Gap between circle and label.
    private let gap: Int = 4

    override open class func createUI(_ c: javax.swing.JComponent) -> javax.swing.plaf.ComponentUI {
      return BasicRadioButtonUI()
    }

    override open func getPreferredSize(_ component: javax.swing.JComponent) -> java.awt.Dimension? {
      guard let btn = component as? javax.swing.AbstractButton else { return nil }
      let fm = java.awt.FontMetrics.make(for: component.font)
      let w  = circleSize + gap + fm.stringWidth(btn.getText()) + 4
      let h  = Swift.max(circleSize, fm.getHeight()) + 4
      return java.awt.Dimension(w, h)
    }

    override open func paint(_ g: java.awt.Graphics, on component: javax.swing.JComponent) {
      guard let btn = component as? javax.swing.AbstractButton else { return }

      let h   = component.bounds.height
      let cy  = (h - circleSize) / 2   // circle top-y

      // Background
      g.setColor(component.getBackground())
      g.fillRect(0, 0, component.bounds.width, h)

      // Outer circle (approximated with drawOval)
      g.setColor(java.awt.SystemColor.controlDkShadow)
      g.drawOval(0, cy, circleSize - 1, circleSize - 1)

      // Inner white fill
      g.setColor(java.awt.SystemColor.window)
      g.fillOval(1, cy + 1, circleSize - 3, circleSize - 3)

      // Selection dot
      if btn.isSelected() {
        g.setColor(java.awt.SystemColor.controlText)
        let dotInset = 3
        g.fillOval(dotInset, cy + dotInset,
                   circleSize - 2 * dotInset - 1,
                   circleSize - 2 * dotInset - 1)
      }

      // Label
      let text = btn.getText()
      if !text.isEmpty {
        let fm   = java.awt.FontMetrics.make(for: component.font)
        let tx   = circleSize + gap
        let ty   = (h - fm.getHeight()) / 2 + fm.getAscent()
        g.setColor(component.getForeground())
        g.drawString(text, tx, ty)
      }
    }
  }
}
