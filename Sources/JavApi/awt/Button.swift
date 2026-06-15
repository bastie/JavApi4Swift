/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// A push-button with a text label — mirrors `java.awt.Button`.
  open class Button: Component {

    // -------------------------------------------------------------------------
    // MARK: Properties
    // -------------------------------------------------------------------------

    public var label: String
    public var actionCommand: String
    /// True while the mouse button is held down — triggers inverted border in paint().
    public var isPressed: Bool = false

    private var actionListeners: [java.awt.event.ActionListener] = []

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    public init(_ label: String = "") {
      self.label         = label
      self.actionCommand = label
      super.init()
      background = java.awt.SystemColor.control
    }

    // -------------------------------------------------------------------------
    // MARK: Label
    // -------------------------------------------------------------------------

    public func getLabel() -> String         { label }
    public func setLabel(_ l: String)        { label = l; actionCommand = l; repaint() }
    public func getActionCommand() -> String { actionCommand }
    public func setActionCommand(_ cmd: String) { actionCommand = cmd }

    // -------------------------------------------------------------------------
    // MARK: Listeners
    // -------------------------------------------------------------------------

    public func addActionListener(_ l: java.awt.event.ActionListener) {
      actionListeners.append(l)
    }
    public func removeActionListener(_ l: java.awt.event.ActionListener) {
      actionListeners.removeAll { $0 === l }
    }
    public func getActionListeners() -> [java.awt.event.ActionListener] { actionListeners }

    // -------------------------------------------------------------------------
    // MARK: Dispatch (call from platform bridge on click)
    // -------------------------------------------------------------------------

    public func doClick() {
      let e = java.awt.event.ActionEvent(
        self, java.awt.event.ActionEvent.ACTION_PERFORMED, actionCommand)
      actionListeners.forEach { $0.actionPerformed(e) }
    }

    // -------------------------------------------------------------------------
    // MARK: Preferred size
    // -------------------------------------------------------------------------

    override public func getPreferredSize() -> java.awt.Dimension {
      if let d = _preferredSize { return d }
      let fm = getFontMetrics(font)
      let w  = fm.stringWidth(label) + 20   // 10 px padding each side
      let h  = fm.getHeight() + 10          // 5 px padding top/bottom
      return java.awt.Dimension(w, h)
    }

    // -------------------------------------------------------------------------
    // MARK: Paint
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics) {
      // Paint in LOCAL coordinates (0,0) — Container.paint() has already
      // translated the graphics context to this component's origin.
      let x = 0, y = 0, w = bounds.width, h = bounds.height

      // Fill
      g.setColor(background)
      g.fillRect(x, y, w, h)

      // Border: invert highlight/shadow when pressed
      let hiColor: java.awt.Color = isPressed ? java.awt.SystemColor.controlShadow : java.awt.SystemColor.controlHighlight
      let loColor: java.awt.Color = isPressed ? java.awt.SystemColor.controlHighlight : java.awt.SystemColor.controlShadow
      g.setColor(hiColor)
      g.drawLine(x, y, x + w - 1, y)                    // top
      g.drawLine(x, y, x, y + h - 1)                    // left
      g.setColor(loColor)
      g.drawLine(x + w - 1, y, x + w - 1, y + h - 1)   // right
      g.drawLine(x, y + h - 1, x + w - 1, y + h - 1)   // bottom

      if isPressed {
        let r = background.getRed(), gv = background.getGreen(), b = background.getBlue()
        let luminance = (r * 299 + gv * 587 + b * 114) / 1000
        let delta = luminance < 128 ? 50 : -40
        let pr = min(255, max(0, r  + delta))
        let pg = min(255, max(0, gv + delta))
        let pb = min(255, max(0, b  + delta))
        g.setColor(java.awt.Color(pr, pg, pb))
        g.fillRect(x + 1, y + 1, w - 2, h - 2)
      }

      guard !label.isEmpty else { return }
      let fm     = getFontMetrics(font)
      let offset = isPressed ? 1 : 0
      let tx = x + (w - fm.stringWidth(label)) / 2 + offset
      let ty = y + (h - fm.getHeight()) / 2 + fm.getAscent() + offset
      g.setColor(java.awt.SystemColor.controlText)
      g.drawString(label, tx, ty)
    }
    override open func dispose() {
      actionListeners.removeAll()
      super.dispose()
    }

  }
}
