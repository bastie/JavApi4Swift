/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.basic {

  /// Basic Look & Feel UI delegate for `JPasswordField`.
  ///
  /// Identical to `BasicTextFieldUI` except that the displayed text is replaced
  /// by a sequence of the field's echo character (default `😎`).
  ///
  /// - Since: Java 1.2
  @MainActor
  open class BasicPasswordFieldUI: javax.swing.plaf.basic.BasicTextFieldUI {

    override open func paint(_ g: java.awt.Graphics, on component: javax.swing.JComponent) {
      guard let field = component as? javax.swing.JPasswordField else {
        // Fallback: render as plain text field
        super.paint(g, on: component)
        return
      }

      let w   = component.bounds.width
      let h   = component.bounds.height
      let fm  = java.awt.FontMetrics.make(for: component.font)
      let padX = 4
      let padY = 2

      // Background
      let bg = field.isEditable() ? java.awt.SystemColor.window : java.awt.SystemColor.control
      g.setColor(bg)
      g.fillRect(1, 1, w - 2, h - 2)

      let isFocused = _SwiftUIFocusManager.shared.focusOwner === field

      // Border — blue focus ring when focused
      if isFocused {
        g.setColor(java.awt.Color(59, 130, 246))
      } else {
        g.setColor(java.awt.SystemColor.controlShadow)
        g.drawLine(0, 0, w-1, 0)
        g.drawLine(0, 0, 0,   h-1)
        g.setColor(java.awt.SystemColor.controlHighlight)
        g.drawLine(w-1, 0,   w-1, h-1)
        g.drawLine(0,   h-1, w-1, h-1)
      }
      if isFocused {
        g.drawLine(0,   0,   w-1, 0)
        g.drawLine(0,   0,   0,   h-1)
        g.drawLine(w-1, 0,   w-1, h-1)
        g.drawLine(0,   h-1, w-1, h-1)
      }

      // Build masked text
      let realLen    = field.getText().count
      let echoChar   = field.echoCharIsSet() ? field.getEchoChar() : nil
      let maskedText = echoChar.map { ch in String(repeating: ch, count: realLen) }
                       ?? field.getText()

      let textY = (h - fm.getHeight()) / 2 + fm.getAscent()
      let chars  = Array(maskedText)

      // Selection highlight (on masked text)
      let selStart = field.getSelectionStart()
      let selEnd   = field.getSelectionEnd()
      if selStart < selEnd, selEnd <= chars.count {
        let xS = padX + fm.stringWidth(String(chars[0..<selStart]))
        let xE = padX + fm.stringWidth(String(chars[0..<selEnd]))
        g.setColor(java.awt.Color(173, 214, 255))
        g.fillRect(xS, padY, xE - xS, h - padY * 2)
      }

      // Masked text
      if !maskedText.isEmpty {
        g.setColor(component.getForeground())
        g.drawString(maskedText, padX, textY)
      }

      // Caret
      if isFocused {
        let caretPos = min(field.getCaretPosition(), chars.count)
        let xCaret   = padX + fm.stringWidth(String(chars[0..<caretPos]))
        g.setColor(java.awt.Color.black)
        g.drawLine(xCaret, padY + 1, xCaret, h - padY - 2)
      }
    }
  }
}
