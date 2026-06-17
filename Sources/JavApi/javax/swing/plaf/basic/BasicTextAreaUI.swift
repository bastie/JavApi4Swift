/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.basic {

  /// Basic Look & Feel UI delegate for `JTextArea`.
  ///
  /// Renders a multi-line plain-text area:
  /// - White / `SystemColor.window` background
  /// - Sunken 1 px border
  /// - Each line drawn at correct baseline with 4 px left/top padding
  ///
  /// Preferred size is derived from `rows` × `columns` and the font metrics.
  /// Line-wrap is not enforced by the paint routine — the text is clipped to
  /// the component bounds by the graphics context.
  ///
  /// - Since: Java 1.2
  @MainActor
  open class BasicTextAreaUI: javax.swing.plaf.ComponentUI {

    private let padX: Int = 4
    private let padY: Int = 3

    // -------------------------------------------------------------------------
    // MARK: Preferred size
    // -------------------------------------------------------------------------

    override open func getPreferredSize(_ component: javax.swing.JComponent) -> java.awt.Dimension? {
      guard let area = component as? javax.swing.JTextArea else { return nil }
      let fm   = java.awt.FontMetrics.make(for: component.font)
      let rows = area.getRows()    > 0 ? area.getRows()    : 4
      let cols = area.getColumns() > 0 ? area.getColumns() : 20
      let w    = fm.charWidth("m") * cols + padX * 2 + 2
      let h    = fm.getHeight() * rows   + padY * 2 + 2
      return java.awt.Dimension(w, h)
    }

    // -------------------------------------------------------------------------
    // MARK: Paint
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics, _ component: javax.swing.JComponent) {
      guard let area = component as? javax.swing.text.JTextComponent else { return }

      let w  = component.bounds.width
      let h  = component.bounds.height
      let fm = java.awt.FontMetrics.make(for: component.font)

      // Background
      let bg = area.isEditable() ? java.awt.SystemColor.window : java.awt.SystemColor.control
      g.setColor(bg)
      g.fillRect(1, 1, w - 2, h - 2)

      let isFocused = _SwiftUIFocusManager.shared.focusOwner === area

      // Border — blue focus ring when focused, sunken otherwise
      if isFocused {
        g.setColor(java.awt.Color(59, 130, 246))
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

      let text  = area.getText()
      let lines = text.components(separatedBy: "\n")
      let lineH = fm.getHeight()

      // Selection highlight
      let selStart = area.getSelectionStart()
      let selEnd   = area.getSelectionEnd()
      if selStart < selEnd {
        // Walk lines to paint per-line selection rectangles
        var charIdx = 0
        for (i, line) in lines.enumerated() {
          let lineStart = charIdx
          let lineEnd   = charIdx + line.count
          let lineY     = padY + i * lineH
          if selEnd > lineStart && selStart < lineEnd + 1 {
            let hiStart = max(selStart, lineStart) - lineStart
            let hiEnd   = min(selEnd,   lineEnd)   - lineStart
            let lineChars = Array(line)
            let xS = padX + fm.stringWidth(String(lineChars[0..<min(hiStart, lineChars.count)]))
            let xE = padX + fm.stringWidth(String(lineChars[0..<min(hiEnd,   lineChars.count)]))
            g.setColor(java.awt.Color(173, 214, 255))
            g.fillRect(xS, lineY, max(xE - xS, 2), lineH)
          }
          charIdx += line.count + 1  // +1 for '\n'
        }
      }

      // Text — one line at a time
      if !text.isEmpty {
        g.setColor(component.getForeground())
        for (i, line) in lines.enumerated() {
          let textY = padY + fm.getAscent() + i * lineH
          guard textY < h - padY else { break }
          g.drawString(line, padX, textY)
        }
      }

      // Caret — drawn only when focused
      if isFocused {
        let caretPos  = area.getCaretPosition()
        // Find line + col for caret
        var charIdx   = 0
        var caretLine = 0
        var caretCol  = 0
        for (i, line) in lines.enumerated() {
          let lineEnd = charIdx + line.count
          if caretPos <= lineEnd {
            caretLine = i
            caretCol  = caretPos - charIdx
            break
          }
          charIdx += line.count + 1
        }
        let lineChars = Array(lines[caretLine])
        let xCaret    = padX + fm.stringWidth(String(lineChars[0..<min(caretCol, lineChars.count)]))
        let yCaret    = padY + caretLine * lineH
        g.setColor(java.awt.Color.black)
        g.drawLine(xCaret, yCaret + 1, xCaret, yCaret + lineH - 2)
      }
    }
  }
}
