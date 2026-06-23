/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.basic {

  /// UI delegate for `JRadioButtonMenuItem`.
  ///
  /// Extends `BasicMenuItemUI` by drawing a circle (radio button) indicator
  /// to the left of the text label, with a filled dot when the item is
  /// selected.  The indicator size derives from the component font.
  ///
  /// ## Layout
  ///
  /// ```
  /// |<-- padX -->|( • )<-- indicatorGap -->|  Label text  |<-- padX -->|
  /// ```
  ///
  /// - Since: Java 1.2 / JFC 1.0
  @MainActor
  open class BasicRadioButtonMenuItemUI: javax.swing.plaf.basic.BasicMenuItemUI {

    /// Diameter of the radio circle (derived from font cap-height).
    private var _circleSize: Int = 13

    override open class func createUI(_ c: javax.swing.JComponent) -> javax.swing.plaf.ComponentUI {
      return BasicRadioButtonMenuItemUI()
    }

    // -------------------------------------------------------------------------
    // MARK: Indicator geometry
    // -------------------------------------------------------------------------

    override open func indicatorWidth() -> Int { _circleSize }

    private func updateCircleSize(for component: javax.swing.JComponent) {
      let fm = java.awt.FontMetrics.make(for: component.font)
      _circleSize = fm.getAscent()
    }

    // -------------------------------------------------------------------------
    // MARK: Preferred size
    // -------------------------------------------------------------------------

    override open func getPreferredSize(_ component: javax.swing.JComponent) -> java.awt.Dimension? {
      updateCircleSize(for: component)
      return super.getPreferredSize(component)
    }

    // -------------------------------------------------------------------------
    // MARK: Paint
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics, _ component: javax.swing.JComponent) {
      updateCircleSize(for: component)
      super.paint(g, component)
    }

    /// Draws the radio circle and, when `selected`, a filled inner dot.
    override open func paintIndicator(_ g: java.awt.Graphics,
                                      in rect: java.awt.Rectangle,
                                      selected: Bool) {
      let x = rect.x
      let y = rect.y
      let d = rect.width   // diameter

      // Outer circle
      g.setColor(java.awt.SystemColor.controlDkShadow)
      g.drawOval(x, y, d - 1, d - 1)

      // Inner fill
      g.setColor(java.awt.SystemColor.window)
      g.fillOval(x + 1, y + 1, d - 3, d - 3)

      // Selection dot
      if selected {
        g.setColor(java.awt.SystemColor.controlText)
        let inset = d / 4
        g.fillOval(x + inset, y + inset, d - 2 * inset - 1, d - 2 * inset - 1)
      }
    }
  }
}
