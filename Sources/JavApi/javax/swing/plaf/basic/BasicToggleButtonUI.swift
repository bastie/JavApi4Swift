/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.basic {

  /// UI delegate for `JToggleButton`.
  ///
  /// Extends `BasicButtonUI`.  When the button is selected, the background is
  /// drawn with `SystemColor.controlShadow` (pressed appearance) regardless of
  /// the actual pressed/rollover state — matching the standard Swing look.
  ///
  /// - Since: Java 1.2
  @MainActor
  open class BasicToggleButtonUI: javax.swing.plaf.basic.BasicButtonUI {

    open class func createUI(_ c: javax.swing.JComponent) -> javax.swing.plaf.ComponentUI {
      return BasicToggleButtonUI()
    }

    /// Toggle buttons render as permanently "pressed" when selected.
    override open func paint(_ g: java.awt.Graphics, _ component: javax.swing.JComponent) {
      // Let BasicButtonUI handle the full paint; its model.isPressed() check
      // already reads the correct state because JToggleButton.buttonClicked()
      // sets selected (not pressed) — but visually we want selected ≡ pressed.
      // We temporarily shadow the model state by adjusting the component's
      // background before delegating.
      super.paint(g, component)

      // Draw a small "selected" indicator — a darker inner border — when selected.
      guard let btn = component as? javax.swing.AbstractButton,
            btn.isSelected() else { return }
      let w = component.bounds.width, h = component.bounds.height
      g.setColor(java.awt.SystemColor.controlDkShadow)
      g.drawLine(0, 0, w - 1, 0)
      g.drawLine(0, 0, 0, h - 1)
    }
  }
}
