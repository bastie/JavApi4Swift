/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// A multi-line text-input area — mirrors `java.awt.TextArea`.
  ///
  /// Selection, caret, clipboard, and text-change events are inherited from
  /// `TextComponent`. Keyboard and mouse interaction is wired up in
  /// `AWTFocusManager` and `AWTWindowHost`.
  open class TextArea: TextComponent {

    // -------------------------------------------------------------------------
    // MARK: Scrollbar-visibility constants
    // -------------------------------------------------------------------------

    /// Show both horizontal and vertical scroll bars.
    public static let SCROLLBARS_BOTH            = 0
    /// Show vertical scroll bar only.
    public static let SCROLLBARS_VERTICAL_ONLY   = 1
    /// Show horizontal scroll bar only.
    public static let SCROLLBARS_HORIZONTAL_ONLY = 2
    /// Show no scroll bars.
    public static let SCROLLBARS_NONE            = 3

    // -------------------------------------------------------------------------
    // MARK: Properties
    // -------------------------------------------------------------------------

    public var rows:    Int
    public var columns: Int
    public var scrollbarVisibility: Int

    // Internal scroll state (in pixels)
    var scrollOffsetY: Int = 0

    // Width (px) reserved for the internal vertical scrollbar strip
    let scrollbarWidth: Int = 12

    // Vertical padding inside the text area
    let padX: Int = 4
    let padY: Int = 3

    // -------------------------------------------------------------------------
    // MARK: Constructors
    // -------------------------------------------------------------------------

    public override init() {
      rows    = 5
      columns = 20
      scrollbarVisibility = TextArea.SCROLLBARS_BOTH
      super.init()
      background = java.awt.SystemColor.text
    }

    public init(_ text: String) {
      rows    = 5
      columns = 20
      scrollbarVisibility = TextArea.SCROLLBARS_BOTH
      super.init()
      self.text  = text
      background = java.awt.SystemColor.text
    }

    public init(_ text: String, _ rows: Int, _ columns: Int) {
      self.rows    = rows
      self.columns = columns
      scrollbarVisibility = TextArea.SCROLLBARS_BOTH
      super.init()
      self.text  = text
      background = java.awt.SystemColor.text
    }

    public init(_ text: String, _ rows: Int, _ columns: Int, _ scrollbarVisibility: Int) {
      self.rows    = rows
      self.columns = columns
      self.scrollbarVisibility = scrollbarVisibility
      super.init()
      self.text  = text
      background = java.awt.SystemColor.text
    }

    // -------------------------------------------------------------------------
    // MARK: Java API
    // -------------------------------------------------------------------------

    public func getRows() -> Int    { rows }
    public func getColumns() -> Int { columns }
    public func getScrollbarVisibility() -> Int { scrollbarVisibility }

    public func append(_ s: String) {
      setText(getText() + s)
      setCaretPosition(text.count)
    }

    public func insert(_ s: String, _ pos: Int) {
      var chars = Array(text)
      let idx   = max(0, min(pos, chars.count))
      chars.insert(contentsOf: s, at: idx)
      setText(String(chars))
      setCaretPosition(idx + s.count)
    }

    public func replaceRange(_ s: String, _ start: Int, _ end: Int) {
      var chars = Array(text)
      let lo    = max(0, min(start, chars.count))
      let hi    = max(lo, min(end, chars.count))
      chars.replaceSubrange(lo..<hi, with: s)
      setText(String(chars))
      setCaretPosition(lo + s.count)
    }

    // -------------------------------------------------------------------------
    // MARK: Line helpers
    // -------------------------------------------------------------------------

    /// Split the current text on `\n` and return the array of lines.
    public func computeLines() -> [String] {
      text.components(separatedBy: "\n")
    }

    /// Return the flat character offset for the start of `lineIndex`.
    func charIndexForLineStart(_ lineIndex: Int) -> Int {
      let lines = computeLines()
      var offset = 0
      for i in 0..<min(lineIndex, lines.count) {
        offset += lines[i].count + 1  // +1 for '\n'
      }
      return offset
    }

    /// Convert a flat character index to (lineIndex, columnIndex).
    func lineAndCol(for flatIndex: Int) -> (line: Int, col: Int) {
      let lines = computeLines()
      var remaining = max(0, flatIndex)
      for (i, line) in lines.enumerated() {
        if remaining <= line.count {
          return (i, remaining)
        }
        remaining -= line.count + 1  // +1 for '\n'
      }
      // Past end — clamp to last line end
      let lastLine = lines.count - 1
      return (max(0, lastLine), lines.last?.count ?? 0)
    }

    /// Convert (lineIndex, column) back to a flat character index.
    func flatIndex(line: Int, col: Int) -> Int {
      let lines   = computeLines()
      let safeL   = max(0, min(line, lines.count - 1))
      let safeC   = max(0, min(col, lines[safeL].count))
      return charIndexForLineStart(safeL) + safeC
    }

    // -------------------------------------------------------------------------
    // MARK: 2-D hit-test helper
    // -------------------------------------------------------------------------

    /// Returns the flat character index closest to (`awtX`, `awtY`) within the
    /// text area's coordinate space.
    public func charIndex(atX awtX: Int, atY awtY: Int) -> Int {
      let fm       = getFontMetrics(font)
      let lineH    = fm.getHeight()
      guard lineH > 0 else { return 0 }

      let textTop  = bounds.y + padY - scrollOffsetY
      let relY     = awtY - textTop
      let lineIdx  = max(0, relY / lineH)

      let lines = computeLines()
      let safeLine = min(lineIdx, lines.count - 1)
      let line     = lines[safeLine]
      let lineChars = Array(line)
      let lineStartX = bounds.x + padX
      let relX       = awtX - lineStartX
      guard relX > 0 else { return charIndexForLineStart(safeLine) }

      var prevW = 0
      for i in 0..<lineChars.count {
        let nextW    = fm.stringWidth(String(lineChars.prefix(i + 1)))
        let midpoint = (prevW + nextW) / 2
        if relX <= midpoint { return charIndexForLineStart(safeLine) + i }
        prevW = nextW
      }
      return charIndexForLineStart(safeLine) + lineChars.count
    }

    // -------------------------------------------------------------------------
    // MARK: Line navigation
    // -------------------------------------------------------------------------

    /// Move the caret to the same column on the line above (`up = true`) or
    /// below (`up = false`), optionally extending the selection.
    public func moveCaretToAdjacentLine(up: Bool, extending: Bool) {
      let (line, col) = lineAndCol(for: caretPosition)
      let lines       = computeLines()
      let targetLine: Int
      if up {
        guard line > 0 else { return }   // already on first line
        targetLine = line - 1
      } else {
        guard line < lines.count - 1 else { return }   // already on last line
        targetLine = line + 1
      }
      // Preserve column, clamped to target line length
      let targetCol = min(col, lines[targetLine].count)
      let newFlat   = flatIndex(line: targetLine, col: targetCol)
      if extending {
        extendSelection(to: newFlat)
      } else {
        setCaretPosition(newFlat)
      }
      ensureCaretVisible()
    }

    /// Move the caret to the beginning (`end = false`) or end (`end = true`)
    /// of the **current line**, optionally extending the selection.
    public func moveCaretToLineEdge(end: Bool, extending: Bool) {
      let (line, _) = lineAndCol(for: caretPosition)
      let lines     = computeLines()
      let safeL     = min(line, lines.count - 1)
      let newFlat   = end
        ? charIndexForLineStart(safeL) + lines[safeL].count
        : charIndexForLineStart(safeL)
      if extending {
        extendSelection(to: newFlat)
      } else {
        setCaretPosition(newFlat)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Ensure caret visible
    // -------------------------------------------------------------------------

    /// Adjust `scrollOffsetY` so the line containing the caret is in view.
    public func ensureCaretVisible() {
      let fm       = getFontMetrics(font)
      let lineH    = fm.getHeight()
      guard lineH > 0 else { return }

      let (caretLine, _) = lineAndCol(for: caretPosition)
      let lineTop        = caretLine * lineH
      let lineBottom     = lineTop + lineH

      let visibleH = bounds.height - 2 * padY
      if lineTop < scrollOffsetY {
        scrollOffsetY = lineTop
      } else if lineBottom > scrollOffsetY + visibleH {
        scrollOffsetY = lineBottom - visibleH
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Scrollbar thumb geometry (for mouse interaction)
    // -------------------------------------------------------------------------

    /// Returns the rect of the internal vertical scrollbar thumb.
    /// Returns `nil` when all content fits and no scrolling is needed.
    public func verticalScrollbarThumbRect() -> java.awt.Rectangle? {
      guard scrollbarVisibility == TextArea.SCROLLBARS_BOTH ||
            scrollbarVisibility == TextArea.SCROLLBARS_VERTICAL_ONLY else { return nil }
      let fm      = getFontMetrics(font)
      let lineH   = max(1, fm.getHeight())
      let lines   = computeLines()
      let totalH  = lines.count * lineH
      let visibleH = bounds.height - 2 * padY
      guard totalH > visibleH else { return nil }

      let trackX = bounds.x + bounds.width - scrollbarWidth
      let trackH = bounds.height
      let thumbH = max(12, trackH * visibleH / totalH)
      let thumbY = bounds.y + trackH * scrollOffsetY / totalH
      return java.awt.Rectangle(trackX, thumbY, scrollbarWidth, thumbH)
    }

    // -------------------------------------------------------------------------
    // MARK: Scrollbar drag state
    // -------------------------------------------------------------------------

    var isScrollbarDragging: Bool = false
    var scrollDragStartY:    Int  = 0
    var scrollDragStartOff:  Int  = 0

    // -------------------------------------------------------------------------
    // MARK: Paint
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics) {
      let x = bounds.x, y = bounds.y
      let w = bounds.width, h = bounds.height
      let hasVScrollbar =
        scrollbarVisibility == TextArea.SCROLLBARS_BOTH ||
        scrollbarVisibility == TextArea.SCROLLBARS_VERTICAL_ONLY

      // Background
      g.setColor(editable ? background : java.awt.SystemColor.control)
      g.fillRect(x, y, w, h)

      let hasFocus = isFocusOwner

      let fm      = getFontMetrics(font)
      let lineH   = fm.getHeight()
      let lines   = computeLines()
      let textW   = hasVScrollbar ? w - scrollbarWidth : w
      let sel0    = selectionStart
      let sel1    = selectionEnd

      // Render each line
      for (lineIdx, line) in lines.enumerated() {
        let lineChars  = Array(line)
        let lineStart  = charIndexForLineStart(lineIdx)
        let lineEnd    = lineStart + lineChars.count

        let lineY      = y + padY + lineIdx * lineH - scrollOffsetY
        // Clip: only draw lines that are (partially) visible
        guard lineY + lineH > y && lineY < y + h else { continue }

        let ty = lineY + fm.getAscent()

        // Selection range within this line
        let selLo = max(sel0, lineStart)
        let selHi = min(sel1, lineEnd)
        let hasSelOnLine = hasFocus && hasSelection && selLo < selHi

        if hasSelOnLine {
          // Draw selection highlight rect
          let loOff  = fm.stringWidth(String(lineChars.prefix(selLo - lineStart)))
          let hiOff  = fm.stringWidth(String(lineChars.prefix(selHi - lineStart)))
          let hiX    = x + padX + hiOff
          // If selection continues to next line, extend highlight to right edge
          let selEndX = (sel1 > lineEnd) ? x + textW : hiX
          g.setColor(java.awt.SystemColor.textHighlight)
          g.fillRect(x + padX + loOff, lineY, selEndX - (x + padX + loOff), lineH)
        }

        // Draw text segments
        if !line.isEmpty {
          if hasSelOnLine {
            let lo = selLo - lineStart
            let hi = selHi - lineStart
            // Before selection
            if lo > 0 {
              g.setColor(foreground)
              g.drawString(String(lineChars.prefix(lo)), x + padX, ty)
            }
            // Selected segment
            let selX = x + padX + fm.stringWidth(String(lineChars.prefix(lo)))
            g.setColor(java.awt.SystemColor.textHighlightText)
            g.drawString(String(lineChars[lo..<hi]), selX, ty)
            // After selection
            if hi < lineChars.count {
              let afterX = x + padX + fm.stringWidth(String(lineChars.prefix(hi)))
              g.setColor(foreground)
              g.drawString(String(lineChars.suffix(lineChars.count - hi)), afterX, ty)
            }
          } else {
            g.setColor(foreground)
            g.drawString(line, x + padX, ty)
          }
        }

        // Cursor
        if editable && hasFocus && !hasSelection {
          let (caretLine, caretCol) = lineAndCol(for: caretPosition)
          if caretLine == lineIdx {
            let cxOff = fm.stringWidth(String(lineChars.prefix(caretCol)))
            let cx    = x + padX + cxOff
            g.setColor(foreground)
            g.drawLine(cx, lineY + 2, cx, lineY + lineH - 2)
          }
        }
      }

      // Vertical scrollbar strip
      if hasVScrollbar {
        let trackX = x + w - scrollbarWidth
        g.setColor(java.awt.SystemColor.scrollbar)
        g.fillRect(trackX, y, scrollbarWidth, h)

        if let tr = verticalScrollbarThumbRect() {
          g.setColor(java.awt.SystemColor.control)
          g.fillRect(tr.x, tr.y, tr.width, tr.height)
          g.setColor(java.awt.SystemColor.controlShadow)
          g.drawLine(tr.x, tr.y, tr.x + tr.width - 1, tr.y)
          g.drawLine(tr.x, tr.y, tr.x, tr.y + tr.height - 1)
          g.drawLine(tr.x + tr.width - 1, tr.y, tr.x + tr.width - 1, tr.y + tr.height - 1)
          g.drawLine(tr.x, tr.y + tr.height - 1, tr.x + tr.width - 1, tr.y + tr.height - 1)
        }
      }

      // Border
      let borderColor = hasFocus
        ? java.awt.Color.keyboardFocusIndicator
        : java.awt.SystemColor.windowBorder
      g.setColor(borderColor)
      g.drawLine(x,     y,     x+w-1, y)
      g.drawLine(x,     y,     x,     y+h-1)
      g.drawLine(x+w-1, y,     x+w-1, y+h-1)
      g.drawLine(x,     y+h-1, x+w-1, y+h-1)
    }
  }
}
