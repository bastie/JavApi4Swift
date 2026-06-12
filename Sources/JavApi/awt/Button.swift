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
    // MARK: Paint
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics) {
      let x = bounds.x, y = bounds.y, w = bounds.width, h = bounds.height

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

      // Fill: shift background brightness when pressed.
      // Dark backgrounds are lightened, light backgrounds are darkened — ensures
      // visible contrast in both Light Mode and Dark Mode.
      if isPressed {
        let r = background.getRed(), gv = background.getGreen(), b = background.getBlue()
        let luminance = (r * 299 + gv * 587 + b * 114) / 1000   // ITU-R BT.601
        let delta = luminance < 128 ? 50 : -40
        let pr = min(255, max(0, r  + delta))
        let pg = min(255, max(0, gv + delta))
        let pb = min(255, max(0, b  + delta))
        g.setColor(java.awt.Color(pr, pg, pb))
        g.fillRect(x + 1, y + 1, w - 2, h - 2)
      }

      // Label — offset by 1px right/down when pressed (classic AWT behaviour)
      guard !label.isEmpty else { return }
      let fm     = getFontMetrics(font)
      let offset = isPressed ? 1 : 0
      let tx = x + (w - fm.stringWidth(label)) / 2 + offset
      let ty = y + (h - fm.getHeight()) / 2 + fm.getAscent() + offset
      g.setColor(java.awt.SystemColor.controlText)
      g.drawString(label, tx, ty)
    }
  }
}
