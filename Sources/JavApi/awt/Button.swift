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
    public func setLabel(_ l: String)        { label = l; actionCommand = l }
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
    // MARK: Paint
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics) {
      let x = bounds.x, y = bounds.y, w = bounds.width, h = bounds.height

      // Fill
      g.setColor(background)
      g.fillRect(x, y, w, h)

      // Border: invert highlight/shadow when pressed
      let hiColor  = isPressed ? java.awt.Color(0x88, 0x88, 0x88) : java.awt.Color(0xFF, 0xFF, 0xFF)
      let loColor  = isPressed ? java.awt.Color(0xFF, 0xFF, 0xFF) : java.awt.Color(0x88, 0x88, 0x88)
      g.setColor(hiColor)
      g.drawLine(x, y, x + w - 1, y)                    // top
      g.drawLine(x, y, x, y + h - 1)                    // left
      g.setColor(loColor)
      g.drawLine(x + w - 1, y, x + w - 1, y + h - 1)   // right
      g.drawLine(x, y + h - 1, x + w - 1, y + h - 1)   // bottom

      // Label
      guard !label.isEmpty else { return }
      let fm = getFontMetrics(font)
      let tx = x + (w - fm.stringWidth(label)) / 2
      let ty = y + (h - fm.getHeight()) / 2 + fm.getAscent()
      g.setColor(foreground)
      g.drawString(label, tx, ty)
    }
  }
}
