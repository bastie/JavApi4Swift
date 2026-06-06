/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// A toggle or radio-button component — mirrors `java.awt.Checkbox`.
  ///
  /// Without a `CheckboxGroup` it behaves as an independent toggle (checkbox).
  /// With a `CheckboxGroup` it behaves as a radio button (mutual exclusion).
  open class Checkbox: Component {

    // -------------------------------------------------------------------------
    // MARK: Properties
    // -------------------------------------------------------------------------

    public var label: String
    private(set) var state: Bool
    public var checkboxGroup: CheckboxGroup?

    private var itemListeners: [java.awt.event.ItemListener] = []

    // Size of the tick-box / radio circle in pixels
    private let boxSize = 13

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    public init(_ label: String = "", state: Bool = false, group: CheckboxGroup? = nil) {
      self.label         = label
      self.state         = state
      self.checkboxGroup = group
      super.init()
      if state, let g = group { g.checkboxSelected(self) }
    }

    // -------------------------------------------------------------------------
    // MARK: State
    // -------------------------------------------------------------------------

    public func getState() -> Bool { state }

    public func setState(_ s: Bool) {
      setState(s, notifyGroup: true)
    }

    /// Internal setter — `notifyGroup: false` avoids recursion.
    internal func setState(_ s: Bool, notifyGroup: Bool) {
      guard state != s else { return }
      state = s
      if notifyGroup && s, let g = checkboxGroup {
        g.checkboxSelected(self)
      }
      fireItemEvent()
    }

    public func getLabel() -> String     { label }
    public func setLabel(_ l: String)    { label = l }

    public func getCheckboxGroup() -> CheckboxGroup? { checkboxGroup }
    public func setCheckboxGroup(_ g: CheckboxGroup?) {
      checkboxGroup = g
      if state, let g { g.checkboxSelected(self) }
    }

    // -------------------------------------------------------------------------
    // MARK: Listeners
    // -------------------------------------------------------------------------

    public func addItemListener(_ l: java.awt.event.ItemListener) {
      itemListeners.append(l)
    }
    public func removeItemListener(_ l: java.awt.event.ItemListener) {
      itemListeners.removeAll { $0 === l }
    }

    private func fireItemEvent() {
      let change = state
        ? java.awt.event.ItemEvent.SELECTED
        : java.awt.event.ItemEvent.DESELECTED
      let e = java.awt.event.ItemEvent(
        self, java.awt.event.ItemEvent.ITEM_STATE_CHANGED,
        item: label as AnyObject, stateChange: change)
      itemListeners.forEach { $0.itemStateChanged(e) }
    }

    // -------------------------------------------------------------------------
    // MARK: Paint
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics) {
      let x = bounds.x, y = bounds.y, h = bounds.height
      let boxY = y + (h - boxSize) / 2  // vertically centred

      if checkboxGroup != nil {
        paintRadio(g, x: x, y: boxY)
      } else {
        paintCheckbox(g, x: x, y: boxY)
      }

      // Label
      if !label.isEmpty {
        let fm  = getFontMetrics(font)
        let tx  = x + boxSize + 4
        let ty  = y + (h - fm.getHeight()) / 2 + fm.getAscent()
        g.setColor(java.awt.SystemColor.controlText)
        g.drawString(label, tx, ty)
      }
    }

    private func paintCheckbox(_ g: java.awt.Graphics, x: Int, y: Int) {
      // Box background
      g.setColor(java.awt.SystemColor.window)
      g.fillRect(x, y, boxSize, boxSize)
      // Border
      g.setColor(java.awt.SystemColor.windowBorder)
      g.drawRect(x, y, boxSize - 1, boxSize - 1)

      guard state else { return }
      // Checkmark (two lines: \ and /)
      g.setColor(java.awt.SystemColor.controlText)
      g.drawLine(x + 2, y + 6, x + 5, y + 10)
      g.drawLine(x + 5, y + 10, x + 11, y + 2)
    }

    private func paintRadio(_ g: java.awt.Graphics, x: Int, y: Int) {
      // Circle background
      g.setColor(java.awt.SystemColor.window)
      g.fillOval(x, y, boxSize, boxSize)
      // Border
      g.setColor(java.awt.SystemColor.windowBorder)
      g.drawOval(x, y, boxSize - 1, boxSize - 1)

      guard state else { return }
      // Filled inner circle
      let margin = 3
      g.setColor(java.awt.SystemColor.controlText)
      g.fillOval(x + margin, y + margin,
                 boxSize - 2 * margin, boxSize - 2 * margin)
    }
  }
}
