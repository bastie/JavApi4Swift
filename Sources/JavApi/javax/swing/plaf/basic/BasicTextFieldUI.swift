/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.basic {

  /// Basic Look & Feel UI delegate for `JTextField`.
  ///
  /// Renders a single-line text input:
  /// - White / `SystemColor.window` background
  /// - Sunken 1 px border (shadow + highlight lines)
  /// - Text drawn baseline-correct with 4 px left padding
  ///
  /// Preferred size is derived from the font metrics and the field's
  /// `columns` hint (falls back to a minimum of 120 px wide).
  ///
  /// - Since: Java 1.2
  @MainActor
  open class BasicTextFieldUI: javax.swing.plaf.ComponentUI {

    private let padX: Int = 4
    private let padY: Int = 2

    // -------------------------------------------------------------------------
    // MARK: Preferred size
    // -------------------------------------------------------------------------

    override open func getPreferredSize(_ component: javax.swing.JComponent) -> java.awt.Dimension? {
      let fm   = java.awt.FontMetrics.make(for: component.font)
      let h    = fm.getHeight() + padY * 2 + 2  // +2 for top/bottom border
      let cols = (component as? javax.swing.JTextField)?.getColumns() ?? 0
      // Default width: 20 "m"-wide characters when no columns hint is given —
      // same heuristic as Java Swing (no hardcoded pixel constant).
      let defaultCols = 20
      let w    = fm.charWidth("m") * (cols > 0 ? cols : defaultCols) + padX * 2 + 2
      return java.awt.Dimension(w, h)
    }

    // -------------------------------------------------------------------------
    // MARK: Paint
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics, _ component: javax.swing.JComponent) {
      guard let field = component as? javax.swing.text.JTextComponent else { return }

      let w  = component.bounds.width
      let h  = component.bounds.height
      let fm = java.awt.FontMetrics.make(for: component.font)

      // Background
      let bg = field.isEditable() ? java.awt.SystemColor.window : java.awt.SystemColor.control
      g.setColor(bg)
      g.fillRect(1, 1, w - 2, h - 2)

      let isFocused = field.isFocusOwner

      // Border — blue focus ring when focused, sunken otherwise
      if isFocused {
        g.setColor(java.awt.Color(59, 130, 246))  // blue focus ring
        g.drawLine(0,   0,   w-1, 0)
        g.drawLine(0,   0,   0,   h-1)
        g.drawLine(w-1, 0,   w-1, h-1)
        g.drawLine(0,   h-1, w-1, h-1)
      } else {
        g.setColor(java.awt.SystemColor.controlShadow)
        g.drawLine(0,   0,   w-1, 0)
        g.drawLine(0,   0,   0,   h-1)
        g.setColor(java.awt.SystemColor.controlHighlight)
        g.drawLine(w-1, 0,   w-1, h-1)
        g.drawLine(0,   h-1, w-1, h-1)
      }

      let text  = field.getText()
      let textY = (h - fm.getHeight()) / 2 + fm.getAscent()

      // Selection highlight
      let selStart = field.getSelectionStart()
      let selEnd   = field.getSelectionEnd()
      if selStart < selEnd {
        let chars = Array(text)
        let xSel  = padX + fm.stringWidth(String(chars[0..<selStart]))
        let xSelE = padX + fm.stringWidth(String(chars[0..<selEnd]))
        g.setColor(java.awt.Color(173, 214, 255))  // light blue selection
        g.fillRect(xSel, padY, xSelE - xSel, h - padY * 2)
      }

      // Text
      if !text.isEmpty {
        g.setColor(component.getForeground())
        g.drawString(text, padX, textY)
      }

      // Caret — drawn only when focused
      if isFocused {
        let chars    = Array(text)
        let caretPos = min(field.getCaretPosition(), chars.count)
        let xCaret   = padX + fm.stringWidth(String(chars[0..<caretPos]))
        g.setColor(java.awt.Color.black)
        g.drawLine(xCaret, padY + 1, xCaret, h - padY - 2)
      }
    }
  }
}
