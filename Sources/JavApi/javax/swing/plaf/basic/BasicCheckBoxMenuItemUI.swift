/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.basic {

  /// UI delegate for `JCheckBoxMenuItem`.
  ///
  /// Extends `BasicMenuItemUI` by drawing a small square checkbox indicator
  /// to the left of the text label.  The indicator size is derived from the
  /// component font so that preferred size and painting are always in sync.
  ///
  /// ## Layout
  ///
  /// ```
  /// |<-- padX -->|[ ✓ ]<-- indicatorGap -->|  Label text  |<-- padX -->|
  /// ```
  ///
  /// - Since: Java 1.2 / JFC 1.0
  @MainActor
  open class BasicCheckBoxMenuItemUI: javax.swing.plaf.basic.BasicMenuItemUI {

    /// Side length of the checkbox square (derived from font cap-height + 2).
    private var _boxSize: Int = 13

    override open class func createUI(_ c: javax.swing.JComponent) -> javax.swing.plaf.ComponentUI {
      return BasicCheckBoxMenuItemUI()
    }

    // -------------------------------------------------------------------------
    // MARK: Indicator geometry
    // -------------------------------------------------------------------------

    override open func indicatorWidth() -> Int { _boxSize }

    /// Recalculates `_boxSize` from the component font so size stays dynamic.
    private func updateBoxSize(for component: javax.swing.JComponent) {
      let fm = java.awt.FontMetrics.make(for: component.font)
      _boxSize = fm.getAscent()   // roughly matches cap-height
    }

    // -------------------------------------------------------------------------
    // MARK: Preferred size — recalculate box size first
    // -------------------------------------------------------------------------

    override open func getPreferredSize(_ component: javax.swing.JComponent) -> java.awt.Dimension? {
      updateBoxSize(for: component)
      return super.getPreferredSize(component)
    }

    // -------------------------------------------------------------------------
    // MARK: Paint
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics, _ component: javax.swing.JComponent) {
      updateBoxSize(for: component)
      super.paint(g, component)
    }

    /// Draws the checkbox square and, when `selected`, a ✓ check mark.
    override open func paintIndicator(_ g: java.awt.Graphics,
                                      in rect: java.awt.Rectangle,
                                      selected: Bool) {
      let x = rect.x
      let y = rect.y
      let s = rect.width   // square size

      // Outer border
      g.setColor(java.awt.SystemColor.controlDkShadow)
      g.drawRect(x, y, s - 1, s - 1)

      // Inner fill
      g.setColor(java.awt.SystemColor.window)
      g.fillRect(x + 1, y + 1, s - 2, s - 2)

      // Check mark
      if selected {
        g.setColor(java.awt.SystemColor.controlText)
        // Two line segments forming a ✓
        let cx = x + 2
        let cy = y + s / 2 - 1
        g.drawLine(cx,         cy + 2,     cx + 3,     cy + s / 2)
        g.drawLine(cx + 3,     cy + s / 2, cx + s - 3, cy)
        // Thicken by drawing one pixel below
        g.drawLine(cx,         cy + 3,     cx + 3,     cy + s / 2 + 1)
        g.drawLine(cx + 3,     cy + s / 2 + 1, cx + s - 3, cy + 1)
      }
    }
  }
}
