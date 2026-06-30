/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.basic {

  /// UI delegate for `JCheckBox`.
  ///
  /// Renders a small square box to the left of the label, with a check mark
  /// (✓) drawn inside when the button is selected.
  ///
  /// - Since: Java 1.2
  @MainActor
  open class BasicCheckBoxUI: javax.swing.plaf.basic.BasicToggleButtonUI {

    /// Size of the check box square in pixels.
    private let boxSize: Int = 13
    /// Gap between box and label.
    private let gap: Int = 4

    override open class func createUI(_ c: javax.swing.JComponent) -> javax.swing.plaf.ComponentUI {
      return BasicCheckBoxUI()
    }

    // CheckBox draws its own box outline in paint() — no ButtonBorder wanted.
    override open func installUI(_ component: javax.swing.JComponent) {}
    override open func uninstallUI(_ component: javax.swing.JComponent) {}

    override open func getPreferredSize(_ component: javax.swing.JComponent) -> java.awt.Dimension? {
      guard let btn = component as? javax.swing.AbstractButton else { return nil }
      let fm = java.awt.FontMetrics.make(for: component.font)
      let w  = boxSize + gap + fm.stringWidth(btn.getText()) + 4
      let h  = Swift.max(boxSize, fm.getHeight()) + 4
      return java.awt.Dimension(w, h)
    }

    override open func paint(_ g: java.awt.Graphics, _ component: javax.swing.JComponent) {
      guard let btn = component as? javax.swing.AbstractButton else { return }

      let h   = component.bounds.height
      let by  = (h - boxSize) / 2   // box top-y (centred vertically)

      // Background
      g.setColor(component.getBackground())
      g.fillRect(0, 0, component.bounds.width, h)

      // Box outline
      g.setColor(java.awt.SystemColor.controlDkShadow)
      g.drawLine(0,           by,            boxSize - 1, by)
      g.drawLine(0,           by,            0,           by + boxSize - 1)
      g.drawLine(boxSize - 1, by,            boxSize - 1, by + boxSize - 1)
      g.drawLine(0,           by + boxSize - 1, boxSize - 1, by + boxSize - 1)

      // Box interior
      g.setColor(java.awt.SystemColor.window)
      g.fillRect(1, by + 1, boxSize - 2, boxSize - 2)

      // Check mark when selected
      if btn.isSelected() {
        g.setColor(java.awt.SystemColor.controlText)
        // Draw a simple ✓ with three line segments
        let cx = 2, cy = by + 3
        g.drawLine(cx,     cy + 3, cx + 3, cy + 6)
        g.drawLine(cx + 3, cy + 6, cx + 8, cy)
        // Thicken
        g.drawLine(cx,     cy + 4, cx + 3, cy + 7)
        g.drawLine(cx + 3, cy + 7, cx + 8, cy + 1)
      }

      // Label
      let text = btn.getText()
      if !text.isEmpty {
        let fm   = java.awt.FontMetrics.make(for: component.font)
        let tx   = boxSize + gap
        let ty   = (h - fm.getHeight()) / 2 + fm.getAscent()
        g.setColor(component.getForeground())
        g.drawString(text, tx, ty)
      }
    }
  }
}
