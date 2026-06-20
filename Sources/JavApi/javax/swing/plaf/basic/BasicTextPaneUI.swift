/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.basic {

  /// Basic Look & Feel UI delegate for `JTextPane`.
  ///
  /// Renders a multi-line styled-text area backed by `DefaultStyledDocument`.
  /// Per-character attributes from `StyleConstants` are applied:
  /// - `Bold` / `Italic`  → font weight / style
  /// - `FontSize`         → point size
  /// - `Foreground`       → text colour
  /// - `Underline`        → underline decoration
  ///
  /// **Variable line heights:** every line's height is the maximum `FontMetrics`
  /// height among all characters on that line.  Caret painting, selection
  /// highlighting and mouse hit-testing all use the same cumulative-Y layout so
  /// that clicks in large-font lines map to the correct character offset.
  ///
  /// - Since: Java 1.2
  @MainActor
  open class BasicTextPaneUI: javax.swing.plaf.ComponentUI {

    // ── constants ──────────────────────────────────────────────────────────────
    let padX: Int = 4   // accessible by mouseDown hit-test in _SwiftUINativeCanvas
    let padY: Int = 3

    // -------------------------------------------------------------------------
    // MARK: Preferred size
    // -------------------------------------------------------------------------

    override open func getPreferredSize(_ component: javax.swing.JComponent) -> java.awt.Dimension? {
      let fm = java.awt.FontMetrics.make(for: component.font)
      let w  = fm.charWidth("m") * 40 + padX * 2 + 2
      let h  = fm.getHeight()    *  8 + padY * 2 + 2
      return java.awt.Dimension(w, h)
    }

    // -------------------------------------------------------------------------
    // MARK: Paint
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics, _ component: javax.swing.JComponent) {
      guard let pane = component as? javax.swing.JTextPane else { return }

      let w = component.bounds.width
      let h = component.bounds.height

      // Background
      let bg = pane.isEditable() ? java.awt.SystemColor.window : java.awt.SystemColor.control
      g.setColor(bg)
      g.fillRect(1, 1, w - 2, h - 2)

      let isFocused = pane.isFocusOwner

      // Border
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

      guard let sd = pane.getStyledDocument() else {
        _paintPlain(g, pane, w: w, h: h); return
      }

      let text  = pane.getText()
      let lines = text.components(separatedBy: "\n")

      // Pre-compute per-line Y layout (variable heights)
      let layout = _lineLayout(lines: lines, sd: sd, baseFont: component.font)

      let selStart = pane.getSelectionStart()
      let selEnd   = pane.getSelectionEnd()
      var charOffset = 0

      for (lineIdx, line) in lines.enumerated() {
        let (lineY, lineH, _) = layout[lineIdx]

        // ── Selection highlight ──────────────────────────────────────────────
        if selStart < selEnd {
          let lineStart = charOffset
          let lineEnd   = charOffset + line.count
          if selEnd > lineStart && selStart < lineEnd + 1 {
            let hiStart = max(selStart, lineStart) - lineStart
            let hiEnd   = min(selEnd,   lineEnd)   - lineStart
            let xS = padX + _xForCol(hiStart, lineStart: charOffset, line: line, sd: sd, baseFont: component.font)
            let xE = padX + _xForCol(hiEnd,   lineStart: charOffset, line: line, sd: sd, baseFont: component.font)
            g.setColor(java.awt.Color(173, 214, 255))
            g.fillRect(xS, lineY, max(xE - xS, 2), lineH)
          }
        }

        // ── Styled character runs ────────────────────────────────────────────
        var x        = padX
        var runStart = 0
        let lineChars = Array(line)

        while runStart < lineChars.count {
          let absIdx = charOffset + runStart
          let attrs  = sd.getCharacterElement(absIdx)

          var runEnd = runStart + 1
          while runEnd < lineChars.count {
            if !_sameAttrs(attrs, sd.getCharacterElement(charOffset + runEnd)) { break }
            runEnd += 1
          }

          let runStr = String(lineChars[runStart..<runEnd])
          let (runFont, _, underline, fgColor) = _resolveAttrs(attrs, baseFont: component.font)
          let runFm = java.awt.FontMetrics.make(for: runFont)

          // Baseline: bottom-align within the line (tallest glyph defines lineH)
          let textY = lineY + lineH - runFm.getDescent()

          g.setFont(runFont)
          g.setColor(fgColor)
          g.drawString(runStr, x, textY)

          if underline {
            g.drawLine(x, textY + 1, x + runFm.stringWidth(runStr) - 1, textY + 1)
          }

          x += runFm.stringWidth(runStr)
          runStart = runEnd
        }

        charOffset += line.count + 1
      }

      // ── Caret ───────────────────────────────────────────────────────────────
      if isFocused {
        let caretPos = pane.getCaretPosition()
        var offset   = 0
        for (lineIdx, line) in lines.enumerated() {
          if caretPos <= offset + line.count {
            let col    = caretPos - offset
            let (lineY, lineH, _) = layout[lineIdx]
            let caretX = padX + _xForCol(col, lineStart: offset, line: line, sd: sd, baseFont: component.font)
            g.setColor(java.awt.Color.black)
            g.drawLine(caretX, lineY + 1, caretX, lineY + lineH - 2)
            break
          }
          offset += line.count + 1
        }
      }

      // Restore default font
      g.setFont(component.font)
    }

    // -------------------------------------------------------------------------
    // MARK: Layout helper — shared with hit-test in _SwiftUINativeCanvas
    // -------------------------------------------------------------------------

    /// Returns `[(yTop, lineHeight, ascent)]` for every line.
    ///
    /// `yTop` is the cumulative Y from the component top (including `padY`).
    /// `lineHeight` is the maximum `FontMetrics.getHeight()` over all characters
    /// on that line (minimum: base font height, so empty lines still have height).
    func _lineLayout(
      lines: [String],
      sd: javax.swing.text.StyledDocument,
      baseFont: java.awt.Font
    ) -> [(yTop: Int, lineHeight: Int, ascent: Int)] {

      let baseFm  = java.awt.FontMetrics.make(for: baseFont)
      let baseH   = baseFm.getHeight()
      let baseAsc = baseFm.getAscent()

      var result: [(Int, Int, Int)] = []
      var y          = padY
      var charOffset = 0

      for line in lines {
        var maxH   = baseH
        var maxAsc = baseAsc

        if !line.isEmpty {
          var i = 0
          while i < line.count {
            let attrs = sd.getCharacterElement(charOffset + i)
            let (runFont, _, _, _) = _resolveAttrs(attrs, baseFont: baseFont)
            let fm = java.awt.FontMetrics.make(for: runFont)
            maxH   = max(maxH,   fm.getHeight())
            maxAsc = max(maxAsc, fm.getAscent())
            // Skip to end of run
            var j = i + 1
            while j < line.count {
              if !_sameAttrs(attrs, sd.getCharacterElement(charOffset + j)) { break }
              j += 1
            }
            i = j
          }
        }

        result.append((y, maxH, maxAsc))
        y += maxH
        charOffset += line.count + 1
      }

      return result
    }

    // -------------------------------------------------------------------------
    // MARK: Private helpers
    // -------------------------------------------------------------------------

    /// Pixel X offset (from left edge of content area, without padX) for `col`
    /// characters into `line`, respecting per-character font attributes.
    func _xForCol(
      _ col: Int,
      lineStart: Int,
      line: String,
      sd: javax.swing.text.StyledDocument,
      baseFont: java.awt.Font
    ) -> Int {
      let lineChars = Array(line)
      let end = min(col, lineChars.count)
      var x = 0
      var i = 0
      while i < end {
        let attrs = sd.getCharacterElement(lineStart + i)
        let (runFont, _, _, _) = _resolveAttrs(attrs, baseFont: baseFont)
        let runFm = java.awt.FontMetrics.make(for: runFont)
        var j = i + 1
        while j < end {
          if !_sameAttrs(attrs, sd.getCharacterElement(lineStart + j)) { break }
          j += 1
        }
        x += runFm.stringWidth(String(lineChars[i..<j]))
        i = j
      }
      return x
    }

    /// Resolve `AttributeSet?` → `(font, fontSize, underline, fgColor)`.
    func _resolveAttrs(
      _ attrs: javax.swing.text.AttributeSet?,
      baseFont: java.awt.Font
    ) -> (java.awt.Font, Int, Bool, java.awt.Color) {
      let fontSize: Int
      let bold:     Bool
      let italic:   Bool
      let underline: Bool
      let fgColor:  java.awt.Color
      if let a = attrs {
        fontSize  = javax.swing.text.StyleConstants.getFontSize(a)
        bold      = javax.swing.text.StyleConstants.isBold(a)
        italic    = javax.swing.text.StyleConstants.isItalic(a)
        underline = javax.swing.text.StyleConstants.isUnderline(a)
        fgColor   = javax.swing.text.StyleConstants.getForeground(a)
      } else {
        fontSize  = baseFont.getSize()
        bold      = false
        italic    = false
        underline = false
        fgColor   = java.awt.Color.black
      }
      var style = baseFont.getStyle()
      if bold   { style |= java.awt.Font.BOLD   }
      if italic { style |= java.awt.Font.ITALIC }
      return (java.awt.Font(baseFont.getName(), style, fontSize), fontSize, underline, fgColor)
    }

    /// Plain-text fallback when no `StyledDocument` is available.
    private func _paintPlain(_ g: java.awt.Graphics,
                              _ pane: javax.swing.JTextPane,
                              w: Int, h: Int) {
      let fm    = java.awt.FontMetrics.make(for: pane.font)
      let text  = pane.getText()
      let lines = text.components(separatedBy: "\n")
      g.setColor(pane.getForeground())
      for (i, line) in lines.enumerated() {
        let y = padY + fm.getAscent() + i * fm.getHeight()
        guard y < h - padY else { break }
        g.drawString(line, padX, y)
      }
    }

    /// Returns `true` when both optional `AttributeSet`s have the same visual attributes.
    func _sameAttrs(_ a: javax.swing.text.AttributeSet?,
                    _ b: javax.swing.text.AttributeSet?) -> Bool {
      guard let a, let b else { return a == nil && b == nil }
      return javax.swing.text.StyleConstants.isBold(a)      == javax.swing.text.StyleConstants.isBold(b)
          && javax.swing.text.StyleConstants.isItalic(a)    == javax.swing.text.StyleConstants.isItalic(b)
          && javax.swing.text.StyleConstants.isUnderline(a) == javax.swing.text.StyleConstants.isUnderline(b)
          && javax.swing.text.StyleConstants.getFontSize(a) == javax.swing.text.StyleConstants.getFontSize(b)
          && javax.swing.text.StyleConstants.getForeground(a).getRGB()
          == javax.swing.text.StyleConstants.getForeground(b).getRGB()
    }
  }
}
