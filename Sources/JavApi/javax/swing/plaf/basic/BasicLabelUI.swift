/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.basic {

  /// Default UI delegate for `JLabel`.
  ///
  /// Draws the label text in the component foreground colour, aligned
  /// according to `JLabel.getHorizontalAlignment()` and
  /// `JLabel.getVerticalAlignment()`.  The font is taken from the component's
  /// `font` property (defaults to `"Dialog" PLAIN 12`).
  ///
  /// ## Colours
  ///
  /// | Role | Source |
  /// |---|---|
  /// | Text | component foreground (`SystemColor.windowText` default) |
  /// | Background (opaque only) | component background |
  ///
  @MainActor
  open class BasicLabelUI: javax.swing.plaf.ComponentUI {

    // -------------------------------------------------------------------------
    // MARK: Preferred size
    // -------------------------------------------------------------------------

    override open func getPreferredSize(of component: javax.swing.JComponent) -> java.awt.Dimension? {
      guard let label = component as? javax.swing.JLabel else { return nil }
      let fm = java.awt.FontMetrics.make(for: component.font)
      let w  = fm.stringWidth(label.getText()) + 4   // 2px padding each side
      let h  = fm.getHeight() + 4
      return java.awt.Dimension(w, h)
    }

    // -------------------------------------------------------------------------
    // MARK: Painting
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics, on component: javax.swing.JComponent) {
      guard let label = component as? javax.swing.JLabel else { return }
      let text = label.getText()
      guard !text.isEmpty else { return }

      let w  = component.bounds.width
      let h  = component.bounds.height
      let fm = java.awt.FontMetrics.make(for: component.font)
      let tw = fm.stringWidth(text)
      let th = fm.getHeight()

      // Horizontal alignment
      let hAlign = label.getHorizontalAlignment()
      let textX: Int
      switch hAlign {
      case javax.swing.JLabel.CENTER:
        textX = (w - tw) / 2
      case javax.swing.JLabel.RIGHT, javax.swing.JLabel.TRAILING:
        textX = w - tw - 2
      default:
        textX = 2   // LEFT / LEADING
      }

      // Vertical alignment
      let vAlign = label.getVerticalAlignment()
      let textY: Int
      switch vAlign {
      case javax.swing.JLabel.TOP:    textY = fm.getAscent() + 2
      case javax.swing.JLabel.BOTTOM: textY = h - fm.getDescent() - 2
      default:                                textY = (h - th) / 2 + fm.getAscent()  // CENTER
      }

      g.setColor(component.getForeground())
      g.drawString(text, textX, textY)
    }
  }
}
