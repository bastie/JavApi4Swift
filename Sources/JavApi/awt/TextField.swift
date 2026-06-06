/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// A single-line text-input field — mirrors `java.awt.TextField`.
  open class TextField: TextComponent {

    // -------------------------------------------------------------------------
    // MARK: Properties
    // -------------------------------------------------------------------------

    public var columns: Int
    /// When non-zero, input is masked with this character (password field).
    public var echoChar: Character = "\0"

    private var actionListeners: [java.awt.event.ActionListener] = []

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    public init(_ text: String = "", columns: Int = 0) {
      self.columns = columns
      super.init()
      self.text    = text
      background   = java.awt.Color(0xFF, 0xFF, 0xFF)
    }

    // -------------------------------------------------------------------------
    // MARK: Echo (password)
    // -------------------------------------------------------------------------

    public func getEchoChar() -> Character     { echoChar }
    public func setEchoChar(_ c: Character)    { echoChar = c }
    public func echoCharIsSet() -> Bool        { echoChar != "\0" }

    // -------------------------------------------------------------------------
    // MARK: Action (fired on Return key)
    // -------------------------------------------------------------------------

    public func addActionListener(_ l: java.awt.event.ActionListener) {
      actionListeners.append(l)
    }
    public func removeActionListener(_ l: java.awt.event.ActionListener) {
      actionListeners.removeAll { $0 === l }
    }

    public func doAction() {
      let e = java.awt.event.ActionEvent(
        self, java.awt.event.ActionEvent.ACTION_PERFORMED, text)
      actionListeners.forEach { $0.actionPerformed(e) }
    }

    // -------------------------------------------------------------------------
    // MARK: Hit-test helper: character index for a given AWT x coordinate
    // -------------------------------------------------------------------------

    /// Returns the character-gap index (0 … text.count) closest to `awtX`
    /// (absolute x in frame / component coordinate space).
    public func charIndex(at awtX: Int) -> Int {
      let display = echoCharIsSet()
        ? String(repeating: echoChar, count: text.count)
        : text
      let fm   = getFontMetrics(font)
      let pad  = 4
      let relX = awtX - bounds.x - pad
      guard relX > 0 else { return 0 }

      let chars = Array(display)
      var prevW = 0
      for i in 0..<chars.count {
        let nextW    = fm.stringWidth(String(chars.prefix(i + 1)))
        let midpoint = (prevW + nextW) / 2
        if relX <= midpoint { return i }
        prevW = nextW
      }
      return chars.count
    }

    // -------------------------------------------------------------------------
    // MARK: Paint
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics) {
      let x = bounds.x, y = bounds.y, w = bounds.width, h = bounds.height
      let pad = 4

      // Background
      g.setColor(editable ? background : java.awt.Color(0xEE, 0xEE, 0xEE))
      g.fillRect(x, y, w, h)

      let hasFocus = isFocusOwner

      // Display string (masked for password fields)
      let display: String = echoCharIsSet()
        ? String(repeating: echoChar, count: text.count)
        : text
      let chars = Array(display)
      let fm    = getFontMetrics(font)
      let ty    = y + (h - fm.getHeight()) / 2 + fm.getAscent()

      // Selection highlight (filled rect behind text)
      if hasFocus && hasSelection {
        let lo  = selectionStart
        let hi  = selectionEnd
        let loX = x + pad + fm.stringWidth(String(chars.prefix(lo)))
        let hiX = x + pad + fm.stringWidth(String(chars.prefix(hi)))
        g.setColor(java.awt.SystemColor.textHighlight)
        g.fillRect(loX, y + 2, hiX - loX, h - 4)
      }

      // Text — drawn in segments when a selection is active
      if !display.isEmpty {
        if hasFocus && hasSelection {
          let lo = selectionStart
          let hi = selectionEnd
          // Before selection
          if lo > 0 {
            g.setColor(foreground)
            g.drawString(String(chars.prefix(lo)), x + pad, ty)
          }
          // Selected text (white on highlight)
          if lo < hi {
            let selX = x + pad + fm.stringWidth(String(chars.prefix(lo)))
            g.setColor(java.awt.SystemColor.textHighlightText)
            g.drawString(String(chars[lo..<hi]), selX, ty)
          }
          // After selection
          if hi < chars.count {
            let afterX = x + pad + fm.stringWidth(String(chars.prefix(hi)))
            g.setColor(foreground)
            g.drawString(String(chars.suffix(chars.count - hi)), afterX, ty)
          }
        } else {
          g.setColor(foreground)
          g.drawString(display, x + pad, ty)
        }
      }

      // Cursor (vertical bar at caretPosition — only when focused and no selection)
      if editable && hasFocus && !hasSelection {
        let cx = x + pad + fm.stringWidth(String(chars.prefix(caretPosition))) + 1
        g.setColor(foreground)
        g.drawLine(cx, y + 3, cx, y + h - 3)
      }

      // Border: platform focus-ring when focused, sunken grey otherwise
      let borderColor = hasFocus
        ? java.awt.Color.keyboardFocusIndicator
        : java.awt.Color(0x88, 0x88, 0x88)
      g.setColor(borderColor)
      g.drawLine(x,         y,         x + w - 1, y)          // top
      g.drawLine(x,         y,         x,         y + h - 1)  // left
      g.drawLine(x + w - 1, y,         x + w - 1, y + h - 1)  // right
      g.drawLine(x,         y + h - 1, x + w - 1, y + h - 1)  // bottom
    }
  }
}
