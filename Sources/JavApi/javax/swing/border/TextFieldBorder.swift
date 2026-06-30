/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.border {

  /// The default border for text-input components (`JTextField`, `JTextArea`,
  /// `JTextPane`, `JPasswordField`).
  ///
  /// Renders a sunken two-line bevel when the component does not have focus,
  /// and a solid blue focus ring when it does.  Colors are derived from
  /// `SystemColor` at paint time so they are always in sync with the active
  /// Look & Feel.
  ///
  /// This border is installed by `BasicTextFieldUI.installUI()` (and its
  /// subclass UIs) and should not normally be constructed directly.
  ///
  /// ## Visual description
  ///
  /// **Focused:**
  /// A 1-pixel solid border in `Color(59, 130, 246)` (blue).
  ///
  /// **Unfocused:**
  /// A classic sunken bevel:
  /// - top-left: `SystemColor.controlShadow`
  /// - bottom-right: `SystemColor.controlHighlight`
  ///
  /// - Since: JavApi⁴Swift 1.0
  @MainActor
  public final class TextFieldBorder: AbstractBorder {

    public override init() {}

    override public func paintBorder(
      _ component: java.awt.Component,
      _ g: java.awt.Graphics,
      _ x: Int, _ y: Int, _ width: Int, _ height: Int
    ) {
      let w = width
      let h = height
      let focused = (component as? javax.swing.JComponent)?.isFocusOwner ?? false

      if focused {
        g.setColor(java.awt.Color(59, 130, 246))
        g.drawLine(x,         y,         x + w - 1, y)
        g.drawLine(x,         y,         x,         y + h - 1)
        g.drawLine(x + w - 1, y,         x + w - 1, y + h - 1)
        g.drawLine(x,         y + h - 1, x + w - 1, y + h - 1)
      } else {
        // Sunken bevel: shadow top-left, highlight bottom-right
        g.setColor(java.awt.SystemColor.controlShadow)
        g.drawLine(x,         y,         x + w - 1, y)
        g.drawLine(x,         y,         x,         y + h - 1)
        g.setColor(java.awt.SystemColor.controlHighlight)
        g.drawLine(x + w - 1, y,         x + w - 1, y + h - 1)
        g.drawLine(x,         y + h - 1, x + w - 1, y + h - 1)
      }
    }

    override public func getBorderInsets(_ component: java.awt.Component) -> java.awt.Insets {
      java.awt.Insets(2, 4, 2, 4)
    }

    override public var isBorderOpaque: Bool { false }
  }
}
