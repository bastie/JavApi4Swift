/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.border {

  /// The default border for `JButton` — paints a simple raised/pressed 3-D bevel
  /// whose colors are derived from the component's current background at paint time.
  ///
  /// Unlike `BevelBorder` the colors are not fixed at construction time; they are
  /// recomputed on every `paintBorder` call so they always match the button's
  /// current background (including pressed/rollover state changes).
  ///
  /// This border is installed by `BasicButtonUI.installUI()` and should not
  /// normally be constructed directly — use `BorderFactory` for generic borders.
  @MainActor
  public final class ButtonBorder: AbstractBorder {

    public override init() {}

    override public func paintBorder(
      _ component: java.awt.Component,
      _ g: java.awt.Graphics,
      _ x: Int, _ y: Int, _ width: Int, _ height: Int
    ) {
      guard let btn = component as? javax.swing.AbstractButton else { return }

      let bg = component.getBackground()
      let borderDark = java.awt.Color(
        Swift.max(0, bg.getRed()   - 50),
        Swift.max(0, bg.getGreen() - 50),
        Swift.max(0, bg.getBlue()  - 50))
      let borderLight = java.awt.Color(
        Swift.min(255, bg.getRed()   + 40),
        Swift.min(255, bg.getGreen() + 40),
        Swift.min(255, bg.getBlue()  + 40))

      let w = width
      let h = height

      if btn.getModel().isPressed() {
        // Inset: dark top-left, light bottom-right
        g.setColor(borderDark)
        g.drawLine(x,         y,         x + w - 1, y)
        g.drawLine(x,         y,         x,         y + h - 1)
        g.setColor(borderLight)
        g.drawLine(x + w - 1, y,         x + w - 1, y + h - 1)
        g.drawLine(x,         y + h - 1, x + w - 1, y + h - 1)
      } else {
        // Raised: light top-left, dark bottom-right + inner shadow
        g.setColor(borderLight)
        g.drawLine(x,         y,         x + w - 2, y)
        g.drawLine(x,         y,         x,         y + h - 2)
        g.setColor(borderDark)
        g.drawLine(x + w - 1, y,         x + w - 1, y + h - 1)
        g.drawLine(x,         y + h - 1, x + w - 1, y + h - 1)
        g.setColor(java.awt.SystemColor.controlShadow)
        g.drawLine(x + w - 2, y + 1,     x + w - 2, y + h - 2)
        g.drawLine(x + 1,     y + h - 2, x + w - 2, y + h - 2)
      }
    }

    override public func getBorderInsets(_ component: java.awt.Component) -> java.awt.Insets {
      java.awt.Insets(2, 2, 2, 2)
    }

    override public var isBorderOpaque: Bool { true }
  }
}
